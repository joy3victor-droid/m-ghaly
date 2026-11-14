import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class ExportAudio {
  const ExportAudio({required this.path, required this.volume});

  final String path;
  final double volume;
}

class ExportException implements Exception {
  ExportException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ExportService {
  static Future<String?> export({
    required List<String> videos,
    required List<Duration> durations,
    required List<ExportAudio> audios,
    required int width,
    required int height,
    required void Function(double progress) onProgress,
    int fps = 30,
  }) async {
    if (videos.isEmpty) throw ExportException('لا توجد فيديوهات للتصدير');

    final w = width - (width % 2);
    final h = height - (height % 2);

    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/mghaly_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final args = <String>['-y'];
    var inputCount = 0;

    final videoInputIndex = <int>[];
    for (final path in videos) {
      args.addAll(['-i', path]);
      videoInputIndex.add(inputCount++);
    }

    final hasAudio = <bool>[];
    for (final path in videos) {
      hasAudio.add(await _hasAudioStream(path));
    }

    final silentInputIndex = <int, int>{};
    for (var i = 0; i < videos.length; i++) {
      if (hasAudio[i]) continue;
      final seconds = (durations[i].inMilliseconds / 1000).toStringAsFixed(3);
      args.addAll([
        '-f',
        'lavfi',
        '-t',
        seconds,
        '-i',
        'anullsrc=r=44100:cl=stereo',
      ]);
      silentInputIndex[i] = inputCount++;
    }

    final extraInputIndex = <int>[];
    for (final audio in audios) {
      args.addAll(['-i', audio.path]);
      extraInputIndex.add(inputCount++);
    }

    final filters = <String>[];
    final concatInputs = StringBuffer();

    for (var i = 0; i < videos.length; i++) {
      filters.add(
        '[${videoInputIndex[i]}:v]'
        'scale=$w:$h:force_original_aspect_ratio=decrease,'
        'pad=$w:$h:(ow-iw)/2:(oh-ih)/2:black,'
        'setsar=1,fps=$fps,format=yuv420p[v$i]',
      );

      final audioSource = hasAudio[i]
          ? '${videoInputIndex[i]}:a:0'
          : '${silentInputIndex[i]}:a';

      filters.add(
        '[$audioSource]aresample=44100,'
        'aformat=sample_fmts=fltp:channel_layouts=stereo,'
        'atrim=duration=${(durations[i].inMilliseconds / 1000).toStringAsFixed(3)},'
        'asetpts=PTS-STARTPTS[a$i]',
      );

      concatInputs.write('[v$i][a$i]');
    }

    filters.add(
      '${concatInputs}concat=n=${videos.length}:v=1:a=1[vout][amain]',
    );

    String audioOut = '[amain]';

    if (audios.isNotEmpty) {
      final mixInputs = StringBuffer('[amain]');

      for (var i = 0; i < audios.length; i++) {
        filters.add(
          '[${extraInputIndex[i]}:a:0]aresample=44100,'
          'aformat=sample_fmts=fltp:channel_layouts=stereo,'
          'volume=${audios[i].volume.toStringAsFixed(2)}[x$i]',
        );
        mixInputs.write('[x$i]');
      }

      final count = audios.length + 1;
      filters.add(
        '${mixInputs}amix=inputs=$count:duration=first:dropout_transition=0,'
        'volume=$count,alimiter=limit=0.95[aout]',
      );
      audioOut = '[aout]';
    }

    args.addAll([
      '-filter_complex',
      filters.join(';'),
      '-map',
      '[vout]',
      '-map',
      audioOut,
      '-c:v',
      'libx264',
      '-preset',
      'veryfast',
      '-crf',
      '23',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
      '-movflags',
      '+faststart',
      outPath,
    ]);

    final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);

    FFmpegKitConfig.enableStatisticsCallback((stats) {
      if (totalMs <= 0) return;
      onProgress((stats.getTime() / totalMs).clamp(0.0, 1.0).toDouble());
    });

    final session = await FFmpegKit.executeWithArguments(args);
    final code = await session.getReturnCode();

    if (ReturnCode.isSuccess(code)) {
      onProgress(1.0);
      return outPath;
    }

    if (ReturnCode.isCancel(code)) {
      final partial = File(outPath);
      if (await partial.exists()) await partial.delete();
      return null;
    }

    final logs = await session.getAllLogsAsString() ?? '';
    final tail = logs.length > 600 ? logs.substring(logs.length - 600) : logs;
    throw ExportException('فشل التصدير:\n$tail');
  }

  static Future<void> cancel() => FFmpegKit.cancel();

  static Future<bool> _hasAudioStream(String path) async {
    try {
      final session = await FFprobeKit.getMediaInformation(path);
      final streams = session.getMediaInformation()?.getStreams() ?? [];
      return streams.any((s) => s.getType() == 'audio');
    } catch (_) {
      return false;
    }
  }
}

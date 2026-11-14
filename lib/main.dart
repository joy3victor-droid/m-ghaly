import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:gal/gal.dart';
import 'export_service.dart';
import 'text_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MGhalyApp());
}

class MGhalyApp extends StatelessWidget {
  const MGhalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M-GHALY',
      theme: ThemeData.dark(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.ltr, child: child!),
      home: const HomeScreen(),
    );
  }
}

bool isVideo(XFile file) {
  final path = file.path.toLowerCase();

  return path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm') ||
      path.endsWith('.3gp') ||
      path.endsWith('.avi');
}

// ================= HOME SCREEN =================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> openProject(BuildContext context) async {
    final picker = ImagePicker();
    final selectedFiles = await picker.pickMultipleMedia();

    if (!context.mounted || selectedFiles.isEmpty) return;

    final usedPaths = <String>{};

    final videos = selectedFiles
        .where(isVideo)
        .where((file) => usedPaths.add(file.path))
        .toList();

    if (videos.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لم يتم اختيار أي فيديو')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectScreen(files: videos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101116),
      appBar: AppBar(
        toolbarHeight: 58,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC04D), Color(0xFFE87516)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.22),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.movie_creation_outlined,
                color: Color(0xFF171717),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'M-GHALY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF252D3B), Color(0xFF191D27), Color(0xFF11141C)],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF202635), Color(0xFF101116), Color(0xFF090B10)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFC04D), Color(0xFFE87516)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.28),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.movie_creation_outlined,
                    size: 68,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'M-GHALY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'VIDEO EDITOR',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 390),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B202B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.09),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Create Your Next Video',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bring your clips together and start editing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => openProject(context),
                          icon: const Icon(Icons.add_rounded, size: 25),
                          label: const Text(
                            'New Project',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: const Color(0xFF171717),
                            elevation: 7,
                            shadowColor: Colors.orange.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      color: Colors.white38,
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Your videos. Your creativity.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= PROJECT SCREEN =================

class AudioTrack {
  AudioTrack({required this.path, required this.name, required this.player});

  final String path;
  final String name;
  final AudioPlayer player;
  double volume = 1.0;
  bool enabled = true;
}

class ProjectScreen extends StatefulWidget {
  final List<XFile> files;

  const ProjectScreen({super.key, required this.files});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late List<XFile> files;

  double timelineScale = 1.0;
  double timelineScaleStart = 1.0;

  final Map<int, Offset> timelinePointers = {};
  double timelinePinchStartDistance = 0.0;

  VideoPlayerController? controller;
  final List<AudioTrack> audioTracks = [];

  Duration currentVideoProjectOffset = Duration.zero;
  int selectedIndex = 0;
  int loadRequestId = 0;

  bool videoReady = false;
  bool isAutoAdvancing = false;

  String? videoError;

  VideoPlayerController? lastCompletedController;

  final Map<String, Future<Uint8List?>> thumbnails = {};
  final Map<String, Future<Duration?>> videoDurations = {};
  final Map<String, Future<Waveform?>> waveformFutures = {};

  @override
  void initState() {
    super.initState();

    files = List<XFile>.of(widget.files);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (files.isNotEmpty) {
      loadVideo(0);
    }
  }

  // ================= THUMBNAILS =================

  // ================= AUDIO WAVEFORM =================

  Future<Waveform?> getAudioWaveform(String path) {
    return waveformFutures.putIfAbsent(path, () async {
      try {
        final directory = await getTemporaryDirectory();
        final waveFile = File(
          '${directory.path}/mghaly_${path.hashCode.toUnsigned(32)}.wave',
        );

        if (await waveFile.exists()) {
          try {
            return await JustWaveform.parse(waveFile);
          } catch (_) {
            await waveFile.delete();
          }
        }

        final audioFile = File(path);
        if (!await audioFile.exists()) return null;

        final waveform =
            await JustWaveform.extract(
                  audioInFile: audioFile,
                  waveOutFile: waveFile,
                  zoom: const WaveformZoom.pixelsPerSecond(100),
                )
                .where((progress) => progress.waveform != null)
                .map((progress) => progress.waveform!)
                .first;

        return waveform;
      } catch (e) {
        debugPrint('Waveform extraction error: $e');
        return null;
      }
    });
  }

  Future<Uint8List?> getThumbnail(String path) {
    return thumbnails.putIfAbsent(
      path,
      () => VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 240,
        quality: 65,
      ),
    );
  }

  // ================= VIDEO DURATION =================

  Future<Duration?> getVideoDuration(String path) {
    return videoDurations.putIfAbsent(path, () async {
      final videoController = VideoPlayerController.file(File(path));

      try {
        await videoController.initialize();
        return videoController.value.duration;
      } catch (e) {
        return null;
      } finally {
        await videoController.dispose();
      }
    });
  }

  // ================= OPEN VIDEO TRIMMER =================

  Future<void> openTrimScreen() async {
    if (files.isEmpty || selectedIndex < 0 || selectedIndex >= files.length) {
      return;
    }

    final selectedFile = files[selectedIndex];

    final outputPath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoTrimScreen(file: File(selectedFile.path)),
      ),
    );

    if (!mounted || outputPath == null || outputPath.isEmpty) return;

    final alreadyAdded = files.any((file) => file.path == outputPath);
    if (alreadyAdded) return;

    final newIndex = selectedIndex + 1;

    recordHistory();
    setState(() {
      files.insert(newIndex, XFile(outputPath));
    });

    await loadVideo(newIndex);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الفيديو المقصوص وإضافته إلى Timeline'),
      ),
    );
  }

  // ================= ADD VIDEOS =================

  Future<void> addVideos() async {
    final picker = ImagePicker();
    final selectedFiles = await picker.pickMultipleMedia();

    if (!mounted || selectedFiles.isEmpty) return;

    final existingPaths = files.map((file) => file.path).toSet();

    final newVideos = selectedFiles
        .where(isVideo)
        .where((file) => existingPaths.add(file.path))
        .toList();

    if (newVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم تتم إضافة فيديوهات جديدة')),
      );
      return;
    }

    final wasEmpty = files.isEmpty;

    recordHistory();
    setState(() {
      files.addAll(newVideos);
    });

    if (wasEmpty) {
      await loadVideo(0);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة ${newVideos.length} فيديو')),
    );
  }
  // ================= MULTIPLE AUDIO TRACKS =================

  Future<void> addAudio() async {
    final result = await FilePicker.pickFile(type: FileType.audio);
    if (result == null || result.path == null) return;

    final player = AudioPlayer();

    try {
      await player.setFilePath(result.path!);
      await player.setVolume(1.0);

      if (!mounted) {
        await player.dispose();
        return;
      }

      setState(() {
        audioTracks.add(
          AudioTrack(path: result.path!, name: result.name, player: player),
        );
      });

      if (controller?.value.isPlaying ?? false) {
        unawaited(syncAudioWithVideo(play: true));
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تمت إضافة مسار صوتي جديد')));
    } catch (e) {
      await player.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر فتح الملف الصوتي: $e')));
    }
  }

  Future<void> pauseAudioTracks() async {
    for (final track in List<AudioTrack>.of(audioTracks)) {
      try {
        if (track.player.playing) {
          await track.player.pause();
        }
      } catch (e) {
        debugPrint('Audio pause error: $e');
      }
    }
  }

  Future<void> syncAudioWithVideo({
    bool play = false,
    Duration? localPosition,
  }) async {
    final activeController = controller;

    if (activeController == null || !activeController.value.isInitialized) {
      if (!play) await pauseAudioTracks();
      return;
    }

    final position =
        currentVideoProjectOffset +
        (localPosition ?? activeController.value.position);

    for (final track in List<AudioTrack>.of(audioTracks)) {
      if (!audioTracks.contains(track)) continue;

      try {
        final audioDuration = track.player.duration;

        if (audioDuration != null && position >= audioDuration) {
          if (track.player.playing) await track.player.pause();
          await track.player.seek(audioDuration);
          continue;
        }

        await track.player.seek(position);
        await track.player.setVolume(track.enabled ? track.volume : 0.0);

        if (play && track.enabled) {
          unawaited(track.player.play());
        } else if (track.player.playing) {
          await track.player.pause();
        }
      } catch (e) {
        debugPrint('Audio sync error (${track.name}): $e');
      }
    }
  }

  Future<void> deleteAudioTrack(AudioTrack track) async {
    if (!audioTracks.contains(track)) return;

    setState(() {
      audioTracks.remove(track);
    });

    try {
      await track.player.stop();
      await track.player.dispose();
    } catch (e) {
      debugPrint('Audio dispose error: $e');
    }
  }

  // ================= FIXED PLAYHEAD / SCROLLING TIMELINE =================

  final ScrollController timelineScroll = ScrollController();
  bool userScrubbing = false;
  double currentPixelsPerSecond = 30.0;

  void syncTimelineToPlayback() {
    final active = controller;
    if (!mounted || userScrubbing || active == null || !videoReady) return;
    if (!timelineScroll.hasClients) return;

    final position = currentVideoProjectOffset + active.value.position;
    final target = (position.inMilliseconds / 1000 * currentPixelsPerSecond)
        .clamp(0.0, timelineScroll.position.maxScrollExtent)
        .toDouble();

    if ((timelineScroll.offset - target).abs() > 0.5) {
      timelineScroll.jumpTo(target);
    }
  }

  void scrubToPixels(double pixels, double pixelsPerSecond) {
    if (pixelsPerSecond <= 0) return;
    final ms = (pixels / pixelsPerSecond * 1000).round();
    unawaited(seekToProjectTime(Duration(milliseconds: math.max(0, ms))));
  }

  Duration? pendingSeek;
  bool isSeeking = false;

  Future<void> seekToProjectTime(Duration target) async {
    pendingSeek = target;
    if (isSeeking) return;
    isSeeking = true;

    try {
      while (pendingSeek != null && mounted) {
        final next = pendingSeek!;
        pendingSeek = null;
        await seekProjectOnce(next);
      }
    } finally {
      isSeeking = false;
    }
  }

  Future<void> seekProjectOnce(Duration target) async {
    if (files.isEmpty) return;

    var elapsed = Duration.zero;
    var index = files.length - 1;
    var local = Duration.zero;

    for (var i = 0; i < files.length; i++) {
      final clipDuration =
          await getVideoDuration(files[i].path) ?? Duration.zero;
      if (target < elapsed + clipDuration || i == files.length - 1) {
        index = i;
        local = target - elapsed;
        final limit = clipDuration - const Duration(milliseconds: 100);
        if (local > limit) local = limit;
        if (local < Duration.zero) local = Duration.zero;
        break;
      }
      elapsed += clipDuration;
    }

    if (!mounted) return;

    if (index != selectedIndex || controller == null || !videoReady) {
      await loadVideo(index);
    }

    final active = controller;
    if (!mounted || active == null || !active.value.isInitialized) return;

    if (active.value.isPlaying) await active.pause();
    await pauseAudioTracks();

    lastCompletedController = null;
    await active.seekTo(local);
    await syncAudioWithVideo(localPosition: local);
  }

  // ================= TEXT OVERLAYS =================

  final List<TextClip> textClips = [];

  Duration currentProjectPosition() {
    final c = controller;
    return currentVideoProjectOffset +
        (c != null && videoReady ? c.value.position : Duration.zero);
  }

  Widget previewText(TextClip t, double w, double h) {
    final fontSize = h * t.sizeFraction;
    final text = Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      child: Text(
        t.text,
        textAlign: TextAlign.center,
        textDirection: t.textDirection,
        style: TextStyle(
          color: Color(t.colorValue),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: textShadows(fontSize),
        ),
      ),
    );

    if (t.position == 0) {
      return Positioned(
        top: h * 0.08,
        left: 0,
        right: 0,
        child: Center(child: text),
      );
    }
    if (t.position == 1) {
      return Positioned.fill(child: Center(child: text));
    }
    return Positioned(
      bottom: h * 0.12,
      left: 0,
      right: 0,
      child: Center(child: text),
    );
  }

  Widget buildTextOverlay(VideoPlayerController c) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          return AnimatedBuilder(
            animation: c,
            builder: (context, _) {
              final position = currentVideoProjectOffset + c.value.position;
              final active = textClips
                  .where((t) => position >= t.start && position < t.end)
                  .toList();
              if (active.isEmpty) return const SizedBox.shrink();
              return Stack(
                children: [
                  for (final t in active)
                    previewText(t, box.maxWidth, box.maxHeight),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> addTextClipDialog() async {
    final textController = TextEditingController();
    var seconds = 3;
    var position = 2;
    var size = 0.08;
    var colorValue = 0xFFFFFFFF;

    const palette = <int>[
      0xFFFFFFFF,
      0xFFFFEB3B,
      0xFFFFAB40,
      0xFFFF5252,
      0xFF69F0AE,
      0xFF40C4FF,
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) {
          Widget chip(String label, bool selected, VoidCallback onTap) {
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setLocal(onTap),
            );
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF252630),
            title: const Text('إضافة نص'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'اكتب النص هنا',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('المدة (ثانية)'),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final s in [2, 3, 5, 10])
                        chip('$s', seconds == s, () => seconds = s),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('المكان'),
                  Wrap(
                    spacing: 6,
                    children: [
                      chip('أعلى', position == 0, () => position = 0),
                      chip('وسط', position == 1, () => position = 1),
                      chip('أسفل', position == 2, () => position = 2),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('الحجم'),
                  Wrap(
                    spacing: 6,
                    children: [
                      chip('صغير', size == 0.05, () => size = 0.05),
                      chip('متوسط', size == 0.08, () => size = 0.08),
                      chip('كبير', size == 0.12, () => size = 0.12),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('اللون'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in palette)
                        GestureDetector(
                          onTap: () => setLocal(() => colorValue = c),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorValue == c
                                    ? Colors.white
                                    : Colors.white24,
                                width: colorValue == c ? 3 : 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'إضافة',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          );
        },
      ),
    );

    final text = textController.text.trim();
    textController.dispose();

    if (confirmed != true || text.isEmpty || !mounted) return;

    final start = currentProjectPosition();

    setState(() {
      textClips.add(
        TextClip(
          text: text,
          start: start,
          end: start + Duration(seconds: seconds),
          position: position,
          sizeFraction: size,
          colorValue: colorValue,
        ),
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تمت إضافة النص')));
  }

  Future<void> openTextManager() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF252630),
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) {
          final sorted = List<TextClip>.of(textClips)
            ..sort((a, b) => a.start.compareTo(b.start));

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.orangeAccent,
                    ),
                    title: const Text('إضافة نص عند المؤشر'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      unawaited(addTextClipDialog());
                    },
                  ),
                  const Divider(height: 1),
                  if (sorted.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'لا توجد نصوص بعد',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final t in sorted)
                          ListTile(
                            title: Text(
                              t.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${formatTime(t.start)} - ${formatTime(t.end)}',
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              unawaited(seekToProjectTime(t.start));
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() => textClips.remove(t));
                                setSheet(() {});
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= UNDO / REDO =================

  final List<List<String>> undoStack = [];
  final List<List<String>> redoStack = [];

  List<String> snapshotFiles() => files.map((f) => f.path).toList();

  void recordHistory() {
    undoStack.add(snapshotFiles());
    if (undoStack.length > 30) undoStack.removeAt(0);
    redoStack.clear();
  }

  Future<void> restoreSnapshot(List<String> paths) async {
    final currentPath = selectedIndex >= 0 && selectedIndex < files.length
        ? files[selectedIndex].path
        : null;

    setState(() {
      files = paths.map((p) => XFile(p)).toList();
    });

    if (files.isEmpty) {
      await clearPreview();
      return;
    }

    var target = currentPath == null
        ? -1
        : files.indexWhere((f) => f.path == currentPath);
    if (target == -1) target = math.min(selectedIndex, files.length - 1);
    if (target < 0) target = 0;

    await loadVideo(target);
  }

  Future<void> undo() async {
    if (undoStack.isEmpty || isSplitting || isExporting) return;

    await controller?.pause();
    await pauseAudioTracks();

    redoStack.add(snapshotFiles());
    final previous = undoStack.removeLast();
    await restoreSnapshot(previous);
  }

  Future<void> redo() async {
    if (redoStack.isEmpty || isSplitting || isExporting) return;

    await controller?.pause();
    await pauseAudioTracks();

    undoStack.add(snapshotFiles());
    final next = redoStack.removeLast();
    await restoreSnapshot(next);
  }

  // ================= SPLIT =================

  bool isSplitting = false;

  Future<void> splitAtPlayhead() async {
    final activeController = controller;
    if (!videoReady ||
        activeController == null ||
        files.isEmpty ||
        isSplitting ||
        isExporting) {
      return;
    }

    final position = activeController.value.position;
    final duration = activeController.value.duration;
    const margin = Duration(milliseconds: 500);

    if (position < margin || duration - position < margin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حرّك المؤشر لنقطة داخل الكليب قبل التقسيم'),
        ),
      );
      return;
    }

    await activeController.pause();
    await pauseAudioTracks();
    if (!mounted) return;

    final index = selectedIndex;
    final sourcePath = files[index].path;

    setState(() => isSplitting = true);

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Color(0xFF252630),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(width: 16),
                Text('جاري التقسيم...'),
              ],
            ),
          ),
        ),
      ),
    );

    List<String>? parts;
    String? errorMessage;

    try {
      parts = await ExportService.splitVideo(sourcePath, position);
    } catch (e) {
      errorMessage = e.toString();
    }

    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    setState(() => isSplitting = false);

    final newParts = parts;
    if (newParts == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'فشل التقسيم')),
      );
      return;
    }

    recordHistory();
    setState(() {
      files[index] = XFile(newParts[0]);
      files.insert(index + 1, XFile(newParts[1]));
    });

    await loadVideo(index);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تقسيم الكليب إلى جزئين')),
    );
  }

  // ================= EXPORT =================

  bool isExporting = false;

  Future<void> exportProject() async {
    if (files.isEmpty || isExporting) return;

    final activeController = controller;
    final videoSize = activeController != null && videoReady
        ? activeController.value.size
        : const Size(1280, 720);

    await activeController?.pause();
    await pauseAudioTracks();

    final progress = ValueNotifier<double>(0.0);
    var dialogOpen = true;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF252630),
            title: const Text('جاري التصدير...'),
            content: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (_, value, __) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: value,
                    color: Colors.orangeAccent,
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 12),
                  Text('${(value * 100).round()}%'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => unawaited(ExportService.cancel()),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ).then((_) => dialogOpen = false),
    );

    setState(() => isExporting = true);

    String? outputPath;
    String? errorMessage;

    try {
      final durations = <Duration>[];
      for (final file in files) {
        durations.add(await getVideoDuration(file.path) ?? Duration.zero);
      }

      final outW = videoSize.width.round() - videoSize.width.round() % 2;
      final outH = videoSize.height.round() - videoSize.height.round() % 2;
      final texts = <ExportText>[];
      for (final t in textClips) {
        texts.add(
          ExportText(
            pngPath: await renderTextOverlay(t, outW, outH),
            startMs: t.start.inMilliseconds,
            endMs: t.end.inMilliseconds,
          ),
        );
      }

      outputPath = await ExportService.export(
        videos: files.map((f) => f.path).toList(),
        durations: durations,
        audios: audioTracks
            .where((t) => t.enabled && t.volume > 0)
            .map((t) => ExportAudio(path: t.path, volume: t.volume))
            .toList(),
        width: videoSize.width.round(),
        height: videoSize.height.round(),
        texts: texts,
        onProgress: (value) => progress.value = value,
      );

      if (outputPath != null) {
        await Gal.putVideo(outputPath);
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    if (dialogOpen && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    progress.dispose();
    if (!mounted) return;
    setState(() => isExporting = false);

    final message =
        errorMessage ??
        (outputPath == null
            ? 'تم إلغاء التصدير'
            : 'تم حفظ الفيديو في المعرض');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> updateCurrentProjectOffset() async {
    if (files.isEmpty || selectedIndex < 0 || selectedIndex >= files.length) {
      currentVideoProjectOffset = Duration.zero;
      return;
    }

    final targetIndex = selectedIndex;
    Duration total = Duration.zero;

    for (var i = 0; i < targetIndex; i++) {
      final duration = await getVideoDuration(files[i].path);

      if (!mounted || selectedIndex != targetIndex) return;

      total += duration ?? Duration.zero;
    }

    currentVideoProjectOffset = total;
  }

  // ================= LOAD VIDEO =================

  Future<void> loadVideo(int index, {bool autoplay = false}) async {
    if (!mounted || index < 0 || index >= files.length) return;

    final targetFile = files[index];
    final requestId = ++loadRequestId;

    final oldController = controller;

    await pauseAudioTracks();
    oldController?.removeListener(handleVideoProgress);

    setState(() {
      selectedIndex = index;
      videoReady = false;
      videoError = null;
      controller = null;
      lastCompletedController = null;
    });

    await oldController?.dispose();

    if (!mounted || requestId != loadRequestId) return;

    if (!files.any((file) => file.path == targetFile.path)) return;

    final newController = VideoPlayerController.file(
      File(targetFile.path),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    controller = newController;

    try {
      await newController.initialize();

      if (!mounted ||
          requestId != loadRequestId ||
          controller != newController) {
        return;
      }

      final actualIndex = files.indexWhere(
        (file) => file.path == targetFile.path,
      );

      if (actualIndex == -1) return;

      newController.addListener(handleVideoProgress);

      setState(() {
        selectedIndex = actualIndex;
        videoReady = true;
      });

      await updateCurrentProjectOffset();

      if (!mounted ||
          requestId != loadRequestId ||
          controller != newController) {
        return;
      }

      if (autoplay) {
        await newController.play();
        await syncAudioWithVideo(play: true, localPosition: Duration.zero);
      }
    } catch (e) {
      if (!mounted ||
          requestId != loadRequestId ||
          controller != newController) {
        return;
      }

      setState(() {
        videoError = e.toString();
      });
    }
  }

  // ================= PLAY / PAUSE =================

  Future<void> togglePlayback(VideoPlayerController activeController) async {
    if (!mounted ||
        !activeController.value.isInitialized ||
        controller != activeController) {
      return;
    }

    try {
      if (activeController.value.isPlaying) {
        await activeController.pause();
        await pauseAudioTracks();
      } else {
        if (activeController.value.duration > Duration.zero &&
            activeController.value.position >=
                activeController.value.duration) {
          await activeController.seekTo(Duration.zero);
        }

        lastCompletedController = null;
        await activeController.play();
        await syncAudioWithVideo(play: true);
      }
    } catch (e) {
      debugPrint('Video playback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذر تشغيل الفيديو: $e')));
      }
    }
  }

  // ================= AUTO NEXT VIDEO =================

  void handleVideoProgress() {
    syncTimelineToPlayback();
    final activeController = controller;

    if (!mounted || !videoReady || activeController == null) return;

    final value = activeController.value;

    if (!value.isInitialized ||
        value.isPlaying ||
        value.duration <= Duration.zero) {
      return;
    }

    if (value.position >= value.duration) {
      if (lastCompletedController == activeController || isAutoAdvancing) {
        return;
      }

      lastCompletedController = activeController;

      unawaited(playNextVideo(activeController));
    }
  }

  Future<void> playNextVideo(VideoPlayerController endedController) async {
    if (isAutoAdvancing || controller != endedController) return;

    isAutoAdvancing = true;

    try {
      final nextIndex = selectedIndex + 1;

      if (nextIndex < files.length) {
        await loadVideo(nextIndex, autoplay: true);
      } else {
        await pauseAudioTracks();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('انتهى تشغيل جميع الفيديوهات')),
        );
      }
    } finally {
      isAutoAdvancing = false;
    }
  }

  // ================= DELETE VIDEO =================

  Future<void> confirmDeleteVideo(int index) async {
    if (index < 0 || index >= files.length) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252630),
          title: const Text('حذف الفيديو'),
          content: const Text('هل تريد حذف هذا الفيديو من المشروع؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await deleteVideo(index);
  }

  Future<void> deleteVideo(int index) async {
    if (index < 0 || index >= files.length) return;

    final wasSelected = index == selectedIndex;
    final deletedPath = files[index].path;

    recordHistory();
    setState(() {
      files.removeAt(index);
      thumbnails.remove(deletedPath);
      videoDurations.remove(deletedPath);

      if (files.isEmpty) {
        selectedIndex = 0;
      } else if (wasSelected) {
        selectedIndex = index >= files.length ? files.length - 1 : index;
      } else if (index < selectedIndex) {
        selectedIndex--;
      }
    });

    if (wasSelected) {
      if (files.isEmpty) {
        await clearPreview();
      } else {
        await loadVideo(selectedIndex);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الفيديو من المشروع')));
  }

  // ================= CLEAR PREVIEW =================

  Future<void> clearPreview() async {
    loadRequestId++;

    final oldController = controller;

    oldController?.removeListener(handleVideoProgress);

    currentVideoProjectOffset = Duration.zero;

    setState(() {
      controller = null;
      videoReady = false;
      videoError = null;
      selectedIndex = 0;
      lastCompletedController = null;
    });

    await oldController?.dispose();
  }

  // ================= REORDER VIDEOS =================

  void reorderVideos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    if (oldIndex < 0 ||
        oldIndex >= files.length ||
        newIndex < 0 ||
        newIndex >= files.length) {
      return;
    }

    final selectedPath = selectedIndex < files.length
        ? files[selectedIndex].path
        : null;

    recordHistory();
    setState(() {
      final movedFile = files.removeAt(oldIndex);

      files.insert(newIndex, movedFile);

      if (selectedPath != null) {
        selectedIndex = files.indexWhere((file) => file.path == selectedPath);
      }
    });

    unawaited(updateCurrentProjectOffset());
  }

  // ================= TIME FORMAT =================

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    loadRequestId++;

    controller?.removeListener(handleVideoProgress);
    controller?.dispose();
    for (final track in audioTracks) {
      unawaited(track.player.dispose());
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    timelineScroll.dispose();

    super.dispose();
  }

  Widget _timelineHeaderChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= USER INTERFACE =================

  @override
  Widget build(BuildContext context) {
    final currentController = controller;

    return Scaffold(
      backgroundColor: const Color(0xFF101116),
      appBar: AppBar(
        toolbarHeight: 54,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC04D), Color(0xFFE87516)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.22),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.movie_creation_outlined,
                color: Color(0xFF171717),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'M-GHALY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'VIDEO EDITOR',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF252D3B), Color(0xFF191D27), Color(0xFF11141C)],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'النصوص',
            onPressed: files.isEmpty ? null : () => unawaited(openTextManager()),
            icon: const Icon(Icons.title_rounded),
            color: Colors.orangeAccent,
            disabledColor: Colors.white24,
          ),
          IconButton(
            tooltip: 'تراجع',
            onPressed: undoStack.isEmpty || isSplitting || isExporting
                ? null
                : () => unawaited(undo()),
            icon: const Icon(Icons.undo_rounded),
            color: Colors.orangeAccent,
            disabledColor: Colors.white24,
          ),
          IconButton(
            tooltip: 'إعادة',
            onPressed: redoStack.isEmpty || isSplitting || isExporting
                ? null
                : () => unawaited(redo()),
            icon: const Icon(Icons.redo_rounded),
            color: Colors.orangeAccent,
            disabledColor: Colors.white24,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: TextButton.icon(
              onPressed: files.isEmpty || isSplitting || isExporting
                  ? null
                  : () => unawaited(splitAtPlayhead()),
              icon: const Icon(Icons.vertical_split_rounded, size: 19),
              label: const Text('تقسيم'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB9D7FF),
                disabledForegroundColor: Colors.white24,
                backgroundColor: const Color(0xFF1D3350),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.lightBlueAccent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: TextButton.icon(
              onPressed: files.isEmpty || isExporting
                  ? null
                  : () => unawaited(exportProject()),
              icon: const Icon(Icons.ios_share_rounded, size: 19),
              label: const Text('تصدير'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF171717),
                disabledForegroundColor: Colors.white24,
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: TextButton.icon(
              onPressed: files.isEmpty
                  ? null
                  : () => unawaited(openTrimScreen()),
              icon: const Icon(Icons.content_cut_rounded, size: 19),
              label: const Text('قص'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orangeAccent,
                disabledForegroundColor: Colors.white24,
                backgroundColor: const Color(0xFF332719),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.orangeAccent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextButton.icon(
              onPressed: () => unawaited(addVideos()),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('إضافة فيديو'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB8F2D0),
                backgroundColor: const Color(0xFF19382D),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.greenAccent.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final timelineHeight = (constraints.maxHeight * 0.55).clamp(
            150.0,
            240.0,
          );

          return Column(
            children: [
              // ===== LARGE VIDEO PREVIEW =====
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF171B24),
                              Color(0xFF050608),
                              Color(0xFF11151D),
                            ],
                          ),
                        ),
                        child: Center(
                          child: videoReady && currentController != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF080A0F),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: const Color(0xFF626C7D),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        blurRadius: 14,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: Colors.orangeAccent.withValues(
                                          alpha: 0.07,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: AspectRatio(
                                    aspectRatio:
                                        currentController.value.aspectRatio,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        VideoPlayer(currentController),
                                        Positioned.fill(
                                          child: buildTextOverlay(
                                            currentController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF191E28)
                                        .withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: videoError != null
                                          ? Colors.redAccent.withValues(
                                              alpha: 0.45,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.10,
                                            ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (videoError != null) ...[
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 42,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'تعذر تشغيل الفيديو',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else if (files.isEmpty) ...[
                                        const Icon(
                                          Icons.video_library_outlined,
                                          color: Colors.orangeAccent,
                                          size: 44,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'أضف فيديو لبدء المونتاج',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'ستظهر معاينة الفيديو هنا',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ] else ...[
                                        const SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                            color: Colors.orangeAccent,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'جاري تجهيز الفيديو...',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // ===== FIXED PLAYER CONTROLS =====
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF292E3A), Color(0xFF171A22)],
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFF454D5C), width: 1),
                        ),
                      ),
                      child: videoReady && currentController != null
                          ? AnimatedBuilder(
                              animation: currentController,
                              builder: (context, child) {
                                final position =
                                    currentController.value.position;
                                final duration =
                                    currentController.value.duration;
                                final maxValue = duration.inMilliseconds > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1.0;
                                final currentValue = position.inMilliseconds
                                    .toDouble()
                                    .clamp(0.0, maxValue)
                                    .toDouble();

                                return Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF49351F),
                                            Color(0xFF29231D),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.orangeAccent.withValues(
                                            alpha: 0.65,
                                          ),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orangeAccent
                                                .withValues(alpha: 0.18),
                                            blurRadius: 9,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        iconSize: 39,
                                        color: Colors.orangeAccent,
                                        icon: Icon(
                                          currentController.value.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                        ),
                                        onPressed: () => unawaited(
                                          togglePlayback(currentController),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF59351F),
                                            Color(0xFF30231C),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.orangeAccent.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orangeAccent
                                                .withValues(alpha: 0.10),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        formatTime(position),
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 4,
                                          activeTrackColor: Colors.orangeAccent,
                                          inactiveTrackColor: const Color(
                                            0xFF414957,
                                          ),
                                          thumbColor: Colors.orangeAccent,
                                          overlayColor: Colors.orangeAccent
                                              .withValues(alpha: 0.16),
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                enabledThumbRadius: 7,
                                                elevation: 3,
                                              ),
                                          overlayShape:
                                              const RoundSliderOverlayShape(
                                                overlayRadius: 15,
                                              ),
                                        ),
                                        child: Slider(
                                          value: currentValue,
                                          min: 0,
                                          max: maxValue,
                                          onChanged: (value) {
                                            if (value < maxValue - 500) {
                                              lastCompletedController = null;
                                            }
                                            final newPosition = Duration(
                                              milliseconds: value.toInt(),
                                            );
                                            unawaited(
                                              currentController.seekTo(
                                                newPosition,
                                              ),
                                            );
                                            unawaited(
                                              syncAudioWithVideo(
                                                play: currentController
                                                    .value
                                                    .isPlaying,
                                                localPosition: newPosition,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF303D52),
                                            Color(0xFF202936),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF65758D),
                                        ),
                                      ),
                                      child: Text(
                                        formatTime(duration),
                                        style: const TextStyle(
                                          color: Color(0xFFD5E0F0),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'أزرار تشغيل الفيديو',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // ===== COMBINED TIMELINE AREA =====
              SizedBox(
                height: timelineHeight,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF20212A),
                  padding: const EdgeInsets.fromLTRB(5, 3, 5, 4),
                  child: Column(
                    children: [
                      Container(
                        height: 36,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF303D50), Color(0xFF202A38)],
                          ),
                          border: Border.all(color: Color(0xFF46566B)),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.movie_creation_outlined,
                                color: Colors.orangeAccent,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'M-GHALY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 18,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TIMELINE',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            _timelineHeaderChip(
                              Icons.video_library_outlined,
                              '${files.length}',
                              Colors.orangeAccent,
                            ),
                            const SizedBox(width: 5),
                            _timelineHeaderChip(
                              Icons.audiotrack,
                              '${audioTracks.length}',
                              Colors.greenAccent,
                            ),
                            const SizedBox(width: 5),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF205C40),
                                    Color(0xFF123B2B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.55,
                                  ),
                                  width: 0.9,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.greenAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  minimumSize: const Size(0, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: addAudio,
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.greenAccent,
                                  size: 17,
                                ),
                                label: const Text(
                                  'إضافة صوت',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<Duration>(
                          future: () async {
                            Duration total = Duration.zero;
                            for (final file in files) {
                              final duration = await getVideoDuration(
                                file.path,
                              );
                              if (duration != null) total += duration;
                            }
                            for (final track in audioTracks) {
                              final duration = track.player.duration;
                              if (duration != null && duration > total) {
                                total = duration;
                              }
                            }
                            return total;
                          }(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                  strokeWidth: 2,
                                ),
                              );
                            }

                            final totalDuration = snapshot.data!;
                            final pixelsPerSecond = 30.0 * timelineScale;
                            final timelineWidth =
                                (totalDuration.inMilliseconds /
                                        1000 *
                                        pixelsPerSecond)
                                    .clamp(60.0, 30000.0)
                                    .toDouble();

                            final tickStep = totalDuration.inMinutes >= 2
                                ? 10
                                : 5;
                            final totalSeconds = totalDuration.inSeconds;

                            final audioRowsHeight = audioTracks.isEmpty
                                ? 44.0
                                : audioTracks.length * 44.0;
                            final tracksHeight = 26.0 + 58.0 + audioRowsHeight;

                            final leftTrackHeaders = Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF343B4B),
                                        Color(0xFF222936),
                                      ],
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFF596477),
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white70,
                                        size: 13,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'TIME',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 58,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF49351F),
                                        Color(0xFF292A30),
                                      ],
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFF76532B),
                                      ),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.movie_creation_outlined,
                                        color: Colors.orangeAccent,
                                        size: 21,
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'VIDEO',
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (audioTracks.isEmpty)
                                  Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1D4936),
                                          Color(0xFF172B25),
                                        ],
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFF286747),
                                        ),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.graphic_eq,
                                          color: Colors.greenAccent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'AUDIO',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ...audioTracks.map((track) {
                                  return SizedBox(
                                    height: 44,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 22,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF19382D),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF315C49),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.audiotrack,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  track.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 25,
                                                      minHeight: 28,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                tooltip: 'كتم أو تفعيل المسار',
                                                onPressed: () async {
                                                  setState(() {
                                                    track.enabled =
                                                        !track.enabled;
                                                  });
                                                  if (!track.enabled &&
                                                      track.player.playing) {
                                                    await track.player.pause();
                                                  }
                                                  await track.player.setVolume(
                                                    track.enabled
                                                        ? track.volume
                                                        : 0.0,
                                                  );
                                                  if (track.enabled &&
                                                      (controller
                                                              ?.value
                                                              .isPlaying ??
                                                          false)) {
                                                    await syncAudioWithVideo(
                                                      play: true,
                                                    );
                                                  }
                                                  if (mounted) setState(() {});
                                                },
                                                icon: Icon(
                                                  track.enabled
                                                      ? Icons.volume_up
                                                      : Icons.volume_off,
                                                  color: track.enabled
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  size: 16,
                                                ),
                                              ),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 25,
                                                      minHeight: 28,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                tooltip: 'حذف المسار',
                                                onPressed: () => unawaited(
                                                  deleteAudioTrack(track),
                                                ),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 22,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF252B30),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF3B454A),
                                              width: 0.7,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.volume_down,
                                                color: Colors.white70,
                                                size: 14,
                                              ),
                                              Expanded(
                                                child: SliderTheme(
                                                  data: SliderThemeData(
                                                    trackHeight: 3,
                                                    activeTrackColor:
                                                        Colors.greenAccent,
                                                    inactiveTrackColor:
                                                        Colors.white24,
                                                    thumbColor:
                                                        Colors.greenAccent,
                                                    overlayColor: Colors
                                                        .greenAccent
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    thumbShape:
                                                        const RoundSliderThumbShape(
                                                          enabledThumbRadius: 5,
                                                        ),
                                                    overlayShape:
                                                        const RoundSliderOverlayShape(
                                                          overlayRadius: 9,
                                                        ),
                                                  ),
                                                  child: Slider(
                                                    value: track.volume,
                                                    min: 0,
                                                    max: 1,
                                                    divisions: 20,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        track.volume = value;
                                                      });
                                                      unawaited(
                                                        track.player.setVolume(
                                                          track.enabled
                                                              ? value
                                                              : 0.0,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 34,
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 3,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF173B2D,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF347653,
                                                    ),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${(track.volume * 100).round()}%',
                                                  style: const TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );

                            final rightTrackContent = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: timelineWidth,
                                  height: 26,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFF303846),
                                                Color(0xFF202630),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...List.generate(totalSeconds + 1, (
                                        second,
                                      ) {
                                        final left = second * pixelsPerSecond;
                                        if (left > timelineWidth) {
                                          return const SizedBox.shrink();
                                        }

                                        final isMajor = second % tickStep == 0;

                                        return Positioned(
                                          left: left,
                                          top: 0,
                                          child: SizedBox(
                                            width: 42,
                                            height: 26,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: isMajor ? 2 : 1,
                                                    height: isMajor ? 14 : 5,
                                                    decoration: BoxDecoration(
                                                      color: isMajor
                                                          ? Colors.orangeAccent
                                                          : Colors.white30,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                      boxShadow: isMajor
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .orangeAccent
                                                                    .withValues(
                                                                      alpha:
                                                                          0.35,
                                                                    ),
                                                                blurRadius: 4,
                                                              ),
                                                            ]
                                                          : [],
                                                    ),
                                                  ),
                                                ),
                                                if (isMajor)
                                                  Positioned(
                                                    left: 3,
                                                    top: 11,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF18212D,
                                                        ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .orangeAccent
                                                              .withValues(
                                                                alpha: 0.45,
                                                              ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        formatTime(
                                                          Duration(
                                                            seconds: second,
                                                          ),
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors
                                                              .orangeAccent,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          height: 1,
                                          color: Colors.white24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // VIDEO TRACK
                                SizedBox(
                                  width: timelineWidth,
                                  height: 58,
                                  child: files.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'لا توجد فيديوهات',
                                            style: TextStyle(
                                              color: Colors.white54,
                                            ),
                                          ),
                                        )
                                      : ReorderableListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: files.length,
                                          onReorderItem: reorderVideos,
                                          buildDefaultDragHandles: false,
                                          itemBuilder: (context, index) {
                                            final file = files[index];
                                            final selected =
                                                selectedIndex == index;

                                            return FutureBuilder<Duration?>(
                                              key: ValueKey<String>(file.path),
                                              future: getVideoDuration(
                                                file.path,
                                              ),
                                              builder: (context, durationSnapshot) {
                                                final duration =
                                                    durationSnapshot.data ??
                                                    const Duration(seconds: 4);
                                                final clipWidth =
                                                    (duration.inMilliseconds /
                                                            1000 *
                                                            pixelsPerSecond)
                                                        .clamp(
                                                          60.0,
                                                          timelineWidth,
                                                        )
                                                        .toDouble();

                                                return ReorderableDelayedDragStartListener(
                                                  index: index,
                                                  child: GestureDetector(
                                                    onTap: () => unawaited(
                                                      loadVideo(index),
                                                    ),
                                                    child: Container(
                                                      width: clipWidth,
                                                      margin:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Color(
                                                                  0xFF354153,
                                                                ),
                                                                Color(
                                                                  0xFF202936,
                                                                ),
                                                              ],
                                                            ),
                                                        border: Border.all(
                                                          color: selected
                                                              ? Colors
                                                                    .orangeAccent
                                                              : const Color(
                                                                  0xFF46505E,
                                                                ),
                                                          width: selected
                                                              ? 2.5
                                                              : 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              9,
                                                            ),
                                                        boxShadow: selected
                                                            ? [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .orange
                                                                      .withValues(
                                                                        alpha:
                                                                            0.18,
                                                                      ),
                                                                  blurRadius: 8,
                                                                  spreadRadius:
                                                                      1,
                                                                ),
                                                              ]
                                                            : [],
                                                      ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: Stack(
                                                              fit: StackFit
                                                                  .expand,
                                                              children: [
                                                                FutureBuilder<
                                                                  Uint8List?
                                                                >(
                                                                  future:
                                                                      getThumbnail(
                                                                        file.path,
                                                                      ),
                                                                  builder: (context, thumbnailSnapshot) {
                                                                    if (thumbnailSnapshot
                                                                            .hasData &&
                                                                        thumbnailSnapshot.data !=
                                                                            null) {
                                                                      return Stack(
                                                                        fit: StackFit
                                                                            .expand,
                                                                        children: [
                                                                          Image.memory(
                                                                            thumbnailSnapshot.data!,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                          const DecoratedBox(
                                                                            decoration: BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                begin: Alignment.topCenter,
                                                                                end: Alignment.bottomCenter,
                                                                                colors: [Color(0x18000000), Colors.transparent, Color(0x55000000)],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }
                                                                    return Container(
                                                                      decoration: const BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          begin:
                                                                              Alignment.topLeft,
                                                                          end: Alignment
                                                                              .bottomRight,
                                                                          colors: [
                                                                            Color(
                                                                              0xFF354153,
                                                                            ),
                                                                            Color(
                                                                              0xFF171E29,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      child: const Center(
                                                                        child: Icon(
                                                                          Icons
                                                                              .video_camera_back_rounded,
                                                                          color:
                                                                              Colors.orangeAccent,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                if (selected)
                                                                  Positioned(
                                                                    top: 4,
                                                                    left: 4,
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            3,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: const Color(
                                                                          0xE62B2114,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              5,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors.orangeAccent.withValues(
                                                                            alpha:
                                                                                0.8,
                                                                          ),
                                                                          width:
                                                                              0.8,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.orangeAccent.withValues(
                                                                              alpha: 0.18,
                                                                            ),
                                                                            blurRadius:
                                                                                5,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: const Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.check_circle,
                                                                            color:
                                                                                Colors.orangeAccent,
                                                                            size:
                                                                                10,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                3,
                                                                          ),
                                                                          Text(
                                                                            'SELECTED',
                                                                            style: TextStyle(
                                                                              color: Colors.orangeAccent,
                                                                              fontSize: 7,
                                                                              fontWeight: FontWeight.bold,
                                                                              letterSpacing: 0.5,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                Positioned(
                                                                  top: 0,
                                                                  right: 0,
                                                                  child: IconButton(
                                                                    tooltip: 'حذف الفيديو',
                                                                    iconSize:
                                                                        16,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    constraints: const BoxConstraints(
                                                                      minWidth:
                                                                          24,
                                                                      minHeight:
                                                                          24,
                                                                    ),
                                                                    icon: const Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .redAccent,
                                                                    ),
                                                                    onPressed: () =>
                                                                        unawaited(
                                                                          confirmDeleteVideo(
                                                                            index,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 17,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 4,
                                                                ),
                                                            decoration: const BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                    0xFF263345,
                                                                  ),
                                                                  Color(
                                                                    0xFF18212D,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    'VIDEO ${index + 1}',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          8,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 2,
                                                                ),
                                                                Text(
                                                                  formatTime(
                                                                    duration,
                                                                  ),
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .orangeAccent,
                                                                    fontSize: 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                ),

                                // AUDIO TRACKS WITH REAL WAVEFORMS
                                if (audioTracks.isEmpty)
                                  SizedBox(
                                    width: timelineWidth,
                                    height: 44,
                                    child: Container(
                                      height: 38,
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF173326),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: const Text(
                                        'لا توجد مسارات صوتية',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),

                                ...audioTracks.map((track) {
                                  final audioDuration =
                                      track.player.duration ?? Duration.zero;
                                  final clipWidth =
                                      (audioDuration.inMilliseconds /
                                              1000 *
                                              pixelsPerSecond)
                                          .clamp(60.0, timelineWidth)
                                          .toDouble();

                                  return SizedBox(
                                    width: timelineWidth,
                                    height: 44,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Container(
                                          width: timelineWidth,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color(0xFF1B3C30),
                                                Color(0xFF10251E),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF286747),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: clipWidth,
                                          height: 38,
                                          child: FutureBuilder<Waveform?>(
                                            future: getAudioWaveform(
                                              track.path,
                                            ),
                                            builder: (context, snapshot) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: track.enabled
                                                        ? const [
                                                            Color(0xFF23865A),
                                                            Color(0xFF125638),
                                                          ]
                                                        : const [
                                                            Color(0xFF515B58),
                                                            Color(0xFF303936),
                                                          ],
                                                  ),
                                                  border: Border.all(
                                                    color: track.enabled
                                                        ? Colors
                                                              .greenAccent
                                                              .shade400
                                                        : Colors.white24,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: track.enabled
                                                          ? Colors.greenAccent
                                                                .withValues(
                                                                  alpha: 0.20,
                                                                )
                                                          : Colors.black
                                                                .withValues(
                                                                  alpha: 0.12,
                                                                ),
                                                      blurRadius: track.enabled
                                                          ? 7
                                                          : 3,
                                                      spreadRadius:
                                                          track.enabled ? 1 : 0,
                                                    ),
                                                  ],
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: snapshot.hasData
                                                    ? Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          CustomPaint(
                                                            painter: AudioWaveformPainter(
                                                              waveform: snapshot
                                                                  .data!,
                                                              color:
                                                                  track.enabled
                                                                  ? Colors
                                                                        .greenAccent
                                                                  : Colors
                                                                        .white54,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            left: 5,
                                                            top: 4,
                                                            right: 5,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withAlpha(
                                                                      125,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                track.name,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 3,
                                                            child: Icon(
                                                              Icons
                                                                  .graphic_eq_rounded,
                                                              size: 13,
                                                              color:
                                                                  track.enabled
                                                                  ? Colors
                                                                        .greenAccent
                                                                  : Colors
                                                                        .white54,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const Center(
                                                        child: SizedBox(
                                                          width: 15,
                                                          height: 15,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth:
                                                                    1.5,
                                                                color: Colors
                                                                    .greenAccent,
                                                              ),
                                                        ),
                                                      ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );

                            final timelineCanvas = rightTrackContent;

                            return Listener(
                              onPointerDown: (event) {
                                timelinePointers[event.pointer] =
                                    event.localPosition;
                                if (timelinePointers.length == 2) {
                                  final points = timelinePointers.values
                                      .toList();
                                  timelinePinchStartDistance =
                                      (points[0] - points[1]).distance;
                                  timelineScaleStart = timelineScale;
                                }
                              },
                              onPointerMove: (event) {
                                if (!timelinePointers.containsKey(
                                  event.pointer,
                                )) {
                                  return;
                                }
                                timelinePointers[event.pointer] =
                                    event.localPosition;
                                if (timelinePointers.length < 2 ||
                                    timelinePinchStartDistance <= 0) {
                                  return;
                                }
                                final points = timelinePointers.values.toList();
                                final distance =
                                    (points[0] - points[1]).distance;
                                final nextScale =
                                    (timelineScaleStart *
                                            distance /
                                            timelinePinchStartDistance)
                                        .clamp(0.5, 3.0)
                                        .toDouble();
                                if ((nextScale - timelineScale).abs() > 0.005 &&
                                    mounted) {
                                  setState(() {
                                    timelineScale = nextScale;
                                  });
                                }
                              },
                              onPointerUp: (event) {
                                timelinePointers.remove(event.pointer);
                                if (timelinePointers.length < 2) {
                                  timelinePinchStartDistance = 0.0;
                                }
                              },
                              onPointerCancel: (event) {
                                timelinePointers.remove(event.pointer);
                                if (timelinePointers.length < 2) {
                                  timelinePinchStartDistance = 0.0;
                                }
                              },
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SizedBox(
                                  height: tracksHeight,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 145,
                                        child: leftTrackHeaders,
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, box) {
                                            final half = box.maxWidth / 2;

                                            if ((currentPixelsPerSecond -
                                                        pixelsPerSecond)
                                                    .abs() >
                                                0.001) {
                                              currentPixelsPerSecond =
                                                  pixelsPerSecond;
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback(
                                                    (_) =>
                                                        syncTimelineToPlayback(),
                                                  );
                                            }

                                            return Stack(
                                              children: [
                                                NotificationListener<
                                                  ScrollNotification
                                                >(
                                                  onNotification: (n) {
                                                    if (n.metrics.axis !=
                                                        Axis.horizontal) {
                                                      return false;
                                                    }
                                                    if (n
                                                            is ScrollStartNotification &&
                                                        n.dragDetails != null) {
                                                      userScrubbing = true;
                                                    } else if (n
                                                            is ScrollUpdateNotification &&
                                                        userScrubbing) {
                                                      scrubToPixels(
                                                        n.metrics.pixels,
                                                        pixelsPerSecond,
                                                      );
                                                    } else if (n
                                                        is ScrollEndNotification) {
                                                      userScrubbing = false;
                                                    }
                                                    return false;
                                                  },
                                                  child: SingleChildScrollView(
                                                    controller: timelineScroll,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: half,
                                                        ),
                                                    child: SizedBox(
                                                      width: timelineWidth,
                                                      height: tracksHeight,
                                                      child: timelineCanvas,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: half - 7,
                                                  top: 0,
                                                  bottom: 0,
                                                  child: const IgnorePointer(
                                                    child: SizedBox(
                                                      width: 14,
                                                      child: CustomPaint(
                                                        painter:
                                                            _PlayheadHeadPainter(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= AUDIO WAVEFORM PAINTER =================

class _PlayheadHeadPainter extends CustomPainter {
  const _PlayheadHeadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(const Offset(7, 10), Offset(7, size.height), linePaint);

    final sharpLine = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 2;

    canvas.drawLine(const Offset(7, 10), Offset(7, size.height), sharpLine);

    final head = Path()
      ..moveTo(0, 0)
      ..lineTo(14, 0)
      ..lineTo(7, 10)
      ..close();

    canvas.drawShadow(head, Colors.orangeAccent, 4, true);
    canvas.drawPath(head, Paint()..color = Colors.orangeAccent);
  }

  @override
  bool shouldRepaint(covariant _PlayheadHeadPainter oldDelegate) => false;
}

class AudioWaveformPainter extends CustomPainter {
  final Waveform waveform;
  final Color color;

  AudioWaveformPainter({required this.waveform, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || waveform.length <= 0) {
      return;
    }

    final centerY = size.height / 2;
    final maxHeight = size.height * 0.44;
    final maxValue = waveform.flags == 0 ? 32768.0 : 128.0;

    // Subtle center line.
    final centerPaint = Paint()
      ..color = color.withAlpha(65)
      ..strokeWidth = 0.7;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerPaint,
    );

    // Soft waveform glow.
    final glowPaint = Paint()
      ..color = color.withAlpha(65)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    // Gradient waveform bars.
    final wavePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.55),
              color,
              color.withValues(alpha: 0.75),
            ],
          ).createShader(
            Rect.fromLTWH(0, centerY - maxHeight, size.width, maxHeight * 2),
          )
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (double x = 3; x < size.width - 2; x += 3) {
      final index = ((x / size.width) * waveform.length).floor().clamp(
        0,
        waveform.length - 1,
      );

      final low = waveform.getPixelMin(index).toDouble();
      final high = waveform.getPixelMax(index).toDouble();

      final amplitude = (math.max(low.abs(), high.abs()) / maxValue).clamp(
        0.035,
        1.0,
      );

      final halfHeight = amplitude * maxHeight;

      final top = Offset(x, centerY - halfHeight);
      final bottom = Offset(x, centerY + halfHeight);

      canvas.drawLine(top, bottom, glowPaint);
      canvas.drawLine(top, bottom, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform || oldDelegate.color != color;
  }
}

// ================= VIDEO TRIM SCREEN =================

class VideoTrimScreen extends StatefulWidget {
  final File file;

  const VideoTrimScreen({super.key, required this.file});

  @override
  State<VideoTrimScreen> createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();

  double startValue = 0.0;
  double endValue = 0.0;

  bool isLoading = true;
  bool isPlaying = false;
  bool isSaving = false;

  String? loadError;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> loadVideo() async {
    try {
      await _trimmer.loadVideo(videoPath: widget.file.path);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = e.toString();
      });
    }
  }

  Future<void> toggleTrimPlayback() async {
    if (isLoading || isSaving || loadError != null) return;

    try {
      final playbackState = await _trimmer.videoPlaybackControl(
        startValue: startValue,
        endValue: endValue,
      );

      if (!mounted) return;

      setState(() {
        isPlaying = playbackState;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر تشغيل المعاينة: $e')));
    }
  }

  Future<void> saveTrimmedVideo() async {
    if (isSaving || isLoading || loadError != null) return;

    setState(() {
      isSaving = true;
    });

    try {
      await _trimmer.saveTrimmedVideo(
        startValue: startValue,
        endValue: endValue,
        onSave: (outputPath) {
          if (!mounted) return;

          if (outputPath == null || outputPath.isEmpty) {
            setState(() {
              isSaving = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم إنشاء الفيديو المقصوص')),
            );
            return;
          }

          Navigator.pop(context, outputPath);
        },
      );

      if (mounted && isSaving) {
        setState(() {
          isSaving = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ أثناء القص: $e')));
    }
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101116),
      appBar: AppBar(
        toolbarHeight: 56,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF332719),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orangeAccent.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                color: Colors.orangeAccent,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'قص الفيديو',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF252D3B), Color(0xFF191D27), Color(0xFF11141C)],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton.icon(
              onPressed: isSaving || isLoading || loadError != null
                  ? null
                  : saveTrimmedVideo,
              icon: const Icon(Icons.save_rounded, size: 19),
              label: const Text(
                'حفظ الجزء',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orangeAccent,
                disabledForegroundColor: Colors.white24,
                backgroundColor: const Color(0xFF332719),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: Colors.orangeAccent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B202B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.orangeAccent.withValues(alpha: 0.22),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: CircularProgressIndicator(
                        color: Colors.orangeAccent,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل الفيديو...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : loadError != null
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF241B20),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'تعذر تحميل الفيديو',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (isSaving)
                  const LinearProgressIndicator(
                    color: Colors.orange,
                    backgroundColor: Colors.white12,
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF626C7D),
                          Color(0xFF252D3B),
                          Color(0xFFB36B28),
                          Color(0xFF252D3B),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.orangeAccent.withValues(alpha: 0.07),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF050608),
                        child: VideoViewer(trimmer: _trimmer),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 5, 12, 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B202B),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.orangeAccent.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.orangeAccent,
                        size: 21,
                      ),
                      SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          'اسحب طرفي التحديد لاختيار بداية ونهاية المقطع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 65,
                    viewerWidth: MediaQuery.of(context).size.width - 24,
                    editorProperties: TrimEditorProperties(
                      handleStyle: TrimHandleStyle.circle,
                      circleSize: 7,
                      circleSizeOnDrag: 10,
                      borderWidth: 3,
                      borderRadius: 7,
                      circlePaintColor: Colors.orangeAccent,
                      borderPaintColor: Colors.orangeAccent,
                      scrubberPaintColor: Colors.white,
                    ),
                    onChangeStart: (value) {
                      startValue = value;
                    },
                    onChangeEnd: (value) {
                      endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      if (!mounted) return;
                      setState(() {
                        isPlaying = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFC04D), Color(0xFFE87516)],
                    ),
                    border: Border.all(
                      color: Colors.orangeAccent.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.22),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: isPlaying ? 'إيقاف المعاينة' : 'تشغيل المعاينة',
                    onPressed: isSaving ? null : toggleTrimPlayback,
                    iconSize: 36,
                    color: const Color(0xFF171717),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}

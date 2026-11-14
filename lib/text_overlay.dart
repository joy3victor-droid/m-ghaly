import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TextClip {
  TextClip({
    required this.text,
    required this.start,
    required this.end,
    this.position = 2,
    this.sizeFraction = 0.08,
    this.colorValue = 0xFFFFFFFF,
  });

  final String text;
  final Duration start;
  final Duration end;

  /// 0 = أعلى، 1 = وسط، 2 = أسفل
  final int position;

  /// حجم الخط كنسبة من ارتفاع الفيديو
  final double sizeFraction;
  final int colorValue;

  TextDirection get textDirection =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text)
      ? TextDirection.rtl
      : TextDirection.ltr;
}

List<Shadow> textShadows(double fontSize) => [
  Shadow(
    color: Colors.black,
    blurRadius: fontSize * 0.15,
    offset: Offset(0, fontSize * 0.04),
  ),
  Shadow(color: Colors.black, blurRadius: fontSize * 0.3),
];

/// يرسم النص على صورة PNG شفافة بحجم الفيديو الناتج، ويرجّع مسارها.
Future<String> renderTextOverlay(TextClip clip, int width, int height) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
  );

  final fontSize = height * clip.sizeFraction;

  final painter = TextPainter(
    text: TextSpan(
      text: clip.text,
      style: TextStyle(
        color: Color(clip.colorValue),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: textShadows(fontSize),
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: clip.textDirection,
    maxLines: 6,
  )..layout(maxWidth: width * 0.9);

  final dx = (width - painter.width) / 2;
  final double dy;
  switch (clip.position) {
    case 0:
      dy = height * 0.08;
      break;
    case 1:
      dy = (height - painter.height) / 2;
      break;
    default:
      dy = height * 0.88 - painter.height;
  }

  painter.paint(canvas, Offset(dx, dy));

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/text_${DateTime.now().microsecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(data!.buffer.asUint8List());
  return file.path;
}

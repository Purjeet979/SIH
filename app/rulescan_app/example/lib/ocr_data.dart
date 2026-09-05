import 'dart:ui';

class OcrBlock {
  final String text;
  final Rect boundingBox;
  final List<OcrLine> lines;

  OcrBlock({required this.text, required this.boundingBox, required this.lines});
}

class OcrLine {
  final String text;
  final Rect boundingBox;

  OcrLine({required this.text, required this.boundingBox});
}

import 'package:flutter/material.dart';


class Stroke {
  final List<Offset> points = [];
  final Color color;
  final double width;
  final bool isErase;

  Stroke({
    this.color = Colors.blue,
    this.width = 2.5,
    this.isErase = false,
  });
}

class NotesPainter extends CustomPainter {
  final List<Stroke> strokesByRun;
  final Rect? blockRect;
  final Stroke? tempStroke;

  NotesPainter({
    required this.strokesByRun,
    required this.blockRect,
    required this.tempStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokesByRun) {
      final paint = Paint()
        ..color = stroke.isErase ? Colors.white : stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawStroke(canvas, paint, stroke.points);
    }

    if (tempStroke != null) {
      final paint = Paint()
        ..color = tempStroke!.isErase ? Colors.white : tempStroke!.color
        ..strokeWidth = tempStroke!.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      _drawStroke(canvas, paint, tempStroke!.points);
    }
  }

  void _drawStroke(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.length < 2) return;
    Path path = Path();
    bool started = false;
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      if (blockRect != null && blockRect!.contains(pt)) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotesPainter oldDelegate) {
    return oldDelegate.strokesByRun != strokesByRun ||
        oldDelegate.tempStroke != tempStroke ||
        oldDelegate.blockRect != blockRect;
  }
}

/// Clears all strokes in the provided list.
void clearStrokes(List<Stroke> strokes) {
  strokes.clear();
}

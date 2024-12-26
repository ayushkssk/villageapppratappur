import 'package:flutter/material.dart';
import 'dart:math' as math;

class VillagePatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  VillagePatternPainter({
    this.color = Colors.brown,
    this.opacity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5;

    final patternSize = 80.0;
    final numX = (size.width / patternSize).ceil();
    final numY = (size.height / patternSize).ceil();

    for (var y = 0; y < numY; y++) {
      for (var x = 0; x < numX; x++) {
        final offsetX = x * patternSize;
        final offsetY = y * patternSize;

        // Draw hut
        final hutPath = Path()
          ..moveTo(offsetX + 20, offsetY + 40)
          ..lineTo(offsetX + 30, offsetY + 25)
          ..lineTo(offsetX + 40, offsetY + 40)
          ..lineTo(offsetX + 40, offsetY + 55)
          ..lineTo(offsetX + 20, offsetY + 55)
          ..close();
        canvas.drawPath(hutPath, paint);

        // Draw door
        canvas.drawRect(
          Rect.fromLTWH(offsetX + 27, offsetY + 45, 6, 10),
          paint,
        );

        // Draw tree
        final treePath = Path()
          ..moveTo(offsetX + 55, offsetY + 55)
          ..lineTo(offsetX + 62, offsetY + 35)
          ..lineTo(offsetX + 69, offsetY + 55)
          ..close();
        canvas.drawPath(treePath, paint);

        // Draw tree trunk
        canvas.drawRect(
          Rect.fromLTWH(offsetX + 60, offsetY + 55, 4, 8),
          paint,
        );

        // Draw field lines
        final fieldPath = Path();
        for (var i = 0; i < 2; i++) {
          fieldPath.moveTo(offsetX, offsetY + 65 + (i * 8));
          for (var j = 0; j < 4; j++) {
            fieldPath.quadraticBezierTo(
              offsetX + 10 + (j * 20),
              offsetY + 62 + (i * 8) + (j.isEven ? 3 : -3),
              offsetX + 20 + (j * 20),
              offsetY + 65 + (i * 8),
            );
          }
        }
        canvas.drawPath(fieldPath, paint);

        // Draw birds (only in some cells for variation)
        if ((x + y) % 3 == 0) {
          final birdPath = Path()
            ..moveTo(offsetX + 10, offsetY + 15)
            ..quadraticBezierTo(
              offsetX + 15,
              offsetY + 10,
              offsetX + 20,
              offsetY + 15,
            )
            ..quadraticBezierTo(
              offsetX + 15,
              offsetY + 20,
              offsetX + 10,
              offsetY + 15,
            );
          canvas.drawPath(birdPath, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(VillagePatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.opacity != opacity;
  }
}

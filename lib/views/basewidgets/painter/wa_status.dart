import 'dart:math';

import 'package:flutter/material.dart';

class CustomRoundedPainter extends CustomPainter {
  Color buttonBorderColor;
  Color progressColor;
  double percentage;
  double width;

  CustomRoundedPainter({required this.buttonBorderColor,required this.progressColor, required this.percentage, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = buttonBorderColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete =  Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      radius,
      line
    );
    double arcAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(
        center: center, 
        radius: radius
      ),
      -pi / 2,
      arcAngle,
      false,
      complete
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DashedCirclePainter extends CustomPainter {
  final int dashes;
  final Color color;
  final double gapSize;
  final double strokeWidth;

  DashedCirclePainter({
    this.dashes = 1,
    this.color = Colors.white,
    this.gapSize = 1,
    this.strokeWidth = 1
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double gap = pi / 180 * gapSize;
    final double singleAngle = (pi * 2) / dashes;

    for (int i = 0; i < dashes; i++) {
      final Paint paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(
          center:  Offset(size.width / 2, size.height / 2), 
          radius:  min(size.width / 2, size.height / 2),
        ), 
        gap + singleAngle * i, 
        singleAngle - gap * 2, false, paint
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter oldDelegate) {
    return true;
  }
}
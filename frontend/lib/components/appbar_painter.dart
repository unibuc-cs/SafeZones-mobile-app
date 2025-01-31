import 'package:flutter/material.dart';

class CurvedAppBar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.6,
        size.width * 0.5, size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.6,
        size.width, size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

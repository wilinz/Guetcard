import 'dart:math';

import 'package:flutter/material.dart';

/// 在全面屏 iPhone 机型的额角绘制一个黑色圆角遮盖，以减少黑色额头的违和感
class BlackCornerRadiusPainter extends CustomPainter {
  double degToRad(num deg) => deg * (pi / 180);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 38.5;
    Path path = Path();
    path.lineTo(radius, 0);
    path.arcTo(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      degToRad(-90),
      degToRad(-90),
      true,
    );
    path.lineTo(0, 0);
    path.close();
    path.moveTo(size.width - radius, 0);
    path.arcTo(
        Rect.fromCircle(center: Offset(size.width - radius, radius), radius: radius),
      degToRad(-90),
      degToRad(90),
      true,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width - radius, 0);
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

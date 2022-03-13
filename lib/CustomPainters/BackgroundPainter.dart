import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const bgColor = Color.fromARGB(255, 11, 185, 8);
    const fgColor = Color.fromARGB(255, 60, 199, 56);
    final Size physicalSize = Size(window.physicalSize.width, window.physicalSize.height);

    (() {
      // 绘制纯色背景
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: physicalSize.width,
        height: physicalSize.height,
      );
      var paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = bgColor;
      canvas.drawRect(rect, paint);
    })();
    (() {
      // 绘制宽斜线
      Path path = Path();
      double distance = 20;  // 条纹中心间距
      double strokeWidth = 7;  // 条纹宽度
      for (int i = 0; i < physicalSize.width / distance * 2; i++) {
        path.relativeMoveTo(-distance * i, 0);
        path.relativeMoveTo(physicalSize.width, -physicalSize.width);
        path.relativeLineTo(-physicalSize.width * 2, physicalSize.width * 2);
        path.moveTo(0, 0);

        path.relativeMoveTo(distance * i, 0);
        path.relativeMoveTo(physicalSize.width, -physicalSize.width);
        path.relativeLineTo(-physicalSize.width * 2, physicalSize.width * 2);
        path.moveTo(0, 0);
      }

      var paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..color = fgColor
        ..strokeWidth = strokeWidth;
      canvas.drawPath(path, paint);
    })();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;  // 任何情况下都不需要重绘
  }
}

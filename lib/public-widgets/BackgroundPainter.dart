import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const bgColor = Color.fromARGB(255, 11, 185, 8);
    const fgColor = Color.fromARGB(255, 60, 199, 56);
    (() {
      // 绘制纯色背景
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 2,
        height: size.height * 2,
      );
      var paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = bgColor;
      canvas.drawRect(rect, paint);
    })();
    (() {
      // TODO: 绘制宽斜线
      Path path = Path();
      double distance = 20;
      double strokeWidth = 7;
      for (int i = 0; i < size.width / distance * 4; i++) {
        path.relativeMoveTo(-distance * i, 0);
        path.relativeMoveTo(size.width, -size.width);
        path.relativeLineTo(-size.width * 4, size.width * 4);
        path.moveTo(0, 0);

        path.relativeMoveTo(distance * i, 0);
        path.relativeMoveTo(size.width, -size.width);
        path.relativeLineTo(-size.width * 4, size.width * 4);
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
    return false;
  }
}

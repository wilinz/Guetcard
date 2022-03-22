import 'package:flutter/material.dart';

import '../../../CustomPainters/BackgroundPainter.dart';

class BackgroundStripe extends StatelessWidget {
  const BackgroundStripe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // 给 CustomPaint 组件建立一个新的画布，防止其跟着其他元素（如时钟）一起被重绘，
      // 可大幅降低性能开销
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: BackgroundPainter(),
        willChange: false,
        isComplex: true,
      ),
    );
  }
}

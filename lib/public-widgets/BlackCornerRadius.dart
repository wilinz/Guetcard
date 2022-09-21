import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/CustomPainters/BlackCornerRadiusPainter.dart';
import 'package:guet_card/Utils/WebJS/WebJSMethods.dart';

class BlackCornerRadius extends StatelessWidget {
  const BlackCornerRadius({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Builder(builder: (context) {
        if (kIsWeb && RegExp("iPhone; CPU iPhone OS .* like Mac OS X").hasMatch(WebJSMethods.getUserAgent() ?? "")) {
          if (MediaQuery.of(context).size.height / MediaQuery.of(context).size.width > 2) {
            // 识别为 iPhone 网页端则添加一个黑色额角遮盖
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BlackCornerRadiusPainter(),
            );
          }
        }
        // 否则返回一个隐形 widget
        return SizedBox(width: 0, height: 0);
      }),
    );
  }
}

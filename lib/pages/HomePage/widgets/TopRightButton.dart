import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Const.dart';

/// 右上角图标
class TopRightButton extends StatelessWidget {
  const TopRightButton({Key? key}) : super(key: key);
  final double _height = 21.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      padding: EdgeInsets.only(top: 55, right: 15),
      child: Container(
        height: _height + 9,
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("about");
          },
          child: Builder(builder: (context) {
            if (kIsWeb) {
              return Image.network(
                Const.networkImages["topRightIcon"]!,
                height: _height,
              );
            } else {
              return Image.asset(
                "assets/images/TopRightIcon.png",
                height: _height,
              );
            }
          }),
          style: OutlinedButton.styleFrom(
            backgroundColor: Color(0x30000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
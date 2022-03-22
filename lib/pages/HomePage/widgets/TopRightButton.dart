import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Const.dart';

/// 右上角图标
class TopRightButton extends StatelessWidget {
  const TopRightButton({Key? key}) : super(key: key);
  final double _imgHeight = 21.0;

  @override
  Widget build(BuildContext context) {
    double safeAreaTopHeight = MediaQuery.of(context).padding.top;
    return SafeArea(
      child: Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(top: kIsWeb ? 30 : safeAreaTopHeight > 40 ? 0 : 15, right: 15),
        child: Container(
          height: _imgHeight + 9,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("about");
            },
            child: Builder(builder: (context) {
              if (kIsWeb) {
                return Image.network(
                  Const.networkImages["topRightIcon"]!,
                  height: _imgHeight,
                );
              } else {
                return Image.asset(
                  Const.assetImages["topRightIcon"]!,
                  height: _imgHeight,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 显示通行证的组件
class EntryPermit extends StatelessWidget {
  const EntryPermit({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "临时通行证",
        maxLines: 1,
        style: TextStyle(
          fontFamily: "PingFangSC-Heavy",
          color: Color(0xFF007f00),
          fontSize: 20,
        ),
      ),
    );
  }
}

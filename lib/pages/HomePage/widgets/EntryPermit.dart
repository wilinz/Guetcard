import 'package:flutter/material.dart';

/// 显示通行证的组件
class EntryPermit extends StatelessWidget {
  const EntryPermit({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "桂电学生临时通行证",
        maxLines: 1,
        style: TextStyle(
          fontFamily: "PingFangSC-Regular",
          color: Color(0xff0cbb0a),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

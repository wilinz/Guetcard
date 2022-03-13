import 'dart:async';

import 'package:flutter/material.dart';

/// 显示时间（精确到毫秒）的动态组件，间隔 [_duration] ms刷新一次来模拟原版小程序中的卡顿感
class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  String _time = getTime();
  late Timer _countdownTimer;
  final int _duration = 130;

  static String getTime() => DateTime.now()
      .toString()
      .split(' ')[1]
      .substring(0, 11)
      .replaceAll(".", ":");

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: _duration),
          (timer) {
        if (mounted) {
          setState(() {
            _time = getTime();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Center(
        child: Text(
          _time,
          style: TextStyle(
            fontFamily: "PingFangSC-Heavy",
            fontSize: 27,
            color: Color(0xff0cbb0a),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }
}
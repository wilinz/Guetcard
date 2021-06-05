import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 在SimpleDialog上封装的一个简单的输入对话框
class InputDialog extends StatelessWidget {
  final Widget title;
  final Function onOkBtnPressed;
  final TextEditingController controller;

  const InputDialog({
    Key key,
    this.title,
    this.onOkBtnPressed,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: title,
      children: <Widget>[
        TextField(
          controller: controller,
        ),
        Row(
          children: [TextButton(onPressed: onOkBtnPressed, child: Text("确定"))],
          mainAxisAlignment: MainAxisAlignment.end,
        )
      ],
      contentPadding: EdgeInsets.symmetric(horizontal: 25),
    );
  }
}
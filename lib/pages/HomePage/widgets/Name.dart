import 'package:flutter/material.dart';
import 'package:guet_card/Providers/UsernameProvider.dart';
import 'package:guet_card/public-widgets/InputDialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 显示姓名的动态组件
class Name extends StatefulWidget {
  const Name({Key? key}) : super(key: key);

  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<Name> {
  TextEditingController _controller = TextEditingController(text: "");

  Future<String> _getNameFromPref() async {
    var pref = await SharedPreferences.getInstance();
    return pref.getString("name") ?? "";
  }

  Future<void> _inputName() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: Text(
            "请输入姓名最后一个字",
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
          onOkBtnPressed: () async {
            var pref = await SharedPreferences.getInstance();
            if (_controller.text.length > 1) {
              _controller.text = _controller.text.characters.first;
            }
            Provider.of<UsernameProvider>(context, listen: false).username = _controller.text;
            await pref.setString("name", _controller.text);
            Navigator.of(context).pop();
          },
          controller: _controller,
        );
      },
    ).then((val) {
      _controller.text = Provider.of<UsernameProvider>(context, listen: false).username;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _getNameFromPref().then((String name) async {
        Provider.of<UsernameProvider>(context, listen: false).username = name;
        _controller.text = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          _inputName();
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "**${Provider.of<UsernameProvider>(context).username} 可以通行",
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: "PingFangSC-Heavy",
                    color: Color(0xFF007f00),
                    fontSize: 22,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(200, 40),
          alignment: Alignment.topCenter,
        ));
  }
}

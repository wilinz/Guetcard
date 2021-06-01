import 'dart:ui';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guet_card/CardView.dart';
import 'package:guet_card/AboutPage.dart';

void printPref() async {
  var pref = await SharedPreferences.getInstance();
  try {
    String userAvatar = pref.getString("userAvatar") ?? "null";
    String name = pref.getString("name") ?? "null";
    print("userAvatar: ${userAvatar}\nname: ${name}");
  } catch (e) {
    print(e);
  }
}

void main() {
  runApp(new MyApp());
  // 设为仅竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  
  // 自定义组件，继承于无状态组件类
  @override
  Widget build(BuildContext context) {
    double _titleOffset = 0.0;
    bool _centerTitle = true;
    double _bubble_width = 30.0;
    if (!kIsWeb) {
      _titleOffset = Platform.isIOS ? 0 : -15;
      _centerTitle = Platform.isIOS ? true : false;
    }
    //printPref();

    // 需要实现 build 方法并返回一个组件
    return MaterialApp(
      title: '桂电畅行证',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 9, 186, 7),
        buttonColor: Colors.green,
        brightness: Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Transform(
            child: Text("桂电畅行证",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
            transform: Matrix4.translationValues(_titleOffset, 0.0, 0.0),
          ),
          centerTitle: _centerTitle,
          leading: SizedBox(
            height: 40,
            child: Center(
              child: OutlinedButton(
                // 左上角图标
                  child: TopLeftIconImage(),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 7, 158, 6),
                      shape: CircleBorder(),
                      minimumSize: Size(_bubble_width, _bubble_width))),
            ),
          ),
          actions: [
            SizedBox(
                height: _bubble_width,
                child: Center(
                  child: Builder(
                    builder: (context) => OutlinedButton(
                      // 右上角图标
                      child: TopRightIconsImage(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 158, 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))),
                        padding: EdgeInsets.all(5),
                        minimumSize: Size(90, _bubble_width),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AboutPage()));
                      },
                    ),
                  )
                )),
            SizedBox(
              width: 10,
            )
          ],
          elevation: 0,
          toolbarHeight: 50,
          brightness: Brightness.dark,
        ),
        body: HomeContent(),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
}

/// 主界面视图
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Container(
      child: ListView(
        children: <Widget>[
          /*Container(
            height: 10,
            decoration: BoxDecoration(color: Color.fromARGB(255, 9, 186, 7)),
          ),*/
          CheckPointView(),
          Container(
            height: 34,
            decoration: BoxDecoration(color: Color.fromARGB(255, 9, 186, 7)),
          ),
          CardView(screenHeight: height, screenWidth: width,),
        ],
        physics: BouncingScrollPhysics(),
      ),
      color: Color.fromARGB(255, 9, 186, 7),
    );
  }
}

/// 左上角图标
class TopLeftIconImage extends StatelessWidget {
  const TopLeftIconImage({Key key}) : super(key: key);
  static const _height = 20.0;
  @override
  Widget build(BuildContext context) {
    if (kIsWeb == true) {
      return Image.network(
        "https://i.loli.net/2021/05/30/8O9fP1GUZhb564l.png",
        height: _height,
      );
    }
    return Image.asset(
      "images/top_left_icon.png",
      width: _height,
    );
  }
}

/// 右上角图标
class TopRightIconsImage extends StatelessWidget {
  const TopRightIconsImage({Key key}) : super(key: key);
  static const _height = 20.0;
  @override
  Widget build(BuildContext context) {
    if (kIsWeb == true) {
      return Image.network(
        "https://i.loli.net/2021/05/30/mr6O9tUyzq4Iu8x.png",
        height: _height,
      );
    }
    return Image.asset(
      "images/top_right_icons.png",
      height: _height,
    );
  }
}

/// 检查点（即通行证下方的那行字）按钮动态视图
class CheckPointView extends StatefulWidget {
  const CheckPointView({Key key}) : super(key: key);

  @override
  _CheckPointViewState createState() => _CheckPointViewState();
}

class _CheckPointViewState extends State<CheckPointView> {
  var _checkPointName = "花江检查点";
  onLabelPressed() async {
    var checkPointName = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                  title: const Text('请选择扫码点'),
                  children: <Widget>[
                    CheckPointDialogOption(name: "花江检查点"),
                    CheckPointDialogOption(name: "花江后街"),
                    CheckPointDialogOption(name: "金鸡岭正门"),
                  ]);
            }) ??
        _checkPointName;
    setState(() {
      this._checkPointName = checkPointName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        child: Text(
          _checkPointName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19, color: Colors.white),
          maxLines: 1,
        ),
        onPressed: onLabelPressed,
      ),
      height: 50.0,
      decoration: BoxDecoration(color: Color.fromARGB(255, 9, 186, 7)),
    );
  }
}

/// 选择检查点按钮的列表内项目
class CheckPointDialogOption extends StatelessWidget {
  String name;
  CheckPointDialogOption({Key key, String name}) : super(key: key) {
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, name);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(name),
        ));
  }
}

/// 底部浮动bar
class BottomBar extends StatelessWidget {
  const BottomBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          OutlinedButton(
            child: Text(
              "返回首页",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(145, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2))),
              side: BorderSide(color: Color.fromARGB(255, 230, 230, 230)),
            ),
          ),
          SizedBox(
            width: 40,
          ),
          OutlinedButton(
            child: Text(
              "出行记录",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(145, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2))),
              side: BorderSide(color: Color.fromARGB(255, 230, 230, 230)),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      height: 60,
    );
  }
}

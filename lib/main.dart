import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:guet_card/AboutPage.dart';
import 'package:guet_card/CardView.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:flutter_intro/flutter_intro.dart';

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

Future<String> initPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  return version;
}

Intro? intro;

void main() {
  runApp(new MyApp());
  // 设为仅竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

/// app的根组件
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _titleOffset = 0.0;
    bool _centerTitle = true;
    double _bubble_width = 30.0;
    if (!kIsWeb) {
      _titleOffset = Platform.isIOS ? 0 : -15;
      _centerTitle = Platform.isIOS ? true : false;
    }

    return ProgressHud(
      isGlobalHud: true,
      child: MaterialApp(
        title: '桂电畅行证',
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 9, 186, 7),
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
                  child: Builder(
                builder: (context) => OutlinedButton(
                  // 左上角图标
                  child: TopLeftIconImage(),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 7, 158, 6),
                      shape: CircleBorder(),
                      minimumSize: Size(_bubble_width, _bubble_width)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutPage()));
                  },
                ),
              )),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        padding: EdgeInsets.all(5),
                        minimumSize: Size(90, _bubble_width),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()));
                      },
                    ),
                  ))),
              SizedBox(
                width: 10,
              )
            ],
            elevation: 0,
            toolbarHeight: 50,
          ),
          body: HomeContent(),
          bottomNavigationBar: BottomBar(),
        ),
      ),
    );
  }
}

/// 主界面视图
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late BuildContext globalContext;

  void initGuide() {
    intro = Intro(

        /// You can set it true to disable animation
        noAnimation: false,

        /// The total number of guide pages, must be passed
        stepCount: 3,

        /// Click on whether the mask is allowed to be closed.
        maskClosable: true,

        /// When highlight widget is tapped.
        onHighlightWidgetTap: (introStatus) {
          print(introStatus);
        },

        /// The padding of the highlighted area and the widget
        padding: EdgeInsets.all(8),

        /// Border radius of the highlighted area
        borderRadius: BorderRadius.all(Radius.circular(4)),

        /// Use the default useDefaultTheme provided by the library to quickly build a guide page
        /// Need to customize the style and content of the guide page, implement the widgetBuilder method yourself
        /// * Above version 2.3.0, you can use useAdvancedTheme to have more control over the style of the widget
        /// * Please see https://github.com/tal-tech/flutter_intro/issues/26
        widgetBuilder:
            StepWidgetBuilder.useAdvancedTheme(widgetBuilder: (params) {
          List<String> textToBeShown = [
            '点击这里来更改检查点名称',
            '点击这里来更改头像',
            '点击这里来更改姓名',
          ];
          return Container(child: Builder(builder: (context) {
            if (params.currentStepIndex + 1 < params.stepCount) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      textToBeShown[params.currentStepIndex],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: OutlinedButton(
                          onPressed: () {
                            params.onNext!();
                          },
                          child: Text('下一步',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromARGB(100, 100, 100, 100),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                            enableFeedback: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: OutlinedButton(
                          onPressed: () {
                            params.onFinish();
                          },
                          child: Text('跳过',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromARGB(100, 100, 100, 100),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                            enableFeedback: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      textToBeShown[params.currentStepIndex],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: OutlinedButton(
                      onPressed: () {
                        params.onFinish();
                        print("finish");
                      },
                      child: Text('完成',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color.fromARGB(100, 100, 100, 100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                        enableFeedback: true,
                      ),
                    ),
                  ),
                ],
              );
            }
          }));
        }));
  }

  void showGuide(BuildContext globalContext) {
    print("intro.keys: ${intro?.keys}");
    if (context != null) {
      if (kIsWeb) {
        String webIntroImg =
            "https://i.loli.net/2021/09/23/qLX2RwNy4WBgzS8.png";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Stack(
                children: [
                  Center(child: Image.network(webIntroImg)),
                  Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.all(30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(padding: EdgeInsets.all(5), child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("跳过",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromARGB(100, 100, 100, 100),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                            enableFeedback: true,
                          ),
                        )),
                        Padding(padding: EdgeInsets.all(5), child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            intro?.start(globalContext);
                          },
                          child: Text("下一步",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromARGB(100, 100, 100, 100),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                            enableFeedback: true,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              );
            });
      }
    } else {
      throw "Wait for app loading";
    }
  }

  void checkForUpdate() async {
    String currentVersion = await initPackageInfo();
    var response;
    try {
      response = await Dio().get(
          "https://gitee.com/api/v5/repos/guetcard/guetcard/releases/latest");
    } catch (e) {
      print(e);
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> map = response.data;
      String remoteVersion =
          map["tag_name"].replaceAll("v", "").replaceAll(".", "");
      if (int.parse(remoteVersion) >
          int.parse(currentVersion.replaceAll(".", ""))) {
        String? apkUrl;
        for (var item in map["assets"]) {
          if (item["name"] != null && item["name"].endsWith(".apk")) {
            apkUrl = item["browser_download_url"];
          }
        }

        if (Platform.isAndroid) {
          await FlutterXUpdate.init(
            debug: false,
            isWifiOnly: false,
          );
          UpdateEntity updateEntity = UpdateEntity(
              hasUpdate: true,
              versionCode: int.parse(remoteVersion),
              versionName: map["tag_name"],
              updateContent: map["body"],
              downloadUrl: apkUrl);
          FlutterXUpdate.updateByInfo(updateEntity: updateEntity);
        } else if (Platform.isIOS) {
          if (context != null) {
            Map<String, dynamic> updateInfo = {
              "ipaUrl": null,
              "versionName": null,
              "description": null,
            };
            updateInfo['ipaUrl'] =
                "https://gitee.com/guetcard/guetcard/releases";
            updateInfo['versionName'] = map["tag_name"];
            updateInfo['description'] = map["body"];
            showIOSDialog(context, updateInfo);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      Future.delayed(Duration(seconds: 5), this.checkForUpdate);
    }
    this.initGuide();
    Future.delayed(Duration(seconds: 2), () => this.showGuide(globalContext));
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      child: ListView(
        children: <Widget>[
          CheckPointView(
            key: intro?.keys[0],
          ),
          Container(
            height: 34,
            decoration: BoxDecoration(color: Color.fromARGB(255, 9, 186, 7)),
          ),
          CardView(
            screenWidth: width,
          ),
        ],
        physics: BouncingScrollPhysics(),
      ),
      color: Color.fromARGB(255, 9, 186, 7),
    );
  }
}

/// 左上角图标
class TopLeftIconImage extends StatelessWidget {
  const TopLeftIconImage({Key? key}) : super(key: key);
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
  const TopRightIconsImage({Key? key}) : super(key: key);
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
  const CheckPointView({Key? key}) : super(key: key);

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

/// 选择检查点按钮列表内项目
class CheckPointDialogOption extends StatelessWidget {
  late String name;

  CheckPointDialogOption({Key? key, required String name}) : super(key: key) {
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
  const BottomBar({Key? key}) : super(key: key);

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
            onPressed: () {},
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
            onPressed: () {},
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      height: 60,
    );
  }
}

// 跳转 AppStore 更新 iOSUrl APP 在 AppStore 的链接
Future<void> showIOSDialog(
    BuildContext context, Map<String, dynamic> updateInfo) async {
  showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
              decoration: new BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
                        child: Text(
                          '是否升级到${updateInfo["versionName"]}版本',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xff555555),
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Text(updateInfo["description"],
                          style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                              decoration: TextDecoration.none)),
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextButton(
                              child: Text(
                                "下次再说",
                                style: TextStyle(
                                    color: Color(0xffffbb5b), fontSize: 18.0),
                              ),
                              onPressed: () =>
                                  Navigator.of(context).pop(), //关闭对话框
                            ),
                            TextButton(
                              child: Text(
                                "立即前往",
                                style: TextStyle(
                                    color: Color(0xffffbb5b), fontSize: 18.0),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop(); //关闭对话框
                                await canLaunch(updateInfo["ipaUrl"])
                                    ? await launch(updateInfo["ipaUrl"])
                                    : throw 'Could not launch ${updateInfo["ipaUrl"]}';
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ))),
        ],
      );
    },
  );
}

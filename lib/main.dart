import 'dart:io';
import 'dart:ui';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:guet_card/AboutPage.dart';
import 'package:guet_card/CardView.dart';
import 'package:guet_card/IntroImage.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void printPref() async {
  var pref = await SharedPreferences.getInstance();
  try {
    String userAvatar = pref.getString("userAvatar") ?? "null";
    String name = pref.getString("name") ?? "null";
    print("userAvatar: $userAvatar\nname: $name");
  } catch (e) {
    print(e);
  }
}

Future<String> initPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  return version;
}

void main() {
  runApp(new MyApp());
  // 设为仅竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}

/// app的根组件
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _titleOffset = 0.0;
    bool _centerTitle = true;
    double bubbleWidth = 30.0;
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
          home: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 9, 186, 7),
                  title: Transform(
                    child: Text(
                      "桂电畅行证",
                      style: TextStyle(
                        fontFamily: "PingFangSC",
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    transform:
                        Matrix4.translationValues(_titleOffset, 0.0, 0.0),
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
                            minimumSize: Size(bubbleWidth, bubbleWidth),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    SizedBox(
                      height: bubbleWidth,
                      child: Center(
                        child: Builder(
                          builder: (context) => OutlinedButton(
                            // 右上角图标
                            child: TopRightIconsImage(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 7, 158, 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              padding: EdgeInsets.all(5),
                              minimumSize: Size(90, bubbleWidth),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                  elevation: 0,
                  toolbarHeight: 50,
                ),
                body: HomeContent(),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: BottomBar(),
              )
            ],
          )),
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
  late SharedPreferences pref;

  final String addToHomepageImageUrl =
      "https://i.loli.net/2021/09/23/qLX2RwNy4WBgzS8.png";
  final String showUseGuideImg =
      "https://i.loli.net/2021/09/25/sjYc26oa8VdRf5F.jpg";

  Future<void> initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  void showGuide(BuildContext globalContext) {
    void _showAddToHomepageGuide(Function() onFinished) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return IntroImage(
            imgUrl: addToHomepageImageUrl,
            onFinished: () {
              print("_showAddToHomepageGuide onFinished");
              Navigator.pop(context);
              onFinished();
            },
            onSkip: () {
              Navigator.pop(context);
            },
          );
        },
      );
    }

    void _showUseGuide() {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            // TODO 使用assets中图片
            return IntroImage(
              imgUrl: kIsWeb ? showUseGuideImg : "assets/images/tutorial.jpg",
              onFinished: () {
                print("_showUseGuide onFinished");
                Navigator.pop(context);
                pref.setBool("isSkipGuide", true);
              },
              onSkip: () {
                Navigator.pop(context);
              },
              nextText: "不再提示",
            );
          });
    }

    //pref.setBool("isSkipGuide", false);
    bool? isSkipGuide = pref.getBool("isSkipGuide");
    print("isSkipGuide: $isSkipGuide");
    if (isSkipGuide == null || isSkipGuide == false) {
      if (kIsWeb) {
        _showAddToHomepageGuide(_showUseGuide);
      } else {
        _showUseGuide();
      }
    }
  }

  void checkForUpdate() async {
    debugPrint("Check for update");
    String currentVersion = await initPackageInfo();
    await Dio()
        .get(
      "https://gitee.com/api/v5/repos/guetcard/guetcard/releases/latest",
    )
        .then((value) async {
      debugPrint("Checking updates: $value.data");
      Map<String, dynamic> map = value.data;
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
          Map<String, dynamic> updateInfo = {
            "ipaUrl": null,
            "versionName": null,
            "description": null,
          };
          updateInfo['ipaUrl'] = "https://gitee.com/guetcard/guetcard/releases";
          updateInfo['versionName'] = map["tag_name"];
          updateInfo['description'] = map["body"];
          showIOSDialog(context, updateInfo);
        }
      }
    }).onError((error, stackTrace) {
      ProgressHud.showErrorAndDismiss(text: "获取更新失败");
    });
  }

  @override
  void initState() {
    super.initState();
    this.initPref().then((value) => this.showGuide(globalContext));
    if (!kIsWeb) {
      Future.delayed(Duration(seconds: 5), this.checkForUpdate);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 预加载两张教程图片
    precacheImage(NetworkImage(addToHomepageImageUrl), context);
    precacheImage(NetworkImage(showUseGuideImg), context);
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    final size = MediaQuery.of(context).size;

    return Container(
      child: ListView(
        children: <Widget>[
          CheckPointView(),
          Container(
            height: 25,
            decoration: BoxDecoration(color: Color.fromARGB(255, 9, 186, 7)),
          ),
          Container(
            // 1180/1064 是二维码图片的长宽比
            height: 1180 / 1064 * size.width + 670,
            decoration:
                BoxDecoration(color: Color.fromARGB(255, 242, 242, 242)),
            child: CardView(
              screenWidth: size.width,
            ),
            alignment: Alignment.topCenter,
          ),
        ],
        physics: BouncingScrollPhysics(),
      ),
      color: Colors.black, //Color.fromARGB(255, 9, 186, 7),
    );
  }
}

/// 左上角图标
class TopLeftIconImage extends StatelessWidget {
  const TopLeftIconImage({Key? key}) : super(key: key);
  static const _height = 20.0;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/TopLeftIcon.png",
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
    return Image.asset(
      "assets/images/TopRightIcon.png",
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
                  title: const Text(
                    '请选择扫码点',
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                    ),
                  ),
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
        child: Transform(
          transform: Matrix4.translationValues(0.0, -8.0, 0.0),
          child: Text(
            _checkPointName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "PingFangSC-Bold",
              fontSize: 20,
              color: Colors.white,
            ),
            maxLines: 1,
          ),
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
  late final String name;

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
        child: Text(
          name,
          style: TextStyle(
            fontFamily: "PingFangSC",
          ),
        ),
      ),
    );
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
                fontFamily: "PingFangSC",
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(145, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
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
                fontFamily: "PingFangSC",
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(145, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
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
                        fontFamily: "PingFangSC",
                        fontSize: 16.0,
                        color: Color(0xff555555),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Text(
                    updateInfo["description"],
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          child: Text(
                            "下次再说",
                            style: TextStyle(
                              fontFamily: "PingFangSC",
                              color: Color(0xffffbb5b),
                              fontSize: 18.0,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(), //关闭对话框
                        ),
                        TextButton(
                          child: Text(
                            "立即前往",
                            style: TextStyle(
                              fontFamily: "PingFangSC",
                              color: Color(0xffffbb5b),
                              fontSize: 18.0,
                            ),
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
              ),
            ),
          ),
        ],
      );
    },
  );
}

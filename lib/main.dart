import 'dart:io';
import 'dart:ui';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:card_swiper/card_swiper.dart';
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
    return ProgressHud(
      isGlobalHud: true,
      child: MaterialApp(
        title: '桂电畅行证',
        theme: ThemeData(
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(
              fontFamily: "PingFangSC",
              color: Colors.white,
            ),
          ),
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        home: Scaffold(
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
  static BuildContext? globalContext;

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late SharedPreferences pref;

  final String addToHomepageImageUrl = "assets/images/AddToHomepageImage.png";
  final String showUseGuideImgUrl = "assets/images/Tutorial.jpg";

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
            return IntroImage(
              imgUrl: showUseGuideImgUrl,
              onFinished: () {
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
    this
        .initPref()
        .then((value) => this.showGuide(HomeContent.globalContext ?? context));
    if (!kIsWeb) {
      Future.delayed(Duration(seconds: 5), this.checkForUpdate);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 预加载两张教程图片
    precacheImage(AssetImage(addToHomepageImageUrl), context);
    precacheImage(AssetImage(showUseGuideImgUrl), context);
  }

  @override
  Widget build(BuildContext context) {
    HomeContent.globalContext = context;
    final size = MediaQuery.of(context).size;
    // 模仿原版畅行码下方布局错位的空白
    double buggyPadding = size.height * 0.1;
    return Stack(
      children: [
        CheckPointImageView(),
        TopRightButton(),
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height:
                    size.height - (315 / 1125) * size.width - 55 - buggyPadding,
                child: CardView(
                  screenWidth: size.width,
                ),
              ),
              SizedBox(
                height: buggyPadding,
              ),
            ],
          ),
          alignment: Alignment.bottomCenter,
        ),
      ],
    );
  }
}

// 检查点照片组件
class CheckPointImageView extends StatefulWidget {
  const CheckPointImageView({Key? key}) : super(key: key);

  @override
  _CheckPointImageViewState createState() => _CheckPointImageViewState();
}

class _CheckPointImageViewState extends State<CheckPointImageView> {
  final List<String> checkPointImgList = [
    "assets/images/huajiang.png",
    "assets/images/houjie.png",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var img in checkPointImgList) {
      precacheImage(AssetImage(img), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
        height: 450 / 1125 * MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Image.asset(
              checkPointImgList[index],
              fit: BoxFit.fill,
            );
          },
          itemCount: checkPointImgList.length,
          onTap: (int index) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('左右滑动切换图片'),
              ),
            );
          },
        ),
      ),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: Color.fromARGB(255, 242, 242, 242)),
    );
  }
}

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AboutPage(),
              ),
            );
          },
          child: Image.asset(
            "assets/images/TopRightIcon.png",
            height: _height,
          ),
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

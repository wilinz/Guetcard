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
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

bool isInDebug = false;

const String avatarListUrl = kIsWeb
    ? "https://guet-card.web.app/avatar_list.txt"
    : "https://gitee.com/guetcard/guetcard/raw/master/avatar_list.txt";

List<String> avatarList = [];

const MaterialColor DarkGreen = const MaterialColor(
  0xff103000,
  // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
  const <int, Color>{
    50: const Color(0xff28451a), //10%
    100: const Color(0xff405933), //20%
    200: const Color(0xff586e4d), //30%
    300: const Color(0xff708366), //40%
    400: const Color(0xff889880), //50%
    500: const Color(0xff9fac99), //60%
    600: const Color(0xffb7c1b3), //70%
    700: const Color(0xffcfd6cc), //80%
    800: const Color(0xffe7eae6), //90%
    900: const Color(0xffffffff), //100%
  },
);

const networkImages = {
  "goldenEdge": "https://i.loli.net/2021/09/30/24CyHckp91Smxrv.png",
  "addToHomepageImage": "https://i.loli.net/2021/09/30/NScER3mYyIl51kr.png",
  "showUseGuideImg": "https://i.loli.net/2021/09/30/3Ld6ra9PS2qNpKU.jpg",
  "huajiang": "https://i.loli.net/2021/09/30/x3bjHMiV8Gn92FE.png",
  "houjie": "https://i.loli.net/2021/09/30/3GZELtMsblgTnvp.png",
  "defaultAvatar": "https://i.loli.net/2021/09/30/aiZBNsvUK3h6JIP.png",
};

void printPref() async {
  var pref = await SharedPreferences.getInstance();
  try {
    debugPrint("User preferences:");
    String? userAvatar = pref.getString("userAvatar");
    String? name = pref.getString("name");
    bool? skipGuide = pref.getBool("isSkipGuide");
    debugPrint("userAvatar: $userAvatar\nname: $name\nisSkipGuide: $skipGuide");
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<String> initPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  return version;
}

void main() {
  bool _determineDebugMode() {
    isInDebug = true;
    return true;
  }

  assert(_determineDebugMode());
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
    if (isInDebug) {
      printPref();
    }
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
            primarySwatch: DarkGreen,
            brightness: Brightness.light,
            // 设定目标平台为 iOS 以启用右滑返回手势
            platform: TargetPlatform.iOS),
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
  late SharedPreferences _pref;

  final String _addToHomepageImageUrl = networkImages["addToHomepageImage"]!;
  final String _showUseGuideImgUrl =
      kIsWeb ? networkImages["showUseGuideImg"]! : "assets/images/Tutorial.jpg";

  Future<void> _initPref() async {
    _pref = await SharedPreferences.getInstance();
  }

  void _showGuide(BuildContext globalContext) {
    void _showAddToHomepageGuide(Function() onFinished) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return IntroImage(
            imgUrl: _addToHomepageImageUrl,
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
              imgUrl: _showUseGuideImgUrl,
              onFinished: () {
                Navigator.pop(context);
                _pref.setBool("isSkipGuide", true);
              },
              onSkip: () {
                Navigator.pop(context);
              },
              nextText: "不再提示",
            );
          });
    }

    bool? isSkipGuide = _pref.getBool("isSkipGuide");
    if (isSkipGuide == null || isSkipGuide == false) {
      if (kIsWeb) {
        _showAddToHomepageGuide(_showUseGuide);
      } else {
        _showUseGuide();
      }
    }
  }

  Future<void> _showIOSDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
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
                            onPressed: () =>
                                Navigator.of(context).pop(), //关闭对话框
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

  void _checkForUpdate() async {
    String currentVersion = await initPackageInfo();
    await Dio()
        .get(
      "https://gitee.com/api/v5/repos/guetcard/guetcard/releases/latest",
    )
        .then((value) async {
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
          _showIOSDialog(context, updateInfo);
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
        ._initPref()
        .then((value) => this._showGuide(HomeContent.globalContext ?? context));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!kIsWeb) {
        this._checkForUpdate();
      }
      // 预缓存头像列表和头像图片
      Dio().get(avatarListUrl).then((value) {
        var list = value.toString().split('\n');
        for (String line in list) {
          avatarList.add(line);
        }
        for (var img in avatarList) {
          precacheImage(
            NetworkImage(img),
            context,
          ).onError((error, stackTrace) {
            precacheImage(NetworkImage(img), context);
          });
        }
      }).onError((error, stackTrace) {
        debugPrint("头像列表下载失败:");
        debugPrint("error: $error");
        ProgressHud.showErrorAndDismiss(text: "头像列表下载失败");
      });
    });
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
  final List<String> checkPointImgList = kIsWeb
      ? [
          networkImages["huajiang"]!,
          networkImages["houjie"]!,
        ]
      : [
          "assets/images/huajiang.png",
          "assets/images/houjie.png",
        ];

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
            if (kIsWeb) {
              return FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: checkPointImgList[index],
                fit: BoxFit.fill,
              );
            }
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

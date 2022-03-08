import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/Const.dart';
import 'package:guet_card/pages/HomePage/widgets/AntiScamCard.dart';
import 'package:guet_card/pages/HomePage/widgets/CovidTestCard.dart';
import 'package:guet_card/pages/HomePage/widgets/LocationHistoryCard.dart';
import 'package:guet_card/pages/HomePage/widgets/Passport.dart';
import 'package:guet_card/public-widgets/BackgroundPainter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Routes.dart';
import '../../main.dart';
import '../../public-widgets/CheckingUpdate.dart';
import '../../public-widgets/IntroImage.dart';
import '../../pages/HomePage/widgets/Avatar.dart';
import '../../pages/HomePage/widgets/CheckPointImage.dart';
import '../../pages/HomePage/widgets/Clock.dart';
import '../../pages/HomePage/widgets/QrHealthCard.dart';
import '../../pages/HomePage/widgets/Name.dart';
import '../../pages/HomePage/widgets/TopRightButton.dart';

/// app的根组件
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: MaterialApp(
        title: '桂电畅行证',
        routes: Routes.routes,
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
      ),
    );
  }
}

/// 主界面内容
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);
  static BuildContext? globalContext;

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late SharedPreferences _pref;

  final String _addToHomepageImageUrl =
      Const.networkImages["addToHomepageImage"]!;
  final String _showUseGuideImgUrl = kIsWeb
      ? Const.networkImages["showUseGuideImg"]!
      : "assets/images/Tutorial.jpg";

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
              Navigator.of(context).pop();
              onFinished();
            },
            onSkip: () {
              Navigator.of(context).pop();
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
                Navigator.of(context).pop();
                _pref.setBool("isSkipGuide", true);
              },
              onSkip: () {
                Navigator.of(context).pop();
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

  void _showAnnouncement({enabled = false}) {
    if (enabled) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("公告"),
            content: Text("""
二维码不能用来通过闸机，不要犯傻！
-----------------
由于市区疫情严峻，希望能与你约定以下几点：
1. 如无必要，请勿离校
2. 遵守防疫规定，保持安全距离
3. 无论在校还是出市区，一旦离开住处就佩戴好口罩
4. 不要滥用本应用，离市或出省必须向辅导员报备请假
5. 有机会且身体允许的情况下，请注射疫苗
"""),
            actions: <Widget>[
              TextButton(
                child: Text("我会遵守约定的！"),
                onPressed: () => Navigator.of(context).pop(), //关闭对话框
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    this
        ._initPref()
        .then((value) => this._showGuide(HomeContent.globalContext ?? context))
        .then((value) => this._showAnnouncement(enabled: false));

    // addPostFrameCallback 是StatefulWidget 渲染结束的回调，只会被调用一次，
    // 之后StatefulWidget 需要刷新UI 也不会被调用
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (kIsWeb) {
        Const.networkImages.forEach((key, value) {
          precacheImage(NetworkImage(value), context);
        });
      } else {
        CheckingUpdate _checkingUpdate = CheckingUpdate();
        _checkingUpdate.checkForUpdate(context);
      }
      // 启动一秒后开始预缓存头像列表和头像图片
      Future.delayed(Duration(seconds: 1), () {
        Dio().get(Const.avatarListUrl).then((value) {
          if (avatarList.length == 0) {
            var list = value.toString().split('\n');
            for (String line in list) {
              if (line.length > 0 && line.startsWith("http")) {
                avatarList.add(line);
              }
            }
            for (var img in avatarList.sublist(0, 20)) {
              precacheImage(NetworkImage(img), context);
            }
          }
        }).onError((error, stackTrace) {
          debugPrint("头像列表下载失败:");
          debugPrint("error: $error");
          ProgressHud.showErrorAndDismiss(text: "头像列表下载失败");
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    HomeContent.globalContext = context;
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          color: Color.fromARGB(255, 242, 242, 242),
        ),
        CustomPaint(
          size: size,
          painter: BackgroundPainter(),
        ),
        CheckPointImageView(),
        TopRightButton(),
        Container(
          margin: EdgeInsets.fromLTRB(15, 120, 15, 0),
          alignment: Alignment.bottomCenter,
          child: ListView(
            padding: EdgeInsets.zero, // 忽略 SafeArea
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    )),
                child: Column(
                  children: [
                    Clock(),
                    SizedBox(
                      height: 30,
                    ),
                    Avatar(),
                    Name(),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CovidTestCard(),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: LocationHistoryCard(),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              AntiScamCard(),
              SizedBox(
                height: 15,
              ),
              QrHealthCard(),
              SizedBox(
                height: 15,
              ),
              Passport(),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

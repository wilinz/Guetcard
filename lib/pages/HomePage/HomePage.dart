import 'dart:async';

import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Routes.dart';
import '../../main.dart';
import '../../Const.dart';
import '../../pages/HomePage/widgets/AntiScamCard.dart';
import '../../pages/HomePage/widgets/BottomBar.dart';
import '../../pages/HomePage/widgets/CovidTestCard.dart';
import '../../pages/HomePage/widgets/LocationHistoryCard.dart';
import '../../pages/HomePage/widgets/Passport.dart';
import '../../CustomPainters/BackgroundPainter.dart';
import '../../public-classes/WebJSMethods.dart';
import '../../public-widgets/CheckingUpdate.dart';
import '../../public-widgets/IntroImage.dart';
import '../../pages/HomePage/widgets/Avatar.dart';
import '../../pages/HomePage/widgets/CheckPointImage.dart';
import '../../pages/HomePage/widgets/Clock.dart';
import '../../pages/HomePage/widgets/QrHealthCard.dart';
import '../../pages/HomePage/widgets/Name.dart';
import '../../pages/HomePage/widgets/TopRightButton.dart';
import '../../public-widgets/BlackCornerRadius.dart';

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
          primarySwatch: Const.Black,
          brightness: Brightness.light,
          platform: TargetPlatform.iOS,  // 设定目标平台为 iOS 以启用右滑返回手势
        ),
      ),
    );
  }
}

/// 主界面内容
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

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

  void _showGuide(BuildContext context) {
    void _showAddToHomepageGuide(Function() callback) {
      if (WebJSMethods.isPwaInstalled() == true) {
        callback();
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return IntroImage(
            imgUrl: _addToHomepageImageUrl,
            onFinished: () {
              Navigator.of(context).pop();
              callback();
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

  void _showAnnouncement({required text, title = "公告", enabled = false}) {
    if (enabled) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: Text("好的"),
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
        .then((value) => this._showGuide(context))
        .then((value) => this._showAnnouncement(text: "", enabled: false));

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
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        // 强制将系统状态栏设置为亮色
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BackgroundPainter(),
              willChange: false,
              isComplex: true,
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
                        // Clock(),
                        SizedBox(height: 90),
                        Avatar(),
                        Name(),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: CovidTestCard(),  // 核酸检测卡片
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: LocationHistoryCard(),  // 行程卡卡片
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  AntiScamCard(), // 反诈中心卡片
                  SizedBox(height: 15),
                  QrHealthCard(),  // 健康码卡片
                  SizedBox(height: 15),
                  Passport(),  // 底部临时通行证卡片
                  SizedBox(height: 15),
                ],
              ),
            ),
            Container(
              // 让时钟覆盖于其他层上方
              margin: EdgeInsets.fromLTRB(15, 120, 15, 0),
              alignment: Alignment.topCenter,
              child: Clock(),
            ),
            BlackCornerRadius(),  // iPhone网页版上方的黑色圆角，非网页不生效
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}

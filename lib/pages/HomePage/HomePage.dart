import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guet_card/Global.dart';
import 'package:guet_card/Routes.dart';
import 'package:guet_card/pages/HomePage/widgets/AntiScamCard.dart';
import 'package:guet_card/pages/HomePage/widgets/AppTitle.dart';
import 'package:guet_card/pages/HomePage/widgets/Avatar.dart';
import 'package:guet_card/pages/HomePage/widgets/BackgroundStripe.dart';
import 'package:guet_card/pages/HomePage/widgets/BottomBar.dart';
import 'package:guet_card/pages/HomePage/widgets/CheckPointImage.dart';
import 'package:guet_card/pages/HomePage/widgets/Clock.dart';
import 'package:guet_card/pages/HomePage/widgets/EntryPermit.dart';
import 'package:guet_card/pages/HomePage/widgets/Name.dart';
import 'package:guet_card/pages/HomePage/widgets/Passport.dart';
import 'package:guet_card/pages/HomePage/widgets/TopRightButton.dart';
import 'package:guet_card/public-classes/CheckingUpdate.dart';
import 'package:guet_card/public-classes/WebJSMethods.dart';
import 'package:guet_card/public-widgets/BlackCornerRadius.dart';
import 'package:guet_card/public-widgets/IntroImage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          primarySwatch: Global.black,
          brightness: Brightness.light,
          platform: TargetPlatform.iOS, // 设定目标平台为 iOS 以启用右滑返回手势
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

  final String _addToHomepageImageUrl = Global.networkImages["addToHomepageImage"]!;
  final String _showUseGuideImgUrl =
      kIsWeb ? Global.networkImages["showUseGuideImg"]! : Global.assetImages["showUseGuideImg"]!;

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
    SharedPreferences.getInstance().then((pref) {
      _pref = pref;
      this._showGuide(context);
    });

    // addPostFrameCallback 是StatefulWidget 渲染结束的回调，只会被调用一次，
    // 之后StatefulWidget 需要刷新UI 也不会被调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        Global.networkImages.forEach((key, value) {
          precacheImage(NetworkImage(value), context);
        });
      } else {
        CheckingUpdate.checkForUpdate(context);
      }
      // 启动一秒后开始预缓存头像列表和头像图片
      // Future.delayed(Duration(seconds: 1), () {
      //   Dio().get(Const.avatarListUrl).then((value) {
      //     if (avatarList.length == 0) {
      //       var list = value.toString().split('\n');
      //       for (String line in list) {
      //         if (line.length > 0 && line.startsWith("http")) {
      //           avatarList.add(line);
      //         }
      //       }
      //       for (var img in avatarList.sublist(0, 20)) {
      //         precacheImage(NetworkImage(img), context);
      //       }
      //     }
      //   }).onError((error, stackTrace) {
      //     debugPrint("头像列表下载失败:");
      //     debugPrint("error: $error");
      //     ProgressHud.showErrorAndDismiss(text: "头像列表下载失败");
      //   });
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            fontFamily: "PingFangSC",
            color: Colors.white,
          ),
        ),
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        platform: TargetPlatform.iOS, // 设定目标平台为 iOS 以启用右滑返回手势
      ),
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          // 强制将系统状态栏设置为亮色
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              BackgroundStripe(),
              CheckPointImageView(),
              AppTitle(),
              TopRightButton(),
              Container(
                margin: EdgeInsets.fromLTRB(15, MediaQuery.of(context).size.width * 0.28, 15, 0),
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
                        ),
                      ),
                      child: Column(
                        children: [
                          // Clock(),
                          SizedBox(height: 50),
                          EntryPermit(),
                          Avatar(),
                          Name(),
                        ],
                      ),
                    ),
                    // SizedBox(height: 15),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Expanded(
                    //       child: CovidTestCard(), // 核酸检测卡片
                    //     ),
                    //     SizedBox(width: 15),
                    //     Expanded(
                    //       child: LocationHistoryCard(), // 行程卡卡片
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 15),
                    AntiScamCard(), // 反诈中心卡片
                    SizedBox(height: 15),
                    // QrHealthCard(),  // 健康码卡片
                    // SizedBox(height: 15),
                    Passport(), // 底部临时通行证卡片
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Container(
                // 让时钟覆盖于其他层上方
                margin: EdgeInsets.fromLTRB(15, MediaQuery.of(context).size.width * 0.28, 15, 0),
                alignment: Alignment.topCenter,
                child: Clock(),
              ),
              BlackCornerRadius(), // iPhone网页版上方的黑色圆角，非网页不生效
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
}

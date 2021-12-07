import 'dart:ui';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guet_card/AboutPage.dart';
import 'package:guet_card/CardView.dart';
import 'package:guet_card/CheckingUpdate.dart';
import 'package:guet_card/IntroImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

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
  "goldenEdge": "https://s2.loli.net/2021/12/07/Nc2WXifen68VZgI.png",
  "addToHomepageImage": "https://i.loli.net/2021/10/14/brJmpNK6nRYBxit.png",
  "showUseGuideImg": "https://s2.loli.net/2021/12/07/7TDvcfGIWzJkX5d.jpg",
  "huajiang": "https://i.loli.net/2021/09/30/x3bjHMiV8Gn92FE.png",
  "houjie": "https://i.loli.net/2021/09/30/3GZELtMsblgTnvp.png",
  "defaultAvatar": "https://i.loli.net/2021/09/30/aiZBNsvUK3h6JIP.png",
  "doneInjection": "https://s2.loli.net/2021/12/07/TrkEJ3VpimfAeHC.png",
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

  void _showAnnouncement() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("公告"),
            content: Text("""由于市区疫情严峻，希望能与你约定以下几点：
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
        });
  }

  @override
  void initState() {
    super.initState();
    this
        ._initPref()
        .then((value) => this._showGuide(HomeContent.globalContext ?? context))
        .then((value) => this._showAnnouncement());
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!kIsWeb) {
        CheckingUpdate _checkingUpdate = CheckingUpdate();
        _checkingUpdate.checkForUpdate(context);
      }
      // 启动一秒后开始预缓存头像列表和头像图片
      Future.delayed(Duration(seconds: 1), () {
        Dio().get(avatarListUrl).then((value) {
          if (avatarList.length == 0) {
            var list = value.toString().split('\n');
            for (String line in list) {
              if (line.length > 0 && line.startsWith("http")) {
                avatarList.add(line);
              }
            }
            for (var img in avatarList) {
              precacheImage(
                NetworkImage(img),
                context,
              );
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
    // 模仿原版畅行码下方布局错位的空白
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
                height: size.height - (315 / 1125) * size.width - 55,
                child: CardView(
                  screenWidth: size.width,
                ),
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
  final String checkPointImg =
      kIsWeb ? networkImages["houjie"]! : "assets/images/houjie.png";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Container(
          height: 450 / 1125 * MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: Builder(builder: (context) {
            if (kIsWeb) {
              return FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: checkPointImg,
                fit: BoxFit.fill,
              );
            }
            return Image.asset(
              checkPointImg,
              fit: BoxFit.fill,
            );
          })),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Global {
  static String? version;
  static const networkImages = {
    "goldenEdge": "https://s4.ax1x.com/2021/12/07/ogrOKO.png",
    "addToHomepageImage": "https://s4.ax1x.com/2021/12/07/ogrXrD.png",
    "showUseGuideImg": "https://s1.ax1x.com/2022/03/12/bTN526.jpg",
    "jinjiling": "https://s1.ax1x.com/2022/03/07/b6nveP.png",
    "huajiang": "https://s1.ax1x.com/2022/03/22/qMEF3R.png",
    "houjie": "https://s4.ax1x.com/2021/12/07/ogr7P1.jpg",
    "dongqu": "https://s1.ax1x.com/2022/03/07/b6uCWQ.png",
    "defaultAvatar": "https://s4.ax1x.com/2021/12/07/ogro5R.png",
    "doneInjection": "https://s4.ax1x.com/2021/12/07/ogrH8x.png",
    "topRightIcon": "https://s4.ax1x.com/2021/12/07/ogrqxK.png",
    "test-tube": "https://s1.ax1x.com/2022/03/08/bguiyd.png",
    "location-history": "https://s1.ax1x.com/2022/03/08/bgBmtO.png",
  };

  static const assetImages = {
    "goldenEdge": "assets/images/GoldenEdge.png",
    "showUseGuideImg": "assets/images/Tutorial.jpg",
    "jinjiling": "assets/images/jinjiling.png",
    "huajiang": "assets/images/huajiang.png",
    "houjie": "assets/images/houjie.jpg",
    "dongqu": "assets/images/dongqu.png",
    "defaultAvatar": "assets/images/DefaultAvatar.png",
    "doneInjection": "assets/images/DoneInjection.png",
    "topRightIcon": "assets/images/TopRightIcon.png",
    "test-tube": "assets/images/test-tube.png",
    "location-history": "assets/images/location-history.png",
  };

  static const String avatarListUrl =
      kIsWeb ? "/avatar_list.txt" : "https://gitee.com/guetcard/guetcard/raw/master/avatar_list.txt";

  static const MaterialColor black = const MaterialColor(0xff000000, const <int, Color>{
    50: const Color(0xff000000), //10%
    100: const Color(0xff000000), //20%
    200: const Color(0xff000000), //30%
    300: const Color(0xff000000), //40%
    400: const Color(0xff000000), //50%
    500: const Color(0xff000000), //60%
    600: const Color(0xff000000), //70%
    700: const Color(0xff000000), //80%
    800: const Color(0xff000000), //90%
    900: const Color(0xff000000), //100%
  });

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
}

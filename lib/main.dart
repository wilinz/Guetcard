import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guet_card/Global.dart';
import 'package:guet_card/Providers/UsernameProvider.dart';
import 'package:guet_card/Utils/CheckingUpdate.dart';
import 'package:guet_card/Utils/LogUtil.dart';
import 'package:guet_card/firebase_options.dart';
import 'package:guet_card/pages/HomePage/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> avatarList = [];

void printPref() async {
  const currentMode = kDebugMode ? "debug" : (kProfileMode ? "profile" : "release");
  if (currentMode == "debug") {
    var pref = await SharedPreferences.getInstance();
    try {
      String? userAvatar = pref.getString("userAvatar");
      String? name = pref.getString("name");
      bool? skipGuide = pref.getBool("isSkipGuide");
      LogUtil.info(message: "userAvatar: $userAvatar\nname: $name\nisSkipGuide: $skipGuide");
    } catch (error, stackTrace) {
      LogUtil.error(message: '读取 SharedPref 出错', error: error, stackTrace: stackTrace);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics.instance.logAppOpen();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => UsernameProvider(""))],
    child: HomePage(),
  ));
  printPref();
  // 设为仅竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  if (!kIsWeb) CheckingUpdate.initPackageInfo().then((version) => Global.version = version);
  if (!kIsWeb && Platform.isAndroid) {
    Global.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    Global.flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }
}

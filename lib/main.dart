import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/HomePage/HomePage.dart';
import 'public-classes/UsernameModel.dart';

import 'public-classes/WebJSMethods.dart';


List<String> avatarList = [];





void printPref() async {
  const currentMode =
      kDebugMode ? "debug" : (kProfileMode ? "profile" : "release");
  if (currentMode == "debug") {
    var pref = await SharedPreferences.getInstance();
    try {
      debugPrint("User preferences:");
      String? userAvatar = pref.getString("userAvatar");
      String? name = pref.getString("name");
      bool? skipGuide = pref.getBool("isSkipGuide");
      debugPrint(
          "userAvatar: $userAvatar\nname: $name\nisSkipGuide: $skipGuide");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsernameModel(""))
      ],
      child: HomePage(),
    )
  );
  printPref();
  // 设为仅竖屏模式
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}


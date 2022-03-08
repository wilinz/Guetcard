import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guet_card/UsernameModel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guet_card/pages/HomePage/HomePage.dart';




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


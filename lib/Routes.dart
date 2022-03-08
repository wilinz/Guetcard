import 'package:flutter/material.dart';
import 'pages/AboutPage/AboutPage.dart';
import 'pages/ChangeAvatarPage/ChangeAvatarPage.dart';
import 'pages/CropAvatarPage/CropAvatarPage.dart';
import 'pages/HomePage/HomePage.dart';
import 'pages/HomePage/widgets/BottomBar.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
      "/": (context) => Scaffold(
        body: HomeContent(),
        bottomNavigationBar: BottomBar(),
      ),
      "about": (context) => AboutPage(),
      "cropAvatarPage": (context) => CropAvatarPage(),
      "changeAvatarPage": (context) => ChangeAvatarPage(),
  };
}
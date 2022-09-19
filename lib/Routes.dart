import 'package:flutter/material.dart';

import 'pages/AboutPage/AboutPage.dart';
import 'pages/ChangeAvatarPage/ChangeAvatarPage.dart';
import 'pages/CropAvatarPage/CropAvatarPage.dart';
import 'pages/HomePage/HomePage.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routes = {
    "/": (context) => HomeContent(),
    "about": (context) => Theme(
          data: ThemeData(
            primarySwatch: Colors.green,
          ),
          child: AboutPage(),
        ),
    "cropAvatarPage": (context) => Theme(
          data: ThemeData(
            primarySwatch: Colors.green,
          ),
          child: CropAvatarPage(),
        ),
    "changeAvatarPage": (context) => Theme(
          data: ThemeData(
            primarySwatch: Colors.green,
          ),
          child: ChangeAvatarPage(),
        ),
  };
}

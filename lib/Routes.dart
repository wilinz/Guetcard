import 'package:flutter/material.dart';
import 'package:guet_card/pages/AboutPage/AboutPage.dart';
import 'package:guet_card/pages/ChangeAvatarPage/ChangeAvatarPage.dart';
import 'package:guet_card/pages/CropAvatarPage/CropAvatarPage.dart';
import 'package:guet_card/pages/HomePage/HomePage.dart';

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

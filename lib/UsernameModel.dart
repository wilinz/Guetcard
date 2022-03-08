import 'package:flutter/material.dart';

class UsernameModel with ChangeNotifier {
  String _username;
  UsernameModel(this._username);

  set username(String name) {
    _username = name.characters.first;
    notifyListeners();
  }
  String get username => _username;

  /// setter 方法的别名
  void setUsername(String name) {
    this.username = name;
  }
}
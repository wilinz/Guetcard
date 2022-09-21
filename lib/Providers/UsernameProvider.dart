import 'package:flutter/material.dart';

class UsernameProvider with ChangeNotifier {
  String _username;
  UsernameProvider(this._username);

  set username(String name) {
    _username = (name.length > 0) ? name.characters.first : "";
    notifyListeners();
  }

  String get username => _username;

  /// setter 方法的别名
  void setUsername(String name) {
    this.username = name;
  }
}

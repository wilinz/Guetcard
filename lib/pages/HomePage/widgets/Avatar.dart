import 'dart:io';

import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:guet_card/Global.dart';
import 'package:guet_card/public-widgets/WebImageWithIndicator.dart';

/// 头像组件，负责调用切换头像的页面及更换头像功能
class Avatar extends StatefulWidget {
  const Avatar({Key? key}) : super(key: key);

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final String _defaultAvatar = kIsWeb ? Global.networkImages['defaultAvatar']! : Global.assetImages['defaultAvatar']!;
  late String _avatarPath;
  final _width = 90.0;

  _AvatarState() {
    _avatarPath = _defaultAvatar;
  }

  /// 从 SharedPreferences 加载用户自定义头像
  void _loadUserAvatar() async {
    if (kIsWeb) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? avatarUrl = pref.getString("userAvatar");
      if (avatarUrl != null) {
        if (mounted) {
          setState(() {
            _avatarPath = avatarUrl;
          });
        }
      }
    } else {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var doc = await getApplicationDocumentsDirectory();
      String? avatarFileName = pref.getString("userAvatar");
      if (avatarFileName != null) {
        if (avatarFileName.startsWith("http")) {
          if (mounted) {
            setState(() {
              _avatarPath = avatarFileName;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _avatarPath = "${doc.path}/$avatarFileName";
            });
          }
        }
      }
    }
  }

  /// 从磁盘中删除此前的旧头像
  void _deletePreviousAvatar(String lastAvatarPath) async {
    if (!lastAvatarPath.startsWith("http")) {
      File lastAvatar = File(lastAvatarPath);
      try {
        lastAvatar.deleteSync();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  /// 将用户自定义头像的路径（或url）保存到 SharedPreferences 中
  void _saveUserAvatar(String path) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("userAvatar", path);
  }

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> sheetContent = [];
    if (!kIsWeb) {
      // 添加移动端特有的菜单
      final ImagePicker _imgPicker = ImagePicker();
      sheetContent.add(
        ListTile(
          leading: Icon(Icons.photo_camera),
          title: Text(
            "由相机拍摄",
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
          onTap: () async {
            var imageFile =
                await _imgPicker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
            if (imageFile != null) {
              Navigator.pop(context);
              File _image = File(imageFile.path);
              var result = await Navigator.of(context).pushNamed("cropAvatarPage", arguments: _image);
              if (result != null) {
                var docPath = await getApplicationDocumentsDirectory();
                var pref = await SharedPreferences.getInstance();
                var lastAvatar = pref.getString("userAvatar");
                if (lastAvatar != null && !lastAvatar.startsWith("http")) {
                  _deletePreviousAvatar("${docPath.path}/${pref.getString("userAvatar")}");
                }
                String name = result as String;
                if (mounted) {
                  setState(() {
                    this._avatarPath = "${docPath.path}/$name";
                  });
                }
                _saveUserAvatar(name);
              }
            }
          },
        ),
      );
      sheetContent.add(
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text(
            "从相册导入",
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
          onTap: () async {
            var imageFile = await _imgPicker.pickImage(
              source: ImageSource.gallery,
            );
            if (imageFile != null) {
              Navigator.pop(context);
              File _image = File(imageFile.path);
              var result = await Navigator.of(context).pushNamed("cropAvatarPage", arguments: _image);
              if (result != null) {
                var docPath = await getApplicationDocumentsDirectory();
                var pref = await SharedPreferences.getInstance();
                var lastAvatar = pref.getString("userAvatar");
                if (lastAvatar != null && !lastAvatar.startsWith("http")) {
                  _deletePreviousAvatar("${docPath.path}/${pref.getString("userAvatar")}");
                }
                String name = result as String;
                if (mounted) {
                  setState(() {
                    this._avatarPath = "${docPath.path}/$name";
                  });
                }
                _saveUserAvatar(name);
              }
            }
          },
        ),
      );
    }
    // 添加双端通用的菜单
    sheetContent.add(
      ListTile(
        leading: Icon(Icons.image),
        title: Text("从默认头像中选择",
            style: TextStyle(
              fontFamily: "PingFangSC",
            )),
        onTap: () async {
          Navigator.pop(context);
          String? url = await Navigator.of(context).pushNamed("changeAvatarPage") as String?;
          if (url != null) {
            if (kIsWeb) {
              String path = url;
              if (mounted) {
                setState(() {
                  _avatarPath = path;
                });
              }
              _saveUserAvatar(path);
            } else {
              ProgressHud.showLoading(text: "正在保存...");
              var docPath = await getApplicationDocumentsDirectory();
              var pref = await SharedPreferences.getInstance();
              var lastAvatar = pref.getString("userAvatar");
              var dir = await getApplicationDocumentsDirectory();
              var name = "${Uuid().v4()}";
              var ext = url.toString().split(".").last;
              Dio().download(url, "${dir.path}/$name.$ext").then(
                (value) {
                  if (value.statusCode == 200) {
                    ProgressHud.dismiss();
                    if (lastAvatar != null && !lastAvatar.startsWith("http")) {
                      _deletePreviousAvatar("${docPath.path}/${pref.getString("userAvatar")}");
                    }
                    if (mounted) {
                      setState(() {
                        _avatarPath = "${dir.path}/$name.$ext";
                      });
                    }
                    _saveUserAvatar("$name.$ext");
                  } else {
                    ProgressHud.dismiss();
                    ProgressHud.showErrorAndDismiss(text: "保存失败，请重试");
                  }
                },
                onError: (error, stackTrace) {
                  ProgressHud.dismiss();
                  ProgressHud.showErrorAndDismiss(text: "保存失败，请重试");
                },
              );
            }
          }
        },
      ),
    );
    sheetContent.add(
      ListTile(
        leading: Icon(Icons.api),
        title: Text("随机头像",
            style: TextStyle(
              fontFamily: "PingFangSC",
            )),
        onTap: () async {
          Navigator.pop(context);
          Future<String> getAvatarUrl() async {
            final result = await Dio().get("https://api.vvhan.com/api/avatar?type=json");
            return result.data["avatar"];
          }

          if (kIsWeb) {
            ProgressHud.showLoading(text: "正在加载...");
            Future.delayed(Duration(seconds: 5)).then((value) => ProgressHud.dismiss());
            var url = await getAvatarUrl();
            String path = url;
            if (mounted) {
              setState(() {
                _avatarPath = path;
              });
            }
            _saveUserAvatar(path);
          } else {
            ProgressHud.showLoading(text: "正在保存...");
            var docPath = await getApplicationDocumentsDirectory();
            var pref = await SharedPreferences.getInstance();
            var lastAvatar = pref.getString("userAvatar");
            var url = await getAvatarUrl();
            var dir = await getApplicationDocumentsDirectory();
            var name = "${Uuid().v4()}";
            var ext = url.toString().split(".").last;
            Dio().download(url, "${dir.path}/$name.$ext").then(
              (value) {
                if (value.statusCode == 200) {
                  ProgressHud.dismiss();
                  if (lastAvatar != null && !lastAvatar.startsWith("http")) {
                    _deletePreviousAvatar("${docPath.path}/${pref.getString("userAvatar")}");
                  }
                  if (mounted) {
                    setState(() {
                      _avatarPath = "${dir.path}/$name.$ext";
                    });
                  }
                  _saveUserAvatar("$name.$ext");
                } else {
                  ProgressHud.dismiss();
                  ProgressHud.showErrorAndDismiss(text: "保存失败，请重试");
                }
              },
              onError: (error, stackTrace) {
                ProgressHud.dismiss();
                ProgressHud.showErrorAndDismiss(text: "保存失败，请重试");
              },
            );
          }
        },
      ),
    );
    sheetContent.add(SizedBox(height: 10));

    late var img;
    if (_avatarPath.startsWith("assets")) {
      // 如果路径的开头是 assets 则意味着是从 asset 中加载默认头像
      img = Image.asset(
        _avatarPath,
        width: _width,
      );
    } else if (_avatarPath.startsWith("http")) {
      // 如果路径开头是 http 则意味着是从网络上加载自定义头像
      img = WebImageWithIndicator(
        imgURL: _avatarPath,
        width: _width,
      );
    } else {
      // 否则从应用程序 data 目录中加载自定义头像
      img = Image.file(
        File(_avatarPath),
        width: _width,
      );
    }
    return TextButton(
      onPressed: () async {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: sheetContent,
            );
          },
        );
      },
      child: img,
    );
  }
}

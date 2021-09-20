import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/ChangeAvatarPage.dart';
import 'package:guet_card/CropAvatarPage.dart';
import 'package:guet_card/InputDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

/// 卡片视图，包括时间、头像、二维码等信息以及外面的灰色框框
class CardView extends StatelessWidget {
  final double cardHeight = 880;
  final double cardViewHeight = 840;
  final double screenWidth;

  const CardView({Key key, this.screenWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(color: Color.fromARGB(255, 242, 242, 242)),
        child: OverflowBox(
          child: FractionallySizedBox(
            child: Card(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(2)),
                  TimerView(),
                  AvatarView(),
                  NameView(),
                  SizedBox(height: 20),
                  QrCodeView(),
                  SizedBox(height: 20),
                  PassportView()
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1))),
              elevation: 0,
              color: Colors.white,
            ),
            widthFactor: 0.93,
          ),
          maxHeight: cardHeight,
          alignment: Alignment.bottomCenter,
        ),
      ),
      height: cardViewHeight,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(color: Color.fromARGB(255, 242, 242, 242)),
    );
  }
}

/// 头像图像显示
class AvatarImage extends StatefulWidget {
  String avatarPath;

  AvatarImage(this.avatarPath, {Key key}) : super(key: key);

  @override
  _AvatarImageState createState() => _AvatarImageState(avatarPath);
}

class _AvatarImageState extends State<AvatarImage> {
  String avatarPath;
  static const _width = 90.0;

  _AvatarImageState(this.avatarPath);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        avatarPath,
        width: _width,
      );
    }
    return Image.asset(
      avatarPath,
      width: _width,
    );
  }
}

/// 头像组件，负责调用切换头像的页面及更换头像功能
class AvatarView extends StatefulWidget {
  const AvatarView({Key key}) : super(key: key);

  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  String _avatarPath = "images/default_avatar.jpg";
  static const String _defaultAvatar = "images/default_avatar.jpg";
  static const _width = 90.0;
  Image img;

  /// 从 SharedPreferences 加载用户自定义头像
  loadUserAvatar() async {
    if (kIsWeb) {
      var pref = await SharedPreferences.getInstance();
      var avatarFileName = pref.getString("userAvatar");
      if (avatarFileName != null) {
        setState(() {
          _avatarPath = avatarFileName;
        });
      }
    } else {
      var pref = await SharedPreferences.getInstance();
      var doc = await getApplicationDocumentsDirectory();
      var avatarFileName = pref.getString("userAvatar");
      if (avatarFileName != null) {
        if (!avatarFileName.startsWith("http")) {
          setState(() {
            _avatarPath = "${doc.path}/$avatarFileName";
          });
        } else {
          setState(() {
            _avatarPath = avatarFileName;
          });
        }
      }
    }
  }

  /// 从磁盘中删除此前的旧头像
  deletePreviousAvatar(String lastAvatarPath) async {
    if (lastAvatarPath != null && !(lastAvatarPath.startsWith("http"))) {
      File lastAvatar = File(lastAvatarPath);
      try {
        lastAvatar.deleteSync();
      } catch (e) {
        print(e);
      }
    }
  }

  /// 将用户自定义头像的路径（或url）保存到 SharedPreferences 中
  saveUserAvatar(String path) async {
    var pref = await SharedPreferences.getInstance();
    if (path != null) {
      pref.setString("userAvatar", path);
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _avatarPath = "https://i.loli.net/2021/05/25/x4KC5FtQEkvf9Ob.jpg";
    }
    loadUserAvatar();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // 网页版
      img = Image.network(
        _avatarPath,
        width: _width,
      );
      return TextButton(
        onPressed: () async {
          var url = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChangeAvatarPage()));
          if (url != null) {
            String path = url as String;
            setState(() {
              _avatarPath = path;
            });
            saveUserAvatar(path);
          }
        },
        child: img,
      );
    } else {
      // 移动端
      img;
      if (_avatarPath.startsWith("image")) {
        // 如果路径的开头是 image 则意味着是从 asset 中加载默认头像
        try {
          img = Image.asset(
            _avatarPath,
            width: _width,
          );
        } catch (e) {
          img = Image.asset(
            _defaultAvatar,
            width: _width,
          );
        }
      } else if (_avatarPath.startsWith("http")) {
        // 如果路径开头是 http 则意味着是从网络上加载自定义头像
        try {
          img = Image.network(
            _avatarPath,
            width: _width,
          );
        } catch (e) {
          img = Image.asset(
            _defaultAvatar,
            width: _width,
          );
        }
      } else {
        // 否则从应用程序 data 目录中加载自定义头像
        try {
          img = Image.file(
            File(_avatarPath),
            width: _width,
          );
        } catch (e) {
          img = Image.asset(
            _defaultAvatar,
            width: _width,
          );
        }
      }
      return TextButton(
          onPressed: () async {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_camera),
                        title: Text("由相机拍摄"),
                        onTap: () async {
                          var imageFile = await ImagePicker().getImage(
                              source: ImageSource.camera,
                              preferredCameraDevice: CameraDevice.front);
                          if (imageFile != null) {
                            Navigator.pop(context);
                            File _image = File(imageFile.path);
                            var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CropAvatarPage(_image)));
                            if (result != null) {
                              var docPath =
                                  await getApplicationDocumentsDirectory();
                              var pref = await SharedPreferences.getInstance();
                              var lastAvatar = pref.getString("userAvatar");
                              if (lastAvatar != null &&
                                  !lastAvatar.startsWith("http")) {
                                deletePreviousAvatar(
                                    "${docPath.path}/${pref.getString("userAvatar")}");
                              }
                              String name = result as String;
                              setState(() {
                                if (name != null) {
                                  this._avatarPath = "${docPath.path}/$name";
                                }
                              });
                              saveUserAvatar(name);
                            }
                          } else {
                            debugPrint("未获取到拍摄的照片");
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text("从相册导入"),
                        onTap: () async {
                          var imageFile = await ImagePicker().getImage(
                            source: ImageSource.gallery,
                          );
                          if (imageFile != null) {
                            Navigator.pop(context);
                            File _image = File(imageFile.path);
                            var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CropAvatarPage(_image)));
                            if (result != null) {
                              var docPath =
                                  await getApplicationDocumentsDirectory();
                              var pref = await SharedPreferences.getInstance();
                              var lastAvatar = pref.getString("userAvatar");
                              if (lastAvatar != null &&
                                  !lastAvatar.startsWith("http")) {
                                deletePreviousAvatar(
                                    "${docPath.path}/${pref.getString("userAvatar")}");
                              }
                              String name = result as String;
                              setState(() {
                                if (name != null) {
                                  this._avatarPath = "${docPath.path}/$name";
                                }
                              });
                              saveUserAvatar(name);
                            }
                          } else {
                            print("未获取到选择的图片");
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text("从默认头像中选择"),
                        onTap: () async {
                          var url = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeAvatarPage()));
                          if (url != null) {
                            Navigator.pop(context);
                            var docPath =
                                await getApplicationDocumentsDirectory();
                            var pref = await SharedPreferences.getInstance();
                            var lastAvatar = pref.getString("userAvatar");
                            if (lastAvatar != null &&
                                !lastAvatar.startsWith("http")) {
                              deletePreviousAvatar(
                                  "${docPath.path}/${pref.getString("userAvatar")}");
                            }
                            String path = url as String;
                            setState(() {
                              _avatarPath = path;
                            });
                            saveUserAvatar(path);
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  );
                });
          },
          child: img);
    }
  }
}

/// 二维码视图，最大尺寸为250
class QrCodeView extends StatelessWidget {
  static const double QrCodeSize = 250;

  @override
  Widget build(BuildContext context) {
    final String time =
        DateTime.now().toString().split(":").sublist(0, 2).join(":");
    return Column(
      children: [
        Stack(
          children: [
            qr.QrImage(
              data: "三点几辣！饮茶先辣！做做len啊做！",
              foregroundColor: Color.fromARGB(255, 0, 180, 0),
              size: QrCodeSize,
            ),
            Container(
              child: Container(
                child: Text("可以通行",
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 180, 0),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    )),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                color: Colors.white,
              ),
              width: QrCodeSize,
              height: QrCodeSize,
              alignment: Alignment.center,
            ),
          ],
        ),
        Container(
          child: Text(
            "更新时间：$time",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          padding: EdgeInsets.only(bottom: 10),
        ),
        Row(
          children: [
            Text(
              "我的行程卡",
              style: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 0, 180, 0),
              ),
            ),
            Text(
              "      |    ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            Text(
              "疫苗接种记录",
              style: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 0, 180, 0),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        SizedBox(height: 30),
        Text(
          "依托全国一体化政务服务平台\n实现跨省（区、市）数据共享和互通互认\n数据来源：国家政务服务平台（广西壮族自治区）",
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 17,
              height: 17,
              color: Color(0xFF00CC00),
            ),
            SizedBox(width: 5, height: 0),
            Text(
              "可通行",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(width: 30, height: 0),
            Container(
              width: 17,
              height: 17,
              color: Color(0xFFFE9900),
            ),
            SizedBox(width: 5, height: 0),
            Text(
              "限制通行",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(width: 30, height: 0),
            Container(
              width: 17,
              height: 17,
              color: Color(0xFFFE0000),
            ),
            SizedBox(width: 5, height: 0),
            Text(
              "不可通行",
              style: TextStyle(color: Colors.grey),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )
      ],
    );
  }
}

/// 显示时间（精确到毫秒）的动态组件，间隔130ms刷新一次来模拟原版小程序中的卡顿感
class TimerView extends StatefulWidget {
  const TimerView({Key key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  String _time = '00:00:00:00';
  Timer _countdownTimer;
  static const int _duration = 130;

  @override
  void initState() {
    super.initState();
    _countdownTimer =
        Timer.periodic(Duration(milliseconds: _duration), (timer) {
      setState(() {
        var time = DateTime.now().toString().split(' ')[1].split('.');
        time[1] = time[1].substring(0, 2);
        if (time[1] == '00') {
          time[1] = '100';
        }
        _time = time.join(':');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Text(
          _time,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 180, 0),
          ),
        ),
      ),
      height: 60,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }
}

/// 显示姓名的动态组件
class NameView extends StatefulWidget {
  const NameView({Key key}) : super(key: key);

  @override
  _NameViewState createState() => _NameViewState();
}

class _NameViewState extends State<NameView> {
  String _lastWordOfName = "";
  TextEditingController _controller = TextEditingController(text: "");

  Future<String> getName() async {
    var pref = await SharedPreferences.getInstance();
    return pref.getString("name") ?? "";
  }

  @override
  void initState() {
    super.initState();
    var name = getName();
    name.then((String name) {
      setState(() {
        _lastWordOfName = name;
        _controller.text = name;
      });
    });
  }

  Future<void> inputName() async {
    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return InputDialog(
            title: Text("请输入姓名最后一个字"),
            onOkBtnPressed: () async {
              var pref = await SharedPreferences.getInstance();
              setState(() {
                _lastWordOfName = _controller.text;
              });
              await pref.setString("name", _controller.text);
              Navigator.pop(context);
            },
            controller: _controller,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _random = Random();
    int next(int min, int max) => min + _random.nextInt(max - min);
    final int randNum1 = next(203, 582);
    final int randNum2 = next(1365, 9658);
    return TextButton(
        onPressed: () {
          inputName();
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "**$_lastWordOfName 可以通行",
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF008000),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Divider(
              height: 30,
              indent: 0,
              endIndent: 0,
              thickness: 0.5,
              color: Colors.grey,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "**$_lastWordOfName的广西健康码",
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                  Text(
                    "姓名：**$_lastWordOfName\n证件类型：身份证\n证件号码：$randNum1********$randNum2",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      //fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(200, 40),
          alignment: Alignment.topCenter,
        ));
  }
}


/// 显示通行证的假按钮
class PassportView extends StatelessWidget {
  const PassportView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF03C160),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    "已同意",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                width: 40,
                height: 20,
              ),
              SizedBox.fromSize(
                size: Size(5, 0),
              ),
              Text(
                "桂电学生桂电学生临时通行证",
                style: TextStyle(color: Colors.black),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          decoration: BoxDecoration(
              border: Border.symmetric(
                  vertical: BorderSide.none,
                  horizontal: BorderSide(
                      color: Color.fromARGB(255, 240, 240, 240), width: 0.7))),
          height: 45,
        ),
        Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.expand_more_outlined,
                color: Color.fromARGB(255, 195, 195, 195),
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
        )
      ],
    );
  }
}
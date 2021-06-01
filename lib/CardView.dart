import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/CropAvatarPage.dart';
import 'package:guet_card/ChangeAvatarPage.dart';
import 'package:guet_card/InputDialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

/// 卡片视图，包括时间、头像、二维码等信息以及外面的灰色框框
class CardView extends StatelessWidget {
  final double cardHeight = 605;
  final double screenHeight;
  final double screenWidth;
  const CardView({Key key, this.screenHeight = 605, this.screenWidth})
      : super(key: key);

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
                  FakeTabButtonView(),
                  QrCodeView(),
                  PassportView(),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1))),
              elevation: 0,
              color: Colors.white,
            ),
            widthFactor: 0.93,
          ),
          maxHeight: cardHeight + 33,
          alignment: Alignment.bottomCenter,
        ),
      ),
      height: screenHeight,
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

class AvatarView extends StatefulWidget {
  const AvatarView({Key key}) : super(key: key);

  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  String _avatarPath = "images/default_avatar.jpg";
  static const String _defaultAvatar = "images/default_avatar.jpg";
  static const _width = 90.0;

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
      /// 网页版
      Image img = Image.network(
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
      /// 移动端
      Image img;
      if (_avatarPath.startsWith("image")) {
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        qr.QrImage(
          data: "三点几辣！饮茶先辣！做做len啊做！三点几饮，饮茶先辣！做咁多，钱带去边度？",
          foregroundColor: Color.fromARGB(255, 0, 204, 0),
          size: 250,
        ),
        SizedBox(
          width: 0,
          height: 10,
        ),
        Container(
          child: Row(
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
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          height: 45,
          //color: Colors.black12,
        ),
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
            color: Colors.black,
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
    return TextButton(
        onPressed: () {
          inputName();
        },
        child: Row(
          children: [
            Text(
              "**" + _lastWordOfName + " 可以通行",
              maxLines: 1,
              style: TextStyle(
                color: Color(0xFF008000),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(200, 40),
          alignment: Alignment.topCenter,
        ));
  }
}

class FakeTabButtonView extends StatelessWidget {
  const FakeTabButtonView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          child: Text(
            "桂电畅行健康码",
            style: TextStyle(color: Colors.white),
          ),
          style: TextButton.styleFrom(
              backgroundColor: Color(0xFF07BA05),
              minimumSize: Size(150, 30),
              side: BorderSide(color: Color(0xFF07BA05)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.zero,
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.zero,
              ))),
        ),
        OutlinedButton(
            child: Text(
              "广西健康码",
              style: TextStyle(color: Color(0xFF07BA05)),
            ),
            style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(150, 30),
                side: BorderSide(color: Color(0xFF07BA05)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.circular(3),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.circular(3),
                )))),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

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

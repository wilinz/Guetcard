import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

import 'ChangeAvatarPage.dart';
import 'CropAvatarPage.dart';
import 'InputDialog.dart';
import 'main.dart';

/// 卡片视图，包括时间、头像、二维码等信息以及外面的灰色框框
class CardView extends StatelessWidget {
  final double screenWidth;
  static double cardHeight = 1000;
  static double cardViewHeight = cardHeight - 30;
  static double cardWidth = 500;

  CardView({Key? key, required this.screenWidth}) {
    CardView.cardWidth = this.screenWidth * 0.95;
    CardView.cardHeight = 1180 / 1064 * cardWidth + 650;
    CardView.cardViewHeight = CardView.cardHeight - 30;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Stack(
          children: [
            TimerView(),
            ListView(
              children: [
                SizedBox(
                  height: (kIsWeb ? 60 : 40),
                ),
                AvatarView(),
                NameView(),
                QrCodeView(),
                SizedBox(height: 20),
                PassportView()
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3))),
        elevation: 0,
        color: Colors.white,
      ),
      width: cardWidth,
    );
  }
}

/// 头像组件，负责调用切换头像的页面及更换头像功能
class AvatarView extends StatefulWidget {
  const AvatarView({Key? key}) : super(key: key);

  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {
  final String _defaultAvatar = kIsWeb
      ? networkImages['defaultAvatar']!
      : "assets/images/DefaultAvatar.png";
  late String _avatarPath;
  final _width = 90.0;
  late Image _img;

  _AvatarViewState({Key? key}) {
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
    if (kIsWeb) {
      // 网页版
      return TextButton(
        onPressed: () async {
          var url = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChangeAvatarPage()));
          if (url != null) {
            String path = url as String;
            if (mounted) {
              setState(() {
                _avatarPath = path;
              });
            }
            _saveUserAvatar(path);
          }
        },
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: _avatarPath,
          width: _width,
        ),
      );
    } else {
      // 移动端
      late var img;
      if (_avatarPath.startsWith("assets")) {
        // 如果路径的开头是 assets 则意味着是从 asset 中加载默认头像
        img = Image.asset(
          _avatarPath,
          width: _width,
        );
      } else if (_avatarPath.startsWith("http")) {
        // 如果路径开头是 http 则意味着是从网络上加载自定义头像
        img = FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: _avatarPath,
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
          final ImagePicker _imgPicker = ImagePicker();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text(
                      "由相机拍摄",
                      style: TextStyle(
                        fontFamily: "PingFangSC",
                      ),
                    ),
                    onTap: () async {
                      var imageFile = await _imgPicker.pickImage(
                          source: ImageSource.camera,
                          preferredCameraDevice: CameraDevice.front);
                      if (imageFile != null) {
                        Navigator.pop(context);
                        File _image = File(imageFile.path);
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CropAvatarPage(_image)));
                        if (result != null) {
                          var docPath =
                              await getApplicationDocumentsDirectory();
                          var pref = await SharedPreferences.getInstance();
                          var lastAvatar = pref.getString("userAvatar");
                          if (lastAvatar != null &&
                              !lastAvatar.startsWith("http")) {
                            _deletePreviousAvatar(
                                "${docPath.path}/${pref.getString("userAvatar")}");
                          }
                          String name = result as String;
                          if (mounted) {
                            setState(() {
                              this._avatarPath = "${docPath.path}/$name";
                            });
                          }
                          _saveUserAvatar(name);
                        }
                      } else {
                        ProgressHud.showErrorAndDismiss(text: "未获取到拍摄的照片");
                      }
                    },
                  ),
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
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CropAvatarPage(_image)));
                        if (result != null) {
                          var docPath =
                              await getApplicationDocumentsDirectory();
                          var pref = await SharedPreferences.getInstance();
                          var lastAvatar = pref.getString("userAvatar");
                          if (lastAvatar != null &&
                              !lastAvatar.startsWith("http")) {
                            _deletePreviousAvatar(
                                "${docPath.path}/${pref.getString("userAvatar")}");
                          }
                          String name = result as String;
                          if (mounted) {
                            setState(() {
                              this._avatarPath = "${docPath.path}/$name";
                            });
                          }
                          _saveUserAvatar(name);
                        }
                      } else {
                        ProgressHud.showErrorAndDismiss(text: "未获取到选择的图片");
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text("从默认头像中选择",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                        )),
                    onTap: () async {
                      var url = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeAvatarPage()));
                      if (url != null) {
                        var docPath = await getApplicationDocumentsDirectory();
                        var pref = await SharedPreferences.getInstance();
                        var lastAvatar = pref.getString("userAvatar");
                        if (kIsWeb) {
                          String path = url as String;
                          if (mounted) {
                            setState(() {
                              _avatarPath = path;
                            });
                          }
                          _saveUserAvatar(path);
                        } else {
                          ProgressHud.showLoading(text: "正在保存...");
                          Dio dio = Dio();
                          var dir = await getApplicationDocumentsDirectory();
                          var name = "${Uuid().v4()}";
                          var ext = url.toString().split(".").last;
                          await dio
                              .download(
                            url,
                            "${dir.path}/$name.$ext",
                          )
                              .then(
                            (value) {
                              if (value.statusCode == 200) {
                                ProgressHud.dismiss();
                                if (lastAvatar != null &&
                                    !lastAvatar.startsWith("http")) {
                                  _deletePreviousAvatar(
                                      "${docPath.path}/${pref.getString("userAvatar")}");
                                }
                                if (mounted) {
                                  setState(() {
                                    _avatarPath = "${dir.path}/$name.$ext";
                                  });
                                }
                                _saveUserAvatar("$name.$ext");
                              } else {
                                ProgressHud.dismiss();
                                ProgressHud.showErrorAndDismiss(
                                    text: "保存失败，请重试");
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
                  SizedBox(
                    height: 10,
                  )
                ],
              );
            },
          );
        },
        child: img,
      );
    }
  }
}

/// 二维码视图，最大尺寸为250
class QrCodeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String time =
        DateTime.now().toString().split(":").sublist(0, 2).join(":");
    //final double QrCodeSize = 230.0;
    var goldenEdge = kIsWeb
        ? FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: networkImages["goldenEdge"]!,
            width: CardView.cardWidth,
          )
        : Image.asset(
            "assets/images/GoldenEdge.png",
            width: CardView.cardWidth,
          );
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          width: CardView.cardWidth,
          child: Stack(
            children: [
              goldenEdge,
              Center(
                child: Transform.translate(
                  offset: Offset(0, 20),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        child: qr.QrImage(
                          data: "三点几辣！饮茶先辣！做做len啊做！饮茶先啦！",
                          foregroundColor: Color(0xFF00CC00),
                          size: CardView.cardWidth * 0.7,
                        ),
                        width: CardView.cardWidth - 50,
                        height: CardView.cardWidth - 50,
                        alignment: Alignment.center,
                      ),
                      // Container(
                      //   child: Container(
                      //     child: Text("可以通行",
                      //         style: TextStyle(
                      //           fontFamily: "PingFangSC-Heavy",
                      //           color: Color(0xFF09BA07),
                      //           fontSize: CardView.cardWidth * 0.14,
                      //           //fontWeight: FontWeight.bold,
                      //         )),
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                      //     color: Colors.white,
                      //   ),
                      //   width: CardView.cardWidth - 50,
                      //   height: CardView.cardWidth - 50,
                      //   alignment: Alignment.center,
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Text(
            "更新时间：$time",
            style: TextStyle(
              fontFamily: "PingFangSC",
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
          padding: EdgeInsets.only(bottom: 10),
        ),
        Row(
          children: [
            Text(
              "我的行程卡",
              style: TextStyle(
                fontFamily: "PingFangSC",
                fontSize: 15,
                color: Color.fromARGB(255, 0, 180, 0),
              ),
            ),
            Text(
              "      |    ",
              style: TextStyle(
                fontFamily: "PingFangSC",
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "疫苗接种记录",
              style: TextStyle(
                fontFamily: "PingFangSC",
                fontSize: 15,
                color: Color.fromARGB(255, 0, 180, 0),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "依托全国一体化政务服务平台\n实现跨省（区、市）数据共享和互通互认\n数据来源：国家政务服务平台（广西壮族自治区）||广西自治区大数据发展局",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
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
              style: TextStyle(
                fontFamily: "PingFangSC",
                color: Colors.grey,
              ),
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
              style: TextStyle(
                fontFamily: "PingFangSC",
                color: Colors.grey,
              ),
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
              style: TextStyle(
                fontFamily: "PingFangSC",
                color: Colors.grey,
              ),
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
  const TimerView({Key? key}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  String _time = '00:00:00:00';
  late Timer _countdownTimer;
  final int _duration = 130;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(
      Duration(milliseconds: _duration),
      (timer) {
        if (mounted) {
          setState(() {
            var time = DateTime.now().toString().split(' ')[1].split('.');
            time[1] = time[1].substring(0, 2);
            if (time[1] == '00') {
              time[1] = '100';
            }
            _time = time.join(':');
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Text(
          _time,
          style: TextStyle(
            fontFamily: "PingFangSC-Heavy",
            fontSize: 27,
            color: Color(0xff0cbb0a),
          ),
        ),
      ),
      height: 60,
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }
}

/// 显示姓名的动态组件
class NameView extends StatefulWidget {
  const NameView({Key? key}) : super(key: key);

  @override
  _NameViewState createState() => _NameViewState();
}

class _NameViewState extends State<NameView> {
  String _lastWordOfName = "";
  TextEditingController _controller = TextEditingController(text: "");

  Future<String> _getNameFromPref() async {
    var pref = await SharedPreferences.getInstance();
    return pref.getString("name") ?? "";
  }

  Future<void> _inputName() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          title: Text(
            "请输入姓名最后一个字",
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
          onOkBtnPressed: () async {
            var pref = await SharedPreferences.getInstance();
            if (mounted) {
              setState(() {
                if (_controller.text.length > 1) {
                  _controller.text = _controller.text.substring(0, 1);
                }
                _lastWordOfName = _controller.text;
              });
            }
            await pref.setString("name", _controller.text);
            Navigator.pop(context);
          },
          controller: _controller,
        );
      },
    ).then((val) {
      _controller.text = _lastWordOfName;
    });
  }

  @override
  void initState() {
    super.initState();
    var name = _getNameFromPref();
    name.then((String name) {
      if (mounted) {
        setState(() {
          _lastWordOfName = name;
          _controller.text = name;
        });
      }
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
          _inputName();
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "**$_lastWordOfName 可以通行",
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: "PingFangSC-Heavy",
                    color: Color(0xFF007f00),
                    fontSize: 22,
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
              thickness: 0.2,
              color: Color.fromARGB(50, 80, 80, 80),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "**$_lastWordOfName的广西健康码",
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "PingFangSC-Heavy",
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                  Text(
                    "姓名：**$_lastWordOfName\n证件类型：身份证\n证件号码：$randNum1********$randNum2",
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      color: Colors.grey,
                      fontSize: 16,
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
  const PassportView({Key? key}) : super(key: key);

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
                      fontFamily: "PingFangSC",
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
                style: TextStyle(
                  fontFamily: "PingFangSC",
                  color: Colors.black,
                ),
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

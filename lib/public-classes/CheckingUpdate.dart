import 'dart:io';

import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CheckingUpdate {
  static Future<String> initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    return version;
  }

  static Future<void> _showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CheckingUpdateDialog(
          updateInfo: updateInfo,
        );
      },
    );
  }

  static void checkForUpdate(BuildContext context) async {
    String currentVersion = await initPackageInfo();
    await Dio()
        .get(
      "https://gitee.com/api/v5/repos/guetcard/guetcard/releases/latest",
    )
        .then((value) async {
      Map<String, dynamic> map = value.data;
      String remoteVersion = map["tag_name"].replaceAll("v", "").replaceAll(".", "");
      // TODO 记得改回 >
      if (int.parse(remoteVersion) >= int.parse(currentVersion.replaceAll(".", ""))) {
        String? apkUrl;
        for (var item in map["assets"]) {
          if (item["name"] != null && item["name"].endsWith(".apk")) {
            apkUrl = item["browser_download_url"];
          }
        }

        if (Platform.isAndroid) {
          // await FlutterXUpdate.init(
          //   debug: false,
          //   isWifiOnly: false,
          // );
          // UpdateEntity updateEntity = UpdateEntity(
          //   isIgnorable: true,
          //   hasUpdate: true,
          //   versionCode: int.parse(remoteVersion),
          //   versionName: map["tag_name"],
          //   updateContent: map["body"],
          //   downloadUrl: apkUrl,
          // );
          // FlutterXUpdate.updateByInfo(updateEntity: updateEntity);
          Map<String, dynamic> updateInfo = {
            "url": null,
            "versionName": null,
            "description": null,
          };
          updateInfo['url'] = apkUrl;
          updateInfo['versionName'] = map["tag_name"];
          updateInfo['description'] = map["body"];
          _showUpdateDialog(context, updateInfo);
        } else if (Platform.isIOS) {
          Map<String, dynamic> updateInfo = {
            "url": null,
            "versionName": null,
            "description": null,
          };
          updateInfo['url'] = "https://gitee.com/guetcard/guetcard/releases";
          updateInfo['versionName'] = map["tag_name"];
          updateInfo['description'] = map["body"];
          _showUpdateDialog(context, updateInfo);
        }
      } else {
        // 已是最新版本
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅当前已是最新版本'),
          ),
        );
      }
    }).onError((error, stackTrace) {
      ProgressHud.showErrorAndDismiss(text: "获取更新失败");
    });
  }
}

class CheckingUpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;
  const CheckingUpdateDialog({Key? key, required this.updateInfo}) : super(key: key);

  @override
  State<CheckingUpdateDialog> createState() => _CheckingUpdateDialogState();
}

class _CheckingUpdateDialogState extends State<CheckingUpdateDialog> {
  double _progress = 0;
  OtaStatus? _status;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            fontFamily: "PingFangSC",
            color: Colors.white,
          ),
        ),
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        platform: TargetPlatform.iOS, // 设定目标平台为 iOS 以启用右滑返回手势
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 0),
              decoration: new BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
                      child: Text(
                        '是否升级到${widget.updateInfo["versionName"]}版本',
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          fontSize: 16.0,
                          color: Color(0xff555555),
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      widget.updateInfo["description"],
                      style: TextStyle(
                        fontFamily: "PingFangSC",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            height: 45,
                            child: TextButton(
                              child: Text(
                                "下次再说",
                                style: TextStyle(
                                  fontFamily: "PingFangSC",
                                  // color: _progress > 0 ? Colors.grey : Color(0xffffbb5b),
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: _progress > 0 ? null : () => Navigator.of(context).pop(), //关闭对话框
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 45,
                            child: _progress > 0
                                ? Center(
                                    child: SizedBox.square(
                                      dimension: 30,
                                      child: CircularProgressIndicator(
                                        value: _progress,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    child: Text(
                                      (!kIsWeb && Platform.isIOS) ? "立即前往" : "立即更新",
                                      style: TextStyle(
                                        fontFamily: "PingFangSC",
                                        // color: Color(0xffffbb5b),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (!kIsWeb && Platform.isIOS) {
                                        Navigator.of(context).pop(); //关闭对话框
                                        await canLaunchUrlString(widget.updateInfo["url"])
                                            ? await launchUrlString(widget.updateInfo["url"])
                                            : throw 'Could not launch ${widget.updateInfo["url"]}';
                                      } else if (!kIsWeb && Platform.isAndroid) {
                                        try {
                                          if (widget.updateInfo['url'] != null)
                                            OtaUpdate().execute(widget.updateInfo['url']).listen((event) {
                                              setState(() {
                                                _progress = (double.tryParse(event.value ?? '0') ?? 0) / 100;
                                                _status = event.status;
                                              });
                                              if (_status == OtaStatus.INSTALLING) {
                                                Navigator.of(context).pop();
                                              }
                                            });
                                        } catch (e) {
                                          print('升级失败，原因：$e');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('很抱歉，升级失败了'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

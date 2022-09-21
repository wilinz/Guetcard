import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guet_card/Global.dart';
import 'package:guet_card/Utils/LogUtil.dart';
import 'package:guet_card/Utils/Utils.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CheckingUpdate {
  static Future<String> initPackageInfo() async => (await PackageInfo.fromPlatform()).version;

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
      if (int.parse(remoteVersion) > int.parse(currentVersion.replaceAll(".", ""))) {
        String? apkUrl;
        String? ipaUrl;
        for (var item in map["assets"]) {
          if (item["name"] != null && item["name"].endsWith(".apk")) {
            apkUrl = item["browser_download_url"];
          } else if (item['name'] != null && item['name'].endsWith('ipa')) {
            ipaUrl = item['browser_download_url'];
          }
        }

        if (Platform.isAndroid) {
          _showUpdateDialog(context, {
            "url": apkUrl,
            "versionName": map["tag_name"],
            "description": map["body"],
          });
        } else if (Platform.isIOS) {
          _showUpdateDialog(context, {
            "url": ipaUrl,
            "versionName": map["tag_name"],
            "description": map["body"],
          });
        }
      } else {
        // 已是最新版本
        Utils.showSnackBar(context, text: '✅当前已是最新版本');
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
                              onPressed:
                                  _progress > 0 && _progress < 1 ? null : () => Navigator.of(context).pop(), //关闭对话框
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 45,
                            child: _progress > 0 && _progress < 1
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
                                            ? await launchUrlString(
                                                widget.updateInfo["url"],
                                                mode: LaunchMode.externalApplication,
                                              )
                                            : throw 'Could not launch ${widget.updateInfo["url"]}';
                                      } else if (!kIsWeb && Platform.isAndroid) {
                                        try {
                                          if (widget.updateInfo['url'] != null) {
                                            int progressId = Random().nextInt(999999);
                                            bool pushLock = false;
                                            OtaUpdate().execute(widget.updateInfo['url']).listen((event) {
                                              switch (event.status) {
                                                case OtaStatus.DOWNLOADING:
                                                  setState(() {
                                                    _progress = (double.tryParse(event.value ?? '0') ?? 1) / 100;
                                                  });
                                                  if (!pushLock) {
                                                    final AndroidNotificationDetails androidNotificationDetails =
                                                        AndroidNotificationDetails(
                                                      'progress channel',
                                                      'progress channel',
                                                      channelShowBadge: false,
                                                      importance: Importance.max,
                                                      priority: Priority.high,
                                                      onlyAlertOnce: true,
                                                      showProgress: true,
                                                      maxProgress: 100,
                                                      progress: int.tryParse(event.value ?? '0') ?? 1,
                                                    );
                                                    final NotificationDetails notificationDetails =
                                                        NotificationDetails(android: androidNotificationDetails);
                                                    Global.flutterLocalNotificationsPlugin.show(
                                                      progressId,
                                                      '正在下载更新...',
                                                      '${event.value}%',
                                                      notificationDetails,
                                                    );
                                                    pushLock = true;
                                                    Future.delayed(Duration(milliseconds: 100))
                                                        .then((value) => pushLock = false);
                                                  }
                                                  break;
                                                case OtaStatus.INSTALLING:
                                                  Navigator.of(context).pop();
                                                  final AndroidNotificationDetails androidNotificationDetails =
                                                      AndroidNotificationDetails(
                                                    'progress channel',
                                                    'progress channel',
                                                    channelShowBadge: false,
                                                    importance: Importance.max,
                                                    priority: Priority.high,
                                                    onlyAlertOnce: true,
                                                    showProgress: false,
                                                  );
                                                  final NotificationDetails notificationDetails =
                                                      NotificationDetails(android: androidNotificationDetails);
                                                  Global.flutterLocalNotificationsPlugin.show(
                                                    progressId,
                                                    '更新下载完成',
                                                    '',
                                                    notificationDetails,
                                                  );
                                                  break;
                                                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                                                  Navigator.of(context).pop();
                                                  ProgressHud.showErrorAndDismiss(text: '更新失败：用户未授权');
                                                  break;
                                                case OtaStatus.ALREADY_RUNNING_ERROR:
                                                case OtaStatus.DOWNLOAD_ERROR:
                                                case OtaStatus.INTERNAL_ERROR:
                                                case OtaStatus.CHECKSUM_ERROR:
                                                  Navigator.of(context).pop();
                                                  ProgressHud.showErrorAndDismiss(text: '更新失败：下载更新包失败');
                                                  break;
                                                default:
                                                  break;
                                              }
                                            });
                                          }
                                        } catch (error, stackTrace) {
                                          LogUtil.error(message: '更新失败', error: e, stackTrace: stackTrace);
                                          ProgressHud.showErrorAndDismiss(text: '更新失败：下载更新包失败');
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

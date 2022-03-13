import 'dart:io';

import 'package:bmprogresshud/progresshud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckingUpdate {
  Future<String> initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    return version;
  }

  Future<void> _showIOSDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) async {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Column(
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
                        '是否升级到${updateInfo["versionName"]}版本',
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
                      updateInfo["description"],
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
                          TextButton(
                            child: Text(
                              "下次再说",
                              style: TextStyle(
                                fontFamily: "PingFangSC",
                                color: Color(0xffffbb5b),
                                fontSize: 18.0,
                              ),
                            ),
                            onPressed: () =>
                                Navigator.of(context).pop(), //关闭对话框
                          ),
                          TextButton(
                            child: Text(
                              "立即前往",
                              style: TextStyle(
                                fontFamily: "PingFangSC",
                                color: Color(0xffffbb5b),
                                fontSize: 18.0,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop(); //关闭对话框
                              await canLaunch(updateInfo["ipaUrl"])
                                  ? await launch(updateInfo["ipaUrl"])
                                  : throw 'Could not launch ${updateInfo["ipaUrl"]}';
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void checkForUpdate(BuildContext context) async {
    String currentVersion = await initPackageInfo();
    await Dio()
        .get(
      "https://gitee.com/api/v5/repos/guetcard/guetcard/releases/latest",
    )
        .then((value) async {
      Map<String, dynamic> map = value.data;
      String remoteVersion =
          map["tag_name"].replaceAll("v", "").replaceAll(".", "");
      if (int.parse(remoteVersion) >
          int.parse(currentVersion.replaceAll(".", ""))) {
        String? apkUrl;
        for (var item in map["assets"]) {
          if (item["name"] != null && item["name"].endsWith(".apk")) {
            apkUrl = item["browser_download_url"];
          }
        }

        if (Platform.isAndroid) {
          await FlutterXUpdate.init(
            debug: false,
            isWifiOnly: false,
          );
          UpdateEntity updateEntity = UpdateEntity(
            isIgnorable: true,
            hasUpdate: true,
            versionCode: int.parse(remoteVersion),
            versionName: map["tag_name"],
            updateContent: map["body"],
            downloadUrl: apkUrl,
          );
          FlutterXUpdate.updateByInfo(updateEntity: updateEntity);
        } else if (Platform.isIOS) {
          Map<String, dynamic> updateInfo = {
            "ipaUrl": null,
            "versionName": null,
            "description": null,
          };
          updateInfo['ipaUrl'] = "https://gitee.com/guetcard/guetcard/releases";
          updateInfo['versionName'] = map["tag_name"];
          updateInfo['description'] = map["body"];
          _showIOSDialog(context, updateInfo);
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

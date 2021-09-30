import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:crop_image/crop_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import "main.dart";

/// 在预设头像中选择一个头像的页面
class ChangeAvatarPage extends StatelessWidget {
  final controller = CropController(
    aspectRatio: 1,
  );

  ChangeAvatarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "选择一个头像",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "PingFangSC",
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: LazyImgList(),
        ),
      ),
      onWillPop: () async {
        ProgressHud.dismiss();
        return true;
      },
    );
  }
}

class LazyImgList extends StatefulWidget {
  const LazyImgList({Key? key}) : super(key: key);

  @override
  _LazyImgListState createState() => _LazyImgListState();
}

class _LazyImgListState extends State<LazyImgList> {
  _LazyImgListState();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    var imgPerRow = width ~/ 120;
    if (avatarList.length != 0) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int vindex) {
            var imgThisRow = imgPerRow;
            if (avatarList.length - (vindex * imgPerRow) < imgPerRow) {
              imgThisRow = avatarList.length - (vindex * imgPerRow);
            }
            var imgWidth = width / imgPerRow;

            return Container(
              height: imgWidth,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int hindex) {
                    return Container(
                      width: imgWidth,
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context)
                              .pop(avatarList[vindex * imgPerRow + hindex]);
                        },
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: avatarList[vindex * imgPerRow + hindex],
                          width: imgWidth,
                          height: imgWidth,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 0,
                    );
                  },
                  itemCount: imgThisRow),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return new SizedBox(
              height: 0,
            );
          },
          itemCount: avatarList.length ~/ imgPerRow + 1);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "网络错误，获取头像列表失败",
            style: TextStyle(
              fontFamily: "PingFangSC",
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ProgressHud.showLoading(text: "正在加载头像列表...");
              Dio().get(avatarListUrl).then((value) {
                print(value);
                var list = value.toString().split('\n');
                for (String line in list) {
                  avatarList.add(line);
                }
              }).then((value) {
                ProgressHud.showSuccessAndDismiss(text: "完成");
                setState(() {});
              }).onError((error, stackTrace) {
                debugPrint("头像列表下载失败:");
                debugPrint("error: $error");
                ProgressHud.showErrorAndDismiss(text: "头像列表下载失败");
              });
            },
            child: Text(
              "点击重试",
              style: TextStyle(
                fontFamily: "PingFangSC",
              ),
            ),
          )
        ],
      );
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 裁剪头像的页面
class CropAvatarPage extends StatefulWidget {
  File avatarImage;

  CropAvatarPage(this.avatarImage, {Key? key}) : super(key: key);
  _CropAvatarPageState createState() => new _CropAvatarPageState(avatarImage);
}

class _CropAvatarPageState extends State<CropAvatarPage> {
  File avatarImage;
  _CropAvatarPageState(this.avatarImage);

  // 是否可返回上一级页面
  bool isPopable = true;

  final controller = CropController(
    aspectRatio: 1,
  );

  @override
  Widget build(BuildContext context) {
    assert(avatarImage != null);
    debugPrint(avatarImage.path);
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CropImage(
              controller: controller,
              image: Image.file(avatarImage),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () async {
            try {
              ProgressHud.show(ProgressHudType.loading, "保存中……");
              setState(() {
                isPopable = false;
              });
              ui.Image image =
              await controller.croppedBitmap(quality: FilterQuality.low);
              var dir = await getApplicationDocumentsDirectory();
              var name = "${Uuid().v4()}.png";
              var path = '${dir.path}/$name';
              debugPrint("Avatar output path: ${path}");
              File savedImage = File(path);
              ByteData? imageData =
              await image.toByteData(format: ui.ImageByteFormat.png);
              if (imageData == null) {
                throw "imageData should not be null!";
              }
              Uint8List pngBytes = imageData.buffer.asUint8List();
              savedImage.writeAsBytesSync(pngBytes);
              Navigator.of(context).pop(name);
            } catch (e) {
              ProgressHud.dismiss();
              ProgressHud.showAndDismiss(ProgressHudType.error, "保存失败！");
              setState(() {
                isPopable = true;
              });
              print(e);
            } finally {
              ProgressHud.dismiss();
                setState(() {
                  isPopable = true;
                });
                ProgressHud.showSuccessAndDismiss(text: "保存成功！");
              }
          },
          backgroundColor: Colors.green,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      onWillPop: () async {
        return isPopable;
      }
    );
  }
}

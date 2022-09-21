import 'dart:io';
import 'dart:ui' as ui;

import 'package:bmprogresshud/bmprogresshud.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/Utils/LogUtil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 裁剪头像的页面
class CropAvatarPage extends StatefulWidget {
  CropAvatarPage({Key? key}) : super(key: key);

  _CropAvatarPageState createState() => new _CropAvatarPageState();
}

class _CropAvatarPageState extends State<CropAvatarPage> {
  late File avatarImage;

  _CropAvatarPageState();

  // 是否可返回上一级页面
  bool isPopable = true;

  final controller = CropController(
    aspectRatio: 1,
  );

  @override
  Widget build(BuildContext context) {
    this.avatarImage = ModalRoute.of(context)?.settings.arguments as File;
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
              if (mounted) {
                setState(() {
                  isPopable = false;
                });
              } else {
                return;
              }
              ui.Image image = await controller.croppedBitmap(quality: FilterQuality.low);
              var dir = await getApplicationDocumentsDirectory();
              var name = "${Uuid().v4()}.png";
              var path = '${dir.path}/$name';
              File savedImage = File(path);
              ByteData? imageData = await image.toByteData(format: ui.ImageByteFormat.png);
              if (imageData == null) {
                throw "imageData should not be null!";
              }
              Uint8List pngBytes = imageData.buffer.asUint8List();
              savedImage.writeAsBytesSync(pngBytes);
              Navigator.of(context).pop(name);
            } catch (error, stackTrace) {
              ProgressHud.dismiss();
              ProgressHud.showAndDismiss(ProgressHudType.error, "保存失败！");
              if (mounted) {
                setState(() {
                  isPopable = true;
                });
              }
              LogUtil.error(message: '裁剪后头像保存失败', error: error, stackTrace: stackTrace);
            } finally {
              ProgressHud.dismiss();
              if (mounted) {
                setState(() {
                  isPopable = true;
                });
              }
              ProgressHud.showSuccessAndDismiss(text: "保存成功！");
            }
          },
          backgroundColor: Colors.green,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      onWillPop: () async {
        return isPopable;
      },
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

/// 裁剪头像的页面
class CropAvatarPage extends StatefulWidget {
  File avatarImage;
  CropAvatarPage(this.avatarImage, {Key key}) : super(key: key);
  _CropAvatarPageState createState() => new _CropAvatarPageState(avatarImage);
}

class _CropAvatarPageState extends State<CropAvatarPage> {
  File avatarImage;
  bool _isSaving = false;
  _CropAvatarPageState(this.avatarImage);

  final controller = CropController(
    aspectRatio: 1,
  );

  @override
  Widget build(BuildContext context) {
    assert(avatarImage != null);
    debugPrint(avatarImage.path);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ModalProgressHUD(
          inAsyncCall: _isSaving,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CropImage(
              controller: controller,
              image: Image.file(avatarImage),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () async {
          if (!_isSaving) {
            try {
              setState(() {
                _isSaving = true;
              });
              ui.Image image =
                  await controller.croppedBitmap(quality: FilterQuality.low);
              var dir = await getApplicationDocumentsDirectory();
              var name = "${Uuid().v4()}.png";
              var path = '${dir.path}/$name';
              debugPrint("Avatar output path: ${path}");
              File savedImage = File(path);
              ByteData imageData =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = imageData.buffer.asUint8List();
              savedImage.writeAsBytesSync(pngBytes);
              Navigator.of(context).pop(name);
            } catch (e) {
              print(e);
            } finally {
              setState(() {
                _isSaving = false;
              });
            }
          }
        },
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

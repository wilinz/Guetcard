import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/pages/ChangeAvatarPage/widgets/LazyImgList.dart';

/// 在预设头像中选择一个头像的页面
class ChangeAvatarPage extends StatelessWidget {
  final controller = CropController(
    aspectRatio: 1,
  );

  ChangeAvatarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

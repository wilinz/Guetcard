import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crop_image/crop_image.dart';
import 'package:dio/dio.dart';


/// 在预设头像中选择一个头像的页面
class ChangeAvatarPage extends StatelessWidget {
  final controller = CropController(
    aspectRatio: 1,
  );
  ChangeAvatarPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("选择一个头像", style: TextStyle(color: Colors.white),),        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.zero,
        alignment: Alignment.topCenter,
        child: LazyImgList(),
      ),
    );
  }
}

class LazyImgList extends StatefulWidget {
  const LazyImgList({Key key}) : super(key: key);

  @override
  _LazyImgListState createState() => _LazyImgListState();
}

class _LazyImgListState extends State<LazyImgList> {
  List<String> imgList;
  static const String avatarListUrl = "https://guet-card.web.app/avatar_list.txt";
  _LazyImgListState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      Dio().get(avatarListUrl).then((value) {
        var list = value.toString().split('\n');
        var _tmp = <String>[];
        for (String line in list) {
          _tmp.add(line);
        }
        setState(() {
          imgList = _tmp;
        });
      });
    } catch (e) {
      debugPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    var imgPerRow = width ~/ 120;
    return ListView.separated(
        itemBuilder: (BuildContext context, int vindex) {
          if (imgList != null) {
          var imgThisRow = imgPerRow;
          if (imgList.length - (vindex * imgPerRow) < imgPerRow) {
            imgThisRow = imgList.length - (vindex * imgPerRow);
          }
          var imgWidth = (width - 40 - (imgPerRow - 1) * 10) / imgPerRow;

            return Container(
              height: imgWidth,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int hindex) {
                    return TextButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .pop(imgList[vindex * imgPerRow + hindex]);
                      },
                      child: Image.network(
                        imgList[vindex * imgPerRow + hindex],
                        width: imgWidth,
                        height: imgWidth,
                        fit: BoxFit.fitWidth,
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
          } else {
            return Text("正在获取头像列表……");
          }
        },
        separatorBuilder: (BuildContext context, int index) {
          return new SizedBox(
            height: 0,
          );
        },
        itemCount: (imgList ?? []).length ~/ imgPerRow + 1);
  }
}

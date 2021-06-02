import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crop_image/crop_image.dart';

/// 在预设头像中选择一个头像的页面
class ChangeAvatarPage extends StatelessWidget {
  final controller = CropController(
    aspectRatio: 1,
  );
  ChangeAvatarPage({Key key}) : super(key: key);

  var avatarList = [
    "https://i.loli.net/2021/05/25/x4KC5FtQEkvf9Ob.jpg",
    "https://i.loli.net/2021/05/29/RwB164EyZSYTnxH.jpg",
    "https://i.loli.net/2021/05/29/alOk92ehEN64IGP.jpg",
    "https://i.loli.net/2021/05/29/KeE2yw5gxXQqbGf.jpg",
    "https://i.loli.net/2021/05/29/2ov7td9CyXYTnPs.jpg",
    "https://i.loli.net/2021/05/29/MgwfUDKz2nkSB78.jpg",
    "https://i.loli.net/2021/05/29/Tx4BY8lIjgpzLXJ.jpg",
    "https://i.loli.net/2021/05/29/fhEINYqi4QDnrAo.jpg",
    "https://i.loli.net/2021/05/29/tWOucr8ZVKP53oh.jpg",
    "https://i.loli.net/2021/05/29/mwxDOrioQIbX8sJ.jpg",
    "https://i.loli.net/2021/05/29/WYsFyUiJ83NfaO9.jpg",
    "https://i.loli.net/2021/05/29/IazEt8XxdLkbyQO.jpg",
    "https://i.loli.net/2021/05/29/lkwQeUCVOFuX8NA.jpg",
    "https://i.loli.net/2021/05/29/LmTIMnsBixrFjuz.jpg",
    "https://i.loli.net/2021/05/29/w5kzMy6XhtQFirv.jpg",
    "https://i.loli.net/2021/05/29/PdaYFcEtA8nC6Up.jpg",
    "https://i.loli.net/2021/05/29/3Sj54n8OzABIlir.jpg",
    "https://i.loli.net/2021/05/29/2pHmWzrBLGNc3ZE.jpg",
    "https://i.loli.net/2021/05/29/JRKwtl8H5ah2bVZ.jpg",
    "https://i.loli.net/2021/05/29/YqiAzWlUegNc8wE.jpg",
    "https://i.loli.net/2021/05/29/gNdUp7Grh6T4Zcq.jpg",
    "https://i.loli.net/2021/05/29/Gy2famICSnk3xlF.jpg",
    "https://i.loli.net/2021/05/29/aWCmclBZkPTXRGg.jpg",
    "https://i.loli.net/2021/05/29/heOPiBIvJdxpDXk.jpg",
    "https://i.loli.net/2021/05/29/mkpRZiKsqYwjeIE.jpg",
    "https://i.loli.net/2021/05/29/cjCSrY8KZ1AXUR6.jpg",
    "https://i.loli.net/2021/05/29/LMoKkwGZ7VibI5Y.jpg",
    "https://i.loli.net/2021/05/29/Fwr7ygWaSvoMCXZ.jpg",
    "https://i.loli.net/2021/05/29/sc4wNVmCHPLKYOW.jpg",
    "https://i.loli.net/2021/05/29/3qXPgWdkAvFabTZ.jpg",
    "https://i.loli.net/2021/05/29/ItHsD5Pm6T7KUxf.jpg",
    "https://i.loli.net/2021/05/29/1wUip5NCDmEj9A3.jpg",
    "https://i.loli.net/2021/05/29/KP8Hfqx1mEjbo49.jpg",
    "https://i.loli.net/2021/05/29/xgm7QKGWrH9hPzi.jpg",
    "https://i.loli.net/2021/05/29/h2msqP1TfVvEAM6.jpg",
    "https://i.loli.net/2021/05/29/GrFKhzoXJiWYHnN.jpg",
  ];

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
        child: LazyImgList(avatarList),
      ),
    );
  }
}

class LazyImgList extends StatefulWidget {
  final imgList;
  const LazyImgList(this.imgList, {Key key}) : super(key: key);

  @override
  _LazyImgListState createState() => _LazyImgListState(imgList);
}

class _LazyImgListState extends State<LazyImgList> {
  final imgList;
  _LazyImgListState(this.imgList);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    var imgPerRow = width ~/ 120;
    return ListView.separated(
        itemBuilder: (BuildContext context, int vindex) {
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
        },
        separatorBuilder: (BuildContext context, int index) {
          return new SizedBox(
            height: 0,
          );
        },
        itemCount: imgList.length ~/ imgPerRow + 1);
  }
}

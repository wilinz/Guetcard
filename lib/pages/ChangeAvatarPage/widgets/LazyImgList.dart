import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Const.dart';
import '../../../main.dart';
import '../../../public-widgets/WebImageWithIndicator.dart';

/// 懒加载的图像列表，能自适应屏幕尺寸并调整图像列数
class LazyImgList extends StatefulWidget {
  const LazyImgList({Key? key}) : super(key: key);

  @override
  _LazyImgListState createState() => _LazyImgListState();
}

class _LazyImgListState extends State<LazyImgList> {
  _LazyImgListState();

  bool _isLoadError = false;
  var _isLoading = false;

  final dio = Dio();

  Future<void> _loadAvatarList() async {
    if (kDebugMode) {
      await Future.delayed(Duration(seconds: 1));
    }
    await dio.get(Const.avatarListUrl).then(
      (value) {
        if (avatarList.length == 0) {
          var list = value.toString().split('\n');
          for (String line in list) {
            if (line.length > 0 && line.startsWith("http")) {
              avatarList.add(line);
            }
          }
        }
        if (mounted) {
          setState(() {});
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoadError = true;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (avatarList.length <= 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => _loadAvatarList(),
      );
    }
  }

  @override
  void dispose() {
    dio.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    int imgPerRow = width ~/ 120;
    if (avatarList.length != 0) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int vindex) {
            int imgThisRow = imgPerRow;
            if (avatarList.length - (vindex * imgPerRow) < imgPerRow) {
              imgThisRow = avatarList.length - (vindex * imgPerRow);
            }
            var imgWidth = width / imgPerRow;

            var imgBuilder = (int hindex) {
              return Container(
                width: imgWidth,
                child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(avatarList[vindex * imgPerRow + hindex]);
                    },
                    child: WebImageWithIndicator(imgURL: avatarList[vindex * imgPerRow + hindex])),
              );
            };

            List<Widget> row = [];
            for (var i = 0; i < imgThisRow; i++) {
              row.add(imgBuilder(i));
            }

            return Container(
              height: imgWidth,
              child: Row(
                children: row,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return new SizedBox(
              height: 0,
            );
          },
          itemCount: avatarList.length ~/ imgPerRow + 1);
    } else {
      if (_isLoadError) {
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
            Builder(builder: (context) {
              if (_isLoading) {
                return CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                    }
                    _loadAvatarList().then((_) {
                      _isLoading = false;
                    });
                  },
                  child: Text(
                    "点击重试",
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                    ),
                  ),
                );
              }
            }),
          ],
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    }
  }
}

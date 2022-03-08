import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

/// 用于在启动 App 时展示教程图片的组件
class IntroImage extends StatefulWidget {
  final String imgUrl;
  final void Function() onFinished;
  final void Function() onSkip;
  final String skipText;
  final String nextText;

  const IntroImage(
      {Key? key,
      required this.imgUrl,
      required this.onFinished,
      required this.onSkip,
      this.skipText = "跳过",
      this.nextText = "下一步"})
      : super(key: key);

  @override
  _IntroImageState createState() {
    bool useLocalAssets = false;
    if (!imgUrl.startsWith("http")) {
      useLocalAssets = true;
    }
    return _IntroImageState(
      useLocalAssets: useLocalAssets,
      imgUrl: imgUrl,
      onFinished: onFinished,
      onSkip: onSkip,
      skipText: skipText,
      nextText: nextText,
    );
  }
}

class _IntroImageState extends State<IntroImage> {
  final bool useLocalAssets;
  final String imgUrl;
  final void Function() onFinished;
  final void Function() onSkip;
  final String skipText;
  final String nextText;

  _IntroImageState(
      {required this.useLocalAssets,
      required this.imgUrl,
      required this.onFinished,
      required this.onSkip,
      required this.skipText,
      required this.nextText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(50),
          child: Center(child: Builder(
            builder: (BuildContext context) {
              if (useLocalAssets) {
                return Image.asset(imgUrl);
              }
              return FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: imgUrl,
              );
            },
          )),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: OutlinedButton(
                  onPressed: onSkip,
                  child: Text(
                    this.skipText,
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color.fromARGB(100, 100, 100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    enableFeedback: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: OutlinedButton(
                  onPressed: onFinished,
                  child: Text(
                    this.nextText,
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color.fromARGB(100, 100, 100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    enableFeedback: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

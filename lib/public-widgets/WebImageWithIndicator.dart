import 'package:flutter/material.dart';

/// 用于加载网络图像的组件，该组件会在图像未加载完成时展示一个圆形进度条
class WebImageWithIndicator extends StatelessWidget {
  final imgURL;
  final width;
  const WebImageWithIndicator({Key? key, required this.imgURL, this.width }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imgURL,
      fit: BoxFit.fill,
      width: width,
      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}

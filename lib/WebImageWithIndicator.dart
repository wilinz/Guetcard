import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Const.dart';
import '../../../public-widgets/WebImageWithIndicator.dart';

/// 检查点照片组件
class CheckPointImageView extends StatefulWidget {
  const CheckPointImageView({Key? key}) : super(key: key);

  @override
  _CheckPointImageViewState createState() => _CheckPointImageViewState();
}

class _CheckPointImageViewState extends State<CheckPointImageView> {
  final List<String> checkPointImgs = [
    kIsWeb ? Const.networkImages["huajiang"]! : Const.assetImages["huajiang"]!,
    kIsWeb ? Const.networkImages["houjie"]! : Const.assetImages["houjie"]!,
    kIsWeb ? Const.networkImages["jinjiling"]! : Const.assetImages["jinjiling"]!,
    kIsWeb ? Const.networkImages["dongqu"]! : Const.assetImages["dongqu"]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.topCenter,
      child: Container(
        height: 450 / 1125 * MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Swiper(
          itemCount: checkPointImgs.length,
          itemBuilder: (context, index) {
            if (kIsWeb) {
              return WebImageWithIndicator(imgURL: checkPointImgs[index]);
            }
            return Image.asset(
              checkPointImgs[index],
              fit: BoxFit.fill,
            );
          },
        ),
      ),
    );
  }
}
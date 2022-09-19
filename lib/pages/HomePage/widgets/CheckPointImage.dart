import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Global.dart';
import '../../../public-widgets/WebImageWithIndicator.dart';

/// 检查点照片组件
class CheckPointImageView extends StatefulWidget {
  const CheckPointImageView({Key? key}) : super(key: key);

  @override
  _CheckPointImageViewState createState() => _CheckPointImageViewState();
}

class _CheckPointImageViewState extends State<CheckPointImageView> {
  final List<String> checkPointImgs = [
    kIsWeb ? Global.networkImages["huajiang"]! : Global.assetImages["huajiang"]!,
    kIsWeb ? Global.networkImages["houjie"]! : Global.assetImages["houjie"]!,
    kIsWeb ? Global.networkImages["jinjiling"]! : Global.assetImages["jinjiling"]!,
    kIsWeb ? Global.networkImages["dongqu"]! : Global.assetImages["dongqu"]!,
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

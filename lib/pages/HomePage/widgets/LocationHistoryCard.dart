import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/public-widgets/WebImageWithIndicator.dart';

import '../../../Const.dart';

/// 行程卡卡片
class LocationHistoryCard extends StatelessWidget {
  const LocationHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        width: width,
        height: width,
        padding: EdgeInsets.only(left: 12, right: 12, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "行程记录 >",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Center(
                heightFactor: 1.5,
                child: Container(
                  width: width * 0.3,
                  child: Builder(
                    builder: (BuildContext context) {
                      return kIsWeb
                          ? WebImageWithIndicator(imgURL: Const.networkImages["location-history"]!)
                          : Image.asset(Const.assetImages["location-history"]!);
                    },
                  ),
                )
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    "今日未核验",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                      "1秒前"
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}

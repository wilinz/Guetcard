import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/public-widgets/WebImageWithIndicator.dart';

import '../../../Const.dart';

class CovidTestCard extends StatelessWidget {
  const CovidTestCard({Key? key}) : super(key: key);

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
              "核酸检测 >",
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
                          ? WebImageWithIndicator(imgURL: Const.networkImages["test-tube"])
                          : Image.asset("assets/images/test-tube.png");
                    },
                  ),
                )
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    "近48小时无核酸记录",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                      "近4天未检测"
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
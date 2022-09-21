import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guet_card/Global.dart';
import 'package:guet_card/Providers/UsernameProvider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:transparent_image/transparent_image.dart';

/// 健康码卡片视图
class QrHealthCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int next(int min, int max) => min + Random().nextInt(max - min);
      final int randNum1 = next(203, 582);
      final int randNum2 = next(1365, 9658);
      final String time = DateTime.now().toString().split(":").sublist(0, 2).join(":");
      final double qrCodeScale = 0.5;
      var goldenEdge = kIsWeb
          ? FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: Global.networkImages["goldenEdge"]!,
              width: constraints.maxWidth * qrCodeScale,
            )
          : Image.asset(
              Global.assetImages["goldenEdge"]!,
              width: constraints.maxWidth * qrCodeScale,
            );
      var doneInjection = kIsWeb
          ? FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: Global.networkImages["doneInjection"]!,
              width: constraints.maxWidth * 0.8,
            )
          : Image.asset(
              Global.assetImages["doneInjection"]!,
              width: constraints.maxWidth * 0.8,
            );
      return Container(
        // color: Colors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "**${Provider.of<UsernameProvider>(context).username}的广西健康码",
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "PingFangSC-Heavy",
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                  Text(
                    "姓名：**${Provider.of<UsernameProvider>(context).username}\n证件类型：身份证\n证件号码：$randNum1********$randNum2",
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              //width: CardView.cardWidth * qrCodeScale,
              child: Stack(
                children: [
                  Center(
                    child: goldenEdge,
                  ),
                  Center(
                    child: Container(
                      child: QrImage(
                        data: "三点几辣！饮茶先辣！做做len啊做！饮茶先啦！",
                        foregroundColor: Color(0xFF00CC00),
                        size: constraints.maxWidth * 0.76 * qrCodeScale,
                      ),
                      width: constraints.maxWidth * qrCodeScale,
                      height: constraints.maxWidth * qrCodeScale,
                      alignment: Alignment.center,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -10),
              child: Column(
                children: [
                  Container(
                    child: doneInjection,
                    alignment: Alignment.center,
                  ),
                  Container(
                    child: Text(
                      "更新时间：$time",
                      style: TextStyle(
                        fontFamily: "PingFangSC",
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  Row(
                    children: [
                      Text(
                        "我的行程卡",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          fontSize: 15,
                          color: Color.fromARGB(255, 0, 180, 0),
                        ),
                      ),
                      Text(
                        "      |    ",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "疫苗接种记录",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          fontSize: 15,
                          color: Color.fromARGB(255, 0, 180, 0),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "依托全国一体化政务服务平台\n实现跨省（区、市）数据共享和互通互认\n数据来源：国家政务服务平台（广西壮族自治区）||广西壮族自治区大数据发展局",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "PingFangSC",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 17,
                        height: 17,
                        color: Color(0xFF00CC00),
                      ),
                      SizedBox(width: 5, height: 0),
                      Text(
                        "可通行",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 30, height: 0),
                      Container(
                        width: 17,
                        height: 17,
                        color: Color(0xFFFE9900),
                      ),
                      SizedBox(width: 5, height: 0),
                      Text(
                        "限制通行",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 30, height: 0),
                      Container(
                        width: 17,
                        height: 17,
                        color: Color(0xFFFE0000),
                      ),
                      SizedBox(width: 5, height: 0),
                      Text(
                        "不可通行",
                        style: TextStyle(
                          fontFamily: "PingFangSC",
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';

/// 反诈中心卡片
class AntiScamCard extends StatelessWidget {
  const AntiScamCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 30, 64, 221),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Text(
            "注册“金钟罩”、国家反诈中心",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5,),
          Text(
            "科技防诈让你远离诈骗侵害",
            style: TextStyle(
                color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

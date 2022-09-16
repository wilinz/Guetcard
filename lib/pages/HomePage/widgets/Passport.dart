import 'package:flutter/material.dart';

/// 显示通行证的假按钮
class Passport extends StatelessWidget {
  const Passport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: 增加点击展开功能
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            // border: Border.symmetric(
            //   vertical: BorderSide.none,
            //   horizontal: BorderSide(
            //     // 用上下 border 充当分割线
            //     color: Color.fromARGB(255, 240, 240, 240),
            //     width: 0.7,
            //   ),
            // ),
            color: Colors.white,
          ),
          height: 45,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF03C160),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    "已同意",
                    style: TextStyle(
                      fontFamily: "PingFangSC",
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                width: 40,
                height: 20,
              ),
              SizedBox.fromSize(
                size: Size(5, 0),
              ),
              Text(
                "桂电学生桂电学生临时通行证",
                style: TextStyle(
                  fontFamily: "PingFangSC",
                  color: Colors.black,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.expand_more_outlined,
                color: Color.fromARGB(255, 195, 195, 195),
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
        )
      ],
    );
  }
}

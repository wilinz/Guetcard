import 'package:flutter/material.dart';

/// 显示通行证的假按钮
class Passport extends StatefulWidget {
  const Passport({Key? key}) : super(key: key);

  @override
  State<Passport> createState() => _PassportState();
}

class _PassportState extends State<Passport> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
            }),
            child: Container(
              height: 45,
              child: Row(
                children: [
                  SizedBox.square(dimension: 50),
                  Spacer(),
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
                  Spacer(),
                  SizedBox.square(
                    dimension: 50,
                    child: Icon(
                      _isExpanded ? Icons.expand_less_outlined : Icons.expand_more_outlined,
                      color: Color.fromARGB(255, 195, 195, 195),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ),
          _isExpanded
              ? Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 20,
                )
              : Container(),
          _isExpanded
              ? Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '每1天可使用4次，剩余3次',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                          ),
                          Text(
                            '提交后系统自动审核，总限制通行4次',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

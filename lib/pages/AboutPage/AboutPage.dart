import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:guet_card/Const.dart';
import 'package:guet_card/public-classes/CheckingUpdate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String VERSION = "v1.5.4";

/// “关于”页面，使用 Markdown 组件渲染显示
class AboutPage extends StatelessWidget {
  AboutPage({Key? key}) : super(key: key);
  final String _md = '''
# guet_card $VERSION
一个使用 Flutter 重写的 [guet_card](https://gitee.com/guetcard/guetcard)，支持 Android、iOS、[网页端](https://guet-card.web.app)。

此项目为 demo 项目，仅为个人兴趣开发，是学习 Flutter 框架之用，请各位遵循此原则，勿作他用。

![](${Const.networkImages["showUseGuideImg"]!})

# 版权信息
本项目使用 [MIT](https://gitee.com/guetcard/guetcard/blob/master/LICENSE) 授权。
''';

  @override
  Widget build(BuildContext context) {
    List<Widget> _actions = [
      Padding(
        padding: EdgeInsets.only(right: 10),
        child: TextButton(
          child: Text(
            "下次显示教程",
            style: TextStyle(color: Colors.white, fontFamily: "PingFangSC"),
          ),
          onPressed: () async {
            var pref = await SharedPreferences.getInstance();
            pref.setBool("isSkipGuide", false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('👌下次启动时将会显示教程'),
              ),
            );
          },
        ),
      ),
    ];

    if (!kIsWeb) {
      _actions.add(
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: TextButton(
            onPressed: () {
              CheckingUpdate.checkForUpdate(context);
            },
            child: Text(
              "检查更新",
              style: TextStyle(color: Colors.white, fontFamily: "PingFangSC"),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "关于",
          style: TextStyle(
            fontFamily: "PingFangSC",
            color: Colors.white,
          ),
        ),
        toolbarHeight: 50,
        iconTheme: IconThemeData(color: Colors.white),
        actions: _actions,
      ),
      body: Markdown(
        data: _md,
        selectable: true,
        onTapLink: (String text, String? href, String title) async {
          if (href != null) {
            final uri = Uri.parse(href);
            await canLaunchUrl(uri) ? await launchUrl(uri) : throw "url_launch 无法打开 $href";
          } else {
            throw "点击的链接 (text: $text, title: $title) 中不包含 URL";
          }
        },
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontFamily: "PingFangSC",
              ),
          a: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontFamily: "PingFangSC",
                decoration: TextDecoration.underline,
              ),
          strong: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontFamily: "PingFangSC-Regular",
                fontWeight: FontWeight.bold,
              ),
          h1: Theme.of(context).textTheme.headline1!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 24,
              ),
          h2: Theme.of(context).textTheme.headline2!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 20,
              ),
          h3: Theme.of(context).textTheme.headline3!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 18,
              ),
          h4: Theme.of(context).textTheme.headline4!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 16,
              ),
          h5: Theme.of(context).textTheme.headline5!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 15,
              ),
          h6: Theme.of(context).textTheme.headline6!.copyWith(
                fontFamily: "PingFangSC-Heavy",
                fontSize: 14,
              ),
        ),
      ),
    );
  }
}

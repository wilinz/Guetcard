import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:guet_card/CheckingUpdate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

var VERSION = "v1.4.5";

/// “关于”页面，使用 Markdown 组件渲染显示
class AboutPage extends StatelessWidget {
  AboutPage({Key? key}) : super(key: key);
  var _md = '''
# guet_card $VERSION
一个使用 Flutter 重写的 guet_card，支持 Android、iOS、网页端。
此项目为 demo 项目，仅为个人兴趣开发，是学习 Flutter 框架之用，请各位遵循此原则，勿作他用。

![](https://i.loli.net/2021/09/29/5nUS63TpLlmhjJZ.jpg)

gitee 主页为：[gitee](https://gitee.com/guetcard/guetcard)

如果需要反馈问题或提交建议，请提交 [issue](https://gitee.com/guetcard/guetcard/issues) 或发送邮件到 [guetcard@pm.me](mailto:guetcard@pm.me)

## 如何使用
1. 如果你是安卓用户：
    在 [release](https://gitee.com/guetcard/guetcard/releases) 页面中下载 apk 安装包安装
    
2. 如果你是 iPhone 用户：
    1. （推荐）将[此页面](https://guet-card.web.app)添加到主屏幕，作为一个网页应用使用
    2. 使用 AltStore 自签或越狱后安装 [release](https://gitee.com/guetcard/guetcard/releases) 页面中的 ipa 安装包。


# 版权信息
本项目使用 [MIT 授权](https://gitee.com/guetcard/guetcard/blob/master/LICENSE)。

# 致谢
- 感谢 [Flutter](https://flutter.dev/) 提供了优秀易用的跨平台 GUI 框架
- 感谢 [sm.ms](https://sm.ms) 提供了稳定的图床服务
- 感谢开源社区提供了很多优秀的教程和示例项目

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
              CheckingUpdate _checkingUpdate = CheckingUpdate();
              _checkingUpdate.checkForUpdate(context);
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
            await canLaunch(href)
                ? await launch(href)
                : throw "url_launch 无法打开 $href";
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
            color: Colors.green,
          ),
          strong: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontFamily: "PingFangSC-Bold",
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

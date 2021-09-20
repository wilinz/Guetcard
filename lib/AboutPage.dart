import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// “关于”页面，使用 Markdown 组件渲染显示
class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);
  static const md = '''
# guet_card v1.2.0
一个使用 Flutter 重写的 guet_card，支持 Android、iOS、网页端。
此项目为 demo 项目，仅为个人兴趣开发，是学习 Flutter 框架之用，请各位遵循此原则，勿作他用。

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
    return Scaffold(
      appBar: AppBar(
        title: Text("关于", style: TextStyle(color: Colors.white),),
        toolbarHeight: 50,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Markdown(
        data: md,
        selectable: true,
        onTapLink: (String text, String href, String title) async {
          await canLaunch(href)? await launch(href) : throw "url_launch 无法打开 $href";
        },
      ),
    );
  }
}

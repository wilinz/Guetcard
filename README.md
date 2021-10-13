## ⚠️警告
由于 iOS 15 的 CanvasKit 存在 bug，无法显示出页面。如已升级到 iOS 15，请按照以下步骤关闭 CanvasKit 功能：

$\color{red}{打开「设置 - Safari 浏览器 - 高级 - Experimental Features」，找到「GPU Process: Canvas Rendering」选项，将其关闭}$

# guet_card

一个使用 Flutter 重写的 guet_card，支持 Android、iOS、网页端。
此项目为 demo 项目，仅为个人兴趣开发，是学习 Flutter 框架之用，请各位遵循此原则，勿作他用。

<img src="https://i.loli.net/2021/09/29/5nUS63TpLlmhjJZ.jpg" alt="tutorial.png" style="zoom: 50%;" />

## 安装和使用
1. 如果你是安卓用户：
    在 [release](https://gitee.com/guetcard/guetcard/releases) 页面中下载 apk 安装包安装
    
2. 如果你是 iPhone 用户：
    两种方法：
    1. （推荐）将[此页面](https://guet-card.web.app)添加到主屏幕，作为一个网页应用使用

    <img src="https://i.loli.net/2021/09/22/1m5Aj7txbpklY9E.jpg" style="zoom: 33%;" />

    2. 使用 AltStore 自签或越狱后安装 [release](https://gitee.com/guetcard/guetcard/releases) 页面中的 ipa 安装包。

## 构建
```
flutter pub get
flutter build apk  # 构建 Android 版本
flutter build ios  # 构建 iOS 版本
flutter build web  # 构建 web 版本
```
或者使用 `./build.sh` 构建脚本

## 我如何帮忙？
1. 使用**匿名邮箱**，如 ProtonMail 注册一个账号
2. Fork 这个仓库
3. 做出修改后在原仓库提交 PR
4. 多次作出贡献后加入组织
5. 在原作者毕业后接手代码（笑）
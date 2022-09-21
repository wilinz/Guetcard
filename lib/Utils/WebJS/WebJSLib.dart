/// 此文件与 WebJSInterface.dart 是一对互相配合引入的文件，引入代码如下
/// ```dart
/// import "WebJSInterface.dart" if (dart.library.js) 'WebJSLib.dart';
/// ```
/// 由此文件提供实际功能，FakeJSLib 提供非 web 平台的空函数
/// JavaScript 中提供的方法位于 web/JsLib.js 文件中
import 'dart:js' as js;

String? getUA() => js.context.callMethod('getUA');
bool? isPwaInstalled() => js.context.callMethod("isPwaInstalled");

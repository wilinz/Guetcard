/// 此文件与 WebJSLib.dart 是一对互相配合引入的文件，引入代码如下
/// ```dart
/// import "WebJSInterface.dart" if (dart.library.js) 'WebJSLib.dart';
/// ```
/// 由 WebJSLib 提供实际功能，此文件提供非 web 平台的空函数
/// /// JavaScript 中提供的方法位于 web/JsLib.js 文件中

String? getUA() => null;
bool? isPwaInstalled() => null;

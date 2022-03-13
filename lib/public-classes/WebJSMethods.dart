import 'FakeJSLib.dart' if (dart.library.js) 'WebJSLib.dart' as lib;

class WebJSMethods {
  static String? getUserAgent() => lib.getUA();
  static bool? isPwaInstalled() => lib.isPwaInstalled();
}
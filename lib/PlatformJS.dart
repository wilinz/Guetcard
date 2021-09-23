import 'dart:js' as js;

class PlatformJS {
  late String name, version;

  PlatformJS() {
    var p = js.JsObject.fromBrowserObject(js.context['platform']);
    name = p['name'];
    version = p['version'];
  }

  bool isSafari15() {
    return name.toLowerCase() == "safari" &&
        int.parse(version.split(".")[0]) >= 15;
  }
}
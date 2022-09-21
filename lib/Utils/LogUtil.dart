import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LogUtil {
  static void error({required String message, Object? error, StackTrace? stackTrace}) {
    Map<String, dynamic> logObj = {
      'level': 'error',
      'message': '$message',
      'error': '$error',
      'stackTrace': '$stackTrace',
    };
    debugPrint(logObj.toString());
    FirebaseAnalytics.instance.logEvent(name: message, parameters: logObj);
  }

  static void warning({required String message, Object? error, StackTrace? stackTrace}) {
    Map<String, dynamic> logObj = {
      'level': 'warning',
      'message': '$message',
      'error': '$error',
      'stackTrace': '$stackTrace',
    };
    debugPrint(logObj.toString());
  }

  static void debug({required String message, Object? error, StackTrace? stackTrace}) {
    Map<String, dynamic> logObj = {
      'level': 'debug',
      'message': '$message',
      'error': '$error',
      'stackTrace': '$stackTrace',
    };
    debugPrint(logObj.toString());
  }

  static void info({required String message, Object? error, StackTrace? stackTrace}) {
    Map<String, dynamic> logObj = {
      'level': 'info',
      'message': '$message',
      'error': '$error',
      'stackTrace': '$stackTrace',
    };
    debugPrint(logObj.toString());
  }
}

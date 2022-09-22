import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Http {
  static late final Dio _dio;
  Dio get dio => _dio;
  static Http? _http;

  factory Http() {
    if (_http == null) {
      _http = Http._();
    }
    return _http!;
  }

  Http._() {
    _dio = Dio()
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kIsWeb) {
            String originalUrl = options.uri.toString();
            RequestOptions newOptions = options.copyWith(
              baseUrl: 'http://127.0.0.1:12309',
              path: '/guet-card/us-central1/proxy?url=${Uri.encodeFull(originalUrl)}',
            );
            return handler.next(newOptions);
          }
          return handler.next(options);
        },
      ));
  }
}

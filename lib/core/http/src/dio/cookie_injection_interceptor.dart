// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../cookie_utils.dart';

class CookieInjectionInterceptor extends Interceptor {
  const CookieInjectionInterceptor({
    required this.cookie,
  });

  final String cookie;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (cookie.isNotEmpty) {
      final existingCookies = options.headers['cookie'] as String? ?? '';
      options.headers['cookie'] = CookieUtils.mergeCookieHeaders(
        existingCookies,
        cookie,
      );
    }

    super.onRequest(options, handler);
  }
}

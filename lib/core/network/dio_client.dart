import 'package:dio/dio.dart';
import 'package:moviemaster/core/config/app_config.dart';

class DioClient {
  final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.tmdbBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  DioClient() {
    dio.options.queryParameters['api_key'] = AppConfig.tmdbApiKey;
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: false,
      responseHeader: false,
    ));
  }
}
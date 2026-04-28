import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.music.apple.com/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // Add interceptors for headers (Developer Token)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final developerToken = dotenv.env['APPLE_MUSIC_DEVELOPER_TOKEN'] ?? '';
        if (developerToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $developerToken';
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
}

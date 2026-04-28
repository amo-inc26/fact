import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
        // TODO: Get actual token from secure storage or config
        const developerToken = 'YOUR_DEVELOPER_TOKEN';
        options.headers['Authorization'] = 'Bearer $developerToken';
        return handler.next(options);
      },
    ),
  );

  return dio;
}

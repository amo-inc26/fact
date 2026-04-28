import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:music_kit/music_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'apple_music_token_provider.g.dart';

@riverpod
class AppleMusicToken extends _$AppleMusicToken {
  static const _tokenKey = 'apple_music_user_token';

  @override
  FutureOr<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> requestToken(String developerToken) async {
    final musicKit = MusicKit();
    
    // Check current status
    final status = await musicKit.authorizationStatus;
    if (status is! MusicAuthorizationStatusAuthorized) {
      final newStatus = await musicKit.requestAuthorizationStatus();
      if (newStatus is! MusicAuthorizationStatusAuthorized) {
        throw Exception('MusicKit authorization denied');
      }
    }

    // Request User Token
    final userToken = await musicKit.requestUserToken(developerToken);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, userToken);
    
    state = AsyncData(userToken);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    state = const AsyncData(null);
  }
}

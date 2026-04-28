import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'music_sync_service.g.dart';

@riverpod
class MusicSyncService extends _$MusicSyncService {
  @override
  FutureOr<void> build() async {}

  /// 外部サービス（Apple Music/Spotify）に楽曲を同期
  Future<void> syncLikedSong({
    required String title,
    required String artist,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // ユーザーの連携状態を確認
      final profile = await supabase
          .from('profiles')
          .select('apple_music_token, spotify_token')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) return;

      if (profile['apple_music_token'] != null) {
        await _addToAppleMusic(title, artist, profile['apple_music_token']);
      }

      if (profile['spotify_token'] != null) {
        await _addToSpotify(title, artist, profile['spotify_token']);
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  /// Apple Music への追加処理
  /// 
  /// 実行には Apple Developer Program の MusicKit 設定が必要です。
  /// [token] は Apple Music の User Token を想定しています。
  Future<void> _addToAppleMusic(String title, String artist, String token) async {
    // TODO: MusicKit JS または REST API (v1/me/library/playlists) を使用して楽曲を追加
    debugPrint('MusicSync: Syncing to Apple Music -> $title by $artist');
  }

  /// Spotify への追加処理
  /// 
  /// 実行には Spotify for Developers での Client ID 設定が必要です。
  /// [token] は OAuth2 の Access Token を想定しています。
  Future<void> _addToSpotify(String title, String artist, String token) async {
    // TODO: Spotify Web API (POST /v1/playlists/{playlist_id}/tracks) を使用して楽曲を追加
    debugPrint('MusicSync: Syncing to Spotify -> $title by $artist');
  }
  
  /// 外部サービスとの連携開始フロー
  /// 
  /// 認証用の Web ブラウザを起動し、トークンを取得して profiles テーブルに保存します。
  Future<void> linkService(String service) async {
    debugPrint('MusicSync: Starting link flow for $service');
    // TODO: flutter_web_auth 等を使用した OAuth 認証フローの実装
  }
}

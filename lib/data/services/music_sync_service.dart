import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:music_kit/music_kit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

part 'music_sync_service.g.dart';

@riverpod
class MusicSyncService extends _$MusicSyncService {
  final _musicKitPlugin = MusicKit();
  final _dio = Dio();

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

  /// Apple Music への追加
  Future<void> _addToAppleMusic(String title, String artist, String userToken) async {
    final devToken = dotenv.env['APPLE_MUSIC_DEVELOPER_TOKEN'];
    if (devToken == null) return;

    final headers = {
      'Authorization': 'Bearer $devToken',
      'Music-User-Token': userToken,
      'Content-Type': 'application/json',
    };

    try {
      // 1. 曲を検索して ID を取得
      final searchRes = await _dio.get(
        'https://api.music.apple.com/v1/catalog/jp/search',
        queryParameters: {'term': '$title $artist', 'types': 'songs', 'limit': 1},
        options: Options(headers: headers),
      );

      final songs = searchRes.data['results']['songs']?['data'] as List?;
      if (songs == null || songs.isEmpty) {
        debugPrint('Apple Music: Song not found -> $title by $artist');
        return;
      }
      final songId = songs.first['id'];

      // 2. 「Fact Likes」プレイリストを探す、または作成する
      String? playlistId;
      final playlistsRes = await _dio.get(
        'https://api.music.apple.com/v1/me/library/playlists',
        options: Options(headers: headers),
      );

      final playlists = playlistsRes.data['data'] as List;
      for (var p in playlists) {
        if (p['attributes']['name'] == 'Fact Likes') {
          playlistId = p['id'];
          break;
        }
      }

      if (playlistId == null) {
        final createRes = await _dio.post(
          'https://api.music.apple.com/v1/me/library/playlists',
          data: {
            'attributes': {'name': 'Fact Likes', 'description': 'Synced from Fact app'}
          },
          options: Options(headers: headers),
        );
        playlistId = createRes.data['data'][0]['id'];
      }

      // 3. 楽曲を追加
      await _dio.post(
        'https://api.music.apple.com/v1/me/library/playlists/$playlistId/tracks',
        data: {
          'data': [
            {'id': songId, 'type': 'songs'}
          ]
        },
        options: Options(headers: headers),
      );

      debugPrint('Apple Music: Successfully added $title to playlist');
    } catch (e) {
      debugPrint('Apple Music Sync Error: $e');
    }
  }

  /// Spotify への追加
  Future<void> _addToSpotify(String title, String artist, String token) async {
    // TODO: Spotify Web API を叩いてプレイリスト「Fact Likes」へ楽曲を追加
    debugPrint('MusicSync: Syncing $title to Spotify...');
  }
  
  /// 連携開始
  Future<void> linkService(String service) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (service == 'Apple Music') {
      try {
        final status = await _musicKitPlugin.requestAuthorizationStatus();
        if (status is MusicAuthorizationStatusAuthorized) {
          final devToken = dotenv.env['APPLE_MUSIC_DEVELOPER_TOKEN'];
          if (devToken == null || devToken.isEmpty) {
            debugPrint('Error: APPLE_MUSIC_DEVELOPER_TOKEN is missing in .env');
            return;
          }

          final userToken = await _musicKitPlugin.requestUserToken(devToken);
          await supabase.from('profiles').update({'apple_music_token': userToken}).eq('id', user.id);
          debugPrint('Apple Music linked successfully');
        } else {
          debugPrint('Apple Music authorization denied: $status');
        }
      } catch (e) {
        debugPrint('Apple Music link error: $e');
      }
    } else if (service == 'Spotify') {
      // TODO: Spotify OAuth 連携
      debugPrint('Spotify Link: Please configure CLIENT_ID to enable OAuth');
    }
  }
}

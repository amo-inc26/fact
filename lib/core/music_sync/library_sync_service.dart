import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/dio_provider.dart';
import 'apple_music_token_provider.dart';

part 'library_sync_service.g.dart';

@riverpod
class LibrarySyncService extends _$LibrarySyncService {
  @override
  void build() {}

  Future<void> syncLikedSongsToAppleMusic() async {
    final userToken = await ref.read(appleMusicTokenProvider.future);
    if (userToken == null) {
      throw Exception('Apple Music not authorized');
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // 1. Fetch liked songs from Supabase
    final response = await Supabase.instance.client
        .from('liked_songs')
        .select()
        .eq('user_id', user.id);
    
    final likedSongs = response as List;
    if (likedSongs.isEmpty) return;

    // 2. Find or Create "Music Resonance" Playlist
    String? playlistId = await _findResonancePlaylist(userToken);
    playlistId ??= await _createResonancePlaylist(userToken);

    // 3. Get existing tracks in playlist to avoid duplicates
    final existingTracks = await _getPlaylistTracks(playlistId, userToken);

    // 4. Match and Add new songs
    for (final song in likedSongs) {
      final trackId = await _searchTrackId(song['title'], song['artist']);
      if (trackId != null && !existingTracks.contains(trackId)) {
        await _addTrackToPlaylist(playlistId, trackId, userToken);
      }
    }
  }

  Future<String?> _findResonancePlaylist(String userToken) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/me/library/playlists',
      options: Options(headers: {'Music-User-Token': userToken}),
    );
    
    final playlists = response.data['data'] as List;
    for (final p in playlists) {
      if (p['attributes']['name'] == 'Music Resonance') {
        return p['id'];
      }
    }
    return null;
  }

  Future<String> _createResonancePlaylist(String userToken) async {
    final dio = ref.read(dioProvider);
    final response = await dio.post(
      '/me/library/playlists',
      data: {
        'attributes': {
          'name': 'Music Resonance',
          'description': 'Resonated songs from Fact app',
        }
      },
      options: Options(headers: {'Music-User-Token': userToken}),
    );
    
    return response.data['data'][0]['id'];
  }

  Future<Set<String>> _getPlaylistTracks(String playlistId, String userToken) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get(
        '/me/library/playlists/$playlistId/tracks',
        options: Options(headers: {'Music-User-Token': userToken}),
      );
      
      final tracks = response.data['data'] as List;
      return tracks.map((t) => t['id'] as String).toSet();
    } catch (e) {
      return {};
    }
  }

  Future<String?> _searchTrackId(String title, String artist) async {
    final dio = ref.read(dioProvider);
    try {
      final response = await dio.get(
        '/catalog/jp/search',
        queryParameters: {
          'term': '$title $artist',
          'types': 'songs',
          'limit': 1,
        },
      );
      
      final songs = response.data['results']['songs']['data'] as List;
      if (songs.isNotEmpty) {
        return songs[0]['id'];
      }
    } catch (_) {}
    return null;
  }

  Future<void> _addTrackToPlaylist(String playlistId, String trackId, String userToken) async {
    final dio = ref.read(dioProvider);
    await dio.post(
      '/me/library/playlists/$playlistId/tracks',
      data: {
        'data': [
          {'id': trackId, 'type': 'songs'}
        ]
      },
      options: Options(headers: {'Music-User-Token': userToken}),
    );
  }
}

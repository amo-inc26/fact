import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/song_model.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineController extends _$TimelineController {
  @override
  FutureOr<List<SongModel>> build({
    bool isFollowing = false,
    String? genre,
    String? feeling,
    String? scene,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    List<dynamic> postsData = [];
    
    if (isFollowing && user != null) {
      final followingResponse = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', user.id);
      
      final followingIds = (followingResponse as List)
          .map((f) => f['following_id'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      final query = supabase
          .from('posts')
          .select('*, profiles:user_id (username, avatar_url)')
          .inFilter('user_id', followingIds);
      
      final response = await query.order('created_at', ascending: false).limit(50);
      postsData = response as List;
    } else {
      var query = supabase
          .from('posts')
          .select('*, profiles:user_id (username, avatar_url)');
      
      if (genre != null) {
        query = query.eq('genre', genre);
      } else if (feeling != null) {
        query = query.eq('feeling', feeling);
      } else if (scene != null) {
        query = query.eq('scene', scene);
      }
      
      final response = await query.order('created_at', ascending: false).limit(50);
      postsData = response as List;
    }
    
    return await _mapPostsToSongs(postsData);
  }

  Future<List<SongModel>> _mapPostsToSongs(List<dynamic> items) async {
    final List<SongModel> songs = [];
    for (final item in items) {
      final profile = item['profiles'];
      
      final resonanceResponse = await Supabase.instance.client
          .from('liked_songs')
          .select('id')
          .eq('title', item['track_name'])
          .eq('artist', item['artist_name']);
      
      songs.add(SongModel(
        id: item['id'],
        name: item['track_name'],
        artistName: item['artist_name'],
        albumName: '',
        artworkUrl: item['artwork_url'] ?? '',
        previewUrl: item['preview_url'] ?? '',
        genres: item['genre'] != null ? [item['genre']] : [],
        userId: item['user_id'],
        username: profile != null ? profile['username'] : 'Unknown',
        comment: item['comment'],
        resonanceCount: (resonanceResponse as List).length,
      ));
    }
    return songs;
  }

  Future<void> handleSwipe(int index, String direction) async {
    final songs = state.value ?? [];
    if (index >= songs.length) return;
    
    final song = songs[index];
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    double scoreDelta = 0;
    if (direction == 'right') {
      scoreDelta = 1.0;
      await _saveLikedSong(user.id, song);
    } else if (direction == 'up') {
      scoreDelta = 0.5;
    } else if (direction == 'left') {
      scoreDelta = -1.0;
    }

    for (final genre in song.genres) {
      await _updateGenreScore(user.id, genre, scoreDelta);
    }
  }

  Future<void> _updateGenreScore(String userId, String genre, double delta) async {
    final supabase = Supabase.instance.client;
    final existing = await supabase
        .from('user_genre_preferences')
        .select()
        .eq('user_id', userId)
        .eq('genre', genre)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('user_genre_preferences').insert({
        'user_id': userId,
        'genre': genre,
        'preference_score': 1.0 + delta,
      });
    } else {
      final currentScore = (existing['preference_score'] as num).toDouble();
      await supabase.from('user_genre_preferences').update({
        'preference_score': currentScore + delta,
      }).eq('id', existing['id']);
    }
  }

  Future<void> _saveLikedSong(String userId, SongModel song) async {
    await Supabase.instance.client.from('liked_songs').insert({
      'user_id': userId,
      'track_id': song.id,
      'title': song.name,
      'artist': song.artistName,
      'image_url': song.artworkUrl,
      'preview_url': song.previewUrl,
    });
  }
}

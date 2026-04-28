import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/song_model.dart';
import '../post/post_provider.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineController extends _$TimelineController {
  @override
  FutureOr<List<SongModel>> build() async {
    // PostController から全ユーザーの投稿を取得
    final posts = await ref.watch(postControllerProvider.future);
    
    return posts.map((post) => SongModel(
      id: post.id,
      name: post.trackName,
      artistName: post.artistName,
      albumName: '',
      artworkUrl: post.artworkUrl ?? '',
      previewUrl: post.previewUrl ?? '',
      genres: post.genre != null ? [post.genre!] : [],
      username: post.username,
      comment: post.comment,
      resonanceCount: post.resonanceCount,
    )).toList();
  }

  Future<void> handleSwipe(int index, String direction) async {
    final songs = state.value ?? [];
    if (index >= songs.length) return;
    
    final song = songs[index];
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // スコアリング (右:+1.0, 上:+0.5, 左:-1.0)
    double scoreDelta = 0;
    if (direction == 'right') {
      scoreDelta = 1.0;
      await _saveLikedSong(user.id, song);
    } else if (direction == 'up') {
      scoreDelta = 0.5;
    } else if (direction == 'left') {
      scoreDelta = -1.0;
    }

    // ジャンルの嗜好スコアを更新
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

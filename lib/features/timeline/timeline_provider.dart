import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/audio/audio_player_provider.dart';
import '../../data/models/song_model.dart';
import '../../data/services/apple_music_service.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineController extends _$TimelineController {
  @override
  FutureOr<List<SongModel>> build() async {
    final songs = await ref.read(appleMusicServiceProvider.notifier).fetchTopCharts();
    
    // Play first song
    if (songs.isNotEmpty) {
      _playSong(songs.first);
    }
    
    return songs;
  }

  void _playSong(SongModel song) {
    ref.read(audioPlayerControllerProvider.notifier).playUrl(song.previewUrl);
  }

  Future<void> handleSwipe(int index, String direction) async {
    final songs = state.value ?? [];
    if (index >= songs.length) return;
    
    final song = songs[index];
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Scoring Logic
    int scoreDelta = 0;
    if (direction == 'right') {
      scoreDelta = 5;
      await _saveLikedSong(user.id, song);
    } else if (direction == 'up') {
      scoreDelta = 10;
    } else if (direction == 'left') {
      scoreDelta = -2;
    }

    // Update Genre Preferences in Supabase
    for (final genre in song.genres) {
      await _updateGenreScore(user.id, genre, scoreDelta);
    }

    // Play next song
    if (index + 1 < songs.length) {
      _playSong(songs[index + 1]);
    } else {
      ref.read(audioPlayerControllerProvider.notifier).stop();
    }
  }

  Future<void> _updateGenreScore(String userId, String genre, int delta) async {
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
        'preference_score': 5 + delta,
      });
    } else {
      await supabase.from('user_genre_preferences').update({
        'preference_score': (existing['preference_score'] as int) + delta,
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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/song_model.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<List<SongModel>> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final response = await Supabase.instance.client
        .from('liked_songs')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((item) {
      return SongModel(
        id: item['track_id'],
        name: item['title'],
        artistName: item['artist'],
        albumName: '', // Not stored in liked_songs yet
        artworkUrl: item['image_url'],
        previewUrl: item['preview_url'],
        genres: [], // Not stored in liked_songs yet
      );
    }).toList();
  }
}

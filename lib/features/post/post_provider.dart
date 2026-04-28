import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/post_model.dart';

part 'post_provider.g.dart';

@riverpod
class PostController extends _$PostController {
  @override
  FutureOr<List<PostModel>> build() async {
    final response = await Supabase.instance.client
        .from('posts')
        .select('''
          *,
          profiles:user_id (username, avatar_url)
        ''')
        .order('created_at', ascending: false)
        .limit(50);

    final List<PostModel> posts = [];
    for (final item in (response as List)) {
      final profile = item['profiles'];
      
      // Fetch resonance count (total likes for this track)
      final resonanceResponse = await Supabase.instance.client
          .from('liked_songs')
          .select('id')
          .eq('title', item['track_name'])
          .eq('artist', item['artist_name']);

      final count = (resonanceResponse as List).length;

      posts.add(PostModel(
        id: item['id'],
        userId: item['user_id'],
        trackName: item['track_name'],
        artistName: item['artist_name'],
        artworkUrl: item['artwork_url'],
        previewUrl: item['preview_url'],
        comment: item['comment'],
        genre: item['genre'],
        createdAt: DateTime.parse(item['created_at']),
        username: profile != null ? profile['username'] : 'Unknown',
        avatarUrl: profile != null ? profile['avatar_url'] : null,
        resonanceCount: count,
      ));
    }

    return posts;
  }

  Future<void> createPost({
    required String trackName,
    required String artistName,
    String? artworkUrl,
    String? previewUrl,
    String? comment,
    String? genre,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('posts').insert({
      'user_id': user.id,
      'track_name': trackName,
      'artist_name': artistName,
      'artwork_url': artworkUrl,
      'preview_url': previewUrl,
      'comment': comment,
      'genre': genre,
      'track_id': '${trackName}_$artistName',
    });
    
    ref.invalidateSelf();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/post_model.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileData> build({String? userId}) async {
    return _fetchProfileData(userId);
  }

  Future<ProfileData> _fetchProfileData(String? targetUserId) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final targetId = targetUserId ?? currentUser.id;
    final isMe = targetId == currentUser.id;

    // プロフィール情報の取得
    final profileResponse = await supabase
        .from('profiles')
        .select()
        .eq('id', targetId)
        .maybeSingle();

    final profile = profileResponse ?? {
      'id': targetId,
      'username': 'User',
      'avatar_url': null,
      'bio': '',
    };

    // 「感性の門番」チェック：自分以外の場合、共鳴があるか確認
    bool hasResonance = isMe;
    if (!isMe) {
      // 1. 相手の全投稿曲（タイトルとアーティスト）を取得
      final targetPosts = await supabase
          .from('posts')
          .select('track_name, artist_name')
          .eq('user_id', targetId);
      
      if ((targetPosts as List).isNotEmpty) {
        // 2. 自分がいいねした曲の中に、相手の投稿曲があるか確認
        final trackNames = targetPosts.map((p) => p['track_name'] as String).toList();
        final resonanceCheck = await supabase
            .from('liked_songs')
            .select('id')
            .eq('user_id', currentUser.id)
            .inFilter('title', trackNames)
            .limit(1);
        
        hasResonance = (resonanceCheck as List).isNotEmpty;
      }
    }

    // 投稿一覧の取得（共鳴がある場合、または自分の場合のみ）
    List<PostModel> posts = [];
    if (hasResonance) {
      final postsResponse = await supabase
          .from('posts')
          .select('*, profiles:user_id (username, avatar_url)')
          .eq('user_id', targetId)
          .order('created_at', ascending: false);

      posts = (postsResponse as List).map((item) {
        final profile = item['profiles'];
        return PostModel(
          id: item['id'],
          userId: item['user_id'],
          trackName: item['track_name'],
          artistName: item['artist_name'],
          artworkUrl: item['artwork_url'],
          previewUrl: item['preview_url'],
          comment: item['comment'],
          genre: item['genre'],
          feeling: item['feeling'],
          scene: item['scene'],
          createdAt: DateTime.parse(item['created_at']),
          username: profile != null ? profile['username'] : 'Unknown',
          avatarUrl: profile != null ? profile['avatar_url'] : null,
          resonanceCount: 0,
        );
      }).toList();
    }

    // フォロー状態の取得
    bool isFollowing = false;
    if (!isMe) {
      final followCheck = await supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUser.id)
          .eq('following_id', targetId)
          .maybeSingle();
      isFollowing = followCheck != null;
    }

    return ProfileData(
      profile: profile,
      posts: posts,
      isMe: isMe,
      hasResonance: hasResonance,
      isFollowing: isFollowing,
    );
  }

  Future<void> toggleFollow(String targetUserId) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final data = state.value;
    if (data == null) return;

    if (data.isFollowing) {
      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUser.id)
          .eq('following_id', targetUserId);
    } else {
      await supabase.from('follows').insert({
        'follower_id': currentUser.id,
        'following_id': targetUserId,
      });
    }

    ref.invalidateSelf();
  }

  Future<void> updateProfile({String? username, String? bio, String? avatarUrl}) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (username != null) updateData['username'] = username;
    if (bio != null) updateData['bio'] = bio;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    await supabase.from('profiles').update(updateData).eq('id', user.id);

    ref.invalidateSelf();
  }
}

class ProfileData {
  final Map<String, dynamic> profile;
  final List<PostModel> posts;
  final bool isMe;
  final bool hasResonance;
  final bool isFollowing;

  ProfileData({
    required this.profile,
    required this.posts,
    required this.isMe,
    required this.hasResonance,
    required this.isFollowing,
  });
}

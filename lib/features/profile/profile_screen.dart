import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/post_model.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileDataAsync = ref.watch(profileControllerProvider(userId: userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: userId != null 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      ),
      body: profileDataAsync.when(
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white10,
                          backgroundImage: data.profile['avatar_url'] != null
                              ? CachedNetworkImageProvider(data.profile['avatar_url'])
                              : null,
                          child: data.profile['avatar_url'] == null
                              ? const Icon(Icons.person, size: 45, color: Colors.white38)
                              : null,
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('投稿', data.posts.length),
                              _buildStatColumn('共鳴', 0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data.profile['username'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                    ),
                    if (data.profile['bio'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        data.profile['bio'],
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        if (data.isMe)
                          Expanded(
                            child: _buildActionButton('プロフィールを編集', onTap: () {}),
                          )
                        else ...[
                          Expanded(
                            child: _buildActionButton(
                              data.isFollowing ? 'フォロー中' : 'フォローする',
                              isPrimary: !data.isFollowing,
                              onTap: () => ref.read(profileControllerProvider(userId: userId).notifier).toggleFollow(data.profile['id']),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'メッセージ',
                              onTap: data.hasResonance ? () {} : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    if (data.isMe || data.hasResonance) ...[
                      const Text(
                        'My Top 3',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _buildTopThreeSection(),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            if (!data.isMe && !data.hasResonance)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text(
                        '感性の門番',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '共鳴（いいね）をしてプロフィールを見る',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton('タイムラインに戻る', onTap: () => Navigator.pop(context)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = data.posts[index];
                      return _buildGridItem(context, post);
                    },
                    childCount: data.posts.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, {bool isPrimary = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: 12,
        color: onTap == null 
            ? Colors.white10 
            : (isPrimary ? AppColors.primary.withValues(alpha: 0.8) : null),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: onTap == null ? Colors.white24 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
          child: AspectRatio(
            aspectRatio: 1,
            child: GlassContainer(
              padding: EdgeInsets.zero,
              borderRadius: 12,
              child: const Center(
                child: Icon(Icons.add, color: Colors.white24),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildGridItem(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () => _showPostDetail(context, post),
      child: CachedNetworkImage(
        imageUrl: post.artworkUrl ?? '',
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.white10),
        errorWidget: (context, url, error) => const Icon(Icons.music_note, color: Colors.white24),
      ),
    );
  }

  void _showPostDetail(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: post.artworkUrl ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                post.trackName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Text(
                post.artistName,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (post.feeling != null || post.scene != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (post.feeling != null)
                      _buildTag(post.feeling!),
                    if (post.feeling != null && post.scene != null)
                      const SizedBox(width: 8),
                    if (post.scene != null)
                      _buildTag(post.scene!),
                  ],
                ),
              if (post.comment != null && post.comment!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  post.comment!,
                  style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              _buildActionButton('閉じる', onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
    );
  }
}

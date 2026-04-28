import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/music_sync/apple_music_token_provider.dart';
import '../../core/music_sync/library_sync_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongsAsync = ref.watch(profileControllerProvider);
    final appleMusicTokenAsync = ref.watch(appleMusicTokenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'My Resonance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 80,
                        color: Colors.white12,
                      ),
                      const SizedBox(height: 20),
                      
                      // Apple Music Sync Section
                      appleMusicTokenAsync.when(
                        data: (token) {
                          if (token == null) {
                            return _SyncButton(
                              icon: Icons.music_note,
                              label: 'Apple Music と同期',
                              onTap: () async {
                                // Get developer token from .env
                                final devToken = dotenv.env['APPLE_MUSIC_DEVELOPER_TOKEN'] ?? '';
                                try {
                                  await ref.read(appleMusicTokenProvider.notifier).requestToken(devToken);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Apple Music 連携を完了しました')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('エラーが発生しました: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          } else {
                            return _SyncButton(
                              icon: Icons.sync,
                              label: 'プレイリストを更新',
                              onTap: () async {
                                try {
                                  await ref.read(librarySyncServiceProvider.notifier).syncLikedSongsToAppleMusic();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('プレイリストを更新しました')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('同期エラー: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          }
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Liked Songs List
              likedSongsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('まだ「いいね」した曲はありません')),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _LikedSongTile(song: song),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: 25,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedSongTile extends StatelessWidget {
  const _LikedSongTile({required this.song});
  final dynamic song;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: song.artworkUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artistName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // Playback in profile
            icon: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
          ),
        ],
      ),
    );
  }
}

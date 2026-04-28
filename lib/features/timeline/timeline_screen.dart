import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/audio/audio_player_provider.dart';
import '../../data/models/song_model.dart';
import '../../core/theme/background_provider.dart';
import '../post/post_provider.dart';
import 'widgets/music_card.dart';
import 'widgets/resonance_animation.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  bool _showResonance = false;

  void _triggerResonance() {
    setState(() => _showResonance = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showResonance = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final postsAsync = ref.watch(postControllerProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(child: Text('まだ投稿がありません'));
                  }

                  return CardSwiper(
                    cardsCount: posts.length,
                    cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                      final post = posts[index];
                      final song = SongModel(
                        id: post.id,
                        name: post.trackName,
                        artistName: post.artistName,
                        albumName: '',
                        artworkUrl: post.artworkUrl ?? '',
                        previewUrl: post.previewUrl ?? '',
                        genres: post.genre != null ? [post.genre!] : [],
                      );
                      
                      if (index == 0) {
                         ref.read(audioPlayerControllerProvider.notifier).playUrl(song.previewUrl);
                         // Update background
                         Future.microtask(() => ref.read(backgroundImageProvider.notifier).update(song.artworkUrl));
                      }

                      return MusicCard(
                        song: song,
                        username: post.username,
                        comment: post.comment,
                        resonanceCount: post.resonanceCount,
                      );
                    },
                    onSwipe: (previousIndex, currentIndex, direction) {
                      if (direction == CardSwiperDirection.right || direction == CardSwiperDirection.top) {
                        _triggerResonance();
                        HapticFeedback.mediumImpact();
                      } else {
                        HapticFeedback.lightImpact();
                      }

                      if (currentIndex != null && currentIndex < posts.length) {
                        final nextPost = posts[currentIndex];
                        ref.read(audioPlayerControllerProvider.notifier).playUrl(nextPost.previewUrl ?? '');
                        // Update background
                        ref.read(backgroundImageProvider.notifier).update(nextPost.artworkUrl);
                      } else {
                        ref.read(audioPlayerControllerProvider.notifier).stop();
                      }
                      
                      return true;
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
              ),
              
              if (_showResonance)
                const Center(child: ResonanceAnimation()),
            ],
          ),
        );
      },
    );
  }
}

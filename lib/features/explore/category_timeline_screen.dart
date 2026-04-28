import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/audio/audio_player_provider.dart';
import '../../data/models/song_model.dart';
import '../../core/theme/background_provider.dart';
import '../post/post_provider.dart';
import '../timeline/widgets/music_card.dart';
import '../timeline/widgets/resonance_animation.dart';
import 'package:flutter/services.dart';

class CategoryTimelineScreen extends StatefulWidget {
  const CategoryTimelineScreen({
    super.key,
    required this.title,
    this.genre,
    this.feeling,
    this.scene,
  });

  final String title;
  final String? genre;
  final String? feeling;
  final String? scene;

  @override
  State<CategoryTimelineScreen> createState() => _CategoryTimelineScreenState();
}

class _CategoryTimelineScreenState extends State<CategoryTimelineScreen> {
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
        final postsAsync = ref.watch(filteredPostsProvider(
          genre: widget.genre,
          feeling: widget.feeling,
          scene: widget.scene,
        ));

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          body: Stack(
            children: [
              postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(child: Text('まだ投稿がありません', style: TextStyle(color: Colors.white70)));
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
                        ref.read(backgroundImageProvider.notifier).update(nextPost.artworkUrl);
                      } else {
                        ref.read(audioPlayerControllerProvider.notifier).stop();
                      }
                      
                      return true;
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('エラーが発生しました: $e', style: const TextStyle(color: Colors.white))),
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

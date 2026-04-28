import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/audio/audio_player_provider.dart';
import '../../core/theme/background_provider.dart';
import 'timeline_provider.dart';
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
        final timelineAsync = ref.watch(timelineControllerProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              timelineAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const Center(child: Text('まだ投稿がありません'));
                  }

                  return CardSwiper(
                    cardsCount: songs.length,
                    allowedSwipeDirection: const AllowedSwipeDirection.only(
                      left: true,
                      right: true,
                      up: true,
                    ),
                    cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
                      final song = songs[index];
                      
                      if (index == 0) {
                         Future.microtask(() {
                           ref.read(audioPlayerControllerProvider.notifier).playUrl(song.previewUrl);
                           ref.read(backgroundImageProvider.notifier).update(song.artworkUrl);
                         });
                      }

                      return MusicCard(
                        song: song,
                        username: song.username,
                        comment: song.comment,
                        resonanceCount: song.resonanceCount,
                      );
                    },
                    onSwipe: (previousIndex, currentIndex, direction) {
                      String swipeDir = '';
                      if (direction == CardSwiperDirection.right) {
                        swipeDir = 'right';
                        _triggerResonance();
                        HapticFeedback.mediumImpact();
                      } else if (direction == CardSwiperDirection.top) {
                        swipeDir = 'up';
                        HapticFeedback.mediumImpact();
                      } else if (direction == CardSwiperDirection.left) {
                        swipeDir = 'left';
                        HapticFeedback.lightImpact();
                      }

                      ref.read(timelineControllerProvider.notifier).handleSwipe(previousIndex, swipeDir);

                      if (currentIndex != null && currentIndex < songs.length) {
                        final nextSong = songs[currentIndex];
                        ref.read(audioPlayerControllerProvider.notifier).playUrl(nextSong.previewUrl);
                        ref.read(backgroundImageProvider.notifier).update(nextSong.artworkUrl);
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

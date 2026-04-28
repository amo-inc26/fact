import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'timeline_provider.dart';
import 'widgets/music_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineControllerProvider);

    return Scaffold(
      body: timelineAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(child: Text('楽曲が見つかりませんでした'));
          }

          return CardSwiper(
            cardsCount: songs.length,
            cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
              return MusicCard(song: songs[index]);
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              final song = songs[previousIndex];
              String swipeDirection = 'left';
              if (direction == CardSwiperDirection.right) swipeDirection = 'right';
              if (direction == CardSwiperDirection.top) swipeDirection = 'up';
              
              ref.read(timelineControllerProvider.notifier).handleSwipe(song, swipeDirection);
              return true;
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}

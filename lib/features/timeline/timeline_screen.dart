import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/audio/audio_player_provider.dart';
import '../../data/models/song_model.dart';
import '../post/post_provider.dart';
import 'widgets/music_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postControllerProvider);

    return Scaffold(
      body: postsAsync.when(
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
              
              // Play initial song
              if (index == 0) {
                 ref.read(audioPlayerControllerProvider.notifier).playUrl(song.previewUrl);
              }

              return MusicCard(
                song: song,
                username: post.username,
                comment: post.comment,
              );
            },
            onSwipe: (previousIndex, currentIndex, direction) {
              // Handle playback for next song
              if (currentIndex != null && currentIndex < posts.length) {
                final nextPost = posts[currentIndex];
                ref.read(audioPlayerControllerProvider.notifier).playUrl(nextPost.previewUrl ?? '');
              } else {
                ref.read(audioPlayerControllerProvider.notifier).stop();
              }
              
              // TODO: Implement scoring/resonance logic for posts
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

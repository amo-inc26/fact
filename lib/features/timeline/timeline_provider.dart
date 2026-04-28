import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/song_model.dart';
import '../../data/services/apple_music_service.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineController extends _$TimelineController {
  @override
  FutureOr<List<SongModel>> build() async {
    // Initial fetch from top charts
    return ref.read(appleMusicServiceProvider.notifier).fetchTopCharts();
  }

  Future<void> handleSwipe(SongModel song, String direction) async {
    // TODO: Implement scoring logic and playlist sync
    // In a real app, this would update scores in Supabase
  }
}

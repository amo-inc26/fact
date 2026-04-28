import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player_provider.g.dart';

@riverpod
class AudioPlayerController extends _$AudioPlayerController {
  late AudioPlayer _player;

  @override
  AudioPlayer build() {
    _player = AudioPlayer();
    ref.onDispose(() => _player.dispose());
    return _player;
  }

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import '../models/song_model.dart';

part 'apple_music_service.g.dart';

@riverpod
class AppleMusicService extends _$AppleMusicService {
  @override
  void build() {}

  Future<List<SongModel>> searchSongs(String query) async {
    final dio = ref.read(dioProvider);
    
    try {
      final response = await dio.get(
        '/catalog/jp/search',
        queryParameters: {
          'term': query,
          'types': 'songs',
          'limit': 20,
        },
      );

      final results = response.data['results']['songs']['data'] as List;
      return results.map((item) {
        final attributes = item['attributes'];
        final artwork = attributes['artwork'];
        final artworkUrl = (artwork['url'] as String)
            .replaceAll('{w}', '600')
            .replaceAll('{h}', '600');

        return SongModel(
          id: item['id'],
          name: attributes['name'],
          artistName: attributes['artistName'],
          albumName: attributes['albumName'],
          artworkUrl: artworkUrl,
          previewUrl: attributes['previews'][0]['url'],
          genres: List<String>.from(attributes['genreNames']),
        );
      }).toList();
    } catch (e) {
      // For now, return empty or throw
      rethrow;
    }
  }

  Future<List<SongModel>> fetchTopCharts() async {
    final dio = ref.read(dioProvider);
    
    try {
      final response = await dio.get('/catalog/jp/charts', queryParameters: {
        'types': 'songs',
        'limit': 20,
      });

      final results = response.data['results']['songs'][0]['data'] as List;
      return results.map((item) {
        final attributes = item['attributes'];
        final artwork = attributes['artwork'];
        final artworkUrl = (artwork['url'] as String)
            .replaceAll('{w}', '600')
            .replaceAll('{h}', '600');

        return SongModel(
          id: item['id'],
          name: attributes['name'],
          artistName: attributes['artistName'],
          albumName: attributes['albumName'],
          artworkUrl: artworkUrl,
          previewUrl: attributes['previews'][0]['url'],
          genres: List<String>.from(attributes['genreNames']),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}

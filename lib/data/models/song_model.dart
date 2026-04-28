import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_model.freezed.dart';
part 'song_model.g.dart';

@freezed
class SongModel with _$SongModel {
  const factory SongModel({
    required String id,
    required String name,
    required String artistName,
    required String albumName,
    required String artworkUrl,
    required String previewUrl,
    required List<String> genres,
    @Default(0) int likes,
  }) = _SongModel;

  factory SongModel.fromJson(Map<String, dynamic> json) => _$SongModelFromJson(json);
}

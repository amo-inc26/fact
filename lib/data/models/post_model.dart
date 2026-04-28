import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
sealed class PostModel with _$PostModel {
  const factory PostModel({
    required String id,
    required String userId,
    required String trackName,
    required String artistName,
    String? artworkUrl,
    String? previewUrl,
    String? comment,
    String? genre,
    String? feeling,
    String? scene,
    required DateTime createdAt,
    String? username,
    String? avatarUrl,
    @Default(0) int resonanceCount,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
}

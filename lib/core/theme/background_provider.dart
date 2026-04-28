import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_provider.g.dart';

@riverpod
class BackgroundImage extends _$BackgroundImage {
  @override
  String? build() => null;

  void update(String? url) {
    state = url;
  }
}

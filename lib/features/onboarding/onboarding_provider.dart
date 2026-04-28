import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/profile_service.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingStatus extends _$OnboardingStatus {
  @override
  FutureOr<bool> build() async {
    return ref.read(profileServiceProvider.notifier).checkOnboardingCompleted();
  }

  void setCompleted() {
    state = const AsyncValue.data(true);
  }
}

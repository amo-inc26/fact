import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_service.g.dart';

@riverpod
class ProfileService extends _$ProfileService {
  @override
  void build() {}

  Future<bool> checkOnboardingCompleted() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response != null && response['username'] != null;
  }

  Future<void> completeOnboarding({
    required String username,
    required List<String> favoriteGenres,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Create profile
    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'username': username,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Save genre preferences
    final preferences = favoriteGenres.map((genre) => {
      'user_id': user.id,
      'genre': genre,
      'preference_score': 5, // Initial high score for selected genres
    }).toList();

    await Supabase.instance.client.from('user_genre_preferences').insert(preferences);
  }
}

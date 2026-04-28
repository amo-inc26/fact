import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/timeline/timeline_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qteatnmrqgxrwmddtsbu.supabase.co',
    anonKey: 'sb_publishable_N0Mxdh_IJI6jCEFJivq0KQ_hoNodL_0',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    final onboardingAsync = ref.watch(onboardingStatusProvider);

    return MaterialApp(
      title: 'fact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: session == null
          ? const LoginScreen()
          : onboardingAsync.when(
              data: (completed) => completed ? const TimelineScreen() : const OnboardingScreen(),
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/root/root_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
    final authState = ref.watch(authStateProvider);
    final onboardingState = ref.watch(onboardingControllerProvider);

    return MaterialApp(
      title: 'Fact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: authState.when(
        data: (session) {
          if (session == null) {
            return const LoginScreen();
          }
          
          return onboardingState.when(
            data: (isCompleted) {
              if (isCompleted) {
                return const RootNavigationScreen();
              }
              return const OnboardingScreen();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/services/profile_service.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _usernameController = TextEditingController();
  final List<String> _selectedGenres = [];
  
  final List<String> _genres = [
    'J-Pop', 'Rock', 'Hip Hop', 'R&B', 'Electronic',
    'Jazz', 'Classical', 'K-Pop', 'Anime', 'Lo-fi'
  ];

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.defaultGradient,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to fact',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'あなたの「感性」を教えてください',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 40),
                  
                  // Username Field
                  Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: 12,
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '名前を入力',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Genre Selection
                  Text(
                    '好きなジャンル (複数選択可)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _genres.map((genre) {
                          final isSelected = _selectedGenres.contains(genre);
                          return _GenreChip(
                            label: genre,
                            isSelected: isSelected,
                            onTap: () => _toggleGenre(genre),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Submit Button
                  Consumer(
                    builder: (context, ref, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_usernameController.text.isNotEmpty && _selectedGenres.isNotEmpty)
                              ? () async {
                                  await ref.read(profileServiceProvider.notifier).completeOnboarding(
                                    username: _usernameController.text,
                                    favoriteGenres: _selectedGenres,
                                  );
                                  ref.read(onboardingStatusProvider.notifier).setCompleted();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            disabledBackgroundColor: Colors.grey[800],
                          ),
                          child: const Text(
                            '始める',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

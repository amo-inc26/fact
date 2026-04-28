import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/background_provider.dart';
import '../../core/widgets/adaptive_background.dart';
import '../timeline/timeline_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_creation_screen.dart';
import '../explore/explore_screen.dart';
import '../dm/dm_screen.dart';

class RootNavigationScreen extends ConsumerStatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  ConsumerState<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends ConsumerState<RootNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TimelineScreen(),
    const ExploreScreen(),
    const PostCreationScreen(),
    const DMScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = ref.watch(backgroundImageProvider);

    return Scaffold(
      body: AdaptiveBackground(
        imageUrl: backgroundUrl,
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            
            // Floating Navigation Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  borderRadius: 40,
                  blur: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _NavItem(
                        icon: Icons.explore_rounded,
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _NavItem(
                        icon: Icons.add_rounded,
                        isSelected: _selectedIndex == 2,
                        isCenter: true,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _NavItem(
                        icon: Icons.chat_bubble_rounded,
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isCenter = false,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(isCenter ? 14 : 12),
        decoration: BoxDecoration(
          color: isCenter && isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? (isCenter ? Colors.white : AppColors.primary) 
                  : Colors.white.withValues(alpha: 0.5),
              size: isCenter ? 32 : 26,
            ),
            if (isSelected && !isCenter)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

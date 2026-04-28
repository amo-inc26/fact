import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../timeline/timeline_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_creation_screen.dart';

class RootNavigationScreen extends StatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TimelineScreen(),
    const ProfileScreen(),
    const PostCreationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          
          // Floating Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                borderRadius: 40,
                blur: 30,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavItem(
                      icon: Icons.music_note_rounded,
                      isSelected: _selectedIndex == 0,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                    const SizedBox(width: 24),
                    _NavItem(
                      icon: Icons.add_rounded,
                      isSelected: _selectedIndex == 2,
                      isCenter: true,
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                    const SizedBox(width: 24),
                    _NavItem(
                      icon: Icons.person_rounded,
                      isSelected: _selectedIndex == 1,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      child: Container(
        padding: EdgeInsets.all(isCenter ? 14 : 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isCenter ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2)) 
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isCenter ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1) : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
          size: isCenter ? 32 : 28,
        ),
      ),
    );
  }
}

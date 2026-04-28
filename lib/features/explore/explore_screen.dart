import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['ジャンル', '気分', '場面'];

  final List<List<_ExploreItem>> _items = [
    // ジャンル
    [
      _ExploreItem(label: 'ヒップホップ', icon: '🎤', color: Colors.orange),
      _ExploreItem(label: '邦楽', icon: '🇯🇵', color: Colors.pink),
      _ExploreItem(label: 'インディー', icon: '🎸', color: Colors.blue),
      _ExploreItem(label: 'R&B', icon: '✨', color: Colors.purple),
      _ExploreItem(label: 'エレクトロニック', icon: '⚡', color: Colors.teal),
      _ExploreItem(label: 'ロック', icon: '🤘', color: Colors.red),
    ],
    // 気分
    [
      _ExploreItem(label: 'まったり', icon: '🌙', color: Colors.indigo),
      _ExploreItem(label: 'テンション上げたい', icon: '🎉', color: Colors.orangeAccent),
      _ExploreItem(label: 'センチメンタル', icon: '💧', color: Colors.blueAccent),
      _ExploreItem(label: 'ハッピー', icon: '🌟', color: Colors.pinkAccent),
      _ExploreItem(label: '癒やされたい', icon: '🍃', color: Colors.greenAccent),
      _ExploreItem(label: '集中したい', icon: '🔥', color: Colors.deepPurpleAccent),
    ],
    // 場面
    [
      _ExploreItem(label: '通勤・通学', icon: '🚃', color: Colors.lightBlue),
      _ExploreItem(label: '勉強・作業', icon: '📚', color: Colors.purple),
      _ExploreItem(label: 'ドライブ', icon: '🚗', color: Colors.deepOrange),
      _ExploreItem(label: 'デート', icon: '💕', color: Colors.pink),
      _ExploreItem(label: 'カフェタイム', icon: '☕', color: Colors.brown),
      _ExploreItem(label: 'ワークアウト', icon: '💪', color: Colors.red),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '見つける',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  GlassContainer(
                    padding: const EdgeInsets.all(8),
                    borderRadius: 20,
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Segment Control
              GlassContainer(
                padding: const EdgeInsets.all(4),
                borderRadius: 30,
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.primary, Color(0xFFFF4081)],
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _items[_selectedTabIndex].length,
                  itemBuilder: (context, index) {
                    final item = _items[_selectedTabIndex][index];
                    return _ExploreCard(item: item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreItem {
  final String label;
  final String icon;
  final Color color;

  _ExploreItem({required this.label, required this.icon, required this.color});
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.item});
  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top half: Icon with color background
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color.withValues(alpha: 0.8),
                    item.color.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  item.icon,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          
          // Bottom half: Label
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '探索する',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import '../../core/widgets/glass_container.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Feeling / Scene', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ExploreCard(label: 'Chill', icon: Icons.nightlight_round),
                    _ExploreCard(label: 'Energy', icon: Icons.bolt),
                    _ExploreCard(label: 'Study', icon: Icons.menu_book),
                    _ExploreCard(label: 'Drive', icon: Icons.directions_car),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text('Popular Genres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _GenreCard(label: 'J-Pop', color: Colors.pinkAccent),
                    _GenreCard(label: 'Rock', color: Colors.orangeAccent),
                    _GenreCard(label: 'Hip-Hop', color: Colors.blueAccent),
                    _GenreCard(label: 'R&B', color: Colors.purpleAccent),
                    _GenreCard(label: 'Jazz', color: Colors.tealAccent),
                    _GenreCard(label: 'Dance', color: Colors.amberAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.6),
              color.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

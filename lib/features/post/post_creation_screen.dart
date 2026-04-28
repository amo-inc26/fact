import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/song_model.dart';
import '../../data/services/apple_music_service.dart';
import 'post_provider.dart';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final _searchController = TextEditingController();
  final _commentController = TextEditingController();
  List<SongModel> _searchResults = [];
  SongModel? _selectedSong;
  bool _isSearching = false;

  void _onSearch(WidgetRef ref) async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isSearching = true);
    final results = await ref.read(appleMusicServiceProvider.notifier).searchSongs(_searchController.text);
    setState(() {
      _searchResults = results;
      _isSearching = false;
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
                    'Share Resonance',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_selectedSong == null) ...[
                    // Search Bar
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: 12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                return TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '曲名・アーティスト名で検索',
                                  ),
                                  onSubmitted: (_) => _onSearch(ref),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Search Results
                    Expanded(
                      child: _isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final song = _searchResults[index];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl: song.artworkUrl.replaceAll('{w}x{h}', '100x100'),
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  title: Text(song.name),
                                  subtitle: Text(song.artistName),
                                  onTap: () => setState(() => _selectedSong = song),
                                );
                              },
                            ),
                    ),
                  ] else ...[
                    // Selected Song Info
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _selectedSong!.artworkUrl.replaceAll('{w}x{h}', '200x200'),
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedSong!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(_selectedSong!.artistName, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _selectedSong = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Comment Field
                    const Text('Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'この曲の何に「共鳴」した？',
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Post Button
                    Consumer(
                      builder: (context, ref, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref.read(postControllerProvider.notifier).createPost(
                                trackName: _selectedSong!.name,
                                artistName: _selectedSong!.artistName,
                                artworkUrl: _selectedSong!.artworkUrl,
                                previewUrl: _selectedSong!.previewUrl,
                                comment: _commentController.text,
                                genre: _selectedSong!.genres.isNotEmpty ? _selectedSong!.genres.first : null,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('共鳴をシェアしました')),
                                );
                                setState(() {
                                  _selectedSong = null;
                                  _commentController.clear();
                                  _searchController.clear();
                                });
                                // Navigate back to timeline or handled by RootNav
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: const Text('シェアする', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

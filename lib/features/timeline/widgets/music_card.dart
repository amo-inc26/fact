import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../data/models/song_model.dart';

class MusicCard extends StatelessWidget {
  const MusicCard({
    super.key,
    required this.song,
    this.username,
    this.comment,
    this.resonanceCount = 0,
  });

  final SongModel song;
  final String? username;
  final String? comment;
  final int resonanceCount;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 30,
      blur: 20,
      child: Stack(
        children: [
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              imageUrl: song.artworkUrl.replaceAll('{w}x{h}', '800x800'),
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          
          // Info Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (username != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          username!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (resonanceCount > 0)
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          borderRadius: 20,
                          blur: 10,
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$resonanceCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    song.artistName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (comment != null && comment!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 12,
                      child: Text(
                        comment!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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

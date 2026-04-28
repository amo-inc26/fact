import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../theme/app_colors.dart';

class AdaptiveBackground extends StatefulWidget {
  const AdaptiveBackground({
    super.key,
    this.imageUrl,
    required this.child,
  });

  final String? imageUrl;
  final Widget child;

  @override
  State<AdaptiveBackground> createState() => _AdaptiveBackgroundState();
}

class _AdaptiveBackgroundState extends State<AdaptiveBackground> {
  Color _primaryColor = AppColors.background;
  Color _secondaryColor = Colors.black;

  @override
  void didUpdateWidget(AdaptiveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl && widget.imageUrl != null) {
      _updatePalette();
    }
  }

  Future<void> _updatePalette() async {
    if (widget.imageUrl == null) return;
    
    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.imageUrl!.replaceAll('{w}x{h}', '100x100')),
      maximumColorCount: 10,
    );

    if (mounted) {
      setState(() {
        _primaryColor = palette.dominantColor?.color.withValues(alpha: 0.5) ?? AppColors.background;
        _secondaryColor = palette.mutedColor?.color.withValues(alpha: 0.3) ?? Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _secondaryColor,
            Colors.black,
          ],
        ),
      ),
      child: widget.child,
    );
  }
}

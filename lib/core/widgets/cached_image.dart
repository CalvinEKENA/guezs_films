import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shimmer_loading.dart';

/// Cached network image with shimmer loading
/// Handles loading, error states, and caching automatically
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final Alignment alignment;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildError();
    }

    String path = imageUrl!;
    
    // Normalization for Web Assets (Handles spaces and specific content like "Elle et Moi")
    final lowPath = path.toLowerCase();
    
    // Priority 1: Check if this is a known "Elle et Moi" content piece
    // If so, and we are not explicitly forced to network, we try to use the local asset
    if (lowPath.contains('elle et moi') || lowPath.contains('elle_et_moi')) {
      // Extract filename
      final fileName = path.split('/').last.replaceAll('%20', '_').replaceAll(' ', '_');
      // Force local asset path for these specific premium assets
      final assetPath = 'assets/images/$fileName';
      
      return _buildAssetImage(assetPath);
    }

    // Priority 2: Standard Asset vs Network Detection
    if (!path.startsWith('http')) {
      // Local asset
      if (!path.startsWith('assets/')) {
        path = 'assets/$path';
      }
      // Clean up spaces for Web compatibility
      path = path.replaceAll(' ', '_');
      return _buildAssetImage(path);
    }

    // Priority 3: Network Image
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildError(),
      ),
    );
  }

  Widget _buildAssetImage(String assetPath) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Asset image not found: $assetPath. Falling back to error widget.');
          return errorWidget ?? _buildError();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? AppColors.surfaceVariant,
      child: ShimmerLoading(
        width: width ?? 100,
        height: height ?? 150,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.textTertiary,
          size: 32,
        ),
      ),
    );
  }
}

/// Movie poster with automatic aspect ratio
class MoviePoster extends StatelessWidget {
  final String? posterUrl;
  final double width;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showShadow;
  final Alignment alignment;

  const MoviePoster({
    super.key,
    required this.posterUrl,
    this.width = 120,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: width * 1.5,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: CachedImage(
          imageUrl: posterUrl,
          width: width,
          height: width * 1.5,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          alignment: alignment,
        ),
      ),
    );
  }
}

/// Backdrop image with automatic aspect ratio
class BackdropImage extends StatelessWidget {
  final String? backdropUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  const BackdropImage({
    super.key,
    required this.backdropUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedImage(
          imageUrl: backdropUrl,
          width: width ?? double.infinity,
          height: height ?? (width != null ? width! * 9 / 16 : 200),
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        if (overlay != null) Positioned.fill(child: overlay!),
      ],
    );
  }
}

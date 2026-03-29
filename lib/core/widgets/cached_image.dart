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
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildError();
    }

    // Check if it's a local asset
    if (imageUrl!.startsWith('assets/') || !imageUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.asset(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildError(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildError(),
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

  const MoviePoster({
    super.key,
    required this.posterUrl,
    this.width = 120,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
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

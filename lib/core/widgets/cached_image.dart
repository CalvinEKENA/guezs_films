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

    var path = imageUrl!.trim();

    if (!path.startsWith('http')) {
      if (!path.startsWith('assets/')) {
        path = 'assets/$path';
      }
      path = path.replaceAll(' ', '_');
      return _buildAssetImage(path);
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = _cacheDimension(width, pixelRatio);
    final cacheHeight = _cacheDimension(height, pixelRatio);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
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
          debugPrint(
            'Asset image not found: $assetPath. Falling back to error widget.',
          );
          return errorWidget ?? _buildError();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.card,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
          width: 0.8,
        ),
      ),
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
        color: backgroundColor ?? AppColors.card,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
          width: 0.8,
        ),
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

  int? _cacheDimension(double? logicalSize, double pixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * pixelRatio).round().clamp(1, 4096).toInt();
  }
}

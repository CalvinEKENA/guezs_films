import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Shimmer loading placeholder for content
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// Creates a shimmer placeholder for movie posters
  factory ShimmerLoading.poster({double? width}) {
    return ShimmerLoading(
      width: width ?? 120,
      height: (width ?? 120) * 1.5,
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Creates a shimmer placeholder for backdrops
  factory ShimmerLoading.backdrop({double? width}) {
    return ShimmerLoading(
      width: width ?? double.infinity,
      height: (width ?? 300) * 9 / 16,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Creates a shimmer placeholder for text
  factory ShimmerLoading.text({double width = 100, double height = 16}) {
    return ShimmerLoading(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Creates a shimmer placeholder for circles (avatars)
  factory ShimmerLoading.circle({double size = 48}) {
    return ShimmerLoading(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer loading for a horizontal content row
class ShimmerContentRow extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double spacing;

  const ShimmerContentRow({
    super.key,
    this.itemCount = 5,
    this.itemWidth = 120,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemWidth * 1.5 + 44,
      child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(width: spacing),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading.poster(width: itemWidth),
                const SizedBox(height: 8),
                ShimmerLoading.text(width: itemWidth * 0.8),
                const SizedBox(height: 4),
                ShimmerLoading.text(width: itemWidth * 0.5, height: 12),
              ],
            ),
          ),
    );
  }
}

/// Shimmer loading for grid view
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double spacing;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}

/// Shimmer loading for the large hero section
class HeroShimmer extends StatelessWidget {
  const HeroShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.65,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading.text(width: 250, height: 40),
          const SizedBox(height: 16),
          ShimmerLoading.text(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          ShimmerLoading.text(width: 200, height: 16),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: ShimmerLoading.text(height: 48)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerLoading.text(height: 48)),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

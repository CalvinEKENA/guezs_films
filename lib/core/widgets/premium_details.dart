import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cached_image.dart';
import 'gradient_button.dart';
import 'shimmer_loading.dart';

class PremiumDetailsBackdrop extends StatelessWidget {
  const PremiumDetailsBackdrop({
    super.key,
    required this.backdropUrl,
    required this.fallbackImageUrl,
    required this.height,
    this.alignment = Alignment.center,
    this.child,
  });

  final String backdropUrl;
  final String fallbackImageUrl;
  final double height;
  final Alignment alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final imageUrl = backdropUrl.trim().isNotEmpty
        ? backdropUrl
        : fallbackImageUrl;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImage(
            imageUrl: imageUrl,
            height: height,
            fit: BoxFit.cover,
            alignment: alignment,
            borderRadius: BorderRadius.zero,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgCinemaDark.withValues(alpha: 0.34),
                  AppColors.bgCinema.withValues(alpha: 0.08),
                  AppColors.bgCinema.withValues(alpha: 0.62),
                  AppColors.bgCinema,
                ],
                stops: const [0, 0.36, 0.76, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.bgCinemaDark.withValues(alpha: 0.74),
                  Colors.transparent,
                  AppColors.spotlightBlue.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.spotlightBlue.withValues(alpha: 0.12),
                  Colors.transparent,
                  AppColors.brandGold.withValues(alpha: 0.06),
                ],
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class PremiumDetailBadge extends StatelessWidget {
  const PremiumDetailBadge({
    super.key,
    required this.label,
    this.icon,
    this.warning = false,
  });

  final String label;
  final IconData? icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.brandGoldLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warning
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.glassBackground(0.42),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: warning
              ? AppColors.warning.withValues(alpha: 0.52)
              : AppColors.glassBorder(0.34),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

class PremiumMetadataPill extends StatelessWidget {
  const PremiumMetadataPill({
    super.key,
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.brandGold : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? AppColors.glassBorder(0.44)
              : AppColors.border.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: highlight
                  ? AppColors.brandGoldLight
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumGenreChip extends StatelessWidget {
  const PremiumGenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class PremiumIconAction extends StatelessWidget {
  const PremiumIconAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brandGoldLight : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: onPressed == null ? 0.5 : 1,
          child: Container(
            constraints: const BoxConstraints(minWidth: 108),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.glassBackground(0.34),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? AppColors.glassBorder(0.5)
                    : AppColors.border.withValues(alpha: 0.76),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 19),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumDetailsSection extends StatelessWidget {
  const PremiumDetailsSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class PremiumFact {
  const PremiumFact({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class PremiumFactsPanel extends StatelessWidget {
  const PremiumFactsPanel({super.key, required this.facts});

  final List<PremiumFact> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        const gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: facts
              .map(
                (fact) => SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceObsidian.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.brandBlue.withValues(alpha: 0.36),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            fact.icon,
                            size: 17,
                            color: AppColors.brandGoldLight,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fact.label, style: AppTextStyles.labelSmall),
                              const SizedBox(height: 3),
                              Text(
                                fact.value,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class PremiumDetailsStateView extends StatelessWidget {
  const PremiumDetailsStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceObsidian,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder(0.38)),
              ),
              child: Icon(icon, size: 34, color: AppColors.brandGoldLight),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (primaryLabel != null && onPrimaryPressed != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                child: GradientButton(
                  text: primaryLabel!,
                  onPressed: onPrimaryPressed,
                ),
              ),
            ],
            if (secondaryLabel != null && onSecondaryPressed != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: 240,
                child: OutlinedGradientButton(
                  text: secondaryLabel!,
                  onPressed: onSecondaryPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PremiumDetailsSkeleton extends StatelessWidget {
  const PremiumDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 760;
    final horizontalPadding = size.width >= 1200
        ? 64.0
        : size.width >= 900
        ? 32.0
        : 16.0;
    final heroHeight = size.width >= 1200
        ? (size.width * 9 / 21).clamp(430.0, 580.0)
        : (size.height * 0.44).clamp(340.0, 470.0);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ShimmerLoading(
              width: double.infinity,
              height: heroHeight,
              borderRadius: BorderRadius.zero,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    40,
                  ),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerLoading(
                              width: 210,
                              height: 315,
                              borderRadius: BorderRadius.all(
                                Radius.circular(14),
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(child: _buildTextSkeleton()),
                          ],
                        )
                      : _buildTextSkeleton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(width: 130, height: 24),
        SizedBox(height: 16),
        ShimmerLoading(width: double.infinity, height: 44),
        SizedBox(height: 18),
        ShimmerLoading(width: 290, height: 18),
        SizedBox(height: 26),
        ShimmerLoading(width: double.infinity, height: 52),
        SizedBox(height: 32),
        ShimmerLoading(width: 150, height: 24),
        SizedBox(height: 12),
        ShimmerLoading(width: double.infinity, height: 92),
      ],
    );
  }
}

class PremiumStickyCta extends StatelessWidget {
  const PremiumStickyCta({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.helperText,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgCinemaDark.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder(0.24), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              if (helperText != null && helperText!.trim().isNotEmpty) ...[
                Expanded(
                  child: Text(
                    helperText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: helperText == null ? 1 : 2,
                child: GradientButton(
                  text: label,
                  icon: icon,
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

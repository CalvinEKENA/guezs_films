import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cached_image.dart';

class PremiumContentCard extends StatefulWidget {
  const PremiumContentCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.metadata,
    required this.width,
    required this.onTap,
    this.badge,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final String title;
  final String? imageUrl;
  final String metadata;
  final String? badge;
  final double width;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  State<PremiumContentCard> createState() => _PremiumContentCardState();
}

class _PremiumContentCardState extends State<PremiumContentCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _highlighted => _hovered || _focused;

  void _activate() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            _activate();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.97 : (_hovered ? 1.025 : 1),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: widget.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PosterFrame(
                    width: widget.width,
                    imageUrl: widget.imageUrl,
                    badge: widget.badge,
                    highlighted: _highlighted,
                    isFavorite: widget.isFavorite,
                    onFavoriteTap: widget.onFavoriteTap,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.movieTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterFrame extends StatelessWidget {
  const _PosterFrame({
    required this.width,
    required this.imageUrl,
    required this.highlighted,
    required this.isFavorite,
    this.badge,
    this.onFavoriteTap,
  });

  final double width;
  final String? imageUrl;
  final bool highlighted;
  final bool isFavorite;
  final String? badge;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: highlighted
              ? AppColors.glassBorder(0.62)
              : AppColors.border.withValues(alpha: 0.42),
          width: highlighted ? 1.1 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
          if (highlighted)
            BoxShadow(
              color: AppColors.brandGold.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageUrl: imageUrl,
                width: width,
                fit: BoxFit.cover,
                borderRadius: radius,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.06),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.36),
                      ],
                    ),
                  ),
                ),
              ),
              if (badge != null && badge!.trim().isNotEmpty)
                Positioned(left: 8, top: 8, child: _CardBadge(label: badge!)),
              if (onFavoriteTap != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: _FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onFavoriteTap!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgCinemaDark.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.glassBorder(0.34), width: 0.7),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.badge.copyWith(color: AppColors.brandGoldLight),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.bgCinemaDark.withValues(alpha: 0.78),
          shape: BoxShape.circle,
          border: Border.all(
            color: isFavorite
                ? AppColors.glassBorder(0.64)
                : AppColors.border.withValues(alpha: 0.54),
            width: 0.8,
          ),
        ),
        child: Icon(
          isFavorite ? Icons.check_rounded : Icons.add_rounded,
          color: isFavorite ? AppColors.accent : AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

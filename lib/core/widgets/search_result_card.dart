import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'cached_image.dart';

class SearchResultCard extends StatefulWidget {
  const SearchResultCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.contentType,
    required this.year,
    required this.onTap,
    this.rating,
    this.premiumBadge,
  });

  final String title;
  final String? posterUrl;
  final String contentType;
  final int year;
  final double? rating;
  final String? premiumBadge;
  final VoidCallback onTap;

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  void _activate() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || _focused;

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
            scale: _pressed ? 0.975 : (highlighted ? 1.025 : 1),
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: highlighted
                            ? AppColors.glassBorder(0.68)
                            : AppColors.border.withValues(alpha: 0.46),
                        width: highlighted ? 1.2 : 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.42),
                          blurRadius: 16,
                          offset: const Offset(0, 9),
                        ),
                        if (highlighted)
                          BoxShadow(
                            color: AppColors.spotlightBlue.withValues(
                              alpha: 0.16,
                            ),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedImage(
                            imageUrl: widget.posterUrl,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const _PosterGradient(),
                          Positioned(
                            top: 9,
                            left: 9,
                            child: _ResultBadge(label: widget.contentType),
                          ),
                          if (widget.premiumBadge != null &&
                              widget.premiumBadge!.trim().isNotEmpty)
                            Positioned(
                              left: 9,
                              bottom: 9,
                              right: 9,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: _ResultBadge(
                                  label: widget.premiumBadge!,
                                  premium: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (widget.year > 0)
                      Text('${widget.year}', style: AppTextStyles.metadata),
                    if (widget.rating != null && widget.rating! > 0) ...[
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: AppColors.brandGold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.rating!.toStringAsFixed(1),
                        style: AppTextStyles.rating.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterGradient extends StatelessWidget {
  const _PosterGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.2),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0, 0.52, 1],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.label, this.premium = false});

  final String label;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: premium
            ? AppColors.brandGold.withValues(alpha: 0.92)
            : AppColors.bgCinemaDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: premium
              ? AppColors.brandGoldLight.withValues(alpha: 0.64)
              : AppColors.glassBorder(0.34),
          width: 0.7,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.badge.copyWith(
          color: premium ? AppColors.textOnGold : AppColors.brandGoldLight,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/onboarding_slide_model.dart';

class OnboardingSlideWidget extends StatefulWidget {
  const OnboardingSlideWidget({
    super.key,
    required this.slide,
    required this.index,
  });

  final OnboardingSlideModel slide;
  final int index;

  @override
  State<OnboardingSlideWidget> createState() => _OnboardingSlideWidgetState();
}

class _OnboardingSlideWidgetState extends State<OnboardingSlideWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _imageOpacity;
  late final Animation<double> _imageScale;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copyOffset;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _imageOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.58, curve: Curves.easeOut),
    );
    _imageScale = Tween<double>(
      begin: 1.045,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _copyOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.82, curve: Curves.easeOut),
    );
    _copyOffset = Tween<Offset>(begin: const Offset(0, 0.09), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.18, 0.88, curve: Curves.easeOutCubic),
          ),
        );
    _cardOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 1, curve: Curves.easeOut),
    );
    _cardOffset =
        Tween<Offset>(
          begin: const Offset(0.08, 0.12),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, responsive) {
        if (responsive.isDesktop) {
          return _DesktopSlide(
            slide: widget.slide,
            index: widget.index,
            imageOpacity: _imageOpacity,
            imageScale: _imageScale,
            copyOpacity: _copyOpacity,
            copyOffset: _copyOffset,
            cardOpacity: _cardOpacity,
            cardOffset: _cardOffset,
          );
        }
        return _MobileSlide(
          slide: widget.slide,
          imageOpacity: _imageOpacity,
          imageScale: _imageScale,
          copyOpacity: _copyOpacity,
          copyOffset: _copyOffset,
          cardOpacity: _cardOpacity,
          cardOffset: _cardOffset,
        );
      },
    );
  }
}

class _MobileSlide extends StatelessWidget {
  const _MobileSlide({
    required this.slide,
    required this.imageOpacity,
    required this.imageScale,
    required this.copyOpacity,
    required this.copyOffset,
    required this.cardOpacity,
    required this.cardOffset,
  });

  final OnboardingSlideModel slide;
  final Animation<double> imageOpacity;
  final Animation<double> imageScale;
  final Animation<double> copyOpacity;
  final Animation<Offset> copyOffset;
  final Animation<double> cardOpacity;
  final Animation<Offset> cardOffset;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compactHeight = size.height < 720;

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: imageOpacity,
          child: ScaleTransition(
            scale: imageScale,
            child: _SlideImage(
              assetPath: slide.assetPath,
              alignment: slide.mobileImageAlignment,
            ),
          ),
        ),
        const _CinemaImageOverlay(),
        if (!compactHeight)
          Positioned(
            top: size.height * 0.33,
            right: 18,
            child: FadeTransition(
              opacity: cardOpacity,
              child: SlideTransition(
                position: cardOffset,
                child: _FloatingContextCard(slide: slide, compact: true),
              ),
            ),
          ),
        Positioned(
          left: 20,
          right: 20,
          bottom: compactHeight ? 18 : 28,
          child: FadeTransition(
            opacity: copyOpacity,
            child: SlideTransition(
              position: copyOffset,
              child: _SlideCopy(slide: slide, compact: compactHeight),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopSlide extends StatelessWidget {
  const _DesktopSlide({
    required this.slide,
    required this.index,
    required this.imageOpacity,
    required this.imageScale,
    required this.copyOpacity,
    required this.copyOffset,
    required this.cardOpacity,
    required this.cardOffset,
  });

  final OnboardingSlideModel slide;
  final int index;
  final Animation<double> imageOpacity;
  final Animation<double> imageScale;
  final Animation<double> copyOpacity;
  final Animation<Offset> copyOffset;
  final Animation<double> cardOpacity;
  final Animation<Offset> cardOffset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(48, 14, 48, 18),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.spotlightBlue.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 44,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FadeTransition(
                                opacity: imageOpacity,
                                child: ScaleTransition(
                                  scale: imageScale,
                                  child: _SlideImage(
                                    assetPath: slide.assetPath,
                                    alignment: slide.desktopImageAlignment,
                                  ),
                                ),
                              ),
                              const _CinemaImageOverlay(soft: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -28,
                      bottom: 34,
                      child: FadeTransition(
                        opacity: cardOpacity,
                        child: SlideTransition(
                          position: cardOffset,
                          child: _FloatingContextCard(slide: slide),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 74),
              Expanded(
                flex: 5,
                child: FadeTransition(
                  opacity: copyOpacity,
                  child: SlideTransition(
                    position: copyOffset,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(index + 1).toString().padLeft(2, '0')} / 04',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.brandGoldLight,
                            letterSpacing: 3.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 58,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SlideCopy(slide: slide, desktop: true),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideCopy extends StatelessWidget {
  const _SlideCopy({
    required this.slide,
    this.compact = false,
    this.desktop = false,
  });

  final OnboardingSlideModel slide;
  final bool compact;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final titleSize = desktop
        ? 46.0
        : compact
        ? 28.0
        : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slide.eyebrow,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.brandGoldLight,
            letterSpacing: 2.1,
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Text(
          slide.title,
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: titleSize,
            height: 1.08,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 10 : 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 530),
          child: Text(
            slide.description,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: desktop ? 17 : 14,
              height: desktop ? 1.65 : 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingContextCard extends StatelessWidget {
  const _FloatingContextCard({required this.slide, this.compact = false});

  final OnboardingSlideModel slide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 230 : 310,
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(compact ? 17 : 21),
        border: Border.all(color: AppColors.glassBorder(0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 46,
            height: compact ? 38 : 46,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(compact ? 11 : 14),
            ),
            child: Icon(
              slide.cardIcon,
              color: AppColors.textOnGold,
              size: compact ? 20 : 23,
            ),
          ),
          SizedBox(width: compact ? 11 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  slide.cardSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideImage extends StatelessWidget {
  const _SlideImage({required this.assetPath, required this.alignment});

  final String assetPath;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) =>
          const _OnboardingImageFallback(),
    );
  }
}

class _OnboardingImageFallback extends StatelessWidget {
  const _OnboardingImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandBlueDark,
            AppColors.bgCinema,
            AppColors.bgCinemaDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.spotlightBlue.withValues(alpha: 0.09),
              ),
            ),
          ),
          Icon(
            Icons.local_movies_outlined,
            size: 72,
            color: AppColors.brandGold.withValues(alpha: 0.42),
          ),
        ],
      ),
    );
  }
}

class _CinemaImageOverlay extends StatelessWidget {
  const _CinemaImageOverlay({this.soft = false});

  final bool soft;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: soft
              ? [
                  Colors.transparent,
                  AppColors.bgCinema.withValues(alpha: 0.06),
                  AppColors.bgCinema.withValues(alpha: 0.48),
                ]
              : [
                  AppColors.bgCinema.withValues(alpha: 0.04),
                  AppColors.bgCinema.withValues(alpha: 0.18),
                  AppColors.bgCinema.withValues(alpha: 0.94),
                ],
          stops: const [0, 0.5, 1],
        ),
      ),
    );
  }
}

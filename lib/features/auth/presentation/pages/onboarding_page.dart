import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/onboarding_slide_model.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../widgets/onboarding_slide_widget.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.onCompleted, this.completionPath});

  final FutureOr<void> Function()? onCompleted;
  final String? completionPath;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final slide in onboardingSlides) {
      unawaited(
        precacheImage(
          AssetImage(slide.assetPath),
          context,
          onError: (error, stackTrace) {
            // The visible image supplies the branded fallback.
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (_currentIndex == onboardingSlides.length - 1) {
      await _completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _goBack() async {
    if (_currentIndex == 0) return;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    try {
      if (widget.onCompleted != null) {
        await widget.onCompleted!();
      } else {
        await ref.read(onboardingProvider.notifier).completeOnboarding();
      }
      if (!mounted) return;
      final completionPath = widget.completionPath;
      if (completionPath != null) {
        context.go(completionPath);
      } else {
        context.go(Routes.login, extra: {'isLogin': false});
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  String get _ctaLabel {
    if (_currentIndex == 0) return 'Commencer';
    if (_currentIndex == onboardingSlides.length - 1) {
      return 'Explorer GUEZS FILMS';
    }
    return 'Suivant';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCinemaDark,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: ResponsiveLayout(
            builder: (context, responsive) => Column(
              children: [
                _OnboardingHeader(
                  compact: responsive.isMobile,
                  onSkip: _isCompleting ? null : _completeOnboarding,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingSlides.length,
                    onPageChanged: (index) {
                      if (index == _currentIndex) return;
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return OnboardingSlideWidget(
                        key: ValueKey('onboarding-slide-$index'),
                        slide: onboardingSlides[index],
                        index: index,
                      );
                    },
                  ),
                ),
                _OnboardingControls(
                  currentIndex: _currentIndex,
                  itemCount: onboardingSlides.length,
                  label: _ctaLabel,
                  isCompleting: _isCompleting,
                  desktop: responsive.isDesktop,
                  onBack: _currentIndex == 0 ? null : _goBack,
                  onNext: _advance,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.compact, required this.onSkip});

  final bool compact;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 40, 10, compact ? 10 : 32, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.brandGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.glassBorder(0.35)),
            ),
            child: const Icon(
              Icons.movie_filter_rounded,
              size: 18,
              color: AppColors.brandGoldLight,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'GUEZS FILMS',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 2.2,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              minimumSize: const Size(76, 48),
            ),
            child: const Text('Passer'),
          ),
        ],
      ),
    );
  }
}

class _OnboardingControls extends StatelessWidget {
  const _OnboardingControls({
    required this.currentIndex,
    required this.itemCount,
    required this.label,
    required this.isCompleting,
    required this.desktop,
    required this.onBack,
    required this.onNext,
  });

  final int currentIndex;
  final int itemCount;
  final String label;
  final bool isCompleting;
  final bool desktop;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final progress = OnboardingProgressIndicator(
      currentIndex: currentIndex,
      itemCount: itemCount,
    );
    final button = _OnboardingPrimaryButton(
      label: label,
      loading: isCompleting,
      onPressed: isCompleting ? null : onNext,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        desktop ? 48 : 18,
        14,
        desktop ? 48 : 18,
        desktop ? 20 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCinemaDark.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: AppColors.glassBorder(0.16))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: desktop
              ? Row(
                  children: [
                    SizedBox(width: 330, child: progress),
                    const Spacer(),
                    if (onBack != null) ...[
                      _BackButton(onPressed: onBack!),
                      const SizedBox(width: 12),
                    ],
                    SizedBox(width: 310, child: button),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    progress,
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (onBack != null) ...[
                          _BackButton(onPressed: onBack!),
                          const SizedBox(width: 11),
                        ],
                        Expanded(child: button),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Écran précédent',
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Précédent',
        style: IconButton.styleFrom(
          minimumSize: const Size(54, 54),
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surfaceObsidian,
          side: BorderSide(color: AppColors.glassBorder(0.28)),
        ),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  const _OnboardingPrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGold.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.textOnGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: loading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.textOnGold,
                    ),
                  )
                : Row(
                    key: ValueKey(label),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(label, style: AppTextStyles.buttonLarge),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
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

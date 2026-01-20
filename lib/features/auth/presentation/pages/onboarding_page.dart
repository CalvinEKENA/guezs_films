import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Onboarding page with animated slides
/// Introduces the app features before login
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.movie_filter_rounded,
      title: 'Films & Séries Illimités',
      description:
          'Accédez à des milliers de films et séries en streaming haute qualité, où que vous soyez.',
      gradient: [AppColors.primary, AppColors.primaryDark],
    ),
    _OnboardingSlide(
      icon: Icons.download_rounded,
      title: 'Téléchargez & Regardez',
      description:
          'Téléchargez vos contenus préférés et regardez-les hors ligne, même sans connexion internet.',
      gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
    ),
    _OnboardingSlide(
      icon: Icons.devices_rounded,
      title: 'Sur Tous Vos Écrans',
      description:
          'Profitez de Guezs Films sur votre téléphone, tablette, ordinateur ou TV connectée.',
      gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
    _OnboardingSlide(
      icon: Icons.family_restroom_rounded,
      title: 'Profils Personnalisés',
      description:
          'Créez jusqu\'à 4 profils pour toute la famille avec des recommandations adaptées.',
      gradient: [AppColors.accent, AppColors.accentSoft],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'Passer',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index], index);
                },
              ),
            ),

            // Indicators and button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.surfaceVariant,
                      expansionFactor: 3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  GradientButton(
                    text: _currentPage == _slides.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    width: double.infinity,
                    onPressed: _nextPage,
                    icon: _currentPage == _slides.length - 1
                        ? Icons.arrow_forward
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: slide.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(slide.icon, size: 70, color: Colors.white),
              )
              .animate(key: ValueKey('icon_$index'))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          Text(
                slide.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
                slide.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              )
              .animate(key: ValueKey('desc_$index'))
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

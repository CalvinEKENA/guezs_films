import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _Phase { s1, s2, s3, s4, logo, done }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  _Phase _phase = _Phase.s1;
  Timer? _timer;

  // Couleur ambiante par écran (Utilisation de l'Or Métallique pour la cohérence Premium)
  static const _ambientColors = {
    _Phase.s1: AppColors.accentSoft,
    _Phase.s2: AppColors.accentSoft,
    _Phase.s3: AppColors.accentSoft,
    _Phase.s4: AppColors.accentSoft,
  };

  // Données des 4 écrans
  static const _screens = [
    _ScreenData(
      phase: _Phase.s1,
      number: '01 — 04',
      title: 'Le cinéma africain,\nen lumière.',
      subtitle: 'Des œuvres qui parlent de nous,\nracontées par nous.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    _ScreenData(
      phase: _Phase.s2,
      number: '02 — 04',
      title: 'Les créateurs d\'ici,\nà l\'honneur.',
      subtitle: 'Talents camerounais et africains\nau premier plan.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    _ScreenData(
      phase: _Phase.s3,
      number: '03 — 04',
      title: 'Votre culture.\nVotre écran.',
      subtitle: 'Séries originales, films exclusifs,\nhistoires locales.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
    _ScreenData(
      phase: _Phase.s4,
      number: '04 — 04',
      title: 'Une nouvelle ère\ncommence.',
      subtitle: 'Guezs Films. Tout le cinéma africain.',
      imagePath: 'assets/images/onboarding_4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer(const Duration(seconds: 5));
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, _advance);
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      switch (_phase) {
        case _Phase.s1:
          _phase = _Phase.s2;
          _startTimer(const Duration(seconds: 5));
        case _Phase.s2:
          _phase = _Phase.s3;
          _startTimer(const Duration(seconds: 5));
        case _Phase.s3:
          _phase = _Phase.s4;
          _startTimer(const Duration(seconds: 5));
        case _Phase.s4:
          _phase = _Phase.logo;
          // 1200ms fade-in + 1600ms hold + 1000ms fade-out = 3800ms
          _startTimer(const Duration(milliseconds: 3800));
        case _Phase.logo:
          _phase = _Phase.done;
          _timer = null;
          // Mark onboarding as complete in Hive
          ref.read(onboardingProvider.notifier).completeOnboarding();
          context.go(Routes.login, extra: {'isLogin': false});
        case _Phase.done:
          break;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogoPhase = _phase == _Phase.logo;
    final ambientColor = _ambientColors[_phase];
    final currentScreen = _screens.firstWhere(
      (s) => s.phase == _phase,
      orElse: () => _screens.first,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond cinématographique avec effet de zoom subtil et fondu
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            transitionBuilder: (child, animation) {
              final scaleAnimation = Tween<double>(begin: 1.05, end: 1.0)
                  .animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              );
            },
            child: isLogoPhase
                ? Container(
                    key: const ValueKey('black_bg'),
                    color: Colors.black,
                  )
                : Image.asset(
                    currentScreen.imagePath,
                    key: ValueKey(currentScreen.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                  ),
          ),

          // Superposition de gradients pour contraste premium
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Fond ambiant animé (couleur subtile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.5),
                radius: 1.2,
                colors: [
                  (ambientColor ?? Colors.transparent).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Contenu principal (AnimatedSwitcher pour le cross-fade)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: child,
                ),
              );
            },
            child: isLogoPhase
                ? _LogoScreen(key: const ValueKey('logo'), onDone: _advance)
                : _buildOnboardingContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    final data = _screens.firstWhere(
      (s) => s.phase == _phase,
      orElse: () => _screens.first,
    );

    return _OnboardingScreen(
      key: ValueKey(_phase),
      data: data,
      accentColor: _ambientColors[_phase] ?? AppColors.primary,
    );
  }
}

// ─── Écran d'onboarding individuel ────────────────────────────────────────────

class _OnboardingScreen extends StatefulWidget {
  final _ScreenData data;
  final Color accentColor;

  const _OnboardingScreen({
    super.key,
    required this.data,
    required this.accentColor,
  });

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.6)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _anim,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );
    _subtitleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: const Interval(0.3, 1.0)));

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveValues.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),

          // Numéro d'écran
          Text(
            widget.data.number,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accentSoft,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          // Ligne décorative colorée
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 60,
            height: 1.5,
            color: AppColors.accentSoft,
          ),

          const SizedBox(height: 32),

          // Titre
          AnimatedBuilder(
            animation: _anim,
            builder: (_, child) => Opacity(
              opacity: _titleOpacity.value,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  widget.data.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: responsive.isDesktop
                        ? 56
                        : (responsive.width >= 430 ? 44 : 38),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sous-texte
          AnimatedBuilder(
            animation: _anim,
            builder: (_, child) => Opacity(
              opacity: _subtitleOpacity.value,
              child: Text(
                widget.data.subtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

// ─── Logo cinématique ─────────────────────────────────────────────────────────

class _LogoScreen extends StatefulWidget {
  final VoidCallback onDone;

  const _LogoScreen({super.key, required this.onDone});

  @override
  State<_LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<_LogoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Séquence : fade-in 1200ms → hold 1600ms → fade-out 1000ms = 3800ms total
    _anim = AnimationController(
      duration: const Duration(milliseconds: 3800),
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1200,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1600),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1000,
      ),
    ]).animate(_anim);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1200,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 2600),
    ]).animate(_anim);

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveValues.of(context);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Center(
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              'assets/icons/logo.png',
              width: responsive.isDesktop ? 260 : 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _ScreenData {
  final _Phase phase;
  final String number;
  final String title;
  final String subtitle;
  final String imagePath;

  const _ScreenData({
    required this.phase,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

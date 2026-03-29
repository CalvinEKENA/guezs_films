import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _Phase { s1, s2, s3, s4, logo, done }

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  _Phase _phase = _Phase.s1;
  Timer? _timer;

  // Couleur ambiante par écran
  static const _ambientColors = {
    _Phase.s1: AppColors.primary,
    _Phase.s2: AppColors.accent,
    _Phase.s3: Color(0xFF2563EB), // bleu profond
    _Phase.s4: Color(0xFF059669), // vert profond
  };

  // Données des 4 écrans
  static const _screens = [
    _ScreenData(
      phase: _Phase.s1,
      number: '01 — 04',
      title: 'Le cinéma africain,\nen lumière.',
      subtitle: 'Des œuvres qui parlent de nous,\nracontées par nous.',
    ),
    _ScreenData(
      phase: _Phase.s2,
      number: '02 — 04',
      title: 'Les créateurs d\'ici,\nà l\'honneur.',
      subtitle: 'Talents camerounais et africains\nau premier plan.',
    ),
    _ScreenData(
      phase: _Phase.s3,
      number: '03 — 04',
      title: 'Votre culture.\nVotre écran.',
      subtitle: 'Séries originales, films exclusifs,\nhistoires locales.',
    ),
    _ScreenData(
      phase: _Phase.s4,
      number: '04 — 04',
      title: 'Une nouvelle ère\ncommence.',
      subtitle: 'Guezs Films. Tout le cinéma africain.',
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond ambiant animé (couleur subtile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  (ambientColor ?? Colors.transparent)
                      .withValues(alpha: 0.06),
                  Colors.black,
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
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
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

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.6)),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _anim,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: const Interval(0.3, 1.0)),
    );

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),

          // Numéro d'écran
          Text(
            widget.data.number,
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.accentColor.withValues(alpha: 0.8),
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          // Ligne décorative colorée
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 48,
            height: 2,
            color: widget.accentColor,
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
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
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
                  color: AppColors.textTertiary,
                  height: 1.7,
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
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 1200,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1600),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1000,
      ),
    ]).animate(_anim);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Center(
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              'assets/icons/logo.png',
              width: 220,
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

  const _ScreenData({
    required this.phase,
    required this.number,
    required this.title,
    required this.subtitle,
  });
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Beam animation
  late final Animation<double> _beamPosition;
  late final Animation<double> _beamOpacity;

  // Logo animations
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  // Golden glow
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowRadius;

  // Studio name text
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSpacing;

  // Screen fade-out
  late final Animation<double> _screenOpacity;

  // Background gradient
  late final Animation<double> _bgGradientOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    // ── Background gradient: subtle radial depth ──
    _bgGradientOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
      ),
    );

    // ── Golden light beam sweeps across the screen ──
    _beamPosition = Tween<double>(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.02, 0.55, curve: Curves.easeInOut),
      ),
    );
    _beamOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.02, 0.55),
      ),
    );

    // ── Logo fade-in + scale-up (emerges as beam passes center) ──
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.45, curve: Curves.easeIn),
      ),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // ── Golden glow behind logo — persists subtly ──
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.35), weight: 70),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.80, curve: Curves.easeInOut),
      ),
    );
    _glowRadius = Tween<double>(begin: 60.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
      ),
    );

    // ── "GUEZS FILMS" text: delayed reveal with expanding letter-spacing ──
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.72, curve: Curves.easeIn),
      ),
    );
    _textSpacing = Tween<double>(begin: 6.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.78, curve: Curves.easeOut),
      ),
    );

    // ── Screen fade-out ──
    _screenOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        final isOnboardingComplete = ref.read(onboardingProvider);
        if (isOnboardingComplete) {
          context.go(Routes.login);
        } else {
          context.go(Routes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _screenOpacity.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Subtle radial background gradient for depth ──
                Opacity(
                  opacity: _bgGradientOpacity.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          const Color(0xFF1A1A1A).withValues(alpha: 0.6),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Floating golden dust particles ──
                CustomPaint(
                  size: size,
                  painter: _GoldenDustPainter(
                    progress: _controller.value,
                    particleOpacity: _glowOpacity.value.clamp(0.0, 1.0),
                  ),
                ),

                // ── Logo, glow and text ──
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Golden glow behind logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_glowOpacity.value > 0)
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: _glowOpacity.value * 0.5,
                                    ),
                                    blurRadius: _glowRadius.value,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: AppColors.accentSoft.withValues(
                                      alpha: _glowOpacity.value * 0.25,
                                    ),
                                    blurRadius: _glowRadius.value * 1.5,
                                    spreadRadius: 30,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: _glowOpacity.value * 0.15,
                                    ),
                                    blurRadius: 140,
                                    spreadRadius: 50,
                                  ),
                                ],
                              ),
                            ),
                          // Logo with scale animation
                          Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Image.asset(
                                'assets/icons/icon2.png',
                                width: 170,
                                height: 170,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // "GUEZS FILMS" studio name
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Text(
                          'GUEZS FILMS',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            color: AppColors.accentSoft,
                            fontWeight: FontWeight.w600,
                            letterSpacing: _textSpacing.value,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Golden light beam overlay ──
                Opacity(
                  opacity: _beamOpacity.value,
                  child: CustomPaint(
                    size: size,
                    painter: _GoldenBeamPainter(
                      beamPosition: _beamPosition.value,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Golden Light Beam Painter ─────────────────────────────────────────────────

class _GoldenBeamPainter extends CustomPainter {
  final double beamPosition;

  const _GoldenBeamPainter({required this.beamPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final beamCenterX = size.width * beamPosition;
    const beamHalfWidth = 90.0;
    final slant = size.height * 0.22;

    final path = Path()
      ..moveTo(beamCenterX - beamHalfWidth - slant, 0)
      ..lineTo(beamCenterX + beamHalfWidth - slant, 0)
      ..lineTo(beamCenterX + beamHalfWidth + slant, size.height)
      ..lineTo(beamCenterX - beamHalfWidth + slant, size.height)
      ..close();

    final rect = Rect.fromLTWH(
      beamCenterX - beamHalfWidth - slant,
      0,
      beamHalfWidth * 2 + slant * 2,
      size.height,
    );

    // Golden-tinted beam instead of pure white
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFD4AF37).withValues(alpha: 0.03),
          const Color(0xFFFFD700).withValues(alpha: 0.10),
          const Color(0xFFD4AF37).withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GoldenBeamPainter old) =>
      old.beamPosition != beamPosition;
}

// ─── Golden Dust Particles Painter ─────────────────────────────────────────────

class _GoldenDustPainter extends CustomPainter {
  final double progress;
  final double particleOpacity;

  static final List<_Particle> _particles = List.generate(35, (i) {
    final random = Random(i * 42);
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: 1.0 + random.nextDouble() * 2.5,
      speed: 0.3 + random.nextDouble() * 0.7,
      phase: random.nextDouble() * 2 * pi,
    );
  });

  const _GoldenDustPainter({
    required this.progress,
    required this.particleOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particleOpacity <= 0) return;

    for (final p in _particles) {
      // Slow floating movement
      final floatY = (p.y + progress * p.speed * 0.4) % 1.0;
      final floatX = p.x + sin(progress * 4 * pi + p.phase) * 0.02;

      // Twinkling effect
      final twinkle = (sin(progress * 6 * pi + p.phase) + 1) / 2;
      final alpha = particleOpacity * twinkle * 0.6;

      final paint = Paint()
        ..color = AppColors.accent.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(floatX * size.width, floatY * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoldenDustPainter old) =>
      old.progress != progress || old.particleOpacity != particleOpacity;
}

class _Particle {
  final double x, y, size, speed, phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

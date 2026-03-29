import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _beamPosition;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _screenOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _beamPosition = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.60, curve: Curves.easeInOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.50, curve: Curves.easeIn),
      ),
    );

    _glowOpacity =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 0.82, curve: Curves.easeInOut),
          ),
        );

    _screenOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) context.go(Routes.onboarding);
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
                // Logo + golden glow
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Golden glow behind logo
                      if (_glowOpacity.value > 0)
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(
                                  alpha: _glowOpacity.value * 0.6,
                                ),
                                blurRadius: 80,
                                spreadRadius: 20,
                              ),
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: _glowOpacity.value * 0.3,
                                ),
                                blurRadius: 120,
                                spreadRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      // Logo
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Image.asset(
                          'assets/icons/icon2.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                // Light beam overlay
                CustomPaint(
                  size: size,
                  painter: _LightBeamPainter(beamPosition: _beamPosition.value),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LightBeamPainter extends CustomPainter {
  final double beamPosition;

  const _LightBeamPainter({required this.beamPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final beamCenterX = size.width * beamPosition;
    const beamHalfWidth = 80.0;
    final slant = size.height * 0.25; // angle diagonal du faisceau

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

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LightBeamPainter old) => old.beamPosition != beamPosition;
}

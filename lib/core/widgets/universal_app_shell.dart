import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class UniversalAppShell extends StatelessWidget {
  const UniversalAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaQuery.size.height;
        final appWidth = math.min(
          availableWidth,
          AppConstants.universalAppMaxWidth,
        );
        final isFramed = availableWidth > AppConstants.universalAppMaxWidth;
        final radius = BorderRadius.circular(isFramed ? 24 : 0);

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.bgCinemaDark,
                AppColors.brandBlueDark,
                AppColors.bgCinemaDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              width: appWidth,
              height: availableHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.bgCinema,
                borderRadius: radius,
                border: isFramed
                    ? Border.all(color: AppColors.glassBorder(0.24), width: 0.8)
                    : null,
                boxShadow: isFramed
                    ? [
                        BoxShadow(
                          color: AppColors.spotlightBlue.withValues(
                            alpha: 0.14,
                          ),
                          blurRadius: 60,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.58),
                          blurRadius: 48,
                          offset: const Offset(0, 18),
                        ),
                      ]
                    : null,
              ),
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: Size(appWidth, availableHeight),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

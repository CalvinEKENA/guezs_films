import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Étape ${currentIndex + 1} sur $itemCount',
      child: Row(
        children: List.generate(itemCount, (index) {
          final isReached = index <= currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              height: index == currentIndex ? 4 : 2,
              margin: EdgeInsets.only(right: index == itemCount - 1 ? 0 : 7),
              decoration: BoxDecoration(
                gradient: isReached ? AppColors.goldGradient : null,
                color: isReached ? null : AppColors.textDisabled,
                borderRadius: BorderRadius.circular(99),
                boxShadow: index == currentIndex
                    ? [
                        BoxShadow(
                          color: AppColors.brandGold.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

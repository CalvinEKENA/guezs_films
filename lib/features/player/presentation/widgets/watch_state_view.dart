import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';

class WatchStateView extends StatelessWidget {
  const WatchStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.showProgress = false,
  });

  const WatchStateView.loading({
    super.key,
    this.title = 'Chargement',
    this.message = 'Préparation de la lecture...',
  }) : icon = Icons.play_circle_outline_rounded,
       primaryLabel = null,
       onPrimaryPressed = null,
       secondaryLabel = null,
       onSecondaryPressed = null,
       showProgress = true;

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showProgress)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    Icon(icon, color: AppColors.textTertiary, size: 56),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (primaryLabel != null && onPrimaryPressed != null) ...[
                    const SizedBox(height: 24),
                    GradientButton(
                      text: primaryLabel!,
                      icon: Icons.arrow_back_rounded,
                      onPressed: onPrimaryPressed!,
                    ),
                  ],
                  if (secondaryLabel != null && onSecondaryPressed != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onSecondaryPressed!,
                      child: Text(
                        secondaryLabel!,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

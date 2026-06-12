import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PremiumPageHeader extends StatelessWidget {
  const PremiumPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}

class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return _PremiumStateFrame(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      secondaryLabel: secondaryLabel,
      onSecondaryAction: onSecondaryAction,
    );
  }
}

class PremiumErrorState extends StatelessWidget {
  const PremiumErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _PremiumStateFrame(
      icon: Icons.cloud_off_rounded,
      title: title,
      message: message,
      iconColor: AppColors.error,
      actionLabel: onRetry == null ? null : 'Réessayer',
      onAction: onRetry,
    );
  }
}

class PremiumLoadingState extends StatelessWidget {
  const PremiumLoadingState({
    super.key,
    this.title = 'Préparation de votre espace',
    this.message = 'Quelques instants suffisent.',
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.brandGold,
          ),
        ),
      );
    }

    return _PremiumStateFrame(
      icon: Icons.auto_awesome_rounded,
      title: title,
      message: message,
      loading: true,
    );
  }
}

class _PremiumStateFrame extends StatelessWidget {
  const _PremiumStateFrame({
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.brandGoldLight,
    this.loading = false,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceObsidian.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.glassBorder(0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.34),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder(0.22)),
                  ),
                  child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.brandGold,
                          ),
                        )
                      : Icon(icon, size: 34, color: iconColor),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandGold,
                        foregroundColor: AppColors.textOnGold,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
                if (secondaryLabel != null && onSecondaryAction != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onSecondaryAction,
                    child: Text(secondaryLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

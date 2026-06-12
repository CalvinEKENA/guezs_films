import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PremiumFeedbackTone { info, success, warning, error }

void showPremiumSnackBar(
  BuildContext context, {
  required String message,
  PremiumFeedbackTone tone = PremiumFeedbackTone.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        showCloseIcon: actionLabel == null,
        backgroundColor: _toneColor(tone),
        content: Row(
          children: [
            Icon(_toneIcon(tone), size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
}

Future<bool> showPremiumConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Annuler',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: destructive
                ? AppColors.error
                : AppColors.brandGold,
            foregroundColor: destructive
                ? AppColors.textPrimary
                : AppColors.textOnGold,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showPremiumInfoSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  String buttonLabel = 'Compris',
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) => Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 31, color: AppColors.brandGoldLight),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 9),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Color _toneColor(PremiumFeedbackTone tone) {
  return switch (tone) {
    PremiumFeedbackTone.info => AppColors.surfaceVariant,
    PremiumFeedbackTone.success => const Color(0xFF0B5137),
    PremiumFeedbackTone.warning => const Color(0xFF5A4305),
    PremiumFeedbackTone.error => const Color(0xFF681C32),
  };
}

IconData _toneIcon(PremiumFeedbackTone tone) {
  return switch (tone) {
    PremiumFeedbackTone.info => Icons.info_outline_rounded,
    PremiumFeedbackTone.success => Icons.check_circle_outline_rounded,
    PremiumFeedbackTone.warning => Icons.warning_amber_rounded,
    PremiumFeedbackTone.error => Icons.error_outline_rounded,
  };
}

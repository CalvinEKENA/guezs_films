import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bannière affichée en haut de l'écran lorsque l'utilisateur est hors ligne
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isOffline) {
        if (!isOffline) return const SizedBox.shrink();

        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Semantics(
                liveRegion: true,
                label: 'Mode hors ligne',
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bottomSheet.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.46),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.warning,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Hors ligne · certains contenus peuvent être indisponibles',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, stackTrace) => const SizedBox.shrink(),
    );
  }
}

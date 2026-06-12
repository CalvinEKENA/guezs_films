import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/premium_feedback.dart';
import '../../../../core/widgets/premium_states.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/download_item.dart';
import '../providers/download_providers.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          builder: (context, responsive) {
            if (!PlatformCapabilities.supportsDownloads) {
              return Column(
                children: [
                  _DownloadsHeader(responsive: responsive, mobileOnly: true),
                  Expanded(
                    child: PremiumEmptyState(
                      icon: Icons.phone_android_rounded,
                      title: 'Vos séances voyagent avec vous',
                      message:
                          'Les téléchargements hors-ligne sont réservés à l’application mobile pour le moment.',
                      actionLabel: 'Explorer le catalogue',
                      onAction: () => context.go(Routes.search),
                    ),
                  ),
                ],
              );
            }

            final downloadsAsync = ref.watch(activeDownloadsProvider);
            return Column(
              children: [
                _DownloadsHeader(
                  responsive: responsive,
                  count: downloadsAsync.valueOrNull?.length,
                ),
                Expanded(
                  child: downloadsAsync.when(
                    data: (downloads) {
                      if (downloads.isEmpty) {
                        return PremiumEmptyState(
                          icon: Icons.download_for_offline_outlined,
                          title: 'Votre vidéothèque hors-ligne est prête',
                          message:
                              'Téléchargez un film depuis sa fiche pour le regarder sans connexion.',
                          actionLabel: 'Choisir un film',
                          onAction: () => context.go(Routes.search),
                        );
                      }
                      return _DownloadsList(
                        downloads: downloads,
                        responsive: responsive,
                      );
                    },
                    loading: () => _DownloadsLoading(responsive: responsive),
                    error: (_, _) => PremiumErrorState(
                      title: 'Téléchargements indisponibles',
                      message:
                          'Impossible de lire les fichiers enregistrés sur cet appareil.',
                      onRetry: () => ref.invalidate(activeDownloadsProvider),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DownloadsHeader extends StatelessWidget {
  const _DownloadsHeader({
    required this.responsive,
    this.count,
    this.mobileOnly = false,
  });

  final ResponsiveValues responsive;
  final int? count;
  final bool mobileOnly;

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      maxWidth: 980,
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        responsive.isDesktop ? 28 : 18,
        responsive.pagePadding,
        18,
      ),
      child: PremiumPageHeader(
        title: 'Téléchargements',
        subtitle: 'Vos contenus disponibles sans connexion sur cet appareil.',
        trailing: mobileOnly
            ? const _MobileOnlyBadge()
            : count != null && count! > 0
            ? _DownloadCountBadge(count: count!)
            : null,
      ),
    );
  }
}

class _DownloadsLoading extends StatelessWidget {
  const _DownloadsLoading({required this.responsive});

  final ResponsiveValues responsive;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        0,
        responsive.pagePadding,
        responsive.pagePadding,
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: const ShimmerLoading(
            width: double.infinity,
            height: 138,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
    );
  }
}

class _DownloadsList extends ConsumerWidget {
  const _DownloadsList({required this.downloads, required this.responsive});

  final List<DownloadItem> downloads;
  final ResponsiveValues responsive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        0,
        responsive.pagePadding,
        responsive.pagePadding,
      ),
      itemCount: downloads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = downloads[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: _DownloadCard(
              item: item,
              onPlay:
                  item.status == DownloadStatus.completed &&
                      item.localPath.trim().isNotEmpty
                  ? () => context.push(
                      Routes.legacyPlayerPath(
                        videoUrl: item.localPath,
                        title: item.title,
                        posterUrl: item.posterPath,
                      ),
                    )
                  : null,
              onPause: item.status == DownloadStatus.downloading
                  ? () =>
                        ref.read(downloadServiceProvider).pauseDownload(item.id)
                  : null,
              onResume:
                  item.status == DownloadStatus.paused ||
                      item.status == DownloadStatus.failed
                  ? () => _restartDownload(context, ref, item)
                  : null,
              onDelete: () => _deleteDownload(context, ref, item),
            ),
          ),
        );
      },
    );
  }

  Future<void> _restartDownload(
    BuildContext context,
    WidgetRef ref,
    DownloadItem item,
  ) async {
    showPremiumSnackBar(
      context,
      message: 'Reprise du téléchargement de “${item.title}”.',
      tone: PremiumFeedbackTone.info,
    );
    await ref
        .read(downloadServiceProvider)
        .startDownload(item.copyWith(status: DownloadStatus.pending));
  }

  Future<void> _deleteDownload(
    BuildContext context,
    WidgetRef ref,
    DownloadItem item,
  ) async {
    final confirmed = await showPremiumConfirmationDialog(
      context,
      title: 'Supprimer ce téléchargement ?',
      message:
          '“${item.title}” sera retiré de cet appareil. Cette action ne supprime pas le contenu de votre compte.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref
          .read(downloadServiceProvider)
          .deleteDownload(item.id, item.localPath);
      if (!context.mounted) return;
      showPremiumSnackBar(
        context,
        message: 'Téléchargement supprimé.',
        tone: PremiumFeedbackTone.success,
      );
    } catch (_) {
      if (!context.mounted) return;
      showPremiumSnackBar(
        context,
        message: 'La suppression n’a pas pu être terminée.',
        tone: PremiumFeedbackTone.error,
      );
    }
  }
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.item,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final DownloadItem item;
  final VoidCallback? onPlay;
  final Future<void> Function()? onPause;
  final Future<void> Function()? onResume;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = item.progress.clamp(0, 1).toDouble();
    final status = _statusPresentation(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder(0.24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 114,
            child: CachedImage(
              imageUrl: item.posterPath,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(status.icon, size: 16, color: status.color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionBold.copyWith(
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _sizeLabel(item),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (item.status == DownloadStatus.downloading ||
                    item.status == DownloadStatus.paused) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(999),
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.spotlightBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${(progress * 100).round()} %',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onPlay != null)
            _DownloadActionButton(
              tooltip: 'Regarder hors-ligne',
              icon: Icons.play_arrow_rounded,
              emphasized: true,
              onPressed: onPlay!,
            )
          else if (onPause != null)
            _DownloadActionButton(
              tooltip: 'Mettre en pause',
              icon: Icons.pause_rounded,
              onPressed: () => unawaited(onPause!()),
            )
          else if (onResume != null)
            _DownloadActionButton(
              tooltip: item.status == DownloadStatus.failed
                  ? 'Réessayer'
                  : 'Reprendre',
              icon: item.status == DownloadStatus.failed
                  ? Icons.refresh_rounded
                  : Icons.play_arrow_rounded,
              onPressed: () => unawaited(onResume!()),
            ),
          PopupMenuButton<String>(
            tooltip: 'Options du téléchargement',
            color: AppColors.bottomSheet,
            onSelected: (value) {
              if (value == 'delete') unawaited(onDelete());
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Supprimer',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DownloadActionButton extends StatelessWidget {
  const _DownloadActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.emphasized = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          backgroundColor: emphasized
              ? AppColors.brandGold
              : AppColors.brandBlue.withValues(alpha: 0.56),
          foregroundColor: emphasized
              ? AppColors.textOnGold
              : AppColors.textPrimary,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _DownloadCountBadge extends StatelessWidget {
  const _DownloadCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.brandBlue.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder(0.36)),
      ),
      child: Text(
        '$count fichier${count > 1 ? 's' : ''}',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.brandGoldLight,
        ),
      ),
    );
  }
}

class _MobileOnlyBadge extends StatelessWidget {
  const _MobileOnlyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder(0.3)),
      ),
      child: Text(
        'Disponible sur mobile',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.brandGoldLight,
        ),
      ),
    );
  }
}

_DownloadStatusPresentation _statusPresentation(DownloadItem item) {
  return switch (item.status) {
    DownloadStatus.pending => const _DownloadStatusPresentation(
      label: 'En attente',
      icon: Icons.schedule_rounded,
      color: AppColors.textSecondary,
    ),
    DownloadStatus.downloading => const _DownloadStatusPresentation(
      label: 'Téléchargement en cours',
      icon: Icons.downloading_rounded,
      color: AppColors.spotlightBlue,
    ),
    DownloadStatus.completed => const _DownloadStatusPresentation(
      label: 'Prêt hors-ligne',
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    ),
    DownloadStatus.paused => const _DownloadStatusPresentation(
      label: 'Téléchargement en pause',
      icon: Icons.pause_circle_outline_rounded,
      color: AppColors.warning,
    ),
    DownloadStatus.failed => const _DownloadStatusPresentation(
      label: 'Téléchargement interrompu',
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    ),
  };
}

String _sizeLabel(DownloadItem item) {
  if (item.totalSize <= 0) {
    return item.status == DownloadStatus.pending
        ? 'Taille en attente'
        : 'Taille indisponible';
  }
  final total = _formatBytes(item.totalSize);
  if (item.status == DownloadStatus.downloading ||
      item.status == DownloadStatus.paused) {
    return '${_formatBytes(item.downloadedSize)} sur $total';
  }
  return total;
}

String _formatBytes(int bytes) {
  const megabyte = 1024 * 1024;
  const gigabyte = 1024 * megabyte;
  if (bytes >= gigabyte) {
    return '${(bytes / gigabyte).toStringAsFixed(1)} Go';
  }
  return '${(bytes / megabyte).toStringAsFixed(1)} Mo';
}

class _DownloadStatusPresentation {
  const _DownloadStatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

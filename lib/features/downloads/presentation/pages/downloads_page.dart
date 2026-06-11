import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/routes/route_constants.dart';
import '../../domain/entities/download_item.dart';
import '../providers/download_providers.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(activeDownloadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes Téléchargements', style: AppTextStyles.titleMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: downloadsAsync.when(
        data: (downloads) {
          if (downloads.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildDownloadsList(context, ref, downloads);
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 5,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => const ShimmerLoading(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Erreur: $err',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_for_offline,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun téléchargement',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vos films et séries téléchargés pour un visionnage hors-ligne apparaîtront ici.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(Routes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Explorer le catalogue',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(
    BuildContext context,
    WidgetRef ref,
    List<DownloadItem> downloads,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final item = downloads[index];
        return _buildDownloadCard(context, ref, item);
      },
    );
  }

  Widget _buildDownloadCard(
    BuildContext context,
    WidgetRef ref,
    DownloadItem item,
  ) {
    final isDownloading = item.status == DownloadStatus.downloading;
    final isPaused = item.status == DownloadStatus.paused;
    final isCompleted = item.status == DownloadStatus.completed;

    String subtitle = '';
    if (isCompleted) {
      final sizeMb = (item.totalSize / (1024 * 1024)).toStringAsFixed(1);
      subtitle = 'Téléchargé • $sizeMb MB';
    } else if (isDownloading || isPaused) {
      final percentage = (item.progress * 100).toStringAsFixed(0);
      subtitle = isPaused
          ? 'En pause • $percentage%'
          : 'Téléchargement... $percentage%';
    } else {
      subtitle = 'En attente...';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        blur: 10,
        opacity: 0.05,
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 80,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedImage(
                  imageUrl: item.posterPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isDownloading)
                    LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Actions
            if (isCompleted)
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 40,
                ),
                onPressed: () {
                  context.push(
                    Routes.legacyPlayerPath(
                      videoUrl: item.localPath,
                      title: item.title,
                    ),
                  );
                },
              )
            else if (isDownloading)
              GestureDetector(
                onTap: () =>
                    ref.read(downloadServiceProvider).pauseDownload(item.id),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: item.progress,
                      strokeWidth: 3,
                      color: AppColors.accent,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                    const Icon(Icons.pause, color: AppColors.accent, size: 20),
                  ],
                ),
              )
            else if (isPaused)
              IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
                onPressed: () =>
                    ref.read(downloadServiceProvider).startDownload(item),
              ),

            // Options Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
              color: AppColors.surface,
              onSelected: (value) {
                if (value == 'delete') {
                  ref
                      .read(downloadServiceProvider)
                      .deleteDownload(item.id, item.localPath);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/favorites_providers.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ma Liste',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ResponsiveLayout(
        builder: (context, responsive) => favoritesState.when(
          data: (favorites) {
            if (favorites.isEmpty) return _buildEmptyState(responsive);
            return _buildFavoritesGrid(context, ref, favorites, responsive);
          },
          loading: () => Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: ShimmerGrid(
              itemCount: responsive.posterColumns * 3,
              crossAxisCount: responsive.posterColumns,
              spacing: responsive.gridGap,
              padding: EdgeInsets.zero,
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: Text(
                'Erreur lors du chargement de vos favoris.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ResponsiveValues responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.pagePadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 80,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Votre liste est vide',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez des films et séries pour les retrouver ici.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteMovie> favorites,
    ResponsiveValues responsive,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(responsive.pagePadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.posterColumns,
        childAspectRatio: 0.58,
        crossAxisSpacing: responsive.gridGap,
        mainAxisSpacing: responsive.gridGap,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        final targetRoute = favorite.contentType == 'series'
            ? Routes.seriesDetailsPath(favorite.id)
            : Routes.filmDetailsPath(favorite.id);

        return _FavoriteCard(
              favorite: favorite,
              onTap: () => context.push(targetRoute),
              onRemove: () =>
                  ref.read(favoritesProvider.notifier).toggleFavorite(favorite),
            )
            .animate()
            .fadeIn(delay: (index * 35).ms)
            .scale(begin: const Offset(0.97, 0.97));
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteMovie favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _FavoritePoster(favorite: favorite)),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        favorite.contentType == 'series' ? 'Série' : 'Film',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              favorite.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Affiche le poster du favori.
/// Si posterPath est vide, fetche le posterUrl actuel depuis Firestore.
class _FavoritePoster extends ConsumerWidget {
  const _FavoritePoster({required this.favorite});

  final FavoriteMovie favorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favorite.posterPath.isNotEmpty) {
      return CachedImage(
        imageUrl: favorite.posterPath,
        borderRadius: BorderRadius.circular(8),
      );
    }

    if (favorite.contentType == 'series') {
      final seriesAsync = ref.watch(seriesDetailsProvider(favorite.id));
      return seriesAsync.when(
        data: (series) => CachedImage(
          imageUrl: series.posterUrl,
          borderRadius: BorderRadius.circular(8),
        ),
        loading: () => ShimmerLoading(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(8),
        ),
        error: (err, stack) =>
            CachedImage(imageUrl: null, borderRadius: BorderRadius.circular(8)),
      );
    }

    final filmAsync = ref.watch(filmDetailsProvider(favorite.id));
    return filmAsync.when(
      data: (film) => CachedImage(
        imageUrl: film.posterUrl,
        borderRadius: BorderRadius.circular(8),
      ),
      loading: () => ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(8),
      ),
      error: (err, stack) =>
          CachedImage(imageUrl: null, borderRadius: BorderRadius.circular(8)),
    );
  }
}

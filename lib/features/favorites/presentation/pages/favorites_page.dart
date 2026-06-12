import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/premium_content_card.dart';
import '../../../../core/widgets/premium_feedback.dart';
import '../../../../core/widgets/premium_states.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/favorite_movie.dart';
import '../providers/favorites_providers.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          builder: (context, responsive) => Column(
            children: [
              ResponsivePage(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  responsive.isDesktop ? 28 : 18,
                  responsive.pagePadding,
                  18,
                ),
                child: PremiumPageHeader(
                  title: 'Ma liste',
                  subtitle:
                      'Votre sélection personnelle de films et de séries.',
                  trailing: favoritesState.valueOrNull?.isNotEmpty == true
                      ? _CountBadge(count: favoritesState.valueOrNull!.length)
                      : null,
                ),
              ),
              Expanded(
                child: favoritesState.when(
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return PremiumEmptyState(
                        icon: Icons.chair_alt_rounded,
                        title: 'Votre fauteuil VIP vous attend',
                        message:
                            'Ajoutez vos films et séries favoris pour composer une programmation rien qu’à vous.',
                        actionLabel: 'Explorer le catalogue',
                        onAction: () => context.go(Routes.search),
                      );
                    }
                    return _FavoritesGrid(
                      favorites: favorites,
                      responsive: responsive,
                    );
                  },
                  loading: () => ResponsivePage(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    child: ShimmerGrid(
                      itemCount: responsive.posterColumns * 2,
                      crossAxisCount: responsive.posterColumns,
                      spacing: responsive.gridGap,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  error: (_, _) => PremiumErrorState(
                    title: 'Votre liste est indisponible',
                    message:
                        'Impossible de charger vos favoris. Vos contenus ne sont pas perdus.',
                    onRetry: () =>
                        ref.read(favoritesProvider.notifier).loadFavorites(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesGrid extends ConsumerWidget {
  const _FavoritesGrid({required this.favorites, required this.responsive});

  final List<FavoriteMovie> favorites;
  final ResponsiveValues responsive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsivePage(
      padding: EdgeInsets.fromLTRB(
        responsive.pagePadding,
        0,
        responsive.pagePadding,
        responsive.pagePadding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = responsive.posterColumns;
          final cardWidth =
              (constraints.maxWidth - (responsive.gridGap * (columns - 1))) /
              columns;

          return GridView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: cardWidth * 1.5 + 64,
              crossAxisSpacing: responsive.gridGap,
              mainAxisSpacing: responsive.gridGap + 8,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _FavoriteContentCard(
                favorite: favorite,
                width: cardWidth,
                onOpen: () {
                  context.push(
                    favorite.contentType == 'series'
                        ? Routes.seriesDetailsPath(favorite.id)
                        : Routes.filmDetailsPath(favorite.id),
                  );
                },
                onRemove: () => _removeFavorite(context, ref, favorite),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoriteMovie favorite,
  ) async {
    await ref.read(favoritesProvider.notifier).toggleFavorite(favorite);
    if (!context.mounted) return;

    showPremiumSnackBar(
      context,
      message: '“${favorite.title}” a été retiré de votre liste.',
      tone: PremiumFeedbackTone.success,
      actionLabel: 'Annuler',
      onAction: () {
        unawaited(
          ref.read(favoritesProvider.notifier).toggleFavorite(favorite),
        );
      },
    );
  }
}

class _FavoriteContentCard extends ConsumerWidget {
  const _FavoriteContentCard({
    required this.favorite,
    required this.width,
    required this.onOpen,
    required this.onRemove,
  });

  final FavoriteMovie favorite;
  final double width;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var posterUrl = favorite.posterPath;
    if (posterUrl.isEmpty) {
      if (favorite.contentType == 'series') {
        posterUrl =
            ref
                .watch(seriesDetailsProvider(favorite.id))
                .valueOrNull
                ?.posterUrl ??
            '';
      } else {
        posterUrl =
            ref
                .watch(filmDetailsProvider(favorite.id))
                .valueOrNull
                ?.posterUrl ??
            '';
      }
    }

    return PremiumContentCard(
      title: favorite.title,
      imageUrl: posterUrl,
      metadata: favorite.contentType == 'series' ? 'Série' : 'Film',
      badge: 'Dans ma liste',
      width: width,
      isFavorite: true,
      onFavoriteTap: onRemove,
      onTap: onOpen,
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

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
        '$count titre${count > 1 ? 's' : ''}',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.brandGoldLight),
      ),
    );
  }
}

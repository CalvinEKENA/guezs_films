import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/season_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/providers/favorites_providers.dart';

class SeriesDetailsPage extends ConsumerStatefulWidget {
  const SeriesDetailsPage({super.key, required this.seriesId});

  final String seriesId;

  @override
  ConsumerState<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends ConsumerState<SeriesDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String? _selectedSeasonId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final seasonsAsync = ref.watch(seasonsProvider(widget.seriesId));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: seriesAsync.when(
        data: (series) {
          final isFavorite = ref.watch(
            isFavoriteProvider((id: series.id, contentType: 'series')),
          );

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildBackdrop(
                  height: MediaQuery.of(context).size.height * 0.42,
                  backdropUrl: series.backdropUrl,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.title,
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(duration: 350.ms),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildMetadataPill(
                            icon: Icons.tv_rounded,
                            label:
                                '${series.numberOfSeasons} saison${series.numberOfSeasons > 1 ? 's' : ''}',
                          ),
                          _buildMetadataPill(
                            icon: Icons.calendar_today_outlined,
                            label: '${series.year}',
                          ),
                        ],
                      ),
                      if (series.genres.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: series.genres
                              .map((genre) => _buildGenreChip(genre))
                              .toList(growable: false),
                        ),
                      ],
                      const SizedBox(height: 24),
                      GradientButton(
                        text: isFavorite
                            ? 'Retirer des favoris'
                            : 'Ajouter aux favoris',
                        icon: isFavorite
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(
                                FavoriteMovie(
                                  id: series.id,
                                  title: series.title,
                                  posterPath: series.posterUrl,
                                  contentType: 'series',
                                  addedAt: DateTime.now().toIso8601String(),
                                ),
                              );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Synopsis',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        series.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Saisons',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      seasonsAsync.when(
                        data: (seasons) => _buildSeasonsAndEpisodes(
                          seriesId: series.id,
                          seriesTitle: series.title,
                          seasons: seasons,
                        ),
                        loading: () => const ShimmerContentRow(
                          itemCount: 3,
                          itemWidth: 140,
                        ),
                        error: (error, stackTrace) => Text(
                          'Impossible de charger les saisons.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Impossible de charger cette série.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'Réessayer',
                  onPressed: () {
                    ref
                      ..invalidate(seriesDetailsProvider(widget.seriesId))
                      ..invalidate(seasonsProvider(widget.seriesId));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonsAndEpisodes({
    required String seriesId,
    required String seriesTitle,
    required List<SeasonEntity> seasons,
  }) {
    if (seasons.isEmpty) {
      return Text(
        'Aucune saison disponible.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    final selectedSeasonId = _resolveSelectedSeasonId(seasons);
    final selectedSeason = seasons.firstWhere(
      (season) => season.id == selectedSeasonId,
    );
    final episodesAsync = ref.watch(
      episodesProvider((seriesId: seriesId, seasonId: selectedSeasonId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final season = seasons[index];
              final isSelected = season.id == selectedSeasonId;

              return ChoiceChip(
                label: Text(
                  season.title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedSeasonId = season.id;
                  });
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: seasons.length,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          selectedSeason.title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        episodesAsync.when(
          data: (episodes) {
            if (episodes.isEmpty) {
              return Text(
                'Aucun épisode disponible pour cette saison.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }

            return Column(
              children: episodes
                  .map(
                    (episode) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _EpisodeCard(
                        title: episode.title,
                        description: episode.description,
                        duration: _formatDurationSeconds(episode.durationSec),
                        episodeNumber: episode.episodeNumber,
                        seriesTitle: seriesTitle,
                        thumbnailUrl: episode.thumbnailUrl,
                        onTap: () => _playEpisode(
                          seriesId: seriesId,
                          seasonId: selectedSeasonId,
                          episodeId: episode.id,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
          loading: () => const ShimmerContentRow(itemCount: 3, itemWidth: 160),
          error: (error, stackTrace) => Text(
            'Impossible de charger les épisodes.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final opacity = (_scrollOffset / 180).clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: opacity),
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.65),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
      ),
    );
  }

  Widget _buildBackdrop({required double height, required String backdropUrl}) {
    final parallaxOffset = _scrollOffset * 0.35;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallaxOffset),
            child: CachedImage(
              imageUrl: backdropUrl,
              height: height + 80,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.35),
                  AppColors.background.withValues(alpha: 0.95),
                  AppColors.background,
                ],
                stops: const [0.0, 0.45, 0.78, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        genre,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _resolveSelectedSeasonId(List<SeasonEntity> seasons) {
    if (_selectedSeasonId != null &&
        seasons.any((season) => season.id == _selectedSeasonId)) {
      return _selectedSeasonId!;
    }

    final fallbackId = seasons.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedSeasonId = fallbackId;
        });
      }
    });
    return fallbackId;
  }

  String _formatDurationSeconds(int durationSec) {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _playEpisode({
    required String seriesId,
    required String seasonId,
    required String episodeId,
  }) {
    context.push(
      Routes.episodeWatchPath(
        seriesId: seriesId,
        seasonId: seasonId,
        episodeId: episodeId,
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.title,
    required this.description,
    required this.duration,
    required this.episodeNumber,
    required this.seriesTitle,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String title;
  final String description;
  final String duration;
  final int episodeNumber;
  final String seriesTitle;
  final String thumbnailUrl;
  final VoidCallback onTap;

  String get _epBadge => 'Ep.${episodeNumber.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // ── Image de fond 16:9 ─────────────────────────────────────
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedImage(
                      imageUrl: thumbnailUrl,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),

                  // ── Gradient sombre bas ─────────────────────────────────────
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.92),
                          ],
                          stops: const [0.0, 0.38, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ── Badge épisode (haut gauche) ────────────────────────────
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.55),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _epBadge,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                  // ── Durée (haut droite) — uniquement si non nulle ──────────
                  if (duration != '00:00')
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Bouton play central ────────────────────────────────────
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  // ── Texte bas (série + titre) ──────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            seriesTitle.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Filet accent gauche ────────────────────────────────────
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 380.ms, curve: Curves.easeOut)
        .slideY(begin: 0.04, end: 0, duration: 380.ms, curve: Curves.easeOut);
  }
}

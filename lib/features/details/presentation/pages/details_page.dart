import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/promo_code_dialog.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/providers/favorites_providers.dart';

class DetailsPage extends ConsumerStatefulWidget {
  const DetailsPage({super.key, required this.filmId});

  final String filmId;

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

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
    final filmAsync = ref.watch(filmDetailsProvider(widget.filmId));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: filmAsync.when(
        data: (film) {
          final isFavorite = ref.watch(
            isFavoriteProvider((id: film.id, contentType: 'film')),
          );

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildBackdrop(
                  height: MediaQuery.of(context).size.height * 0.42,
                  backdropUrl: film.backdropUrl,
                  onPlay: () => _playFilm(
                    videoUrl: film.videoUrl,
                    title: film.title,
                    posterUrl: film.posterUrl,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        film.title,
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
                            icon: Icons.star_rounded,
                            label: film.rating.toStringAsFixed(1),
                            color: AppColors.getRatingColor(film.rating),
                          ),
                          _buildMetadataPill(
                            icon: Icons.calendar_today_outlined,
                            label: '${film.year}',
                          ),
                          _buildMetadataPill(
                            icon: Icons.schedule_outlined,
                            label: _formatDurationMinutes(film.durationMin),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      if (film.genres.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: film.genres
                              .map((genre) => _buildGenreChip(genre))
                              .toList(growable: false),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: 'Lire',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => _playFilm(
                                videoUrl: film.videoUrl,
                                title: film.title,
                                posterUrl: film.posterUrl,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon: isFavorite ? Icons.check : Icons.add,
                            label: 'Favori',
                            onTap: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(
                                    FavoriteMovie(
                                      id: film.id,
                                      title: film.title,
                                      posterPath: film.posterUrl,
                                      contentType: 'film',
                                      addedAt: DateTime.now().toIso8601String(),
                                    ),
                                  );
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Synopsis',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        film.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 250.ms),
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
                  'Impossible de charger ce film.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'Réessayer',
                  onPressed: () =>
                      ref.invalidate(filmDetailsProvider(widget.filmId)),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildBackdrop({
    required double height,
    required String backdropUrl,
    required VoidCallback onPlay,
  }) {
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
          Center(
            child: GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ).animate().scale(duration: 350.ms).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataPill({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.surfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: color == null ? 1 : 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color ?? AppColors.border,
          width: color == null ? 1 : 0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color ?? AppColors.accent),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDurationMinutes(int durationMin) {
    final hours = durationMin ~/ 60;
    final minutes = durationMin % 60;
    if (hours == 0) {
      return '$minutes min';
    }
    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }

  void _playFilm({
    required String videoUrl,
    required String title,
    required String posterUrl,
  }) {
    showPromoCodeDialog(
      context,
      onSuccess: () {
        context.push(
          Routes.player,
          extra: {'videoUrl': videoUrl, 'title': title, 'posterUrl': posterUrl},
        );
      },
    );
  }
}

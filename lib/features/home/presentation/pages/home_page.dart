import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/film_entity.dart';
import '../../../../core/domain/entities/series_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/promo_code_dialog.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    final featuredFilmsAsync = ref.watch(featuredFilmsProvider);
    final featuredSeriesAsync = ref.watch(featuredSeriesProvider);
    final newFilmsAsync = ref.watch(newFilmsProvider);
    final filmsAsync = ref.watch(filmsProvider);
    final seriesAsync = ref.watch(seriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(featuredFilmsProvider)
            ..invalidate(featuredSeriesProvider)
            ..invalidate(newFilmsProvider)
            ..invalidate(filmsProvider)
            ..invalidate(seriesProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeroSection(
                featuredFilmsAsync: featuredFilmsAsync,
                featuredSeriesAsync: featuredSeriesAsync,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildFilmSection('Nouveautés', newFilmsAsync),
                _buildFilmSection('Films', filmsAsync),
                _buildSeriesSection('Séries', seriesAsync),
                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final opacity = (_scrollOffset / 150).clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: opacity),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'GUEZS',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection({
    required AsyncValue<List<FilmEntity>> featuredFilmsAsync,
    required AsyncValue<List<SeriesEntity>> featuredSeriesAsync,
  }) {
    final featuredFilms =
        featuredFilmsAsync.valueOrNull ?? const <FilmEntity>[];
    final featuredSeriesList =
        featuredSeriesAsync.valueOrNull ?? const <SeriesEntity>[];
    final featuredFilm = featuredFilms.isNotEmpty ? featuredFilms.first : null;
    final featuredSeries = featuredSeriesList.isNotEmpty
        ? featuredSeriesList.first
        : null;

    if (featuredFilm != null) {
      return _buildFilmHero(featuredFilm);
    }
    if (featuredSeries != null) {
      return _buildSeriesHero(featuredSeries);
    }
    if (featuredFilmsAsync.isLoading || featuredSeriesAsync.isLoading) {
      return const HeroShimmer();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Text(
          'Ajoutez un contenu mis en avant dans Firestore.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFilmHero(FilmEntity film) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImage(
            imageUrl: film.backdropUrl,
            borderRadius: BorderRadius.zero,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.25),
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.45, 0.8, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      film.title,
                      style: AppTextStyles.heroTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.12, end: 0),
                const SizedBox(height: 12),
                Text(
                  film.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 120.ms),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: 'Lecture',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _playContent(
                          videoUrl: film.videoUrl,
                          title: film.title,
                          posterUrl: film.posterUrl,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedGradientButton(
                        text: 'Plus d\'infos',
                        icon: Icons.info_outline_rounded,
                        onPressed: () =>
                            context.push('${Routes.film}/${film.id}'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.12, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesHero(SeriesEntity series) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImage(
            imageUrl: series.backdropUrl,
            borderRadius: BorderRadius.zero,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.25),
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.45, 0.8, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  style: AppTextStyles.heroTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  series.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: 'Découvrir',
                        icon: Icons.movie_filter_rounded,
                        onPressed: () =>
                            context.push('${Routes.series}/${series.id}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedGradientButton(
                        text: 'Saisons',
                        icon: Icons.view_list_rounded,
                        onPressed: () =>
                            context.push('${Routes.series}/${series.id}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmSection(
    String title,
    AsyncValue<List<FilmEntity>> asyncFilms,
  ) {
    return _buildSectionContainer(
      title: title,
      child: SizedBox(
        height: 250,
        child: asyncFilms.when(
          data: (films) => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: films.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildFilmCard(films[index]),
          ),
          loading: () => const ShimmerContentRow(),
          error: (error, stackTrace) => _buildErrorText(),
        ),
      ),
    );
  }

  Widget _buildSeriesSection(
    String title,
    AsyncValue<List<SeriesEntity>> asyncSeries,
  ) {
    return _buildSectionContainer(
      title: title,
      child: SizedBox(
        height: 250,
        child: asyncSeries.when(
          data: (seriesList) => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: seriesList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildSeriesCard(seriesList[index]),
          ),
          loading: () => const ShimmerContentRow(),
          error: (error, stackTrace) => _buildErrorText(),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilmCard(FilmEntity film) {
    return GestureDetector(
      onTap: () => context.push('${Routes.film}/${film.id}'),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoviePoster(posterUrl: film.posterUrl, width: 120),
            const SizedBox(height: 8),
            Text(
              film.title,
              style: AppTextStyles.movieTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${film.year}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.06, end: 0);
  }

  Widget _buildSeriesCard(SeriesEntity series) {
    return GestureDetector(
      onTap: () => context.push('${Routes.series}/${series.id}'),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoviePoster(posterUrl: series.posterUrl, width: 120),
            const SizedBox(height: 8),
            Text(
              series.title,
              style: AppTextStyles.movieTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${series.year}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.06, end: 0);
  }

  Widget _buildErrorText() {
    return Center(
      child: Text(
        'Erreur de chargement',
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
  }

  void _playContent({
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

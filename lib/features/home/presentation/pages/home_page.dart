import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/promo_code_dialog.dart';
import '../providers/movie_providers.dart';
import '../../domain/entities/movie.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _ConsumerHomePageState();
}

class _ConsumerHomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(trendingMoviesProvider);
    final popularAsync = ref.watch(popularMoviesProvider);
    final topRatedAsync = ref.watch(topRatedMoviesProvider);
    final nowPlayingAsync = ref.watch(nowPlayingMoviesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(popularMoviesProvider);
          ref.invalidate(topRatedMoviesProvider);
          ref.invalidate(nowPlayingMoviesProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Hero section
            SliverToBoxAdapter(
              child: _buildHeroSection(
                const Movie(
                  id: 999999, // Fake ID
                  title: "L'épouse du Mbenguiste",
                  overview:
                      "Une production originale Guezs Films qui explore les défis et les espoirs d'une femme attendant son mari parti à l'étranger.",
                  posterPath: "assets/images/betty.png",
                  backdropPath: "assets/images/betty.png",
                  voteAverage: 9.5,
                  releaseDate: "2024-12-25",
                  genreIds: [18, 10749], // Drama, Romance
                ),
              ),
            ),

            // Content sections
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildContentSectionAsync('Tendances du moment', trendingAsync),
                _buildContentSectionAsync(
                  'Top 10 en ce moment',
                  topRatedAsync,
                  isTop10: true,
                ),
                _buildContentSectionAsync('Nouveautés', nowPlayingAsync),
                _buildContentSectionAsync('Les plus populaires', popularAsync),
                const SizedBox(height: 100),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // Make app bar more opaque as user scrolls
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
        IconButton(icon: const Icon(Icons.cast, size: 22), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(Movie? movie) {
    if (movie == null) return const HeroShimmer();

    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          CachedImage(
            imageUrl: movie.id == 999999
                ? movie.backdropPath
                : ApiConstants.backdropOriginal + movie.backdropPath,
            borderRadius: BorderRadius.zero,
          ),

          // Gradient overlays
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.3),
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 48,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  movie.title,
                  style: AppTextStyles.heroTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // Description
                Text(
                  movie.overview,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            text: 'Lecture',
                            icon: Icons.play_arrow,
                            height: 48,
                            onPressed: () {
                              showPromoCodeDialog(
                                context,
                                onSuccess: () {
                                  context.push(
                                    '/player',
                                    extra: {
                                      'videoUrl':
                                          'https://sample-videos.com/video123.mp4',
                                      'title': movie.title,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedGradientButton(
                            text: 'Plus d\'infos',
                            icon: Icons.info_outline,
                            height: 48,
                            onPressed: () {
                              context.push('/movie/${movie.id}');
                            },
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSectionAsync(
    String title,
    AsyncValue<List<Movie>> asyncMovies, {
    bool isTop10 = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Content list
        SizedBox(
          height: isTop10 ? 220 : 250,
          child: asyncMovies.when(
            data: (movies) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = movies[index];
                if (isTop10) {
                  return _buildTop10Item(index + 1, movie);
                }
                return _buildMovieItem(movie);
              },
            ),
            loading: () => const ShimmerContentRow(),
            error: (e, st) => Center(
              child: Text(
                'Erreur de chargement',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMovieItem(Movie movie) {
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}');
      },
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            MoviePoster(
              posterUrl: ApiConstants.posterMedium + movie.posterPath,
              width: 120,
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              movie.title,
              style: AppTextStyles.movieTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Year
            Text(
              movie.releaseDate.split('-').first,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTop10Item(int rank, Movie movie) {
    return GestureDetector(
      onTap: () {
        context.push('/movie/${movie.id}');
      },
      child: SizedBox(
        width: 140,
        child: Row(
          children: [
            // Rank number
            Text(
              '$rank',
              style: AppTextStyles.rankingNumber.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            // Poster
            Expanded(
              child: MoviePoster(
                posterUrl: ApiConstants.posterMedium + movie.posterPath,
                width: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

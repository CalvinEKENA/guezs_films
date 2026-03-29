import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/core/theme/app_colors.dart';
import 'package:guezs_films/core/theme/app_text_styles.dart';
import 'package:guezs_films/core/constants/api_constants.dart';
import 'package:guezs_films/core/widgets/cached_image.dart';
import 'package:guezs_films/core/widgets/promo_code_dialog.dart';
import 'package:guezs_films/core/widgets/gradient_button.dart';
import 'package:guezs_films/core/widgets/shimmer_loading.dart';
import 'package:guezs_films/features/home/presentation/providers/movie_providers.dart';
import 'package:guezs_films/features/home/domain/entities/movie.dart';
import 'package:guezs_films/features/home/domain/entities/cast.dart';

/// Details page for movies and TV series
class DetailsPage extends ConsumerStatefulWidget {
  final int contentId;
  final ContentType contentType;

  const DetailsPage({
    super.key,
    required this.contentId,
    required this.contentType,
  });

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  // Scroll controller for parallax effect
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isInMyList = false;

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
    final screenHeight = MediaQuery.of(context).size.height;
    final isLocalMovie = widget.contentId == 999999;

    final AsyncValue<Movie> movieAsync = isLocalMovie
        ? const AsyncValue.data(
            Movie(
              id: 999999,
              title: "L'épouse du Mbenguiste",
              overview:
                  "Une production originale Guezs Films qui explore les défis et les espoirs d'une femme attendant son mari parti à l'étranger.",
              posterPath: "assets/images/betty.png",
              backdropPath: "assets/images/betty.png",
              voteAverage: 9.5,
              releaseDate: "2024-12-25",
              genreIds: [18, 10749],
            ),
          )
        : ref.watch(movieDetailsProvider(widget.contentId));
    final AsyncValue<List<Cast>> creditsAsync = isLocalMovie
        ? const AsyncValue.data([
            Cast(
              id: 1,
              name: 'Yvette MENGUE',
              character: 'L\'épouse',
              profilePath: 'assets/images/yvette.jpg',
            ),
            Cast(
              id: 2,
              name: 'Leslie NOAH',
              character: 'Le Mbenguiste',
              profilePath: '',
            ),
          ])
        : ref.watch(movieCreditsProvider(widget.contentId));
    final similarAsync = ref.watch(similarMoviesProvider(widget.contentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: movieAsync.when(
        data: (movie) => CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Backdrop with parallax
            SliverToBoxAdapter(
              child: _buildBackdrop(screenHeight * 0.45, movie),
            ),

            // Content
            SliverToBoxAdapter(child: _buildContent(movie)),

            // Cast section
            SliverToBoxAdapter(
              child: creditsAsync.when(
                data: (cast) => _buildCastSection(cast),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: ShimmerContentRow(itemCount: 4, itemWidth: 80),
                ),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ),

            // Similar movies section
            SliverToBoxAdapter(
              child: similarAsync.when(
                data: (movies) => _buildSimilarSection(movies),
                loading: () => const ShimmerContentRow(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erreur de chargement',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(movieDetailsProvider(widget.contentId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: opacity),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBackdrop(double height, Movie movie) {
    // Parallax effect
    final parallaxOffset = _scrollOffset * 0.5;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop image with parallax
          Transform.translate(
            offset: Offset(0, -parallaxOffset),
            child: CachedImage(
              imageUrl: movie.id == 999999
                  ? movie.backdropPath
                  : ApiConstants.backdropOriginal + movie.backdropPath,
              height: height + 100,
              borderRadius: BorderRadius.zero,
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.5),
                  AppColors.background,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Play button overlay
          Center(
                child: GestureDetector(
                  onTap: () => _playMovie(movie),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              )
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildContent(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            movie.title,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 8),

          // Metadata row
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getRatingColor(movie.voteAverage),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Year
              Text(
                movie.releaseDate.split('-').first,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              // Age rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textTertiary),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '16+',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Lecture',
                  icon: Icons.play_arrow,
                  onPressed: () => _playMovie(movie),
                ),
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: _isInMyList ? Icons.check : Icons.add,
                label: 'Ma liste',
                onTap: () {
                  setState(() => _isInMyList = !_isInMyList);
                },
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: Icons.thumb_up_outlined,
                label: 'J\'aime',
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Overview
          Text(
            movie.overview,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(List<Cast> cast) {
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Distribution',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final actor = cast[index];
              return SizedBox(
                width: 80,
                child: Column(
                  children: [
                    // Profile image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: ClipOval(
                        child: CachedImage(
                          imageUrl: actor.profilePath.startsWith('assets/')
                              ? actor.profilePath
                              : ApiConstants.profileMedium + actor.profilePath,
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      actor.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    // Character
                    Text(
                      actor.character,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSimilarSection(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Films similaires',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  context.push('/movie/${movie.id}');
                },
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoviePoster(
                        posterUrl: ApiConstants.posterMedium + movie.posterPath,
                        width: 120,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _playMovie(Movie movie) {
    showPromoCodeDialog(
      context,
      onSuccess: () {
        context.push(
          '/player',
          extra: {
            'videoUrl':
                'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
            'title': movie.title,
            'posterUrl': movie.id == 999999
                ? movie.backdropPath
                : ApiConstants.backdropOriginal + movie.backdropPath,
          },
        );
      },
    );
  }
}

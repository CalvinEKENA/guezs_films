import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/domain/entities/film_entity.dart';
import '../../../../core/domain/entities/series_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/user_profile_providers.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/providers/favorites_providers.dart';

// ── Hive key for tracking if welcome notification has been read ──
const _kWelcomeNotifRead = 'welcome_notif_read';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _notificationsRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final box = Hive.box('settings_box');
    final read = box.get(_kWelcomeNotifRead, defaultValue: false) as bool;
    if (mounted) {
      setState(() => _notificationsRead = read);
    }
  }

  Future<void> _markNotificationsRead() async {
    final box = Hive.box('settings_box');
    await box.put(_kWelcomeNotifRead, true);
    if (mounted) {
      setState(() => _notificationsRead = true);
    }
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
    final newSeriesAsync = ref.watch(newSeriesProvider);
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
            ..invalidate(newSeriesProvider)
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
                _buildSeriesSection('Nouveautés', newSeriesAsync),
                _buildSeriesSection('Guezs Films', seriesAsync),
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
    final hasUnreadNotifs = !_notificationsRead;

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
            'GUEZS FILMS',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Image.asset(
            'assets/icons/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        // Notification icon with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasUnreadNotifs
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                size: 22,
              ),
              onPressed: () => _showNotificationsSheet(context),
            ),
            if (hasUnreadNotifs)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Notifications Bottom Sheet — Cupertino Premium ──

  void _showNotificationsSheet(BuildContext context) {
    _markNotificationsRead();

    final user = ref.read(authStateProvider).valueOrNull;
    final profile = ref.read(activeProfileProvider);
    final displayName = profile?.name ?? user?.displayName ?? 'Cinéphile';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _NotificationsSheet(displayName: displayName),
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

    final parallaxOffset = _scrollOffset * 0.35;

    return SizedBox(
      height: screenHeight * 0.52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallaxOffset),
            child: CachedImage(
              imageUrl: film.backdropUrl,
              height: screenHeight * 0.52 + 100,
              borderRadius: BorderRadius.zero,
              alignment: film.title == 'Elle et moi'
                  ? Alignment.topCenter
                  : Alignment.center,
            ),
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
                        onPressed: () => _playContent(film.id),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedGradientButton(
                        text: 'Plus d\'infos',
                        icon: Icons.info_outline_rounded,
                        onPressed: () =>
                            context.push(Routes.filmDetailsPath(film.id)),
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

    final parallaxOffset = _scrollOffset * 0.35;

    return SizedBox(
      height: screenHeight * 0.52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallaxOffset),
            child: CachedImage(
              imageUrl: series.backdropUrl,
              height: screenHeight * 0.52 + 100,
              borderRadius: BorderRadius.zero,
              alignment: series.title == 'Elle et moi'
                  ? Alignment.topCenter
                  : Alignment.center,
            ),
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
                            context.push(Routes.seriesDetailsPath(series.id)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedGradientButton(
                        text: 'Saisons',
                        icon: Icons.view_list_rounded,
                        onPressed: () =>
                            context.push(Routes.seriesDetailsPath(series.id)),
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

  Widget _buildSeriesCard(SeriesEntity series) {
    final isFavorite = ref.watch(
      isFavoriteProvider((id: series.id, contentType: 'series')),
    );

    return GestureDetector(
      onTap: () => context.push(Routes.seriesDetailsPath(series.id)),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                MoviePoster(
                  posterUrl: series.posterUrl,
                  width: 120,
                  alignment: series.title == 'Elle et moi'
                      ? Alignment.topCenter
                      : Alignment.center,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.check_rounded : Icons.add_rounded,
                        color: isFavorite ? AppColors.accent : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  void _playContent(String filmId) {
    context.push(Routes.filmWatchPath(filmId));
  }
}

// ────────────────────────────────────────────────────────────────────────────────
// Notifications Sheet — Cupertino Premium Luxueux
// ────────────────────────────────────────────────────────────────────────────────

class _NotificationsSheet extends StatelessWidget {
  final String displayName;

  const _NotificationsSheet({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.bell_fill,
                color: AppColors.accentSoft,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Notification cards
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              children: [
                // 1. Welcome notification
                _NotificationCard(
                  icon: CupertinoIcons.heart_fill,
                  iconColor: AppColors.primary,
                  title: 'Bienvenue $displayName ! 🎬',
                  body:
                      'Nous sommes ravis de vous accueillir sur Guezs Films. '
                      'Explorez notre catalogue de films et séries africaines exclusives.',
                  time: 'À l\'instant',
                  isNew: true,
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),

                const SizedBox(height: 12),

                // 2. Series announcement
                _NotificationCard(
                      icon: CupertinoIcons.film,
                      iconColor: AppColors.accent,
                      title: '🔥 Nouvelle série en approche !',
                      body:
                          'La série tant attendue "La femme du Mbenguiste" '
                          'débarque le 06 Juin sur Guezs Films. Restez connectés !',
                      time: 'Aujourd\'hui',
                      isNew: true,
                    )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.05, end: 0),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isNew;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNew
                  ? AppColors.accentSoft.withValues(alpha: 0.25)
                  : AppColors.border.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

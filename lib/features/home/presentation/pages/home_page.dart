import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/entities/film_entity.dart';
import '../../../../core/domain/entities/series_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/premium_content_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../favorites/domain/entities/favorite_movie.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../profile/presentation/providers/user_profile_providers.dart';

const _kWelcomeNotifRead = 'welcome_notif_read';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final PageController _heroPageController = PageController();
  double _appBarOpacity = 0;
  bool _notificationsRead = false;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    final box = Hive.box(AppConstants.settingsBox);
    final read = box.get(_kWelcomeNotifRead, defaultValue: false) as bool;
    if (mounted) setState(() => _notificationsRead = read);
  }

  Future<void> _markNotificationsRead() async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(_kWelcomeNotifRead, true);
    if (mounted) setState(() => _notificationsRead = true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _heroPageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final nextOpacity = (_scrollController.offset / 180).clamp(0.0, 1.0);
    if ((nextOpacity - _appBarOpacity).abs() > 0.03) {
      setState(() => _appBarOpacity = nextOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredFilmsAsync = ref.watch(featuredFilmsProvider);
    final featuredSeriesAsync = ref.watch(featuredSeriesProvider);
    final filmsAsync = ref.watch(filmsProvider);
    final newFilmsAsync = ref.watch(newFilmsProvider);
    final seriesAsync = ref.watch(seriesProvider);
    final newSeriesAsync = ref.watch(newSeriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: _refreshHome,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final responsive = ResponsiveValues.fromSize(
                Size(constraints.maxWidth, MediaQuery.sizeOf(context).height),
              );
              final layout = _HomeLayoutSpec.fromResponsive(responsive);

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHero(
                      layout: layout,
                      featuredFilmsAsync: featuredFilmsAsync,
                      featuredSeriesAsync: featuredSeriesAsync,
                      filmsAsync: filmsAsync,
                      seriesAsync: seriesAsync,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildHomeBody(
                      layout: layout,
                      featuredFilmsAsync: featuredFilmsAsync,
                      featuredSeriesAsync: featuredSeriesAsync,
                      filmsAsync: filmsAsync,
                      newFilmsAsync: newFilmsAsync,
                      seriesAsync: seriesAsync,
                      newSeriesAsync: newSeriesAsync,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHome() async {
    ref
      ..invalidate(featuredFilmsProvider)
      ..invalidate(featuredSeriesProvider)
      ..invalidate(filmsProvider)
      ..invalidate(newFilmsProvider)
      ..invalidate(seriesProvider)
      ..invalidate(newSeriesProvider);

    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  PreferredSizeWidget _buildAppBar() {
    final hasUnreadNotifs = !_notificationsRead;

    return AppBar(
      backgroundColor: AppColors.bgCinema.withValues(
        alpha: _appBarOpacity * 0.94,
      ),
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder(0.28)),
            ),
            child: const Icon(
              Icons.local_movies_rounded,
              color: AppColors.textOnBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'GUEZS FILMS',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Image.asset(
            'assets/icons/logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasUnreadNotifs
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                color: AppColors.textPrimary,
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
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgCinema, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
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

  Widget _buildHero({
    required _HomeLayoutSpec layout,
    required AsyncValue<List<FilmEntity>> featuredFilmsAsync,
    required AsyncValue<List<SeriesEntity>> featuredSeriesAsync,
    required AsyncValue<List<FilmEntity>> filmsAsync,
    required AsyncValue<List<SeriesEntity>> seriesAsync,
  }) {
    final heroItems = _resolveHeroItems(
      featuredFilms: featuredFilmsAsync.valueOrNull ?? const <FilmEntity>[],
      featuredSeries: featuredSeriesAsync.valueOrNull ?? const <SeriesEntity>[],
      films: filmsAsync.valueOrNull ?? const <FilmEntity>[],
      series: seriesAsync.valueOrNull ?? const <SeriesEntity>[],
    );

    final isLoading =
        heroItems.isEmpty &&
        (featuredFilmsAsync.isLoading ||
            featuredSeriesAsync.isLoading ||
            filmsAsync.isLoading ||
            seriesAsync.isLoading);

    if (isLoading) {
      return _PremiumHeroLoading(layout: layout);
    }

    if (heroItems.isEmpty) {
      return _EmptyHero(
        layout: layout,
        onExplore: () => context.push(Routes.search),
      );
    }

    return SizedBox(
      height: layout.heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _heroPageController,
            onPageChanged: (index) => setState(() => _heroIndex = index),
            itemCount: heroItems.length,
            itemBuilder: (context, index) => _HeroSlide(
              key: ValueKey(heroItems[index].stableKey),
              item: heroItems[index],
              layout: layout,
              onPrimary: () => _openPrimary(heroItems[index]),
              onDetails: () => _openDetails(heroItems[index]),
            ),
          ),
          if (heroItems.length > 1)
            Positioned(
              left: layout.horizontalPadding,
              right: layout.horizontalPadding,
              bottom: layout.isDesktop ? 30 : 18,
              child: Center(
                child: _HeroIndicators(
                  count: heroItems.length,
                  activeIndex: _heroIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeBody({
    required _HomeLayoutSpec layout,
    required AsyncValue<List<FilmEntity>> featuredFilmsAsync,
    required AsyncValue<List<SeriesEntity>> featuredSeriesAsync,
    required AsyncValue<List<FilmEntity>> filmsAsync,
    required AsyncValue<List<FilmEntity>> newFilmsAsync,
    required AsyncValue<List<SeriesEntity>> seriesAsync,
    required AsyncValue<List<SeriesEntity>> newSeriesAsync,
  }) {
    final films = filmsAsync.valueOrNull ?? const <FilmEntity>[];
    final newFilms = newFilmsAsync.valueOrNull ?? const <FilmEntity>[];
    final featuredFilms =
        featuredFilmsAsync.valueOrNull ?? const <FilmEntity>[];
    final series = seriesAsync.valueOrNull ?? const <SeriesEntity>[];
    final newSeries = newSeriesAsync.valueOrNull ?? const <SeriesEntity>[];
    final featuredSeries =
        featuredSeriesAsync.valueOrNull ?? const <SeriesEntity>[];

    final featuredItems = _dedupeItems([
      ...featuredFilms.map(_HomeContentItem.fromFilm),
      ...featuredSeries.map(_HomeContentItem.fromSeries),
    ]);
    final newItems = _dedupeItems([
      ...newFilms.map(_HomeContentItem.fromFilm),
      ...newSeries.map(_HomeContentItem.fromSeries),
    ]);
    final filmItems = films.map(_HomeContentItem.fromFilm).toList();
    final seriesItems = series.map(_HomeContentItem.fromSeries).toList();
    final spotlightItems = _dedupeItems([
      ...featuredItems,
      ...newItems,
      ...filmItems.take(4),
      ...seriesItems.take(4),
    ]).take(12).toList(growable: false);
    final cineClubItems = _dedupeItems([
      ...filmItems.where(_isCameroonClubItem),
      ...seriesItems.where(_isCameroonClubItem),
    ]);
    final recommendedItems = _recommendedFilms(
      films,
    ).map(_HomeContentItem.fromFilm).take(12).toList(growable: false);

    final hasAnyContent =
        featuredItems.isNotEmpty ||
        newItems.isNotEmpty ||
        filmItems.isNotEmpty ||
        seriesItems.isNotEmpty;
    final isInitialLoading =
        !hasAnyContent &&
        [
          featuredFilmsAsync,
          featuredSeriesAsync,
          filmsAsync,
          newFilmsAsync,
          seriesAsync,
          newSeriesAsync,
        ].any((async) => async.isLoading);
    final hasBlockingError =
        !hasAnyContent &&
        [
          featuredFilmsAsync,
          featuredSeriesAsync,
          filmsAsync,
          newFilmsAsync,
          seriesAsync,
          newSeriesAsync,
        ].any((async) => async.hasError);

    return Padding(
      padding: EdgeInsets.only(top: layout.sectionTopSpacing, bottom: 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isInitialLoading) ...[
            _LoadingSection(layout: layout, title: 'Sous les projecteurs'),
            _LoadingSection(layout: layout, title: 'Nouveautés'),
          ] else if (hasBlockingError) ...[
            _HomeStatePanel(
              layout: layout,
              icon: Icons.cloud_off_rounded,
              title: 'Catalogue indisponible',
              message:
                  'La connexion au catalogue a échoué. Réessayez dans quelques instants.',
              actionLabel: 'Réessayer',
              onAction: _refreshHome,
            ),
          ] else if (!hasAnyContent) ...[
            _HomeStatePanel(
              layout: layout,
              icon: Icons.movie_creation_outlined,
              title: 'La salle se prépare',
              message:
                  'Aucun film ou série n’est encore disponible dans le catalogue.',
              actionLabel: 'Actualiser',
              onAction: _refreshHome,
            ),
          ],
          _buildContentRail(
            layout: layout,
            title: 'Sous les projecteurs',
            subtitle: 'Films et séries mis en avant par la rédaction.',
            items: spotlightItems,
            isLoading:
                spotlightItems.isEmpty &&
                (featuredFilmsAsync.isLoading ||
                    featuredSeriesAsync.isLoading ||
                    newFilmsAsync.isLoading ||
                    newSeriesAsync.isLoading),
          ),
          _buildContentRail(
            layout: layout,
            title: 'Sélections officielles',
            subtitle: 'Les titres que GUEZS FILMS place au premier rang.',
            items: featuredItems,
            isLoading:
                featuredItems.isEmpty &&
                (featuredFilmsAsync.isLoading || featuredSeriesAsync.isLoading),
          ),
          _buildContentRail(
            layout: layout,
            title: 'Nouveautés',
            subtitle: 'Dernières entrées au catalogue.',
            items: newItems,
            isLoading:
                newItems.isEmpty &&
                (newFilmsAsync.isLoading || newSeriesAsync.isLoading),
          ),
          _buildContentRail(
            layout: layout,
            title: 'Recommandés pour vous',
            subtitle: 'Films les mieux notés disponibles actuellement.',
            items: recommendedItems,
            isLoading: recommendedItems.isEmpty && filmsAsync.isLoading,
          ),
          _buildContentRail(
            layout: layout,
            title: 'Films',
            subtitle: 'Longs métrages africains à découvrir.',
            items: filmItems,
            isLoading: filmItems.isEmpty && filmsAsync.isLoading,
            actionLabel: 'Tout voir',
            onAction: () => context.push(Routes.search),
          ),
          _buildContentRail(
            layout: layout,
            title: 'Séries',
            subtitle: 'Saisons et histoires à suivre.',
            items: seriesItems,
            isLoading: seriesItems.isEmpty && seriesAsync.isLoading,
            actionLabel: 'Tout voir',
            onAction: () => context.push(Routes.search),
          ),
          _buildContentRail(
            layout: layout,
            title: 'Ciné-club camerounais',
            subtitle: 'Regards, quartiers et récits du Cameroun.',
            items: cineClubItems,
            isLoading:
                cineClubItems.isEmpty &&
                (filmsAsync.isLoading || seriesAsync.isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRail({
    required _HomeLayoutSpec layout,
    required String title,
    required String subtitle,
    required List<_HomeContentItem> items,
    bool isLoading = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (items.isEmpty && !isLoading) return const SizedBox.shrink();
    if (items.isEmpty && isLoading) {
      return _LoadingSection(layout: layout, title: title, subtitle: subtitle);
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.only(bottom: layout.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: title,
                subtitle: subtitle,
                actionLabel: actionLabel,
                onAction: onAction,
                padding: EdgeInsets.symmetric(
                  horizontal: layout.horizontalPadding,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: layout.railHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.horizontalPadding,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: layout.cardSpacing),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isFavorite = ref.watch(
                      isFavoriteProvider((
                        id: item.id,
                        contentType: item.contentType,
                      )),
                    );

                    return PremiumContentCard(
                      title: item.title,
                      imageUrl: item.posterUrl,
                      metadata: item.metadata,
                      badge: item.primaryBadge,
                      width: layout.cardWidth,
                      isFavorite: isFavorite,
                      onFavoriteTap: () => _toggleFavorite(item),
                      onTap: () => _openDetails(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  void _openPrimary(_HomeContentItem item) {
    if (item.isFilm) {
      context.push(Routes.filmWatchPath(item.id));
      return;
    }
    context.push(Routes.seriesDetailsPath(item.id));
  }

  void _openDetails(_HomeContentItem item) {
    if (item.isFilm) {
      context.push(Routes.filmDetailsPath(item.id));
      return;
    }
    context.push(Routes.seriesDetailsPath(item.id));
  }

  void _toggleFavorite(_HomeContentItem item) {
    ref
        .read(favoritesProvider.notifier)
        .toggleFavorite(
          FavoriteMovie(
            id: item.id,
            title: item.title,
            posterPath: item.posterUrl,
            contentType: item.contentType,
            addedAt: DateTime.now().toIso8601String(),
          ),
        );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({
    super.key,
    required this.item,
    required this.layout,
    required this.onPrimary,
    required this.onDetails,
  });

  final _HomeContentItem item;
  final _HomeLayoutSpec layout;
  final VoidCallback onPrimary;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.backdropUrl.isNotEmpty
        ? item.backdropUrl
        : item.posterUrl;
    final titleStyle =
        (layout.isDesktop
                ? AppTextStyles.displayLarge
                : AppTextStyles.heroTitle)
            .copyWith(
              color: AppColors.textPrimary,
              fontSize: layout.isDesktop ? 48 : 34,
            );

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: layout.heroHeight,
          borderRadius: BorderRadius.zero,
          alignment: item.title.toLowerCase().contains('elle et moi')
              ? Alignment.topCenter
              : Alignment.center,
        ),
        const _HeroOverlay(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.glassBorder(0.46),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: layout.isDesktop
                ? Alignment.centerLeft
                : Alignment.bottomLeft,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    layout.horizontalPadding,
                    112,
                    layout.horizontalPadding,
                    layout.isDesktop ? 72 : 58,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: layout.isDesktop ? 7 : 1,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: layout.isDesktop ? 650 : double.infinity,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.heroBadges
                                    .map((label) => _HeroBadge(label: label))
                                    .toList(growable: false),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: titleStyle,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                item.description,
                                maxLines: layout.isDesktop ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.metadata,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.metadata.copyWith(
                                  color: AppColors.brandGoldLight,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _HeroActions(
                                isDesktop: layout.isDesktop,
                                primaryLabel: item.isFilm
                                    ? 'Entrer en salle'
                                    : 'Voir les épisodes',
                                primaryIcon: item.isFilm
                                    ? Icons.play_arrow_rounded
                                    : Icons.view_list_rounded,
                                onPrimary: onPrimary,
                                onDetails: onDetails,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (layout.isDesktop) ...[
                        const Spacer(flex: 1),
                        _DesktopPosterPreview(item: item),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgCinemaDark.withValues(alpha: 0.42),
                AppColors.bgCinema.withValues(alpha: 0.16),
                AppColors.bgCinema.withValues(alpha: 0.72),
                AppColors.bgCinema,
              ],
              stops: const [0, 0.34, 0.78, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.bgCinemaDark.withValues(alpha: 0.92),
                AppColors.bgCinema.withValues(alpha: 0.52),
                Colors.transparent,
              ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.spotlightBlue.withValues(alpha: 0.14),
                Colors.transparent,
                AppColors.brandGold.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.isDesktop,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    required this.onDetails,
  });

  final bool isDesktop;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final primary = SizedBox(
      width: isDesktop ? 190 : null,
      child: GradientButton(
        text: primaryLabel,
        icon: primaryIcon,
        onPressed: onPrimary,
      ),
    );
    final secondary = SizedBox(
      width: isDesktop ? 150 : null,
      child: OutlinedGradientButton(
        text: 'Détails',
        icon: Icons.info_outline_rounded,
        onPressed: onDetails,
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [primary, const SizedBox(width: 12), secondary],
      );
    }

    return Row(
      children: [
        Expanded(child: primary),
        const SizedBox(width: 12),
        Expanded(child: secondary),
      ],
    );
  }
}

class _DesktopPosterPreview extends StatelessWidget {
  const _DesktopPosterPreview({required this.item});

  final _HomeContentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder(0.42), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.brandGold.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: CachedImage(
            imageUrl: item.posterUrl,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBackground(0.42),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.glassBorder(0.34), width: 0.8),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: AppColors.brandGoldLight),
      ),
    );
  }
}

class _HeroIndicators extends StatelessWidget {
  const _HeroIndicators({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _PremiumHeroLoading extends StatelessWidget {
  const _PremiumHeroLoading({required this.layout});

  final _HomeLayoutSpec layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.heroHeight,
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading.text(width: 132, height: 28),
                  const SizedBox(height: 18),
                  ShimmerLoading.text(
                    width: layout.isDesktop ? 520 : 270,
                    height: 42,
                  ),
                  const SizedBox(height: 14),
                  ShimmerLoading.text(
                    width: layout.isDesktop ? 620 : double.infinity,
                    height: 16,
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoading.text(width: 260, height: 16),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: layout.isDesktop ? 190 : 150,
                        child: ShimmerLoading.text(height: 52),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: layout.isDesktop ? 150 : 130,
                        child: ShimmerLoading.text(height: 52),
                      ),
                    ],
                  ),
                  SizedBox(height: layout.isDesktop ? 70 : 58),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  const _EmptyHero({required this.layout, required this.onExplore});

  final _HomeLayoutSpec layout;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.heroHeight,
      decoration: BoxDecoration(
        gradient: AppColors.bgGradient,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder(0.28), width: 0.8),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.theaters_rounded,
                    color: AppColors.brandGoldLight,
                    size: layout.isDesktop ? 54 : 44,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Le Grand Écran s’ouvre bientôt',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Aucun titre mis en avant n’est disponible pour le moment.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 190,
                    child: GradientButton(
                      text: 'Explorer',
                      icon: Icons.search_rounded,
                      onPressed: onExplore,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({
    required this.layout,
    required this.title,
    this.subtitle,
  });

  final _HomeLayoutSpec layout;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.only(bottom: layout.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: title,
                subtitle: subtitle,
                padding: EdgeInsets.symmetric(
                  horizontal: layout.horizontalPadding,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: layout.railHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: layout.horizontalPadding,
                  ),
                  itemCount: layout.loadingCardCount,
                  separatorBuilder: (context, index) =>
                      SizedBox(width: layout.cardSpacing),
                  itemBuilder: (context, index) => SizedBox(
                    width: layout.cardWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(
                          width: layout.cardWidth,
                          height: layout.cardWidth * 1.5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 10),
                        ShimmerLoading.text(width: layout.cardWidth * 0.82),
                        const SizedBox(height: 6),
                        ShimmerLoading.text(
                          width: layout.cardWidth * 0.56,
                          height: 12,
                        ),
                      ],
                    ),
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

class _HomeStatePanel extends StatelessWidget {
  const _HomeStatePanel({
    required this.layout,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final _HomeLayoutSpec layout;
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.horizontalPadding,
            0,
            layout.horizontalPadding,
            layout.sectionGap,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.glassBackground(0.34),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder(0.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.brandGoldLight, size: 32),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 150,
                  child: GradientButton(
                    text: actionLabel,
                    icon: Icons.refresh_rounded,
                    onPressed: onAction,
                    height: 46,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.56,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
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
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              children: [
                _NotificationCard(
                  icon: CupertinoIcons.heart_fill,
                  iconColor: AppColors.accent,
                  title: 'Bienvenue $displayName',
                  body:
                      'Explorez notre catalogue de films et séries africaines exclusives.',
                  time: 'À l’instant',
                  isNew: true,
                ),
                const SizedBox(height: 12),
                const _NotificationCard(
                  icon: CupertinoIcons.film,
                  iconColor: AppColors.brandGoldLight,
                  title: 'Nouvelle série en approche',
                  body:
                      'La femme du Mbenguiste arrive bientôt sur GUEZS FILMS.',
                  time: 'Aujourd’hui',
                  isNew: true,
                ),
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
  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.isNew = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.5),
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
    );
  }
}

class _HomeLayoutSpec {
  const _HomeLayoutSpec({
    required this.isTablet,
    required this.isDesktop,
    required this.horizontalPadding,
    required this.maxContentWidth,
    required this.heroHeight,
    required this.cardWidth,
    required this.cardSpacing,
    required this.sectionGap,
    required this.sectionTopSpacing,
    required this.loadingCardCount,
  });

  final bool isTablet;
  final bool isDesktop;
  final double horizontalPadding;
  final double maxContentWidth;
  final double heroHeight;
  final double cardWidth;
  final double cardSpacing;
  final double sectionGap;
  final double sectionTopSpacing;
  final int loadingCardCount;

  double get railHeight => cardWidth * 1.5 + 64;

  static _HomeLayoutSpec fromResponsive(ResponsiveValues responsive) {
    if (responsive.isDesktop) {
      return _HomeLayoutSpec(
        isTablet: false,
        isDesktop: true,
        horizontalPadding: responsive.pagePadding,
        maxContentWidth: responsive.isWideDesktop ? 1360 : 1200,
        heroHeight: responsive.isWideDesktop ? 640 : 620,
        cardWidth: responsive.railPosterWidth,
        cardSpacing: responsive.gridGap,
        sectionGap: 42,
        sectionTopSpacing: 34,
        loadingCardCount: responsive.loadingCardCount,
      );
    }

    if (responsive.isTablet) {
      return _HomeLayoutSpec(
        isTablet: true,
        isDesktop: false,
        horizontalPadding: responsive.pagePadding,
        maxContentWidth: responsive.maxContentWidth,
        heroHeight: _clampDouble(responsive.height * 0.62, 520, 620),
        cardWidth: responsive.railPosterWidth,
        cardSpacing: responsive.gridGap,
        sectionGap: 34,
        sectionTopSpacing: 28,
        loadingCardCount: responsive.loadingCardCount,
      );
    }

    return _HomeLayoutSpec(
      isTablet: false,
      isDesktop: false,
      horizontalPadding: responsive.pagePadding,
      maxContentWidth: responsive.maxContentWidth,
      heroHeight: _clampDouble(responsive.height * 0.68, 500, 640),
      cardWidth: responsive.railPosterWidth,
      cardSpacing: responsive.gridGap,
      sectionGap: 30,
      sectionTopSpacing: 24,
      loadingCardCount: responsive.loadingCardCount,
    );
  }
}

class _HomeContentItem {
  const _HomeContentItem({
    required this.id,
    required this.contentType,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.year,
    required this.metadata,
    required this.heroBadges,
    required this.genres,
    this.rating,
  });

  factory _HomeContentItem.fromFilm(FilmEntity film) {
    final badges = _filmBadges(film);
    return _HomeContentItem(
      id: film.id,
      contentType: 'film',
      title: film.title,
      description: film.description,
      posterUrl: film.posterUrl,
      backdropUrl: film.backdropUrl,
      year: film.year,
      metadata: '${film.year} • Film • ${film.durationMin} min',
      heroBadges: badges,
      genres: film.genres,
      rating: film.rating,
    );
  }

  factory _HomeContentItem.fromSeries(SeriesEntity series) {
    final badges = _seriesBadges(series);
    final seasons = series.numberOfSeasons <= 1
        ? '1 saison'
        : '${series.numberOfSeasons} saisons';
    return _HomeContentItem(
      id: series.id,
      contentType: 'series',
      title: series.title,
      description: series.description,
      posterUrl: series.posterUrl,
      backdropUrl: series.backdropUrl,
      year: series.year,
      metadata: '${series.year} • Série • $seasons',
      heroBadges: badges,
      genres: series.genres,
    );
  }

  final String id;
  final String contentType;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final int year;
  final String metadata;
  final List<String> heroBadges;
  final List<String> genres;
  final double? rating;

  bool get isFilm => contentType == 'film';
  String get stableKey => '$contentType:$id';
  String? get primaryBadge => heroBadges.isEmpty ? null : heroBadges.first;
}

List<_HomeContentItem> _resolveHeroItems({
  required List<FilmEntity> featuredFilms,
  required List<SeriesEntity> featuredSeries,
  required List<FilmEntity> films,
  required List<SeriesEntity> series,
}) {
  final featured = _dedupeItems([
    ...featuredFilms.map(_HomeContentItem.fromFilm),
    ...featuredSeries.map(_HomeContentItem.fromSeries),
  ]);
  if (featured.isNotEmpty) return featured.take(6).toList(growable: false);

  final fallback = _dedupeItems([
    ...films.take(2).map(_HomeContentItem.fromFilm),
    ...series.take(2).map(_HomeContentItem.fromSeries),
  ]);
  return fallback.take(4).toList(growable: false);
}

List<_HomeContentItem> _dedupeItems(Iterable<_HomeContentItem> items) {
  final seen = <String>{};
  final result = <_HomeContentItem>[];
  for (final item in items) {
    if (seen.add(item.stableKey)) result.add(item);
  }
  return result;
}

List<FilmEntity> _recommendedFilms(List<FilmEntity> films) {
  final sorted = [...films]..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.where((film) => film.rating >= 7).toList(growable: false);
}

List<String> _filmBadges(FilmEntity film) {
  final badges = <String>[];
  if (film.isFeatured) badges.add('Sélection officielle');
  if (film.isNew) badges.add('Nouveau');
  if (_isRecentlyAdded(film.createdAt)) badges.add('Avant-première');
  if (film.rating >= 8) badges.add('Exclusif');
  if (badges.isEmpty) badges.add('GUEZS Original');
  return badges.take(3).toList(growable: false);
}

List<String> _seriesBadges(SeriesEntity series) {
  final badges = <String>[];
  if (series.isFeatured) badges.add('Sélection officielle');
  if (_isRecentlyAdded(series.createdAt)) badges.add('Nouveau');
  if (series.numberOfSeasons <= 1) badges.add('Avant-première');
  if (badges.isEmpty) badges.add('GUEZS Original');
  return badges.take(3).toList(growable: false);
}

bool _isRecentlyAdded(DateTime date) {
  return DateTime.now().difference(date).inDays <= 45;
}

bool _isCameroonClubItem(_HomeContentItem item) {
  final haystack = [
    item.title,
    item.description,
    ...item.genres,
  ].join(' ').toLowerCase();
  return haystack.contains('cameroun') ||
      haystack.contains('cameroon') ||
      haystack.contains('douala') ||
      haystack.contains('yaounde') ||
      haystack.contains('yaoundé');
}

double _clampDouble(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

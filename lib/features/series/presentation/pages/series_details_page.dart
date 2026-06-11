import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/domain/entities/episode_entity.dart';
import '../../../../core/domain/entities/season_entity.dart';
import '../../../../core/domain/entities/series_entity.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/premium_details.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
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
    final nextOffset = _scrollController.offset;
    if ((nextOffset - _scrollOffset).abs() > 4) {
      setState(() => _scrollOffset = nextOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(seriesDetailsProvider(widget.seriesId));
    final seasonsAsync = ref.watch(seasonsProvider(widget.seriesId));
    final isGuest = ref.watch(authStateProvider).valueOrNull == null;

    return seriesAsync.when(
      data: (series) => _buildSeriesPage(
        series,
        seasonsAsync: seasonsAsync,
        isGuest: isGuest,
      ),
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: const PremiumDetailsSkeleton(),
      ),
      error: (error, stackTrace) {
        final notFound = _isNotFoundError(error);
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(forceOpaque: true),
          body: PremiumDetailsStateView(
            icon: notFound ? Icons.tv_off_outlined : Icons.cloud_off_outlined,
            title: notFound
                ? 'Série introuvable'
                : 'Impossible d’ouvrir cette série',
            message: notFound
                ? 'Cette série n’est plus disponible dans le catalogue.'
                : 'Vérifiez votre connexion puis essayez de nouveau.',
            primaryLabel: 'Réessayer',
            onPrimaryPressed: () {
              ref
                ..invalidate(seriesDetailsProvider(widget.seriesId))
                ..invalidate(seasonsProvider(widget.seriesId));
            },
            secondaryLabel: 'Retour au catalogue',
            onSecondaryPressed: _goBack,
          ),
        );
      },
    );
  }

  Widget _buildSeriesPage(
    SeriesEntity series, {
    required AsyncValue<List<SeasonEntity>> seasonsAsync,
    required bool isGuest,
  }) {
    final responsive = ResponsiveValues.of(context);
    final seasons = seasonsAsync.valueOrNull ?? const <SeasonEntity>[];
    final selectedSeasonId = _resolveSelectedSeasonId(seasons);
    final episodesAsync = selectedSeasonId == null
        ? const AsyncValue<List<EpisodeEntity>>.data([])
        : ref.watch(
            episodesProvider((seriesId: series.id, seasonId: selectedSeasonId)),
          );
    final firstEpisode = episodesAsync.valueOrNull?.firstOrNull;
    final isFavorite = ref.watch(
      isFavoriteProvider((id: series.id, contentType: 'series')),
    );
    final stickyCta = responsive.width < 760 && firstEpisode != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: stickyCta
          ? PremiumStickyCta(
              label: 'Commencer la série',
              icon: Icons.play_arrow_rounded,
              helperText: isGuest ? 'Connexion requise pour regarder' : null,
              onPressed: () => _playEpisode(firstEpisode),
            )
          : null,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: PremiumDetailsBackdrop(
                backdropUrl: series.backdropUrl,
                fallbackImageUrl: series.posterUrl,
                height: _heroHeight(responsive),
                child: _buildHeroCaption(responsive),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsivePage(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  responsive.isDesktop ? 32 : 24,
                  responsive.pagePadding,
                  stickyCta ? 34 : 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      series,
                      responsive: responsive,
                      isGuest: isGuest,
                      isFavorite: isFavorite,
                      firstEpisode: firstEpisode,
                      showPrimaryCta: !stickyCta,
                    ),
                    const SizedBox(height: 38),
                    _buildEditorialContent(series, responsive),
                    const SizedBox(height: 38),
                    PremiumDetailsSection(
                      title: 'Saisons et épisodes',
                      subtitle:
                          'Choisissez une saison puis entrez dans l’épisode.',
                      child: _buildSeasonsAndEpisodes(
                        series: series,
                        seasonsAsync: seasonsAsync,
                        seasons: seasons,
                        selectedSeasonId: selectedSeasonId,
                        episodesAsync: episodesAsync,
                        responsive: responsive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCaption(ResponsiveValues responsive) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ResponsivePage(
          padding: EdgeInsets.fromLTRB(
            responsive.pagePadding,
            0,
            responsive.pagePadding,
            28,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 1,
                color: AppColors.brandGold.withValues(alpha: 0.76),
              ),
              const SizedBox(width: 10),
              Text(
                'GUEZS FILMS  •  SÉRIE',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.brandGoldLight,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    SeriesEntity series, {
    required ResponsiveValues responsive,
    required bool isGuest,
    required bool isFavorite,
    required EpisodeEntity? firstEpisode,
    required bool showPrimaryCta,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 720;
        final poster = _buildPoster(
          series.posterUrl,
          responsive.isDesktop ? 236 : 184,
        );
        final information = _buildPrimaryInformation(
          series,
          isGuest: isGuest,
          isFavorite: isFavorite,
          firstEpisode: firstEpisode,
          showPrimaryCta: showPrimaryCta,
          desktopActions: sideBySide,
        );

        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: _buildPoster(series.posterUrl, 154),
              ),
              const SizedBox(height: 24),
              information,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            poster,
            SizedBox(width: responsive.isDesktop ? 38 : 28),
            Expanded(child: information),
          ],
        );
      },
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.03, end: 0);
  }

  Widget _buildPoster(String posterUrl, double width) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.glassBorder(0.44), width: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.46),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.brandGold.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: CachedImage(
              imageUrl: posterUrl,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryInformation(
    SeriesEntity series, {
    required bool isGuest,
    required bool isFavorite,
    required EpisodeEntity? firstEpisode,
    required bool showPrimaryCta,
    required bool desktopActions,
  }) {
    final displayYear = series.productionYear > 0
        ? series.productionYear
        : series.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _seriesBadges(series)
              .map(
                (badge) => PremiumDetailBadge(
                  label: badge.label,
                  icon: badge.icon,
                  warning: badge.warning,
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 16),
        Text(
          series.title.trim().isEmpty ? 'Titre indisponible' : series.title,
          style: AppTextStyles.displayPrestige.copyWith(
            fontSize: desktopActions ? 44 : 32,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            if (displayYear > 0)
              PremiumMetadataPill(
                icon: Icons.calendar_today_outlined,
                label: '$displayYear',
              ),
            if (series.numberOfSeasons > 0)
              PremiumMetadataPill(
                icon: Icons.video_library_outlined,
                label:
                    '${series.numberOfSeasons} saison${series.numberOfSeasons > 1 ? 's' : ''}',
              ),
            if (series.maturityRating.trim().isNotEmpty)
              PremiumMetadataPill(
                icon: Icons.shield_outlined,
                label: series.maturityRating,
              ),
            if (series.qualityVideo.trim().isNotEmpty)
              PremiumMetadataPill(
                icon: Icons.high_quality_outlined,
                label: series.qualityVideo,
              ),
          ],
        ),
        if (series.genres.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: series.genres
                .where((genre) => genre.trim().isNotEmpty)
                .map((genre) => PremiumGenreChip(label: genre))
                .toList(growable: false),
          ),
        ],
        if (isGuest) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 17,
                color: AppColors.brandGoldLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Connectez-vous pour lancer un épisode. Le contrôle d’accès reste géré à l’entrée de la salle.',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
        if (showPrimaryCta && firstEpisode != null) ...[
          const SizedBox(height: 24),
          _buildWatchActions(
            series,
            firstEpisode: firstEpisode,
            desktop: desktopActions,
          ),
        ] else if (series.trailerUrl.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedGradientButton(
              text: 'Bande-annonce',
              icon: Icons.ondemand_video_rounded,
              onPressed: () => _openTrailer(series.trailerUrl),
            ),
          ),
        ],
        const SizedBox(height: 16),
        PremiumIconAction(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: isFavorite ? 'Dans ma liste' : 'Ajouter aux favoris',
          active: isFavorite,
          onPressed: () => _toggleFavorite(series, isFavorite),
        ),
      ],
    );
  }

  Widget _buildWatchActions(
    SeriesEntity series, {
    required EpisodeEntity firstEpisode,
    required bool desktop,
  }) {
    final primary = SizedBox(
      width: desktop ? 220 : null,
      child: GradientButton(
        text: 'Commencer la série',
        icon: Icons.play_arrow_rounded,
        onPressed: () => _playEpisode(firstEpisode),
      ),
    );
    final hasTrailer = series.trailerUrl.trim().isNotEmpty;
    final trailer = SizedBox(
      width: desktop ? 190 : null,
      child: OutlinedGradientButton(
        text: 'Bande-annonce',
        icon: Icons.ondemand_video_rounded,
        onPressed: hasTrailer ? () => _openTrailer(series.trailerUrl) : null,
      ),
    );

    if (!hasTrailer) return primary;
    if (desktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [primary, const SizedBox(width: 12), trailer],
      );
    }
    return Row(
      children: [
        Expanded(child: primary),
        const SizedBox(width: 12),
        Expanded(child: trailer),
      ],
    );
  }

  Widget _buildEditorialContent(
    SeriesEntity series,
    ResponsiveValues responsive,
  ) {
    final facts = _seriesFacts(series);
    final editorial = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumDetailsSection(
          title: 'L’histoire',
          child: Text(
            series.description.trim().isEmpty
                ? 'La présentation de cette série sera bientôt disponible.'
                : series.description,
            style: AppTextStyles.bodyLarge,
          ),
        ),
        if (series.cast.isNotEmpty) ...[
          const SizedBox(height: 30),
          PremiumDetailsSection(
            title: 'Distribution',
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: series.cast
                  .where((name) => name.trim().isNotEmpty)
                  .map((name) => PremiumGenreChip(label: name))
                  .toList(growable: false),
            ),
          ),
        ],
        if (series.awards.isNotEmpty) ...[
          const SizedBox(height: 30),
          PremiumDetailsSection(
            title: 'Distinctions',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: series.awards
                  .where((award) => award.trim().isNotEmpty)
                  .map(
                    (award) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            size: 18,
                            color: AppColors.brandGold,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(award, style: AppTextStyles.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );

    if (!responsive.isDesktop || facts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          editorial,
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 34),
            PremiumDetailsSection(
              title: 'Fiche de la série',
              child: PremiumFactsPanel(facts: facts),
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: editorial),
        const SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: PremiumDetailsSection(
            title: 'Fiche de la série',
            child: PremiumFactsPanel(facts: facts),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonsAndEpisodes({
    required SeriesEntity series,
    required AsyncValue<List<SeasonEntity>> seasonsAsync,
    required List<SeasonEntity> seasons,
    required String? selectedSeasonId,
    required AsyncValue<List<EpisodeEntity>> episodesAsync,
    required ResponsiveValues responsive,
  }) {
    return seasonsAsync.when(
      loading: () => const _EpisodesSkeleton(),
      error: (error, stackTrace) => _InlineState(
        icon: Icons.cloud_off_outlined,
        title: 'Saisons indisponibles',
        message: 'Impossible de charger les saisons pour le moment.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(seasonsProvider(series.id)),
      ),
      data: (_) {
        if (seasons.isEmpty || selectedSeasonId == null) {
          return const _InlineState(
            icon: Icons.video_library_outlined,
            title: 'Aucune saison disponible',
            message:
                'Cette série est annoncée au catalogue, mais ses épisodes ne sont pas encore publiés.',
          );
        }

        final selectedSeason = seasons.firstWhere(
          (season) => season.id == selectedSeasonId,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: seasons
                    .map(
                      (season) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(_seasonLabel(season)),
                          selected: season.id == selectedSeasonId,
                          showCheckmark: false,
                          selectedColor: AppColors.brandGold,
                          backgroundColor: AppColors.surfaceVariant,
                          side: BorderSide(
                            color: season.id == selectedSeasonId
                                ? AppColors.brandGold
                                : AppColors.border,
                          ),
                          labelStyle: AppTextStyles.labelLarge.copyWith(
                            color: season.id == selectedSeasonId
                                ? AppColors.textOnGold
                                : AppColors.textSecondary,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedSeasonId = season.id);
                          },
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _seasonLabel(selectedSeason),
                    style: AppTextStyles.titleLarge,
                  ),
                ),
                if (episodesAsync.valueOrNull?.isNotEmpty ?? false)
                  Text(
                    '${episodesAsync.valueOrNull!.length} épisode${episodesAsync.valueOrNull!.length > 1 ? 's' : ''}',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            episodesAsync.when(
              loading: () => const _EpisodesSkeleton(),
              error: (error, stackTrace) => _InlineState(
                icon: Icons.cloud_off_outlined,
                title: 'Épisodes indisponibles',
                message:
                    'Impossible de charger cette saison. Réessayez dans un instant.',
                actionLabel: 'Réessayer',
                onAction: () => ref.invalidate(
                  episodesProvider((
                    seriesId: series.id,
                    seasonId: selectedSeasonId,
                  )),
                ),
              ),
              data: (episodes) {
                if (episodes.isEmpty) {
                  return const _InlineState(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'Saison vide',
                    message:
                        'Les épisodes de cette saison ne sont pas encore disponibles.',
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 860 ? 2 : 1;
                    final gap = responsive.gridGap;
                    final cardWidth =
                        (constraints.maxWidth - (gap * (columns - 1))) /
                        columns;

                    return Wrap(
                      spacing: gap,
                      runSpacing: 16,
                      children: episodes
                          .map(
                            (episode) => SizedBox(
                              width: cardWidth,
                              child: _EpisodeCard(
                                episode: episode,
                                seriesTitle: series.title,
                                onTap: () => _playEpisode(episode),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  String? _resolveSelectedSeasonId(List<SeasonEntity> seasons) {
    if (seasons.isEmpty) return null;
    final selected = _selectedSeasonId;
    if (selected != null && seasons.any((season) => season.id == selected)) {
      return selected;
    }
    return seasons.first.id;
  }

  String _seasonLabel(SeasonEntity season) {
    if (season.title.trim().isNotEmpty) return season.title;
    if (season.seasonNumber > 0) return 'Saison ${season.seasonNumber}';
    return 'Saison';
  }

  List<_BadgeData> _seriesBadges(SeriesEntity series) {
    final badges = <_BadgeData>[];
    if (series.isOriginal) {
      badges.add(
        const _BadgeData('GUEZS Original', Icons.auto_awesome_rounded),
      );
    }
    if (series.isExclusive) {
      badges.add(const _BadgeData('Exclusivité', Icons.diamond_outlined));
    }
    if (series.isFeatured) {
      badges.add(
        const _BadgeData('Sélection officielle', Icons.workspace_premium),
      );
    }
    if (series.requiresAccess) {
      badges.add(
        _BadgeData(
          series.accessLabel.trim().isEmpty
              ? 'Accès requis'
              : series.accessLabel,
          Icons.lock_outline_rounded,
          warning: true,
        ),
      );
    }
    if (series.awards.isNotEmpty) {
      badges.add(const _BadgeData('Primée', Icons.emoji_events_outlined));
    }
    if (badges.isEmpty) {
      badges.add(const _BadgeData('Sélection GUEZS', Icons.tv_rounded));
    }
    return badges.take(4).toList(growable: false);
  }

  List<PremiumFact> _seriesFacts(SeriesEntity series) {
    final facts = <PremiumFact>[];
    void add(String label, String value, IconData icon) {
      if (value.trim().isNotEmpty) {
        facts.add(PremiumFact(label: label, value: value, icon: icon));
      }
    }

    add(
      'Création / réalisation',
      series.director,
      Icons.movie_creation_outlined,
    );
    add('Pays', series.country, Icons.public_outlined);
    add('Langue', series.language, Icons.translate_rounded);
    add('Classification', series.maturityRating, Icons.shield_outlined);
    add(
      'Sous-titres',
      series.subtitles.where((item) => item.trim().isNotEmpty).join(', '),
      Icons.subtitles_outlined,
    );
    add('Qualité vidéo', series.qualityVideo, Icons.high_quality_outlined);
    if (series.productionYear > 0) {
      add(
        'Année de production',
        '${series.productionYear}',
        Icons.calendar_month_outlined,
      );
    }
    return facts;
  }

  PreferredSizeWidget _buildAppBar({bool forceOpaque = false}) {
    final opacity = forceOpaque ? 1.0 : (_scrollOffset / 180).clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: opacity),
      elevation: 0,
      leading: IconButton(
        tooltip: 'Retour',
        onPressed: _goBack,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.bgCinemaDark.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder(0.2)),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  double _heroHeight(ResponsiveValues responsive) {
    if (responsive.isDesktop) {
      return (responsive.width * 9 / 21).clamp(430.0, 590.0);
    }
    if (responsive.width >= 700) return 460;
    return (responsive.height * 0.46).clamp(350.0, 470.0);
  }

  void _playEpisode(EpisodeEntity episode) {
    context.push(
      Routes.episodeWatchPath(
        seriesId: episode.seriesId,
        seasonId: episode.seasonId,
        episodeId: episode.id,
      ),
    );
  }

  Future<void> _openTrailer(String trailerUrl) async {
    final uri = Uri.tryParse(trailerUrl.trim());
    if (uri == null || !uri.hasScheme) {
      _showMessage('La bande-annonce n’est pas disponible.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showMessage('Impossible d’ouvrir la bande-annonce.');
    }
  }

  void _toggleFavorite(SeriesEntity series, bool isFavorite) {
    unawaited(
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
          ),
    );
    _showMessage(
      isFavorite
          ? 'Série retirée de votre liste.'
          : 'Série ajoutée à votre liste.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EpisodeCard extends StatefulWidget {
  const _EpisodeCard({
    required this.episode,
    required this.seriesTitle,
    required this.onTap,
  });

  final EpisodeEntity episode;
  final String seriesTitle;
  final VoidCallback onTap;

  @override
  State<_EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<_EpisodeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final locked = episode.isLocked || episode.requiresAccess;
    final accessLabel = episode.accessLabel.trim().isEmpty
        ? 'Accès requis'
        : episode.accessLabel;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        label:
            'Épisode ${episode.episodeNumber}, ${episode.title}${locked ? ', accès requis' : ''}',
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            height: 154,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hovered
                      ? AppColors.glassBorder(0.5)
                      : AppColors.border.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.38),
                    blurRadius: _hovered ? 22 : 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Row(
                  children: [
                    SizedBox(
                      width: 154,
                      height: 154,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedImage(
                            imageUrl: episode.thumbnailUrl,
                            borderRadius: BorderRadius.zero,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  AppColors.surface.withValues(alpha: 0.76),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: locked
                                    ? AppColors.warning.withValues(alpha: 0.88)
                                    : AppColors.brandGold.withValues(
                                        alpha: 0.94,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                locked
                                    ? Icons.lock_outline_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.textOnGold,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ÉPISODE ${episode.episodeNumber}',
                                  style: AppTextStyles.overline.copyWith(
                                    color: AppColors.brandGoldLight,
                                  ),
                                ),
                                const Spacer(),
                                if (episode.durationSec > 0)
                                  Text(
                                    _formatDuration(episode.durationSec),
                                    style: AppTextStyles.caption,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              episode.title.trim().isEmpty
                                  ? widget.seriesTitle
                                  : episode.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium,
                            ),
                            if (episode.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                episode.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (locked) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      accessLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.03, end: 0);
  }

  static String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }
}

class _InlineState extends StatelessWidget {
  const _InlineState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.brandGoldLight),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: OutlinedGradientButton(
                text: actionLabel!,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EpisodesSkeleton extends StatelessWidget {
  const _EpisodesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            ShimmerLoading(width: 110, height: 38),
            SizedBox(width: 10),
            ShimmerLoading(width: 110, height: 38),
          ],
        ),
        SizedBox(height: 20),
        ShimmerLoading(
          width: double.infinity,
          height: 138,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        SizedBox(height: 14),
        ShimmerLoading(
          width: double.infinity,
          height: 138,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ],
    );
  }
}

class _BadgeData {
  const _BadgeData(this.label, this.icon, {this.warning = false});

  final String label;
  final IconData icon;
  final bool warning;
}

bool _isNotFoundError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('introuvable') || text.contains('not-found');
}

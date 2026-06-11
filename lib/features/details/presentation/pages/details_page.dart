import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/domain/entities/film_entity.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/providers/content_providers.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/responsive/responsive_values.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/premium_details.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/downloads/domain/entities/download_item.dart';
import '../../../../features/downloads/presentation/providers/download_providers.dart';
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
    final nextOffset = _scrollController.offset;
    if ((nextOffset - _scrollOffset).abs() > 4) {
      setState(() => _scrollOffset = nextOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filmAsync = ref.watch(filmDetailsProvider(widget.filmId));
    final isGuest = ref.watch(authStateProvider).valueOrNull == null;

    return filmAsync.when(
      data: (film) => _buildFilmPage(film, isGuest: isGuest),
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
            icon: notFound
                ? Icons.movie_filter_outlined
                : Icons.cloud_off_outlined,
            title: notFound
                ? 'Film introuvable'
                : 'La séance ne peut pas démarrer',
            message: notFound
                ? 'Ce film n’est plus disponible dans le catalogue.'
                : 'Vérifiez votre connexion puis essayez de nouveau.',
            primaryLabel: 'Réessayer',
            onPrimaryPressed: () =>
                ref.invalidate(filmDetailsProvider(widget.filmId)),
            secondaryLabel: 'Retour au catalogue',
            onSecondaryPressed: _goBack,
          ),
        );
      },
    );
  }

  Widget _buildFilmPage(FilmEntity film, {required bool isGuest}) {
    final responsive = ResponsiveValues.of(context);
    final isFavorite = ref.watch(
      isFavoriteProvider((id: film.id, contentType: 'film')),
    );
    final canDownload =
        PlatformCapabilities.supportsDownloads &&
        film.videoUrl.trim().isNotEmpty;
    final downloadState = canDownload
        ? ref.watch(downloadStateProvider(film.id)).valueOrNull
        : null;
    final stickyCta = responsive.width < 760;
    final heroHeight = _heroHeight(responsive);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: stickyCta
          ? PremiumStickyCta(
              label: 'Entrer en salle',
              icon: Icons.play_arrow_rounded,
              helperText: isGuest ? 'Connexion requise pour regarder' : null,
              onPressed: () => _playFilm(film.id),
            )
          : null,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: PremiumDetailsBackdrop(
                backdropUrl: film.backdropUrl,
                fallbackImageUrl: film.posterUrl,
                height: heroHeight,
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
                      film,
                      responsive: responsive,
                      isGuest: isGuest,
                      isFavorite: isFavorite,
                      canDownload: canDownload,
                      downloadState: downloadState,
                      showPrimaryCta: !stickyCta,
                    ),
                    const SizedBox(height: 38),
                    _buildEditorialContent(film, responsive),
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
                'GUEZS FILMS  •  GRAND ÉCRAN',
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
    FilmEntity film, {
    required ResponsiveValues responsive,
    required bool isGuest,
    required bool isFavorite,
    required bool canDownload,
    required DownloadItem? downloadState,
    required bool showPrimaryCta,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 720;
        final posterWidth = responsive.isDesktop ? 236.0 : 184.0;
        final poster = _buildPoster(film.posterUrl, posterWidth);
        final information = _buildPrimaryInformation(
          film,
          isGuest: isGuest,
          isFavorite: isFavorite,
          canDownload: canDownload,
          downloadState: downloadState,
          showPrimaryCta: showPrimaryCta,
          desktopActions: sideBySide,
        );

        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: _buildPoster(film.posterUrl, 154),
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
    FilmEntity film, {
    required bool isGuest,
    required bool isFavorite,
    required bool canDownload,
    required DownloadItem? downloadState,
    required bool showPrimaryCta,
    required bool desktopActions,
  }) {
    final badges = _filmBadges(film);
    final displayYear = film.productionYear > 0
        ? film.productionYear
        : film.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges
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
          film.title.trim().isEmpty ? 'Titre indisponible' : film.title,
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
            if (film.durationMin > 0)
              PremiumMetadataPill(
                icon: Icons.schedule_outlined,
                label: _formatDurationMinutes(film.durationMin),
              ),
            if (film.rating > 0)
              PremiumMetadataPill(
                icon: Icons.star_rounded,
                label: film.rating.toStringAsFixed(1),
                highlight: true,
              ),
            if (film.maturityRating.trim().isNotEmpty)
              PremiumMetadataPill(
                icon: Icons.shield_outlined,
                label: film.maturityRating,
              ),
            if (film.qualityVideo.trim().isNotEmpty)
              PremiumMetadataPill(
                icon: Icons.high_quality_outlined,
                label: film.qualityVideo,
              ),
          ],
        ),
        if (film.genres.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: film.genres
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
                  'Connectez-vous pour lancer la lecture. Le contrôle d’accès sera effectué à l’entrée de la salle.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (showPrimaryCta) ...[
          const SizedBox(height: 24),
          _buildWatchActions(film, desktop: desktopActions),
        ] else if (film.trailerUrl.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedGradientButton(
              text: 'Bande-annonce',
              icon: Icons.ondemand_video_rounded,
              onPressed: () => _openTrailer(film.trailerUrl),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            PremiumIconAction(
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: isFavorite ? 'Dans ma liste' : 'Ajouter aux favoris',
              active: isFavorite,
              onPressed: () => _toggleFavorite(film, isFavorite),
            ),
            if (canDownload)
              PremiumIconAction(
                icon: _downloadIcon(downloadState),
                label: _downloadLabel(downloadState),
                active: downloadState?.status == DownloadStatus.completed,
                onPressed:
                    downloadState?.status == DownloadStatus.downloading ||
                        downloadState?.status == DownloadStatus.completed
                    ? null
                    : () => _startDownload(film),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatchActions(FilmEntity film, {required bool desktop}) {
    final primary = SizedBox(
      width: desktop ? 220 : null,
      child: GradientButton(
        text: 'Entrer en salle',
        icon: Icons.play_arrow_rounded,
        onPressed: () => _playFilm(film.id),
      ),
    );
    final hasTrailer = film.trailerUrl.trim().isNotEmpty;
    final trailer = SizedBox(
      width: desktop ? 190 : null,
      child: OutlinedGradientButton(
        text: 'Bande-annonce',
        icon: Icons.ondemand_video_rounded,
        onPressed: hasTrailer ? () => _openTrailer(film.trailerUrl) : null,
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

  Widget _buildEditorialContent(FilmEntity film, ResponsiveValues responsive) {
    final facts = _filmFacts(film);
    final editorial = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumDetailsSection(
          title: 'Synopsis',
          child: Text(
            film.description.trim().isEmpty
                ? 'Le synopsis sera bientôt disponible.'
                : film.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (film.cast.isNotEmpty) ...[
          const SizedBox(height: 30),
          PremiumDetailsSection(
            title: 'Au générique',
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: film.cast
                  .where((name) => name.trim().isNotEmpty)
                  .map((name) => PremiumGenreChip(label: name))
                  .toList(growable: false),
            ),
          ),
        ],
        if (film.awards.isNotEmpty) ...[
          const SizedBox(height: 30),
          PremiumDetailsSection(
            title: 'Distinctions',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: film.awards
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
              title: 'Fiche du film',
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
            title: 'Fiche du film',
            child: PremiumFactsPanel(facts: facts),
          ),
        ),
      ],
    );
  }

  List<_BadgeData> _filmBadges(FilmEntity film) {
    final badges = <_BadgeData>[];
    if (film.isOriginal) {
      badges.add(
        const _BadgeData('GUEZS Original', Icons.auto_awesome_rounded),
      );
    }
    if (film.isExclusive) {
      badges.add(const _BadgeData('Exclusivité', Icons.diamond_outlined));
    }
    if (film.isFeatured) {
      badges.add(
        const _BadgeData('Sélection officielle', Icons.workspace_premium),
      );
    }
    if (film.isNew) {
      badges.add(const _BadgeData('Nouveau', Icons.fiber_new_rounded));
    }
    if (film.requiresAccess) {
      badges.add(
        _BadgeData(
          film.accessLabel.trim().isEmpty ? 'Accès requis' : film.accessLabel,
          Icons.lock_outline_rounded,
          warning: true,
        ),
      );
    }
    if (film.awards.isNotEmpty) {
      badges.add(const _BadgeData('Primé', Icons.emoji_events_outlined));
    }
    if (badges.isEmpty) {
      badges.add(const _BadgeData('Sélection GUEZS', Icons.movie_filter));
    }
    return badges.take(4).toList(growable: false);
  }

  List<PremiumFact> _filmFacts(FilmEntity film) {
    final facts = <PremiumFact>[];
    void add(String label, String value, IconData icon) {
      if (value.trim().isNotEmpty) {
        facts.add(PremiumFact(label: label, value: value, icon: icon));
      }
    }

    add('Réalisation', film.director, Icons.movie_creation_outlined);
    add('Pays', film.country, Icons.public_outlined);
    add('Langue', film.language, Icons.translate_rounded);
    add('Classification', film.maturityRating, Icons.shield_outlined);
    add(
      'Sous-titres',
      film.subtitles.where((item) => item.trim().isNotEmpty).join(', '),
      Icons.subtitles_outlined,
    );
    add('Qualité vidéo', film.qualityVideo, Icons.high_quality_outlined);
    if (film.productionYear > 0) {
      add(
        'Année de production',
        '${film.productionYear}',
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

  String _formatDurationMinutes(int durationMin) {
    final hours = durationMin ~/ 60;
    final minutes = durationMin % 60;
    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h ${minutes.toString().padLeft(2, '0')}';
  }

  void _playFilm(String filmId) {
    context.push(Routes.filmWatchPath(filmId));
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

  void _toggleFavorite(FilmEntity film, bool isFavorite) {
    unawaited(
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
          ),
    );
    _showMessage(
      isFavorite ? 'Film retiré de votre liste.' : 'Film ajouté à votre liste.',
    );
  }

  void _startDownload(FilmEntity film) {
    unawaited(
      ref
          .read(downloadServiceProvider)
          .startDownload(
            DownloadItem(
              id: film.id,
              title: film.title,
              posterPath: film.posterUrl,
              videoUrl: film.videoUrl,
              localPath: '',
            ),
          ),
    );
    _showMessage('Le téléchargement a démarré.');
  }

  IconData _downloadIcon(DownloadItem? item) {
    return switch (item?.status) {
      DownloadStatus.completed => Icons.download_done_rounded,
      DownloadStatus.downloading => Icons.downloading_rounded,
      DownloadStatus.failed => Icons.refresh_rounded,
      _ => Icons.download_rounded,
    };
  }

  String _downloadLabel(DownloadItem? item) {
    return switch (item?.status) {
      DownloadStatus.completed => 'Téléchargé',
      DownloadStatus.downloading =>
        'Téléchargement ${(item!.progress * 100).round()} %',
      DownloadStatus.failed => 'Réessayer',
      _ => 'Télécharger',
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

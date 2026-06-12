import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:guezs_films/core/config/firebase_runtime_config.dart';
import 'package:guezs_films/core/constants/app_constants.dart';
import 'package:guezs_films/core/domain/entities/episode_entity.dart';
import 'package:guezs_films/core/domain/entities/film_entity.dart';
import 'package:guezs_films/core/domain/entities/season_entity.dart';
import 'package:guezs_films/core/domain/entities/series_entity.dart';
import 'package:guezs_films/core/providers/content_providers.dart';
import 'package:guezs_films/core/routes/app_router.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/core/search/search_normalization.dart';
import 'package:guezs_films/core/widgets/premium_states.dart';
import 'package:guezs_films/features/access/domain/entities/watch_access_result.dart';
import 'package:guezs_films/features/access/data/repositories/cloud_functions_watch_access_repository.dart';
import 'package:guezs_films/features/access/presentation/providers/watch_access_providers.dart';
import 'package:guezs_films/features/auth/domain/entities/user_entity.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_error_mapper.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/details/presentation/pages/details_page.dart';
import 'package:guezs_films/features/downloads/presentation/pages/downloads_page.dart';
import 'package:guezs_films/features/downloads/presentation/providers/download_providers.dart';
import 'package:guezs_films/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:guezs_films/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:guezs_films/features/legal/presentation/pages/support_page.dart';
import 'package:guezs_films/features/legal/presentation/pages/terms_of_use_page.dart';
import 'package:guezs_films/features/player/data/player_progress_store.dart';
import 'package:guezs_films/features/player/data/video_controller_factory.dart';
import 'package:guezs_films/features/player/domain/entities/player_content_request.dart';
import 'package:guezs_films/features/player/domain/services/mvp_playback_fallback.dart';
import 'package:guezs_films/features/player/presentation/pages/player_page.dart';
import 'package:guezs_films/features/profile/domain/entities/user_profile_entity.dart';
import 'package:guezs_films/features/profile/presentation/pages/profile_page.dart';
import 'package:guezs_films/features/profile/presentation/pages/profile_selector_page.dart';
import 'package:guezs_films/features/profile/presentation/providers/user_profile_providers.dart';
import 'package:guezs_films/features/search/presentation/pages/search_page.dart';
import 'package:guezs_films/features/series/presentation/pages/series_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // TODO: Add proper widget tests for Guezs Films
    expect(true, isTrue);
  });

  test('Player content requests expose stable local progress keys', () {
    expect(PlayerContentRequest.film('film-42').storageKey, 'film:film-42');
    expect(
      PlayerContentRequest.episode(
        seriesId: 'series-7',
        seasonId: 'season-2',
        episodeId: 'episode-4',
      ).storageKey,
      'episode:series-7:season-2:episode-4',
    );
  });

  test(
    'Player progress resumes useful positions and clears near the end',
    () async {
      SharedPreferences.setMockInitialValues({});
      const store = PlayerProgressStore();
      final request = PlayerContentRequest.film('resume-film');
      const duration = Duration(minutes: 20);
      const resumePosition = Duration(minutes: 3);

      await store.save(request, position: resumePosition, duration: duration);
      expect(await store.load(request, duration: duration), resumePosition);

      await store.save(
        request,
        position: const Duration(minutes: 19),
        duration: duration,
      );
      expect(await store.load(request, duration: duration), isNull);
    },
  );

  test('Video source validation accepts streaming manifests', () {
    expect(
      VideoControllerFactory.isSupportedSource(
        'https://media.example.com/master.m3u8',
      ),
      isTrue,
    );
    expect(
      VideoControllerFactory.isSupportedSource('not a video url'),
      isFalse,
    );
  });

  test('Search normalization supports accents and multi-word tokens', () {
    expect(normalizeSearchText('  Cinéma à Douala  '), 'cinema a douala');
    expect(buildSearchQueryTokens('épopée voyage'), contains('épopée'));
    expect(buildSearchQueryTokens('épopée voyage'), contains('epopee'));
    expect(buildSearchQueryTokens('épopée voyage'), contains('voyage'));
    expect(buildSearchQueryTokens('a'), isEmpty);
  });

  test('Catalog and watch route helpers remain refresh-safe', () {
    expect(Routes.home, '/home');
    expect(Routes.filmDetailsPath('film 42'), '/film/film%2042');
    expect(Routes.seriesDetailsPath('series/7'), '/series/series%2F7');
    expect(Routes.filmWatchPath('film 42'), '/watch/film/film%2042');
    expect(
      Routes.episodeWatchPath(
        seriesId: 'series-7',
        seasonId: 'season-2',
        episodeId: 'episode-4',
      ),
      '/watch/series/series-7/season/season-2/episode/episode-4',
    );
    expect(Routes.support, '/support');
    expect(Routes.privacyPolicy, '/privacy-policy');
    expect(Routes.termsOfUse, '/terms-of-use');
  });

  test(
    'Firebase runtime targets the deployed project and Functions region',
    () {
      expect(FirebaseRuntimeConfig.firebaseProjectId, 'guezs-films');
      expect(FirebaseRuntimeConfig.functionsRegion, 'us-central1');
    },
  );

  test('Functions errors stay explicit and user-facing', () {
    expect(
      WatchAccessFunctionErrorMapper.statusForCode('not-found'),
      WatchAccessStatus.serviceNotDeployed,
    );
    expect(
      WatchAccessFunctionErrorMapper.messageForCode('not-found'),
      'Le service d’accès vidéo n’est pas encore déployé sur Firebase. '
      'Déployez les Cloud Functions ou activez le mode MVP.',
    );
    expect(
      WatchAccessFunctionErrorMapper.statusForCode('permission-denied'),
      WatchAccessStatus.denied,
    );
    expect(
      WatchAccessFunctionErrorMapper.statusForCode('unauthenticated'),
      WatchAccessStatus.guest,
    );
    expect(
      WatchAccessFunctionErrorMapper.statusForCode('failed-precondition'),
      WatchAccessStatus.codeRequired,
    );
    expect(
      WatchAccessFunctionErrorMapper.messageForCode('not-found'),
      isNot(contains('not_found')),
    );
  });

  test('MVP video fallback never bypasses business access decisions', () {
    const videoUrl = 'https://media.example.com/movie.mp4';
    const serviceMissing = WatchAccessResult(
      allowed: false,
      status: WatchAccessStatus.serviceNotDeployed,
      message: 'Service absent',
    );
    const unavailable = WatchAccessResult(
      allowed: false,
      status: WatchAccessStatus.unavailable,
      message: 'Service indisponible',
    );

    expect(
      shouldUseDirectVideoFallback(
        access: serviceMissing,
        directVideoUrl: videoUrl,
      ),
      isTrue,
    );
    expect(
      shouldUseDirectVideoFallback(
        access: unavailable,
        directVideoUrl: videoUrl,
      ),
      isTrue,
    );

    for (final status in [
      WatchAccessStatus.guest,
      WatchAccessStatus.codeRequired,
      WatchAccessStatus.denied,
      WatchAccessStatus.expired,
      WatchAccessStatus.error,
    ]) {
      expect(
        shouldUseDirectVideoFallback(
          access: WatchAccessResult(
            allowed: false,
            status: status,
            message: 'Accès refusé',
          ),
          directVideoUrl: videoUrl,
        ),
        isFalse,
        reason:
            'Le statut ${status.name} ne doit jamais autoriser le fallback.',
      );
    }

    expect(
      shouldUseDirectVideoFallback(access: serviceMissing, directVideoUrl: ' '),
      isFalse,
    );
  });

  test('Auth configuration errors stay user-facing', () {
    final message = AuthErrorMapper.map('redirect_uri_mismatch');

    expect(message, contains('pas disponible'));
    expect(message, isNot(contains('192.168.')));
    expect(message, isNot(contains('Firebase')));
  });

  testWidgets('Search presents premium discovery and catalog filters', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final film = FilmEntity(
      id: 'search-film',
      title: 'Voyage à Douala',
      description: 'Une aventure urbaine.',
      posterUrl: '',
      backdropUrl: '',
      videoUrl: '',
      genres: const ['Drame'],
      year: 2026,
      durationMin: 110,
      rating: 8.4,
      isFeatured: true,
      isNew: true,
      createdAt: DateTime(2026, 6, 10),
      director: 'Awa N.',
      country: 'Cameroun',
      language: 'Français',
      isExclusive: true,
    );
    final series = SeriesEntity(
      id: 'search-series',
      title: 'Nuits de Yaoundé',
      description: 'Une chronique nocturne.',
      posterUrl: '',
      backdropUrl: '',
      genres: const ['Thriller'],
      year: 2025,
      numberOfSeasons: 2,
      isFeatured: true,
      createdAt: DateTime(2026, 5, 20),
      country: 'Cameroun',
      language: 'Français',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filmsProvider.overrideWith((ref) async => [film]),
          seriesProvider.overrideWith((ref) async => [series]),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Rechercher un film, une série, un réalisateur…'),
      findsOneWidget,
    );
    expect(find.text('Tendances du moment'), findsOneWidget);
    expect(find.text('Voyage à Douala'), findsOneWidget);
    expect(find.text('Nuits de Yaoundé'), findsOneWidget);
    expect(find.text('Exclusifs'), findsOneWidget);
    expect(find.text('Pays'), findsOneWidget);

    await tester.tap(find.text('Films'));
    await tester.pumpAndSettle();

    expect(find.text('Voyage à Douala'), findsOneWidget);
    expect(find.text('Nuits de Yaoundé'), findsNothing);
  });

  testWidgets('Search waits for two characters before querying', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filmsProvider.overrideWith((ref) async => const []),
          seriesProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(AppConstants.searchDebounce);

    expect(find.text('Saisissez au moins 2 caractères.'), findsOneWidget);
    expect(find.textContaining('Résultats pour'), findsNothing);
  });

  testWidgets('Search result opens the film details route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final film = FilmEntity(
      id: 'route-film',
      title: 'Le Voyage Bleu',
      description: 'Un film à retrouver par son titre.',
      posterUrl: '',
      backdropUrl: '',
      videoUrl: '',
      genres: const ['Aventure'],
      year: 2026,
      durationMin: 100,
      rating: 7.8,
      isFeatured: false,
      isNew: true,
      createdAt: DateTime(2026, 6, 9),
    );
    final router = GoRouter(
      initialLocation: Routes.search,
      routes: [
        GoRoute(
          path: Routes.search,
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: '${Routes.film}/:filmId',
          builder: (context, state) =>
              Text('Film ${state.pathParameters['filmId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filmsProvider.overrideWith((ref) async => [film]),
          seriesProvider.overrideWith((ref) async => const []),
          searchFilmsProvider('voyage').overrideWith((ref) async => [film]),
          searchSeriesProvider('voyage').overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'voyage');
    await tester.pump(AppConstants.searchDebounce);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Le Voyage Bleu'));
    await tester.tap(find.text('Le Voyage Bleu'));
    await tester.pumpAndSettle();

    expect(find.text('Film route-film'), findsOneWidget);
  });

  testWidgets(
    'Player presents a premium unavailable state for an empty source',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayerPage(videoUrl: '', title: 'Séance indisponible'),
        ),
      );
      await tester.pump();

      expect(find.text('Vidéo indisponible'), findsOneWidget);
      expect(
        find.text('Aucune source de lecture n’est configurée pour ce contenu.'),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
    },
  );

  testWidgets('Watch film route is recognized without navigation extras', (
    tester,
  ) async {
    final pendingFilm = Completer<FilmEntity>();
    final pendingAccess = Completer<WatchAccessResult>();
    final request = PlayerContentRequest.film('test-id');
    final router = GoRouter(
      initialLocation: Routes.filmWatchPath('test-id'),
      routes: AppRouter.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(uid: 'test-user', email: 'test@example.com'),
            ),
          ),
          filmDetailsProvider(
            'test-id',
          ).overrideWith((ref) => pendingFilm.future),
          watchAccessProvider(
            request,
          ).overrideWith((ref) => pendingAccess.future),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();

    expect(find.text('Vérification de l’accès'), findsOneWidget);
  });

  testWidgets('Film details exposes premium conversion content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final film = FilmEntity(
      id: 'film-p6',
      title: 'Le Grand Voyage',
      description: 'Un récit de cinéma conçu pour le grand écran.',
      posterUrl: '',
      backdropUrl: '',
      videoUrl: 'https://example.com/movie.mp4',
      genres: const ['Drame', 'Aventure'],
      year: 2026,
      durationMin: 128,
      rating: 8.7,
      isFeatured: true,
      isNew: true,
      createdAt: DateTime(2026, 6, 11),
      trailerUrl: 'https://example.com/trailer',
      director: 'Awa N.',
      cast: const ['Mina K.', 'Jean T.'],
      country: 'Cameroun',
      language: 'Français',
      maturityRating: '12+',
      subtitles: const ['Français', 'Anglais'],
      qualityVideo: '4K',
      isOriginal: true,
      requiresAccess: true,
      accessLabel: 'Accès requis',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filmDetailsProvider(film.id).overrideWith((ref) async => film),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(uid: 'test-user', email: 'test@example.com'),
            ),
          ),
          isFavoriteProvider((
            id: film.id,
            contentType: 'film',
          )).overrideWith((ref) => false),
          downloadStateProvider(
            film.id,
          ).overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(home: DetailsPage(filmId: 'film-p6')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Le Grand Voyage'), findsOneWidget);
    expect(find.text('Entrer en salle'), findsOneWidget);
    expect(find.text('Bande-annonce'), findsOneWidget);
    expect(find.text('GUEZS Original'), findsOneWidget);
    expect(find.text('Accès requis'), findsOneWidget);
    expect(find.text('Fiche du film'), findsOneWidget);
    expect(find.text('Télécharger'), findsOneWidget);
    expect(find.text('D/L'), findsNothing);
  });

  testWidgets('Series details presents seasons and locked episodes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final series = SeriesEntity(
      id: 'series-p6',
      title: 'Nuits de Douala',
      description: 'Une série chorale au cœur de la ville.',
      posterUrl: '',
      backdropUrl: '',
      genres: const ['Drame'],
      year: 2026,
      numberOfSeasons: 1,
      isFeatured: true,
      createdAt: DateTime(2026, 6, 11),
      director: 'Mireille S.',
      country: 'Cameroun',
      language: 'Français',
      qualityVideo: 'HD',
    );
    const season = SeasonEntity(
      id: 'season-1',
      seriesId: 'series-p6',
      seasonNumber: 1,
      title: 'Saison 1',
    );
    final episode = EpisodeEntity(
      id: 'episode-1',
      seriesId: series.id,
      seasonId: season.id,
      episodeNumber: 1,
      title: 'La première nuit',
      description: 'Les destins se croisent.',
      thumbnailUrl: '',
      videoUrl: 'https://example.com/episode.mp4',
      durationSec: 2700,
      airDate: DateTime(2026, 6, 11),
      requiresAccess: true,
      isLocked: true,
      accessLabel: 'Code requis',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seriesDetailsProvider(series.id).overrideWith((ref) async => series),
          seasonsProvider(
            series.id,
          ).overrideWith((ref) async => const [season]),
          episodesProvider((
            seriesId: series.id,
            seasonId: season.id,
          )).overrideWith((ref) async => [episode]),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(uid: 'test-user', email: 'test@example.com'),
            ),
          ),
          isFavoriteProvider((
            id: series.id,
            contentType: 'series',
          )).overrideWith((ref) => false),
        ],
        child: const MaterialApp(
          home: SeriesDetailsPage(seriesId: 'series-p6'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nuits de Douala'), findsOneWidget);
    expect(find.text('Commencer la série'), findsOneWidget);
    expect(find.text('Saison 1'), findsWidgets);
    expect(find.text('La première nuit'), findsOneWidget);
    expect(find.text('Code requis'), findsOneWidget);
    expect(find.text('Saisons et épisodes'), findsOneWidget);
  });

  testWidgets('Premium empty state exposes a clear primary action', (
    tester,
  ) async {
    var actionTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PremiumEmptyState(
            icon: Icons.event_seat_outlined,
            title: 'Votre fauteuil VIP vous attend',
            message: 'Ajoutez un premier film à votre sélection.',
            actionLabel: 'Explorer le catalogue',
            onAction: () => actionTriggered = true,
          ),
        ),
      ),
    );

    expect(find.text('Votre fauteuil VIP vous attend'), findsOneWidget);
    await tester.tap(find.text('Explorer le catalogue'));
    expect(actionTriggered, isTrue);
  });

  testWidgets('Downloads explains mobile availability on desktop', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DownloadsPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Téléchargements'), findsOneWidget);
      expect(
        find.text(
          'Les téléchargements hors-ligne sont réservés à l’application mobile pour le moment.',
        ),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'Profile guest mode stays honest about unavailable account data',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mon espace'), findsOneWidget);
      expect(find.text('Mode invité'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Facturation'), findsNothing);
    },
  );

  testWidgets('Legal pages expose the required production information', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SupportPage()));
    expect(find.text('Support GUEZS FILMS'), findsOneWidget);
    expect(find.text('Assistance compte'), findsOneWidget);
    expect(find.text('support@guezsfilms.com'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.text('Droits de l’utilisateur'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: TermsOfUsePage()));
    expect(find.text('Conditions d’utilisation'), findsOneWidget);
    expect(find.text('Usage personnel'), findsOneWidget);
  });

  testWidgets('Profile selector renders supplied standard and child profiles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final profiles = [
      UserProfileEntity(
        id: 'standard',
        name: 'Ariane',
        emoji: 'A',
        colorIndex: 0,
        isKids: false,
        createdAt: DateTime(2026, 6, 12),
      ),
      UserProfileEntity(
        id: 'kids',
        name: 'Junior',
        emoji: 'J',
        colorIndex: 4,
        isKids: true,
        createdAt: DateTime(2026, 6, 12),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const UserEntity(
                uid: 'profiles-user',
                email: 'profiles@example.com',
              ),
            ),
          ),
          userProfilesProvider(
            'profiles-user',
          ).overrideWith((ref) => Stream.value(profiles)),
        ],
        child: const MaterialApp(home: ProfileSelectorPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Qui regarde ?'), findsOneWidget);
    expect(find.text('Ariane'), findsOneWidget);
    expect(find.text('Junior'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Enfant'), findsOneWidget);
    expect(find.text('LA FEMME DU MBENGUISTE'), findsNothing);
  });

  testWidgets('Unknown routes show a product-safe error state', (tester) async {
    final router = GoRouter(
      initialLocation: '/route-inconnue',
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const Text('Accueil test'),
        ),
      ],
      errorBuilder: AppRouter.errorBuilder,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Cette page n’est pas disponible'), findsOneWidget);
    expect(find.text('Retour à l’accueil'), findsOneWidget);
    expect(find.text('/route-inconnue'), findsNothing);
    expect(find.text('Page not found'), findsNothing);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:guezs_films/core/domain/entities/episode_entity.dart';
import 'package:guezs_films/core/domain/entities/film_entity.dart';
import 'package:guezs_films/core/domain/entities/season_entity.dart';
import 'package:guezs_films/core/domain/entities/series_entity.dart';
import 'package:guezs_films/core/providers/content_providers.dart';
import 'package:guezs_films/core/routes/app_router.dart';
import 'package:guezs_films/core/routes/route_constants.dart';
import 'package:guezs_films/features/access/domain/entities/watch_access_result.dart';
import 'package:guezs_films/features/access/presentation/providers/watch_access_providers.dart';
import 'package:guezs_films/features/auth/domain/entities/user_entity.dart';
import 'package:guezs_films/features/auth/presentation/providers/auth_providers.dart';
import 'package:guezs_films/features/details/presentation/pages/details_page.dart';
import 'package:guezs_films/features/downloads/presentation/providers/download_providers.dart';
import 'package:guezs_films/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:guezs_films/features/player/domain/entities/player_content_request.dart';
import 'package:guezs_films/features/series/presentation/pages/series_details_page.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // TODO: Add proper widget tests for Guezs Films
    expect(true, isTrue);
  });

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
}

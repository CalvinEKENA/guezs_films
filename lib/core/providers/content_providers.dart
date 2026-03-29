import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_content_datasource.dart';
import '../data/repositories/content_repository_impl.dart';
import '../domain/entities/episode_entity.dart';
import '../domain/entities/film_entity.dart';
import '../domain/entities/season_entity.dart';
import '../domain/entities/series_entity.dart';
import '../domain/repositories/content_repository.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseContentDataSourceProvider = Provider<FirebaseContentDataSource>((
  ref,
) {
  return FirebaseContentDataSourceImpl(ref.watch(firebaseFirestoreProvider));
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(
    dataSource: ref.watch(firebaseContentDataSourceProvider),
  );
});

final filmsProvider = FutureProvider<List<FilmEntity>>((ref) async {
  return ref.watch(contentRepositoryProvider).getFilms();
});

final featuredFilmsProvider = FutureProvider<List<FilmEntity>>((ref) async {
  return ref.watch(contentRepositoryProvider).getFeaturedFilms();
});

final newFilmsProvider = FutureProvider<List<FilmEntity>>((ref) async {
  return ref.watch(contentRepositoryProvider).getNewFilms();
});

final filmDetailsProvider = FutureProvider.family<FilmEntity, String>((
  ref,
  id,
) async {
  return ref.watch(contentRepositoryProvider).getFilmById(id);
});

final seriesProvider = FutureProvider<List<SeriesEntity>>((ref) async {
  return ref.watch(contentRepositoryProvider).getSeries();
});

final featuredSeriesProvider = FutureProvider<List<SeriesEntity>>((ref) async {
  return ref.watch(contentRepositoryProvider).getFeaturedSeries();
});

final seriesDetailsProvider = FutureProvider.family<SeriesEntity, String>((
  ref,
  id,
) async {
  return ref.watch(contentRepositoryProvider).getSeriesById(id);
});

final seasonsProvider = FutureProvider.family<List<SeasonEntity>, String>((
  ref,
  seriesId,
) async {
  return ref.watch(contentRepositoryProvider).getSeasons(seriesId);
});

final episodesProvider =
    FutureProvider.family<
      List<EpisodeEntity>,
      ({String seriesId, String seasonId})
    >((ref, params) async {
      return ref
          .watch(contentRepositoryProvider)
          .getEpisodes(params.seriesId, params.seasonId);
    });

final searchFilmsProvider = FutureProvider.family<List<FilmEntity>, String>((
  ref,
  query,
) async {
  return ref.watch(contentRepositoryProvider).searchFilms(query);
});

final searchSeriesProvider = FutureProvider.family<List<SeriesEntity>, String>((
  ref,
  query,
) async {
  return ref.watch(contentRepositoryProvider).searchSeries(query);
});

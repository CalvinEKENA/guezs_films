import 'package:cloud_firestore/cloud_firestore.dart';

import '../search/search_normalization.dart';
import 'models/episode_model.dart';
import 'models/film_model.dart';
import 'models/season_model.dart';
import 'models/series_model.dart';

abstract class FirebaseContentDataSource {
  Future<List<FilmModel>> getFilms();
  Future<List<FilmModel>> getFeaturedFilms();
  Future<List<FilmModel>> getNewFilms();
  Future<FilmModel> getFilmById(String id);
  Future<List<SeriesModel>> getSeries();
  Future<List<SeriesModel>> getFeaturedSeries();
  Future<List<SeriesModel>> getNewSeries();
  Future<SeriesModel> getSeriesById(String id);
  Future<List<SeasonModel>> getSeasons(String seriesId);
  Future<List<EpisodeModel>> getEpisodes(String seriesId, String seasonId);
  Future<EpisodeModel> getEpisodeById(
    String seriesId,
    String seasonId,
    String episodeId,
  );
  Future<List<FilmModel>> searchFilms(String query);
  Future<List<SeriesModel>> searchSeries(String query);
  Future<List<FilmModel>> getFilmsByGenre(String genre);
  Future<List<SeriesModel>> getSeriesByGenre(String genre);
}

class FirebaseContentDataSourceImpl implements FirebaseContentDataSource {
  FirebaseContentDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _filmsCollection =>
      _firestore.collection('films');

  CollectionReference<Map<String, dynamic>> get _seriesCollection =>
      _firestore.collection('series');

  @override
  Future<List<FilmModel>> getFilms() async {
    final snapshot = await _filmsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(FilmModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<FilmModel>> getFeaturedFilms() async {
    final snapshot = await _filmsCollection
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(FilmModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<FilmModel>> getNewFilms() async {
    final snapshot = await _filmsCollection
        .where('isNew', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(FilmModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<FilmModel> getFilmById(String id) async {
    final doc = await _filmsCollection.doc(id).get();
    if (!doc.exists) {
      throw StateError('Film introuvable: $id');
    }
    return FilmModel.fromFirestore(doc);
  }

  @override
  Future<List<SeriesModel>> getSeries() async {
    final snapshot = await _seriesCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(SeriesModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<SeriesModel>> getFeaturedSeries() async {
    final snapshot = await _seriesCollection
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(SeriesModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<SeriesModel>> getNewSeries() async {
    final snapshot = await _seriesCollection
        .where('isNew', isEqualTo: true)
        .get();
    return snapshot.docs.map(SeriesModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<SeriesModel> getSeriesById(String id) async {
    final doc = await _seriesCollection.doc(id).get();
    if (!doc.exists) {
      throw StateError('Série introuvable: $id');
    }
    return SeriesModel.fromFirestore(doc);
  }

  @override
  Future<List<SeasonModel>> getSeasons(String seriesId) async {
    final snapshot = await _seriesCollection
        .doc(seriesId)
        .collection('seasons')
        .orderBy('seasonNumber')
        .get();

    return snapshot.docs
        .map((doc) => SeasonModel.fromFirestore(seriesId: seriesId, doc: doc))
        .toList(growable: false);
  }

  @override
  Future<List<EpisodeModel>> getEpisodes(
    String seriesId,
    String seasonId,
  ) async {
    final snapshot = await _seriesCollection
        .doc(seriesId)
        .collection('seasons')
        .doc(seasonId)
        .collection('episodes')
        .orderBy('episodeNumber')
        .get();

    return snapshot.docs
        .map(
          (doc) => EpisodeModel.fromFirestore(
            seriesId: seriesId,
            seasonId: seasonId,
            doc: doc,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<EpisodeModel> getEpisodeById(
    String seriesId,
    String seasonId,
    String episodeId,
  ) async {
    final doc = await _seriesCollection
        .doc(seriesId)
        .collection('seasons')
        .doc(seasonId)
        .collection('episodes')
        .doc(episodeId)
        .get();

    if (!doc.exists) {
      throw StateError('Episode introuvable: $episodeId');
    }

    return EpisodeModel.fromFirestore(
      seriesId: seriesId,
      seasonId: seasonId,
      doc: doc,
    );
  }

  @override
  Future<List<FilmModel>> searchFilms(String query) async {
    final queryTokens = buildSearchQueryTokens(query);
    if (queryTokens.isEmpty) return const [];

    final snapshot = await _filmsCollection
        .where('searchTokens', arrayContainsAny: queryTokens)
        .limit(60)
        .get();

    return snapshot.docs.map(FilmModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<SeriesModel>> searchSeries(String query) async {
    final queryTokens = buildSearchQueryTokens(query);
    if (queryTokens.isEmpty) return const [];

    final snapshot = await _seriesCollection
        .where('searchTokens', arrayContainsAny: queryTokens)
        .limit(60)
        .get();

    return snapshot.docs.map(SeriesModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<FilmModel>> getFilmsByGenre(String genre) async {
    final snapshot = await _filmsCollection
        .where('genres', arrayContains: genre)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(FilmModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<List<SeriesModel>> getSeriesByGenre(String genre) async {
    final snapshot = await _seriesCollection
        .where('genres', arrayContains: genre)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(SeriesModel.fromFirestore).toList(growable: false);
  }
}

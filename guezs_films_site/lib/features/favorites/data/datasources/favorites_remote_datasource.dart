import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_movie_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class FavoritesRemoteDataSource {
  Future<void> addFavorite(String userId, FavoriteMovieModel movie);
  Future<void> removeFavorite(String userId, String storageKey);
  Future<List<FavoriteMovieModel>> getFavorites(String userId);
  Stream<List<FavoriteMovieModel>> watchFavorites(String userId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;

  FavoritesRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _getCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  @override
  Future<void> addFavorite(String userId, FavoriteMovieModel movie) async {
    try {
      await _getCollection(userId).doc(movie.storageKey).set(movie.toMap());
    } catch (e) {
      throw ServerException('Erreur Firestore lors de l\'ajout du favori');
    }
  }

  @override
  Future<void> removeFavorite(String userId, String storageKey) async {
    try {
      await _getCollection(userId).doc(storageKey).delete();
    } catch (e) {
      throw ServerException('Erreur Firestore lors du retrait du favori');
    }
  }

  @override
  Future<List<FavoriteMovieModel>> getFavorites(String userId) async {
    try {
      final snapshot = await _getCollection(userId)
          .orderBy('addedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => FavoriteMovieModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Erreur Firestore lors de la récupération des favoris');
    }
  }

  @override
  Stream<List<FavoriteMovieModel>> watchFavorites(String userId) {
    return _getCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoriteMovieModel.fromMap(doc.data()))
              .toList(),
        );
  }
}

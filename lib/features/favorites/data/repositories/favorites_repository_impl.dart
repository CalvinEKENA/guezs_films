import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../models/favorite_movie_model.dart';
import 'package:flutter/foundation.dart';

/// Implémentation Hive locale du dépôt des Favoris
class FavoritesRepositoryImpl implements FavoritesRepository {
  Future<Box<FavoriteMovieModel>> _getBox() async {
    try {
      if (Hive.isBoxOpen(AppConstants.favoritesBox)) {
        return Hive.box<FavoriteMovieModel>(AppConstants.favoritesBox);
      }
      return await Hive.openBox<FavoriteMovieModel>(AppConstants.favoritesBox);
    } catch (e) {
      debugPrint('Error getting Hive box: $e');
      throw CacheException('Impossible de lire les favoris locaux');
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteMovie movie) async {
    try {
      final box = await _getBox();
      final model = FavoriteMovieModel.fromEntity(movie);
      await box.put(model.storageKey, model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erreur lors de l\'ajout aux favoris.'));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteMovie>>> getFavorites() async {
    try {
      final box = await _getBox();
      final List<FavoriteMovieModel> models = box.values.toList();

      // Trier par date d'ajout décroissante (le plus récent en premier)
      models.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la lecture des favoris.'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite({
    required String id,
    required String contentType,
  }) async {
    try {
      final box = await _getBox();
      final isFav = box.containsKey('$contentType:$id');
      return Right(isFav);
    } catch (e) {
      return const Right(false); // Faible risque : on retourne faux par défaut
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String id,
    required String contentType,
  }) async {
    try {
      final box = await _getBox();
      final storageKey = '$contentType:$id';
      if (box.containsKey(storageKey)) {
        await box.delete(storageKey);
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erreur lors du retrait des favoris.'));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../models/favorite_movie_model.dart';
import 'package:flutter/foundation.dart';

/// Implémentation coordonnée (Hive + Firestore) du dépôt des Favoris.
/// Suit une approche "Local-First" pour la performance et l'offline.
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  FavoritesRepositoryImpl({
    required FavoritesRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  }) : _remoteDataSource = remoteDataSource,
       _authRepository = authRepository;

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
      // 1. Mise à jour locale (Hive) - Instantané
      final box = await _getBox();
      final model = FavoriteMovieModel.fromEntity(movie);
      await box.put(model.storageKey, model);

      // 2. Mise à jour distante (Firestore) - Si connecté
      final user = _authRepository.currentUser;
      if (user != null) {
        _remoteDataSource.addFavorite(user.uid, model).catchError((e) {
          debugPrint('Error syncing added favorite to cloud: $e');
        });
      }

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
      final List<FavoriteMovieModel> models = box.values
          .where(
            (model) => !model.isDeleted,
          ) // Ignorer les éléments soft-delete
          .toList();

      // Trier par date d'ajout décroissante
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
      final model = box.get('$contentType:$id');
      final isFav = model != null && !model.isDeleted;
      return Right(isFav);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite({
    required String id,
    required String contentType,
  }) async {
    try {
      // 1. Soft-Delete local (Hive) pour garder la trace
      final box = await _getBox();
      final storageKey = '$contentType:$id';
      final existing = box.get(storageKey);

      if (existing != null) {
        final deletedModel = FavoriteMovieModel(
          id: existing.id,
          title: existing.title,
          posterPath: existing.posterPath,
          contentType: existing.contentType,
          addedAt: existing.addedAt,
          isDeleted: true,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await box.put(storageKey, deletedModel);

        // 2. Propagation vers le distant (Firestore)
        final user = _authRepository.currentUser;
        if (user != null) {
          // On update le docuement Firestore avec isDeleted = true au lieu de le supprimer physiquement
          _remoteDataSource.addFavorite(user.uid, deletedModel).catchError((e) {
            debugPrint('Error syncing removed favorite to cloud: $e');
          });
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erreur lors du retrait des favoris.'));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithCloud() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) return const Right(null);

      final box = await _getBox();

      // 1. Récupération des favoris Cloud
      final remoteFavorites = await _remoteDataSource.getFavorites(user.uid);

      // 2. Merge avec la logique de dates
      await _mergeWithLocal(box, remoteFavorites, user.uid);

      return const Right(null);
    } catch (e) {
      debugPrint('Sync failed: $e');
      return Left(ServerFailure('Erreur lors de la synchronisation cloud.'));
    }
  }

  @override
  Stream<Either<Failure, void>> watchCloudUpdates() async* {
    final user = _authRepository.currentUser;
    if (user == null) {
      yield Left(ServerFailure('Non connecté'));
      return;
    }

    try {
      final box = await _getBox();
      await for (final remoteFavorites in _remoteDataSource.watchFavorites(
        user.uid,
      )) {
        await _mergeWithLocal(box, remoteFavorites, user.uid);
        yield const Right(null);
      }
    } catch (e) {
      debugPrint('Watch updates failed: $e');
      yield Left(ServerFailure('Mise à jour Firestore échouée.'));
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  Future<void> _mergeWithLocal(
    Box<FavoriteMovieModel> box,
    List<FavoriteMovieModel> remoteFavorites,
    String userId,
  ) async {
    final localModels = box.values.toList();

    // Pour chaque document distant
    for (final remote in remoteFavorites) {
      final storageKey = remote.storageKey;
      final local = box.get(storageKey);

      if (local == null) {
        await box.put(storageKey, remote);
      } else {
        final remoteDate = _parseDate(remote.updatedAt);
        final localDate = _parseDate(local.updatedAt);

        if (localDate.isAfter(remoteDate)) {
          // Local plus ressent
          await _remoteDataSource.addFavorite(userId, local);
        } else if (remoteDate.isAfter(localDate)) {
          // Cloud plus ressent
          await box.put(storageKey, remote);
        }
      }
    }

    // Pousser les favoris locaux exclusifs au device (n'ont pas encore été synchronisés)
    for (final local in localModels) {
      final existsInCloud = remoteFavorites.any(
        (r) => r.storageKey == local.storageKey,
      );
      if (!existsInCloud) {
        await _remoteDataSource.addFavorite(userId, local);
      }
    }
  }
}

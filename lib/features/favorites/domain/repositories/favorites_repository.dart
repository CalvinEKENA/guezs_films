import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/favorite_movie.dart';

/// Interface du repository pour la gestion des favoris ("Ma Liste")
abstract class FavoritesRepository {
  /// Ajoute un contenu aux favoris
  Future<Either<Failure, void>> addFavorite(FavoriteMovie content);

  /// Retire un contenu des favoris via son ID et son type
  Future<Either<Failure, void>> removeFavorite({
    required String id,
    required String contentType,
  });

  /// Récupère la liste complète des favoris, triée du plus récent au plus ancien
  Future<Either<Failure, List<FavoriteMovie>>> getFavorites();

  /// Vérifie si un contenu spécifique est dans les favoris
  Future<Either<Failure, bool>> isFavorite({
    required String id,
    required String contentType,
  });

  /// Synchronise les favoris locaux avec le Cloud (fusion par date)
  Future<Either<Failure, void>> syncWithCloud();

  /// S'abonne aux changements temps réel depuis le cloud et met à jour Hive
  Stream<Either<Failure, void>> watchCloudUpdates();
}

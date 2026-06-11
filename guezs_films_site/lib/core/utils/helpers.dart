import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import 'package:intl/intl.dart';

/// Helpers utilitaires globaux pour Guezs Films
class AppHelpers {
  AppHelpers._();

  /// Exécute une requête API de façon sécurisée et convertit les exceptions en [Failure]
  static Future<Either<Failure, T>> safeApiCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Formate une durée (en minutes) au format "Hh MMmin"
  static String formatDuration(int minutes) {
    if (minutes <= 0) return '';
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes.toString().padLeft(2, '0')}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Formate une date (YYYY-MM-DD) au format local (ex: "15 janv. 2024")
  static String formatDate(String dateString, {String locale = 'fr_FR'}) {
    if (dateString.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat.yMMMd(locale).format(date);
    } catch (_) {
      return dateString; // Retourne la chaine d'origine en cas d'erreur de parse
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class ProfileRepository {
  /// Update the user's display name in Firebase Auth
  Future<Either<Failure, void>> updateDisplayName(String name);

  /// Update the user's profile photo URL in Firebase Auth
  Future<Either<Failure, void>> updatePhotoUrl(String photoUrl);

  /// Check if the user has a premium subscription (from Firestore)
  Future<Either<Failure, bool>> isPremium(String userId);

  /// Stream to watch premium status changes
  Stream<bool> watchPremiumStatus(String userId);
}

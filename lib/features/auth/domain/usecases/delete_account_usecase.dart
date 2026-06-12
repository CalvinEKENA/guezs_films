import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import 'delete_account_local_cleanup.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase({
    required FirebaseAuth auth,
    required FirebaseFunctions functions,
  }) : _auth = auth,
       _functions = functions;

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  Future<Either<Failure, void>> execute({
    required AuthCredential credential,
    required bool deleteDownloads,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Aucun utilisateur connecté.'));
      }

      await user.reauthenticateWithCredential(credential);
      await user.getIdToken(true);
      await _functions
          .httpsCallable('deleteMyAccount')
          .call<Map<String, dynamic>>();
      await _auth.signOut();
      await _clearHive(deleteDownloads: deleteDownloads);

      return const Right(null);
    } on FirebaseAuthException catch (error) {
      return Left(
        AuthFailure(
          error.code == 'requires-recent-login'
              ? 'Reconnectez-vous avant de supprimer votre compte.'
              : 'Votre identité n’a pas pu être confirmée.',
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      return Left(
        ServerFailure(
          error.code == 'failed-precondition'
              ? 'Reconnectez-vous avant de supprimer votre compte.'
              : 'La suppression du compte n’a pas pu être terminée.',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure('La suppression du compte n’a pas pu être terminée.'),
      );
    }
  }

  Future<void> _clearHive({required bool deleteDownloads}) async {
    if (Hive.isBoxOpen(AppConstants.favoritesBox)) {
      await Hive.box(AppConstants.favoritesBox).clear();
    }
    if (Hive.isBoxOpen(AppConstants.searchHistoryBox)) {
      await Hive.box(AppConstants.searchHistoryBox).clear();
    }
    if (Hive.isBoxOpen(AppConstants.downloadBox)) {
      if (deleteDownloads) {
        final box = Hive.box(AppConstants.downloadBox);
        await deleteLocalDownloadFiles(box.values);
      }
      await Hive.box(AppConstants.downloadBox).clear();
    }
  }
}

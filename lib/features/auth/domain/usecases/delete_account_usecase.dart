import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import 'delete_account_local_cleanup.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase({
    required AuthRepository authRepository,
    required FirebaseFirestore firestore,
  }) : _authRepository = authRepository,
       _firestore = firestore;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  Future<Either<Failure, void>> execute({
    required AuthCredential credential,
    required bool deleteDownloads,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const Left(AuthFailure('No authenticated user'));

      // TODO: Move full user data deletion to an idempotent admin Cloud Function.
      // 1. Supprimer le compte Firebase Auth EN PREMIER (irréversible — doit réussir avant tout nettoyage)
      final result = await _authRepository.deleteAccount(credential);
      if (result.isLeft()) return result; // propagate failure

      // 2. Nettoyage Firestore (best-effort — compte déjà supprimé)
      await _deleteSubcollection(uid, 'favorites');
      await _deleteSubcollection(uid, 'profiles');
      await _firestore.collection('users').doc(uid).delete();

      // 3. Vider Hive local
      await _clearHive(deleteDownloads: deleteDownloads);

      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _deleteSubcollection(String uid, String collection) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(collection)
          .get();

      // Firestore batch limit: 500 writes per commit
      const batchSize = 500;
      for (var i = 0; i < snapshot.docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final chunk = snapshot.docs.skip(i).take(batchSize);
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (_) {
      // Best-effort cleanup — account already deleted, ignore Firestore errors
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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase({
    required AuthRepository authRepository,
    required FirebaseFirestore firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore;

  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  Future<void> execute({
    required AuthCredential credential,
    required bool deleteDownloads,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user');

    // 1. Supprimer le compte Firebase Auth EN PREMIER (irréversible — doit réussir avant tout nettoyage)
    final result = await _authRepository.deleteAccount(credential);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );

    // 2. Nettoyage Firestore (best-effort — compte déjà supprimé)
    await _deleteSubcollection(uid, 'favorites');
    await _deleteSubcollection(uid, 'profiles');
    await _firestore.collection('users').doc(uid).delete();

    // 3. Vider Hive local
    await _clearHive(deleteDownloads: deleteDownloads);
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
        for (final item in box.values) {
          try {
            final dynamic d = item;
            // localPath is the field name in DownloadItemModel (HiveField(4))
            final path = d.localPath as String?;
            if (path != null && path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) await file.delete();
            }
          } catch (_) {}
        }
      }
      await Hive.box(AppConstants.downloadBox).clear();
    }
  }
}

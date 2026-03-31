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

    // 1. Supprimer subcollections Firestore
    await _deleteSubcollection(uid, 'favorites');
    await _deleteSubcollection(uid, 'profiles');

    // 2. Supprimer le document utilisateur racine
    await _firestore.collection('users').doc(uid).delete();

    // 3. Vider les boîtes Hive locales
    await _clearHive(deleteDownloads: deleteDownloads);

    // 4. Supprimer le compte Firebase Auth (inclut re-auth)
    final result = await _authRepository.deleteAccount(credential);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );
  }

  Future<void> _deleteSubcollection(String uid, String collection) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection(collection)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    if (snapshot.docs.isNotEmpty) await batch.commit();
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

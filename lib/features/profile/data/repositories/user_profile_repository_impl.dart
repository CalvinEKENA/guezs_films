import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _ref(String userId) =>
      _firestore.collection('users').doc(userId).collection('profiles');

  @override
  Stream<List<UserProfileEntity>> watchProfiles(String userId) {
    return _ref(userId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserProfileModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<UserProfileEntity> createProfile({
    required String userId,
    required String name,
    required String emoji,
    required int colorIndex,
    required bool isKids,
  }) async {
    final docRef = _ref(userId).doc();
    final model = UserProfileModel(
      id: docRef.id,
      name: name,
      emoji: emoji,
      colorIndex: colorIndex,
      isKids: isKids,
      createdAt: DateTime.now(),
    );
    await docRef.set(model.toFirestore());
    return model;
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String profileId,
    required String name,
    required String emoji,
    required int colorIndex,
    required bool isKids,
  }) async {
    await _ref(userId).doc(profileId).update({
      'name': name,
      'emoji': emoji,
      'colorIndex': colorIndex,
      'isKids': isKids,
    });
  }

  @override
  Future<void> deleteProfile({
    required String userId,
    required String profileId,
  }) async {
    await _ref(userId).doc(profileId).delete();
  }
}

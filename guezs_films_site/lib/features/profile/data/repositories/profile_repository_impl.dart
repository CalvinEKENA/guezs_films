import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<Either<Failure, void>> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Left(ServerFailure('Utilisateur non connecté'));

      await user.updateDisplayName(name);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors du changement de nom : $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhotoUrl(String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Left(ServerFailure('Utilisateur non connecté'));

      await user.updatePhotoURL(photoUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors du changement d\'avatar : $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isPremium(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return const Right(false);
      
      final data = doc.data() as Map<String, dynamic>;
      return Right(data['isPremium'] == true);
    } catch (e) {
      return Left(ServerFailure('Impossible d\'accéder au statut premium'));
    }
  }

  @override
  Stream<bool> watchPremiumStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final data = doc.data() as Map<String, dynamic>;
          return data['isPremium'] == true;
        });
  }
}

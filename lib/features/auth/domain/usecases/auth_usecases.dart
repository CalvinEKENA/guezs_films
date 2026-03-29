import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  final AuthRepository _repository;

  SignInWithEmailAndPassword(this._repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

class SignUpWithEmailAndPassword {
  final AuthRepository _repository;

  SignUpWithEmailAndPassword(this._repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<Either<Failure, UserEntity>> execute() {
    return _repository.signInWithGoogle();
  }
}

class SignInWithApple {
  final AuthRepository _repository;

  SignInWithApple(this._repository);

  Future<Either<Failure, UserEntity>> execute() {
    return _repository.signInWithApple();
  }
}

class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<Either<Failure, void>> execute() {
    return _repository.signOut();
  }
}

class GetAuthStateChanges {
  final AuthRepository _repository;

  GetAuthStateChanges(this._repository);

  Stream<UserEntity?> execute() {
    return _repository.authStateChanges;
  }
}

class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  UserEntity? execute() {
    return _repository.currentUser;
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/errors/exceptions.dart';
import '../../presentation/providers/auth_error_mapper.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserCredential> signInWithGoogle();

  Future<UserCredential> signInWithApple();

  Future<void> signOut();

  Future<void> deleteAccount(AuthCredential credential);

  Stream<User?> get authStateChanges;

  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(AuthErrorMapper.map(e.code, e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null) {
        await credential.user?.updateDisplayName(displayName);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw ServerException(AuthErrorMapper.map(e.code, e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Flux natif Firebase pour le Web (évite les erreurs de redirect_uri_mismatch)
        final provider = GoogleAuthProvider();
        return await _firebaseAuth.signInWithPopup(provider);
      }

      // Configuration de base pour Google Sign-In (Mobile)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '682820949159-vo9talk0vd4mmkofqd5d57m55m0o0nk3.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled — not an error, just return silently
        throw CancelledException();
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on CancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        throw CancelledException();
      }
      throw ServerException(AuthErrorMapper.map(e.code, e.message));
    } catch (e) {
      throw ServerException(AuthErrorMapper.map('unknown', e.toString()));
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    try {
      if (kIsWeb) {
        // Flux natif Firebase pour le Web (évite les erreurs de type JSObject)
        final provider = AppleAuthProvider();
        provider.addScope('email');
        provider.addScope('name');
        return await _firebaseAuth.signInWithPopup(provider);
      }

      // Flux natif pour Android/iOS
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      final user = userCredential.user;

      // Apple n'envoie le nom qu'à la première connexion — on l'enregistre si absent
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        final name = [appleCredential.givenName, appleCredential.familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (name.isNotEmpty) {
          await user.updateDisplayName(name);
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        throw CancelledException();
      }
      throw ServerException(AuthErrorMapper.map(e.code, e.message));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw CancelledException();
      }
      throw ServerException(AuthErrorMapper.map('apple-auth-error', e.message));
    } catch (e) {
      throw ServerException(AuthErrorMapper.map('unknown', e.toString()));
    }
  }

  /// Génère une chaîne aléatoire sécurisée pour le nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash SHA-256 du nonce (requis par Apple)
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount(AuthCredential credential) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw ServerException('Aucun utilisateur authentifié');
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw ServerException(AuthErrorMapper.map(e.code, e.message));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}

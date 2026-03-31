import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/errors/exceptions.dart';

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
      throw ServerException(e.message ?? 'Erreur d\'authentification');
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
      throw ServerException(e.message ?? 'Erreur d\'inscription');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        throw ServerException('Connexion Google annulée');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Erreur de connexion Google');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserCredential> signInWithApple() async {
    try {
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
    } on SignInWithAppleAuthorizationException catch (e) {
      throw ServerException(e.message);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Erreur Apple Sign-In');
    } catch (e) {
      throw ServerException(e.toString());
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
    final user = _firebaseAuth.currentUser;
    if (user == null) throw StateError('No authenticated user');
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}

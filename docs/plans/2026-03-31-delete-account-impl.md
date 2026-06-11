# Delete Account Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Permettre à l'utilisateur de supprimer définitivement son compte et toutes ses données depuis la page Profil (conformité Play Store).

**Architecture:** Use case `DeleteAccountUseCase` dans la couche domaine orchestre la suppression Firestore → Hive → Firebase Auth. L'`AuthController` expose `deleteAccount()`. La page Profil déclenche 3 dialogs séquentiels (re-auth → downloads → confirmation).

**Tech Stack:** Flutter, Riverpod, Firebase Auth, Cloud Firestore, Hive, google_sign_in, sign_in_with_apple

---

## Task 1 : Ajouter `deleteAccount` à la couche Data Source

**Files:**
- Modify: `lib/features/auth/data/datasources/auth_remote_data_source.dart`

**Step 1: Ajouter la signature dans l'interface abstraite**

Trouver la classe `FirebaseAuthRemoteDataSource` (ou équivalent abstrait) et ajouter :
```dart
Future<void> deleteAccount(AuthCredential credential);
```

**Step 2: Implémenter dans `AuthRemoteDataSourceImpl`**

```dart
@override
Future<void> deleteAccount(AuthCredential credential) async {
  final user = _firebaseAuth.currentUser;
  if (user == null) throw StateError('No authenticated user');
  await user.reauthenticateWithCredential(credential);
  await user.delete();
}
```

**Step 3: Vérifier compilation**
```bash
flutter analyze lib/features/auth/data/datasources/auth_remote_data_source.dart
```
Expected: no errors

**Step 4: Commit**
```bash
git add lib/features/auth/data/datasources/auth_remote_data_source.dart
git commit -m "feat(auth): add deleteAccount to remote data source"
```

---

## Task 2 : Propager dans le Repository

**Files:**
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Step 1: Ajouter dans l'interface domaine**

Dans `auth_repository.dart`, ajouter :
```dart
Future<void> deleteAccount(AuthCredential credential);
```

**Step 2: Implémenter dans `auth_repository_impl.dart`**

```dart
@override
Future<void> deleteAccount(AuthCredential credential) =>
    _remoteDataSource.deleteAccount(credential);
```

**Step 3: Vérifier compilation**
```bash
flutter analyze lib/features/auth/
```
Expected: no errors

**Step 4: Commit**
```bash
git add lib/features/auth/domain/repositories/auth_repository.dart \
        lib/features/auth/data/repositories/auth_repository_impl.dart
git commit -m "feat(auth): propagate deleteAccount through repository layer"
```

---

## Task 3 : Créer `DeleteAccountUseCase`

**Files:**
- Create: `lib/features/auth/domain/usecases/delete_account_usecase.dart`

**Step 1: Créer le fichier**

```dart
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
    await _authRepository.deleteAccount(credential);
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
    // Vider favoris locaux
    if (Hive.isBoxOpen(AppConstants.favoritesBox)) {
      await Hive.box(AppConstants.favoritesBox).clear();
    }
    // Vider historique de recherche
    if (Hive.isBoxOpen(AppConstants.searchHistoryBox)) {
      await Hive.box(AppConstants.searchHistoryBox).clear();
    }
    // Vider downloads (métadonnées + fichiers optionnels)
    if (Hive.isBoxOpen(AppConstants.downloadBox)) {
      if (deleteDownloads) {
        // Supprimer les fichiers physiques avant de vider la box
        final box = Hive.box(AppConstants.downloadBox);
        for (final item in box.values) {
          try {
            // DownloadItemModel a un champ localPath
            final dynamic d = item;
            if (d.localPath != null && d.localPath.toString().isNotEmpty) {
              final file = File(d.localPath as String);
              if (await file.exists()) await file.delete();
            }
          } catch (_) {
            // Ignorer si le fichier n'existe pas
          }
        }
      }
      await Hive.box(AppConstants.downloadBox).clear();
    }
  }
}
```

> **Note:** Ajouter `import 'dart:io';` en tête du fichier pour `File`.

**Step 2: Vérifier compilation**
```bash
flutter analyze lib/features/auth/domain/usecases/delete_account_usecase.dart
```

**Step 3: Commit**
```bash
git add lib/features/auth/domain/usecases/delete_account_usecase.dart
git commit -m "feat(auth): add DeleteAccountUseCase"
```

---

## Task 4 : Exposer dans `AuthController` (Riverpod)

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_providers.dart`

**Step 1: Ajouter un provider pour le use case**

Dans la section providers, ajouter (après les providers existants) :
```dart
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    firestore: FirebaseFirestore.instance,
  );
});
```

**Step 2: Ajouter la méthode dans `AuthController`**

Dans la classe `AuthController` (ou `AuthNotifier`), ajouter :
```dart
Future<void> deleteAccount({
  required AuthCredential credential,
  required bool deleteDownloads,
}) async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() =>
    ref.read(deleteAccountUseCaseProvider).execute(
      credential: credential,
      deleteDownloads: deleteDownloads,
    ),
  );
}
```

**Step 3: Vérifier compilation**
```bash
flutter analyze lib/features/auth/presentation/providers/auth_providers.dart
```

**Step 4: Commit**
```bash
git add lib/features/auth/presentation/providers/auth_providers.dart
git commit -m "feat(auth): expose deleteAccount in AuthController"
```

---

## Task 5 : UI dans `profile_page.dart`

**Files:**
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

### 5a — Bouton "Supprimer mon compte"

Localiser le bouton "Se déconnecter" et ajouter juste en dessous :

```dart
const SizedBox(height: 12),
OutlinedButton.icon(
  icon: const Icon(Icons.delete_forever_rounded, size: 18),
  label: const Text('Supprimer mon compte'),
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.error,
    side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
    minimumSize: const Size(double.infinity, 48),
  ),
  onPressed: () => _startDeleteAccountFlow(context, ref),
),
```

### 5b — Méthode principale `_startDeleteAccountFlow`

```dart
Future<void> _startDeleteAccountFlow(BuildContext context, WidgetRef ref) async {
  // Étape 1 : Re-authentification
  final credential = await _showReauthDialog(context);
  if (credential == null || !context.mounted) return;

  // Étape 2 : Choix des téléchargements
  final deleteDownloads = await _showDeleteDownloadsDialog(context);
  if (deleteDownloads == null || !context.mounted) return;

  // Étape 3 : Confirmation finale
  final confirmed = await _showFinalConfirmationSheet(context);
  if (!confirmed || !context.mounted) return;

  // Exécution
  try {
    await ref.read(authControllerProvider.notifier).deleteAccount(
      credential: credential,
      deleteDownloads: deleteDownloads,
    );
    if (context.mounted) context.go(Routes.login);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mapDeleteError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
```

### 5c — Dialog re-authentification

```dart
Future<AuthCredential?> _showReauthDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final providerId = user.providerData.isNotEmpty
      ? user.providerData.first.providerId
      : 'password';

  if (providerId == 'google.com') {
    return _reauthWithGoogle();
  } else if (providerId == 'apple.com') {
    return _reauthWithApple();
  } else {
    return _showEmailReauthDialog(context, user.email ?? '');
  }
}

Future<AuthCredential?> _showEmailReauthDialog(
  BuildContext context, String email) async {
  final passwordController = TextEditingController();
  AuthCredential? credential;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Confirmez votre identité',
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Entrez votre mot de passe pour continuer.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () {
            credential = EmailAuthProvider.credential(
              email: email,
              password: passwordController.text.trim(),
            );
            Navigator.of(ctx).pop();
          },
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );

  passwordController.dispose();
  return credential;
}

Future<AuthCredential?> _reauthWithGoogle() async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final auth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
  } catch (_) {
    return null;
  }
}

Future<AuthCredential?> _reauthWithApple() async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return oauthCredential;
  } catch (_) {
    return null;
  }
}
```

### 5d — Dialog choix téléchargements

```dart
Future<bool?> _showDeleteDownloadsDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Fichiers téléchargés',
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        'Voulez-vous aussi supprimer vos fichiers téléchargés sur cet appareil ?',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Non, garder les fichiers'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Oui, tout supprimer'),
        ),
      ],
    ),
  );
}
```

### 5e — Bottom sheet confirmation finale

```dart
Future<bool> _showFinalConfirmationSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Suppression définitive',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cette action est irréversible. Votre compte, vos profils et vos favoris seront définitivement supprimés.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Supprimer définitivement',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
```

### 5f — Mapping d'erreurs

```dart
String _mapDeleteError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe incorrect.';
      case 'network-request-failed':
        return 'Vérifiez votre connexion internet.';
      case 'user-not-found':
        return 'Compte introuvable.';
      default:
        return 'Erreur : ${e.message}';
    }
  }
  return 'Une erreur est survenue. Réessayez.';
}
```

### 5g — Imports à ajouter en tête de `profile_page.dart`

```dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
```

**Step final: Vérifier compilation complète**
```bash
flutter analyze lib/features/profile/presentation/pages/profile_page.dart
flutter analyze lib/
```

**Step Commit:**
```bash
git add lib/features/profile/presentation/pages/profile_page.dart
git commit -m "feat(profile): add delete account flow with reauth + confirmation"
```

---

## Task 6 : Vérification end-to-end

**Step 1:** Lancer l'app : `flutter run`

**Step 2:** Aller sur Profil → scroller jusqu'en bas → vérifier que le bouton "Supprimer mon compte" est visible sous "Se déconnecter"

**Step 3:** Taper sur "Supprimer mon compte" → vérifier que le dialog de re-auth apparaît

**Step 4:** Entrer le mot de passe → vérifier le dialog téléchargements

**Step 5:** Choisir → vérifier le bottom sheet de confirmation finale

**Step 6:** Confirmer → vérifier que l'app redirige vers la page de login

**Step 7:** Vérifier dans Firebase Console :
- Authentication → l'utilisateur n'existe plus
- Firestore → `/users/{uid}` et subcollections supprimés

**Step 8:** Commit final si tout fonctionne
```bash
git add -A
git commit -m "feat: account deletion flow complete (Play Store compliance)"
```

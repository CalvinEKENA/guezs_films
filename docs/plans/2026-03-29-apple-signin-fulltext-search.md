# Apple Sign-In + Full-text Search Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implémenter Apple Sign-In (chaîne Clean Architecture complète) et remplacer la recherche Firestore par préfixe par une recherche full-text via tokens `arrayContains`.

**Architecture:**
- Apple Sign-In : nonce SHA-256 → `sign_in_with_apple` → Firebase `OAuthProvider('apple.com')` → même flux que Google Sign-In déjà en place.
- Full-text Search : Cloud Function Node.js génère `searchTokens[]` (préfixes de chaque mot) à chaque write Firestore. Flutter interroge avec `arrayContains(query.toLowerCase())`.

**Tech Stack:** Flutter, `sign_in_with_apple ^6.1.3`, `crypto ^3.0.3`, Firebase Auth, Firebase Functions (Node.js 20), Cloud Firestore `arrayContains`

---

## Fichiers clés à lire avant de commencer

- `lib/features/auth/data/datasources/auth_remote_data_source.dart` — modèle de signInWithGoogle à reproduire pour Apple
- `lib/features/auth/domain/usecases/auth_usecases.dart` — pattern use case existant
- `lib/features/auth/domain/repositories/auth_repository.dart` — interface à étendre
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — implémentation à étendre
- `lib/features/auth/presentation/providers/auth_providers.dart` — pattern provider + AuthController
- `lib/features/auth/presentation/pages/login_page.dart` — ligne ~340 : TODO Apple sign in
- `lib/core/data/firebase_content_datasource.dart` — méthodes searchFilms/searchSeries à remplacer
- `pubspec.yaml` — dépendances à ajouter

---

## TASK 1 — Ajouter les packages

**Fichier:** `pubspec.yaml`

### Step 1: Ajouter sign_in_with_apple et crypto dans pubspec.yaml

Sous la section `# Firebase`, ajouter :
```yaml
sign_in_with_apple: ^6.1.3
crypto: ^3.0.3
```

### Step 2: Installer les packages

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter pub get 2>&1
```
Attendu : `Got dependencies!`

### Step 3: Vérifier l'analyse

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze 2>&1
```
Attendu : `No issues found!`

### Step 4: Commit

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add sign_in_with_apple and crypto packages"
```

---

## TASK 2 — Apple Sign-In : Data Source

**Fichiers:**
- Modify: `lib/features/auth/data/datasources/auth_remote_data_source.dart`

### Step 1: Ajouter les imports nécessaires en tête du fichier

```dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
```

### Step 2: Ajouter `signInWithApple()` à la classe abstraite

Dans la classe abstraite `AuthRemoteDataSource`, ajouter après `signInWithGoogle()` :
```dart
Future<UserEntity> signInWithApple();
```

### Step 3: Implémenter `signInWithApple()` dans `AuthRemoteDataSourceImpl`

Ajouter après l'implémentation de `signInWithGoogle()` :

```dart
@override
Future<UserEntity> signInWithApple() async {
  // 1. Générer un nonce aléatoire
  final rawNonce = _generateNonce();
  final nonce = _sha256ofString(rawNonce);

  // 2. Obtenir les credentials Apple
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );

  // 3. Créer le credential Firebase OAuth
  final oAuthCredential = OAuthProvider('apple.com').credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  // 4. Connecter à Firebase
  final userCredential =
      await _firebaseAuth.signInWithCredential(oAuthCredential);
  final user = userCredential.user;
  if (user == null) throw Exception('Apple Sign-In échoué');

  return UserEntity(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ??
        [appleCredential.givenName, appleCredential.familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' '),
    photoUrl: user.photoURL,
  );
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
```

### Step 4: Vérifier la compilation

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze lib/features/auth/data/datasources/auth_remote_data_source.dart 2>&1
```
Attendu : `No issues found!`

---

## TASK 3 — Apple Sign-In : Repository + Use Case

**Fichiers:**
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Modify: `lib/features/auth/domain/usecases/auth_usecases.dart`

### Step 1: Ajouter `signInWithApple()` à l'interface du repository

Dans `auth_repository.dart`, ajouter après `signInWithGoogle()` :
```dart
Future<UserEntity> signInWithApple();
```

### Step 2: Implémenter dans `auth_repository_impl.dart`

Ajouter après `signInWithGoogle()` :
```dart
@override
Future<UserEntity> signInWithApple() async {
  final result = await _remoteDataSource.signInWithApple();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
}
```

**Note :** si le repository utilise `Either` (dartz), adapter le pattern selon le code existant. Sinon utiliser directement `return await _remoteDataSource.signInWithApple();`

### Step 3: Ajouter le Use Case dans `auth_usecases.dart`

Ajouter à la fin du fichier :
```dart
class SignInWithApple {
  final AuthRepository repository;
  const SignInWithApple(this.repository);

  Future<UserEntity> call() async {
    return repository.signInWithApple();
  }
}
```

### Step 4: Vérifier

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze lib/features/auth/ 2>&1
```
Attendu : `No issues found!`

---

## TASK 4 — Apple Sign-In : Provider + Controller

**Fichier:** `lib/features/auth/presentation/providers/auth_providers.dart`

### Step 1: Ajouter le provider du use case

Après `signInWithGoogleUseCaseProvider`, ajouter :
```dart
final signInWithAppleUseCaseProvider = Provider<SignInWithApple>((ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
});
```

### Step 2: Ajouter `signInWithApple()` dans `AuthController`

Après la méthode `signInWithGoogle()`, ajouter :
```dart
Future<void> signInWithApple() async {
  state = const AsyncLoading();
  try {
    final useCase = _read(signInWithAppleUseCaseProvider);
    final user = await useCase();
    state = AsyncData(user);
  } catch (e, st) {
    state = AsyncError(e, st);
  }
}
```

### Step 3: Vérifier

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze lib/features/auth/presentation/providers/auth_providers.dart 2>&1
```
Attendu : `No issues found!`

### Step 4: Commit

```bash
git add lib/features/auth/
git commit -m "feat: Apple Sign-In - datasource, repository, usecase, provider"
```

---

## TASK 5 — Apple Sign-In : Câblage UI

**Fichier:** `lib/features/auth/presentation/pages/login_page.dart`

### Step 1: Remplacer le TODO par l'appel réel

Chercher :
```dart
assetPath: 'assets/icons/apple.png',
onTap: () {
  // TODO: Apple sign in
},
```

Remplacer par :
```dart
assetPath: 'assets/icons/apple.png',
onTap: () {
  ref.read(authControllerProvider.notifier).signInWithApple();
},
```

### Step 2: Vérifier

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze lib/features/auth/presentation/pages/login_page.dart 2>&1
```
Attendu : `No issues found!`

### Step 3: Analyse complète

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze 2>&1
```
Attendu : `No issues found!`

### Step 4: Commit

```bash
git add lib/features/auth/presentation/pages/login_page.dart
git commit -m "feat: wire Apple Sign-In button in login_page"
```

---

## TASK 6 — Full-text Search : Cloud Function

**Fichiers à créer:**
- `functions/package.json`
- `functions/index.js`

### Step 1: Créer le dossier functions et package.json

Créer `functions/package.json` :
```json
{
  "name": "guezs-films-functions",
  "description": "Cloud Functions for Guezs Films",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions"
  },
  "engines": {
    "node": "20"
  },
  "main": "index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^5.0.0"
  },
  "private": true
}
```

### Step 2: Créer `functions/index.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Génère les tokens de recherche à partir d'un titre.
 * Chaque mot du titre est décomposé en tous ses préfixes (min 2 chars).
 * Ex: "Black Panther" → ["bl","bla","blac","black","pa","pan","pant","panther","black panther"]
 */
function generateSearchTokens(title) {
  if (!title || typeof title !== 'string') return [];
  const tokens = new Set();
  const normalized = title.toLowerCase().trim();
  const words = normalized.split(/\s+/);

  for (const word of words) {
    if (word.length < 2) continue;
    for (let i = 2; i <= word.length; i++) {
      tokens.add(word.substring(0, i));
    }
    tokens.add(word);
  }

  // Ajouter le titre complet normalisé
  tokens.add(normalized);

  return Array.from(tokens);
}

/**
 * Déclencheur Firestore : génère searchTokens sur write de films
 */
exports.generateFilmSearchTokens = functions.firestore
  .document('films/{filmId}')
  .onWrite(async (change) => {
    if (!change.after.exists) return null; // document supprimé
    const data = change.after.data();
    if (!data || !data.title) return null;

    const tokens = generateSearchTokens(data.title);

    // Éviter une boucle infinie : ne mettre à jour que si les tokens ont changé
    const existing = (data.searchTokens || []).slice().sort().join(',');
    const computed = tokens.slice().sort().join(',');
    if (existing === computed) return null;

    return change.after.ref.update({ searchTokens: tokens });
  });

/**
 * Déclencheur Firestore : génère searchTokens sur write de séries
 */
exports.generateSeriesSearchTokens = functions.firestore
  .document('series/{seriesId}')
  .onWrite(async (change) => {
    if (!change.after.exists) return null;
    const data = change.after.data();
    if (!data || !data.title) return null;

    const tokens = generateSearchTokens(data.title);

    const existing = (data.searchTokens || []).slice().sort().join(',');
    const computed = tokens.slice().sort().join(',');
    if (existing === computed) return null;

    return change.after.ref.update({ searchTokens: tokens });
  });
```

### Step 3: Mettre à jour firebase.json pour déclarer les functions

Dans `firebase.json`, ajouter (ou compléter) :
```json
{
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": ["node_modules", ".git"]
    }
  ]
}
```

### Step 4: Commit les functions

```bash
git add functions/ firebase.json
git commit -m "feat: Cloud Functions search tokens generator (films + series)"
```

---

## TASK 7 — Full-text Search : Flutter datasource

**Fichier:** `lib/core/data/firebase_content_datasource.dart`

### Step 1: Remplacer `searchFilms()` par la requête arrayContains

Chercher la méthode `searchFilms` et remplacer son corps :
```dart
Future<List<FilmModel>> searchFilms(String query) async {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return const [];

  final snapshot = await _filmsCollection
      .where('searchTokens', arrayContains: normalizedQuery)
      .get();

  return snapshot.docs
      .map(FilmModel.fromFirestore)
      .toList(growable: false);
}
```

### Step 2: Remplacer `searchSeries()` par la requête arrayContains

```dart
Future<List<SeriesModel>> searchSeries(String query) async {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return const [];

  final snapshot = await _seriesCollection
      .where('searchTokens', arrayContains: normalizedQuery)
      .get();

  return snapshot.docs
      .map(SeriesModel.fromFirestore)
      .toList(growable: false);
}
```

### Step 3: Vérifier

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze lib/core/data/firebase_content_datasource.dart 2>&1
```
Attendu : `No issues found!`

### Step 4: Analyse globale

```bash
cd C:/projets/FlutterProjects/guezs_films && flutter analyze 2>&1
```
Attendu : `No issues found!`

### Step 5: Commit

```bash
git add lib/core/data/firebase_content_datasource.dart
git commit -m "feat: full-text search via Firestore arrayContains searchTokens"
```

---

## TASK 8 — Déploiement des Cloud Functions

### Step 1: Installer les dépendances Node.js

```bash
cd C:/projets/FlutterProjects/guezs_films/functions && npm install 2>&1
```
Attendu : packages firebase-admin et firebase-functions installés.

### Step 2: Déployer les functions

```bash
cd C:/projets/FlutterProjects/guezs_films && firebase deploy --only functions 2>&1
```
Attendu : `✔ Deploy complete!` avec les 2 functions listées.

**Note :** Nécessite d'être connecté à Firebase CLI (`firebase login`). Si le projet utilise le plan Spark (gratuit), les Cloud Functions ne sont pas disponibles — passer au plan Blaze (pay-as-you-go, coût négligeable pour un petit catalogue).

---

## Notes importantes

### Apple Sign-In — Configuration requise avant mise en production
1. Créer un Apple Developer account
2. Enregistrer le Bundle ID de l'app dans Apple Developer Console
3. Activer "Sign In with Apple" dans les capabilities de l'app (Xcode)
4. Activer le provider Apple dans Firebase Console → Authentication → Sign-in providers
5. **Le code fonctionnera dès ces étapes complétées — aucun changement de code supplémentaire requis.**

### Full-text Search — Tokenisation des données existantes
Quand tu ajoutes un film dans Firestore Console, la Cloud Function se déclenche automatiquement et génère les `searchTokens`. Pour les documents ajoutés avant le déploiement de la function, les tokens seront générés lors du prochain update du document.

### Ordre d'implémentation recommandé
1. Task 1 (packages) → Task 2 → Task 3 → Task 4 → Task 5 (Apple Sign-In complet)
2. Task 6 → Task 7 → Task 8 (Full-text Search complet)

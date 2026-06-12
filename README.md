# GUEZS FILMS

Application Flutter de streaming cinéma premium, conçue pour mobile et Web.

Ce dépôt regroupe désormais deux surfaces complémentaires:

- `films.guezs-house.com`: application Flutter GUEZS FILMS;
- `guezs-house.com`: site institutionnel Next.js situé dans `guezs_house_web/`.

Le produit couvre actuellement:

- catalogue films et séries;
- recherche et découverte éditoriale;
- pages détails responsives;
- routes de lecture `/watch/...`;
- contrôle d'accès par règles, entitlements et codes hashés;
- player premium avec reprise locale;
- favoris synchronisés;
- profils utilisateur;
- téléchargements hors-ligne mobiles;
- interface adaptive mobile, tablette et desktop.

## Stack

- Flutter 3.38+ et Dart 3.10+;
- Riverpod 2;
- GoRouter;
- Firebase Auth;
- Cloud Firestore;
- Cloud Functions Node.js 20;
- Firebase Storage;
- Hive et SharedPreferences;
- `video_player`;
- Firebase Hosting pour la SPA Web.

## Prérequis

- Flutter stable configuré;
- Android SDK et Java 17 pour Android;
- Chrome pour le Web;
- Node.js 20 et npm;
- Firebase CLI;
- accès au projet Firebase cible;
- macOS et Xcode pour construire iOS.

Vérification:

```powershell
flutter doctor -v
firebase --version
```

## Installation

```powershell
git clone <url-du-depot>
cd guezs_films
flutter pub get
```

Configurer Firebase pour chaque plateforme avec FlutterFire:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Les fichiers suivants sont spécifiques au projet Firebase:

- `lib/firebase_options.dart`;
- `android/app/google-services.json`;
- `ios/Runner/GoogleService-Info.plist`.

Les clés Admin Firebase et les fichiers `.env` ne doivent jamais être commités.

## Exécution

Web:

```powershell
flutter run -d chrome
```

Android:

```powershell
flutter run -d <device-id>
```

## Validation

Commandes minimales avant livraison:

```powershell
flutter analyze --no-pub lib test
flutter test --no-pub
flutter build web --release
node --check functions/index.js
Get-ChildItem scripts/admin/*.js | ForEach-Object { node --check $_.FullName }
```

Validation optionnelle Android:

```powershell
flutter build apk --release
```

La signature release Android utilise `android/key.properties`. Le keystore et ses mots de passe doivent rester locaux ou dans un gestionnaire de secrets CI.

## Build et déploiement Web

GUEZS FILMS (`films.guezs-house.com`):

```powershell
flutter build web --release
firebase deploy --only hosting
```

`firebase.json` sert `build/web` et réécrit les chemins vers `index.html`. Les refresh directs fonctionnent donc pour:

- `/home`;
- `/film/:id`;
- `/series/:id`;
- `/watch/film/:filmId`;
- `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`.

Site GUEZS HOUSE (`guezs-house.com`):

```powershell
cd guezs_house_web
npm ci
npm run lint
npm run build
```

L'export statique est généré dans `guezs_house_web/out/`. Le ZIP Hostinger et
les sorties de build sont locaux et ne doivent pas être commités.

## Firebase

Installer les dépendances Functions:

```powershell
cd functions
npm ci
cd ..
```

Lancer les émulateurs:

```powershell
firebase emulators:start --only firestore,functions
```

Déployer:

```powershell
firebase deploy --only firestore:rules,firestore:indexes
firebase deploy --only functions
firebase deploy --only hosting
```

La Function `deleteMyAccount` assure le nettoyage idempotent des données utilisateur et la suppression Firebase Auth après réauthentification récente.

## Accès premium

Le flux de lecture ne doit pas lancer directement `/player` pour un contenu catalogue.

1. Flutter ouvre une route `/watch/...`.
2. `createWatchSession` vérifie Auth, règles et entitlements.
3. `validateAccessCode` traite un code côté serveur.
4. Seul le hash SHA-256 du code normalisé est stocké.
5. Le player reçoit la décision d'accès.

La route legacy `/player` reste réservée aux fichiers téléchargés localement.

Scripts d'administration:

```powershell
cd scripts/admin
npm install
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\chemin\serviceAccountKey.json"

node create_access_code.js --code CODE_PRIVE --contentType film --filmId FILM_ID
node create_content_access_rule.js --contentType film --filmId FILM_ID --accessMode codeRequired
```

Le seed d'accès démo exige une confirmation explicite:

```powershell
node seed_access_demo.js --confirm-demo
```

Voir [FIREBASE_ACCESS_SETUP.md](docs/FIREBASE_ACCESS_SETUP.md) et [VIDEO_SECURITY_STRATEGY.md](docs/VIDEO_SECURITY_STRATEGY.md).

## Scripts de contenu

Les scripts historiques de contenu utilisent une clé Admin locale dans `scripts/serviceAccountKey.json`, ignorée par Git.

Ils publient des médias et sont donc bloqués sans confirmation explicite:

```powershell
cd scripts
npm install
npm run seed:demo
npm run fix:public-images
```

Ils sont destinés à la démonstration ou à la maintenance contrôlée, pas à une chaîne de production publique.

## Limites MVP

- les URLs vidéo durables peuvent encore être présentes dans Firestore;
- `getSignedVideoUrl` n'émet pas encore d'URL CDN/Storage courte;
- pas de DRM;
- App Check n'est pas encore imposé;
- qualité, sous-titres et pistes audio ne sont pas encore sélectionnables;
- progression non synchronisée entre appareils;
- préférences profil partiellement locales ou informatives;
- pas de paiement;
- tests Firebase d'autorisation encore limités à la validation de chargement des rules;
- build iOS non validable depuis Windows.

Ces limites sont compatibles avec une démonstration sérieuse et une bêta privée contrôlée. Les URLs signées, App Check, la télémétrie et les tests d'intégration Firebase sont requis avant une production publique premium.

## Roadmap

1. URLs signées courtes ou CDN signé.
2. HLS/DASH multi-bitrate.
3. Sous-titres et pistes audio réels.
4. App Check et limitation des tentatives de code.
5. Analytics de lecture, buffer et conversion.
6. Synchronisation cloud de la progression et des préférences.
7. Tests d'intégration Firebase et mobile.
8. Pipeline CI/CD avec signature et déploiements séparés.

## Documentation

- [P10 Final QA](docs/P10_FINAL_QA_REPORT.md)
- [Release Readiness Checklist](docs/RELEASE_READINESS_CHECKLIST.md)
- [Design tokens](docs/DESIGN_TOKENS_GUEZS_FILMS.md)
- [Player UX](docs/PLAYER_UX.md)
- [Search UX](docs/SEARCH_UX.md)
- [Schéma d'accès](docs/FIRESTORE_ENTITLEMENT_SCHEMA.md)

## Sous-projet historique

`guezs_films_site/` est une ancienne copie Web du projet principal. Ses assets utiles ont été réintégrés dans la racine. Il doit rester gelé temporairement, puis être archivé dans une branche ou un tag et retiré du tronc principal après validation de l'équipe.

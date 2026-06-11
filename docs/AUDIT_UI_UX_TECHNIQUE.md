# Audit UI/UX et technique - Guezs Films

Date de l'audit: 2026-06-11  
Depot audite: `C:\projets\FlutterProjects\guezs_films`  
Objectif produit: application de streaming premium mobile Android/iOS et Web pour films et series africains.

## Resume executif

Le projet a une base fonctionnelle interessante: Flutter, Riverpod, `go_router`, Firebase Auth/Firestore, Hive, ecrans principaux de streaming, favoris, profils, telechargements et player video. L'intention premium est visible dans le theme sombre, les visuels, les animations et le parcours catalogue.

L'etat actuel n'est pas encore pret pour une production mobile + Web. Les bloquants principaux sont la compatibilite Web du projet racine, l'acces video non securise, un player encore prototype, un routing fragile pour les liens Web, une duplication complete dans `guezs_films_site`, et des ecrans tres centres mobile avec peu de vraie adaptation desktop/tablette.

Les risques les plus importants pour une app de streaming premium sont:

- `dart:io` importe dans le projet racine, ce qui bloque Flutter Web.
- Le controle d'acces video repose sur un code promo client (`123456`, `654321`) et des URLs Storage publiques.
- Le player lit des MP4 directs, sans pipeline HLS/DASH, DRM, signed URLs, reprise, qualites reelles ou sous-titres effectifs.
- Le routeur du player lit `state.extra`; les refresh/deep links Web et le lancement depuis la page telechargements ne transportent pas correctement `url/title`.
- `guezs_films_site` duplique presque toute l'application avec quelques adaptations Web, ce qui cree deja une derive de code.
- Les grilles, rails, hero sections et navigations sont dimensionnes surtout pour telephone.
- Les tests sont insuffisants: le test principal ne verifie rien de l'app (`expect(true, isTrue)`).

## Architecture actuelle

### Projet principal

- Application Flutter nommee `guezs_films`.
- State management: `flutter_riverpod`.
- Navigation: `go_router`, avec `ShellRoute` pour les onglets principaux.
- Backend: Firebase Core/Auth/Firestore/Storage.
- Stockage local: Hive, SharedPreferences, Flutter Secure Storage declare.
- Player: `video_player`, `chewie` declare mais non utilise dans le player actuel.
- Offline/downloads: `dio`, `path_provider`, `flutter_local_notifications`, Hive.
- UI: theme custom sombre, `GoogleFonts`, widgets `GlassCard`, `GradientButton`, `CachedImage`, shimmers.
- Firebase Functions: generation des `searchTokens` pour films et series.

### Sous-projet imbrique

`guezs_films_site/` est un second projet Flutter complet, tres proche du projet racine, avec quelques corrections Web:

- `player_page.dart` n'importe plus `dart:io`.
- `download_service.dart` neutralise les telechargements sur Web avec `kIsWeb`.
- `login_page.dart` n'utilise plus `Platform`.
- `delete_account_usecase.dart` evite `File` sur Web.

Cette duplication est un risque majeur: les correctifs Web existent dans le sous-projet, mais pas dans le projet principal.

### Backend Firebase

- `firestore.rules`: lecture catalogue limitee aux utilisateurs connectes; ecriture admin via custom claim `admin`.
- `firestore.indexes.json`: indexes pour `films` et `series` sur `isFeatured`, `isNew`, `genres`, `createdAt`, `rating`.
- `functions/index.js`: generation automatique de tokens de recherche sur write.
- Pas de `storage.rules` ni de configuration Hosting dans `firebase.json`.
- Le script `scripts/seed_content.js` upload les medias dans Firebase Storage avec `public: true`.

## Liste des fichiers critiques

| Fichier | Raison critique |
| --- | --- |
| `lib/main.dart` | Initialisation Firebase/Hive, orientation globale, point d'entree app. |
| `lib/core/routes/app_router.dart` | Redirections auth, shell navigation, player via `state.extra`. |
| `lib/features/player/presentation/pages/player_page.dart` | Import `dart:io`, fallback video sample, player custom incomplet. |
| `lib/features/downloads/data/services/download_service.dart` | Import `dart:io`, `path_provider`, notifications, telechargement MP4 direct. |
| `lib/features/auth/presentation/pages/login_page.dart` | Import `dart:io`, usage `Platform`, boutons sociaux conditionnes par OS. |
| `lib/features/auth/domain/usecases/delete_account_usecase.dart` | Import `dart:io`, suppression Auth avant nettoyage Firestore. |
| `lib/core/data/firebase_content_datasource.dart` | Requetes Firestore catalogue, recherche, absence de pagination. |
| `lib/core/widgets/promo_code_dialog.dart` | Gate de lecture client hardcode, contournable. |
| `firestore.rules` | Modele de securite Firestore, pas suffisant pour securiser les medias video. |
| `scripts/seed_content.js` | Rend les fichiers Storage publics et seed les URLs video. |
| `functions/index.js` | Recherche serveur limitee aux tokens de titre. |
| `web/index.html`, `web/manifest.json` | PWA encore generique dans le projet principal. |
| `android/app/src/main/AndroidManifest.xml` | Permissions minimales; notification Android 13 absente. |
| `ios/Runner/Info.plist` | URL scheme Google present; entitlements Apple Sign-In a verifier hors Info.plist. |
| `guezs_films_site/` | Duplication presque complete et derive des correctifs Web. |

## Problemes bloquants

### P0-01 - Flutter Web bloque dans le projet principal

Imports incompatibles Web detectes:

- `lib/features/auth/presentation/pages/login_page.dart`: `import 'dart:io';`, `Platform.isAndroid`, `Platform.isIOS`, `Platform.isWindows`.
- `lib/features/auth/domain/usecases/delete_account_usecase.dart`: `import 'dart:io';`, `File(path)`.
- `lib/features/player/presentation/pages/player_page.dart`: `import 'dart:io';`, `VideoPlayerController.file(File(videoPath))`.
- `lib/features/downloads/data/services/download_service.dart`: `import 'dart:io';`, `Directory`, `File`, `path_provider`.

Correction recommandee:

- Introduire des services par plateforme avec imports conditionnels (`download_service_mobile.dart`, `download_service_web.dart`, `player_source_resolver_mobile.dart`, `player_source_resolver_web.dart`).
- Remplacer `Platform` dans l'UI par `kIsWeb` + `defaultTargetPlatform` ou par une couche `PlatformCapabilities`.
- Reintegrer proprement les corrections deja presentes dans `guezs_films_site`.

### P0-02 - Acces video non securise pour un produit premium

Le code promo est verifie cote client dans `PromoCodeDialog` avec des valeurs fixes. Le script de seed upload des medias Storage en public. Meme si Firestore limite la lecture catalogue aux utilisateurs connectes, l'URL video publique reste partageable.

Correction recommandee:

- Remplacer le code promo client par une logique d'entitlement serveur: abonnement, achat, code promo valide en Cloud Functions, custom claims ou document d'acces signe.
- Ne pas exposer d'URL Storage publique durable.
- Utiliser des URLs signees courtes, Cloud CDN avec tokenisation, ou une passerelle serveur.
- Activer Firebase App Check et ajouter des rules Storage.

### P0-03 - Player et routing incompatibles avec Web/deep links

Le routeur player lit uniquement:

```dart
final extra = state.extra as Map<String, dynamic>? ?? {};
```

La page telechargements pousse pourtant:

```dart
context.push('${Routes.player}?url=...&title=...')
```

Resultat: le player ignore `url/title`, puis retombe sur la video sample. Sur Web, un refresh de `/player` perd aussi `state.extra`.

Correction recommandee:

- Creer des routes addressables: `/watch/film/:id`, `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`.
- Recuperer les donnees depuis Firestore/entitlement server par ID.
- N'utiliser `state.extra` que comme optimisation non obligatoire.

### P0-04 - Pipeline video non adapte au streaming premium

Le player actuel lit des MP4 directs via `video_player`. Les boutons qualite, audio, sous-titres, cast et fullscreen sont surtout decoratifs.

Manques:

- HLS/DASH adaptatif.
- DRM ou controle d'acces fort.
- Resume/progression persistante.
- Sous-titres reels.
- Selection qualite reelle.
- Gestion erreurs video lisible.
- Autoplay policies Web.
- CORS et headers de streaming.
- Wakelock/lifecycle mobile.

### P0-05 - Duplication `guezs_films_site`

Le sous-projet imbrique contient des corrections Web que le projet principal n'a pas. Maintenir deux apps quasi identiques va creer des regressions permanentes.

Correction recommandee:

- Choisir un seul codebase.
- Supprimer ou transformer `guezs_films_site` en cible build/documentation, pas en copie divergente.
- Si Web et mobile divergent, utiliser des abstractions par plateforme, pas un second projet.

### P0-06 - Suppression de compte potentiellement incoherente

`DeleteAccountUseCase` supprime d'abord Firebase Auth, puis tente de supprimer Firestore cote client. Apres suppression Auth, les rules Firestore peuvent refuser les suppressions (`request.auth == null` ou token invalide). Le compte peut etre supprime mais l'UI peut afficher une erreur et les donnees Firestore rester partiellement presentes.

Correction recommandee:

- Nettoyer les donnees via Cloud Function admin declenchee avant/apres suppression Auth.
- Ou supprimer Firestore avant `user.delete()`, puis supprimer Auth en dernier.
- Ajouter une transaction d'etat `deletionRequested` et une reprise idempotente.

## Problemes importants

### Compatibilite Web et PWA

- `web/index.html` et `web/manifest.json` du projet principal gardent les textes "A new Flutter project" / `guezs_films`.
- Le manifest principal force `orientation: portrait-primary`, incoherent avec une experience Web/desktop et player landscape.
- Pas de configuration Firebase Hosting dans `firebase.json`.
- Les APIs de telechargement mobile ne sont pas separees du Web dans le projet racine.
- `flutter_local_notifications` est importe dans le service telechargement; la strategie Web doit etre explicite.

### Responsive et layout

- Les breakpoints existent dans `AppConstants` mais sont peu ou pas utilises.
- Grilles fixes: `crossAxisCount: 3` dans recherche/favoris.
- Cards fixes: largeur poster `120`, sections horizontales hauteur `250`.
- Hero base sur `MediaQuery.height * 0.52/0.60` sans adaptation desktop.
- Navigation toujours bottom bar, meme sur desktop/tablette ou un rail/top nav serait plus credible.
- Beaucoup de `Stack`/`Positioned` peuvent produire des chevauchements sur petits ecrans, textes longs, langues plus longues ou Web redimensionne.

### UI/UX et credibilite premium

- Plusieurs elements sont encore prototype:
  - video fallback `sample-videos.com`.
  - image de profil selector via `image.pollinations.ai`.
  - `2.3 GB utilises`, `Aucune transaction`, `UPGRADE`, `D/L`.
  - README et PWA generiques.
  - message d'erreur Firebase avec IP locale `192.168.100.203`.
- Le profil selector est hardcode autour de "LA FEMME DU MBENGUISTE", ce qui peut etre puissant comme campagne mais pas comme experience profil generique.
- La logique enfants (`isKids`) n'est pas appliquee au catalogue.
- Les parametres qualite, sous-titres, notifications et facturation ne sont pas persistants.
- `CachedImage` contient une heuristique speciale "Elle et moi", ce qui melange UI generique et contenu specifique.

### Firestore et donnees

- Requetes catalogue sans `limit()` ni pagination.
- `getFilms()` et `getSeries()` chargent tout le catalogue.
- Recherche limitee aux `searchTokens` du titre; pas de recherche acteurs, pays, realisateur, tags, synopsis.
- Incoherence possible des genres: UI en francais (`Comedie`, `Drame`) vs constantes anglaises (`Comedy`, `Drama`) vs seed (`Africain`).
- `getNewSeries()` ne trie pas par `createdAt` contrairement a `getNewFilms()`.
- Favoris stockes par user, pas par profil actif.
- `activeProfileProvider` n'est pas persiste; refresh/restart perd le profil actif.
- Statut premium lu dans `/users/{uid}.isPremium`, mais aucune regle/metier serveur ne protege la lecture video.

### Performance

- Nombreuses animations et `BackdropFilter`/blur sur scroll et modales; couteux sur mobile bas/milieu de gamme et Web CanvasKit.
- `CachedNetworkImage` aide le mobile, mais Web a besoin d'une strategie cache/CDN/images dimensionnees.
- `GoogleFonts` peut ajouter latence reseau et variance de rendu si non bundle.
- Pas de pagination/infinite scroll.
- Pas de prefetch intelligent des images hero/posters.
- Pas de monitoring performance/crashlytics/logging structure.
- `FavoritesPage` peut relire les details Firestore poster par poster si `posterPath` est vide.

### Build et configuration

- `flutter analyze --no-pub lib test` sur le projet principal remonte 1 issue:
  - `lib/features/profile/presentation/pages/profile_selector_page.dart:247:13` - `use_build_context_synchronously`.
- `flutter analyze --no-pub lib test` dans `guezs_films_site` remonte 6 issues:
  - imports `flutter/foundation.dart` inutilises dans `login_page.dart` et `player_page.dart`.
  - `_dio`, `_showProgressNotification`, `_showCompletionNotification` inutilises dans le download service Web.
  - meme warning `use_build_context_synchronously`.
- `flutter build web` n'a pas ete lance pour respecter la contrainte de ne pas produire d'artefacts hors rapport.
- Le premier `flutter analyze --no-pub` complet a depasse le timeout a cause d'un verrou de demarrage Flutter concurrent; correction appliquee: arret des processus d'analyse orphelins puis analyse ciblee `lib test`.

## Ameliorations UI/UX prioritaires

1. Remplacer les grilles fixes par un systeme responsive: mobile 2/3 colonnes, tablette 4/5, desktop 6/8 avec largeur max.
2. Remplacer la bottom nav par navigation adaptive: bottom nav mobile, navigation rail/tableau desktop, header Web.
3. Rendre le hero desktop credible: largeur max, image 16:9, CTA non etires, metas lisibles.
4. Supprimer les textes placeholder et les valeurs factices visibles.
5. Remplacer le profil selector hardcode par un vrai ecran de choix de profils + zone campagne optionnelle pilotee par Firestore.
6. Appliquer `isKids` pour filtrer les contenus et verrouiller les profils enfant.
7. Rendre les boutons player fideles a leurs capacites reelles: masquer audio/sous-titres/qualite/cast tant que non supportes.
8. Ajouter des etats vides premium avec action claire, mais sans texte technique.
9. Remplacer le code "D/L" par une action localisee claire et accessible.
10. Ajouter accessibilite: semantics, tailles tactiles, focus clavier Web, navigation clavier dans player.

## Recommandations mobile

- Garder le player en landscape, mais isoler la gestion orientation dans un service player et restaurer exactement l'etat precedent.
- Ajouter `wakelock_plus` explicitement pour eviter l'extinction ecran pendant lecture.
- Gerer lifecycle: pause/resume, interruption audio, mise en background, perte reseau.
- Android 13+: declarer et demander `POST_NOTIFICATIONS` si les notifications de telechargement restent.
- Telechargements: support HTTP range/reprise reelle, queue, limites Wi-Fi/cellulaire, espace disque, suppression securisee.
- iOS: verifier Apple Sign-In capability/entitlements et les contraintes de telechargement/background.
- Ajouter Crashlytics/Performance Monitoring avant beta.
- Tester Android bas de gamme et iPhone ancien avec `profile` mode, pas seulement debug.

## Recommandations Web

- Supprimer tous les imports `dart:io` du graphe Web.
- Adopter routes addressables et refresh-safe.
- Mettre a jour `web/index.html` et `web/manifest.json` avec marque, description, theme, orientation non bloquante.
- Ajouter configuration Firebase Hosting/CDN si Web est une cible officielle.
- Prevoir CORS/headers video pour Storage/CDN.
- Ne pas proposer les telechargements offline mobile sur Web tant qu'une strategie PWA/IndexedDB/licensing n'est pas definie.
- Adapter navigation et grilles a desktop.
- Tester `flutter build web --release` apres suppression `dart:io`.
- Verifier clavier/souris/focus/hover et accessibilite.

## Recommandations Firebase

- Ajouter `storage.rules` et ne plus rendre les medias publics par seed.
- Remplacer les URLs publiques par des URLs signees courtes ou une couche serveur de streaming.
- Activer Firebase App Check pour Web, Android et iOS.
- Deplacer la validation promo/subscription cote serveur.
- Ajouter Cloud Functions pour suppression de compte et nettoyage Firestore/Storage admin.
- Ajouter limites et pagination aux requetes catalogue.
- Ajouter champs normalises: `slug`, `contentType`, `country`, `language`, `maturityRating`, `releaseDate`, `duration`, `entitlementTier`, `isPublished`.
- Ajouter index pour les requetes reellement utilisees apres refactor.
- Versionner les schemas Firestore et le seed.
- Ajouter tests rules avec Firebase Emulator.

## Recommandations performance

- Introduire pagination (`limit`, cursors) pour catalogue/recherche/favoris.
- Dimensionner les images cote Storage/CDN: poster mobile, poster desktop, backdrop, thumbnail.
- Eviter `BackdropFilter` large dans listes scrollables; reserver aux overlays ponctuels.
- Bundle les polices au lieu de les telecharger a runtime, ou definir une strategie cache.
- Ajouter prefetch des heros et premiers posters.
- Eviter `setState` continu sur scroll quand une `SliverAppBar`/`ValueListenableBuilder` suffit.
- Instrumenter temps de demarrage, frame build/raster, erreurs player, taux de buffering.

## Plan de refactorisation par etapes

### Etape 0 - Stabiliser l'audit baseline

- Garder une branche propre.
- Ne plus developper dans deux projets divergents.
- Decider si `guezs_films_site` est supprime, archive ou fusionne.

### Etape 1 - Debloquer Flutter Web

- Extraire `dart:io` dans des implementations conditionnelles.
- Remplacer `Platform` par une abstraction de capabilities.
- Neutraliser proprement telechargement offline sur Web.
- Lancer `flutter build web --release` apres refactor.

### Etape 2 - Corriger routing et player

- Creer routes `/watch/...` par ID.
- Supprimer le fallback sample video en production.
- Charger le media via repository + entitlement.
- Ajouter etats player: loading, forbidden, unavailable, retry.

### Etape 3 - Securiser l'acces premium

- Implementer entitlement serveur.
- Ajouter Storage rules/App Check/URLs signees.
- Remplacer `PromoCodeDialog` hardcode par validation Cloud Function.

### Etape 4 - Responsive UI

- Creer `ResponsiveScaffold`, `ResponsiveGrid`, breakpoints reels.
- Adapter home/search/favorites/profile/details/player.
- Ajouter navigation desktop.

### Etape 5 - Firebase production

- Pagination Firestore.
- Nettoyage compte via Cloud Function.
- Tests rules/emulators.
- Schema contenu normalise et seed idempotent.

### Etape 6 - Qualite release

- Tests widget/integration pour auth, routing, catalogue, player.
- Tests Web Chrome + mobile.
- Profiling performance.
- Crashlytics/Performance Monitoring.
- Documentation README et runbooks.

## Checklist de validation

- [ ] `flutter analyze --no-pub lib test` sans issue dans le projet principal.
- [ ] `flutter test --no-pub` avec tests non-placeholder.
- [ ] `flutter build web --release` reussi.
- [ ] `flutter build apk --release` reussi.
- [ ] `flutter build ipa --release` prepare avec entitlements valides.
- [ ] Auth email, Google, Apple testes mobile + Web.
- [ ] Refresh Web sur `/home`, `/film/:id`, `/series/:id`, `/watch/...` fonctionne.
- [ ] Player lit un contenu reel, sans fallback sample.
- [ ] Acces video refuse si utilisateur non autorise.
- [ ] Firestore rules testees avec emulator.
- [ ] Storage non public pour les videos premium.
- [ ] App Check active.
- [ ] Grilles et hero verifies mobile, tablette, desktop.
- [ ] Navigation clavier/focus Web verifiee.
- [ ] Telechargement mobile: pause/reprise/suppression/espace disque.
- [ ] Profil enfant filtre le catalogue.
- [ ] Crash/performance monitoring actif en beta.

## Commandes executees et resultats

- `git status --short`: reussi apres relance; worktree deja tres modifie avant l'audit.
- `rg --files`: structure inspectee; premiere tentative timout, relance ciblee reussie.
- `rg -n "dart:io|Platform|VideoPlayerController.file|..."`: imports et patterns critiques identifies.
- `flutter --version`: Flutter `3.38.1`, Dart `3.10.0`.
- `flutter analyze --no-pub`: premiere tentative complete timeout apres environ 184s a cause d'un verrou de demarrage Flutter concurrent; correction: arret des processus Dart orphelins, puis analyse ciblee.
- `flutter analyze --no-pub lib test` dans le projet principal: 1 issue (`use_build_context_synchronously`).
- `flutter test --no-pub test/widget_test.dart` dans le projet principal: passe, mais test placeholder.
- `flutter analyze --no-pub lib test` dans `guezs_films_site`: 6 issues.
- `flutter test --no-pub test/widget_test.dart` dans `guezs_films_site`: passe.
- `flutter build web` non lance pour ne pas creer d'artefacts hors `docs/AUDIT_UI_UX_TECHNIQUE.md`.

## Fichiers inspectes

Liste exacte des fichiers inspectes par lecture directe ou recherche ciblee pendant cet audit, hors contenu binaire des images/icones:

- `analysis_options.yaml`
- `firebase.json`
- `firestore.indexes.json`
- `firestore.rules`
- `pubspec.lock`
- `pubspec.yaml`
- `README.md`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/guezsfilms/premium/MainActivity.kt`
- `ios/Runner/Info.plist`
- `web/index.html`
- `web/manifest.json`
- `functions/index.js`
- `functions/package.json`
- `scripts/package.json`
- `scripts/seed_content.js`
- `test/widget_test.dart`
- `lib/main.dart`
- `lib/firebase_options.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/data/firebase_content_datasource.dart`
- `lib/core/data/models/episode_model.dart`
- `lib/core/data/models/film_model.dart`
- `lib/core/data/models/season_model.dart`
- `lib/core/data/models/series_model.dart`
- `lib/core/data/repositories/content_repository_impl.dart`
- `lib/core/domain/entities/episode_entity.dart`
- `lib/core/domain/entities/film_entity.dart`
- `lib/core/domain/entities/season_entity.dart`
- `lib/core/domain/entities/series_entity.dart`
- `lib/core/domain/repositories/content_repository.dart`
- `lib/core/errors/exceptions.dart`
- `lib/core/errors/failures.dart`
- `lib/core/providers/connectivity_provider.dart`
- `lib/core/providers/content_providers.dart`
- `lib/core/routes/app_router.dart`
- `lib/core/routes/route_constants.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/utils/extensions.dart`
- `lib/core/utils/helpers.dart`
- `lib/core/widgets/cached_image.dart`
- `lib/core/widgets/glass_card.dart`
- `lib/core/widgets/gradient_button.dart`
- `lib/core/widgets/main_scaffold.dart`
- `lib/core/widgets/offline_banner.dart`
- `lib/core/widgets/promo_code_dialog.dart`
- `lib/core/widgets/shimmer_loading.dart`
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/entities/user_entity.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/usecases/auth_usecases.dart`
- `lib/features/auth/domain/usecases/delete_account_usecase.dart`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/onboarding_page.dart`
- `lib/features/auth/presentation/pages/splash_page.dart`
- `lib/features/auth/presentation/providers/auth_error_mapper.dart`
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/providers/onboarding_provider.dart`
- `lib/features/details/presentation/pages/details_page.dart`
- `lib/features/downloads/data/models/download_item_model.dart`
- `lib/features/downloads/data/repositories/download_repository_impl.dart`
- `lib/features/downloads/data/services/download_service.dart`
- `lib/features/downloads/domain/entities/download_item.dart`
- `lib/features/downloads/domain/repositories/download_repository.dart`
- `lib/features/downloads/presentation/pages/downloads_page.dart`
- `lib/features/downloads/presentation/providers/download_providers.dart`
- `lib/features/favorites/data/datasources/favorites_remote_datasource.dart`
- `lib/features/favorites/data/models/favorite_movie_model.dart`
- `lib/features/favorites/data/repositories/favorites_repository_impl.dart`
- `lib/features/favorites/domain/entities/favorite_movie.dart`
- `lib/features/favorites/domain/repositories/favorites_repository.dart`
- `lib/features/favorites/presentation/pages/favorites_page.dart`
- `lib/features/favorites/presentation/providers/favorites_providers.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/player/presentation/pages/player_page.dart`
- `lib/features/profile/data/models/user_profile_model.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`
- `lib/features/profile/data/repositories/user_profile_repository_impl.dart`
- `lib/features/profile/domain/entities/user_profile_entity.dart`
- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/domain/repositories/user_profile_repository.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/profile/presentation/pages/profile_selector_page.dart`
- `lib/features/profile/presentation/providers/profile_providers.dart`
- `lib/features/profile/presentation/providers/user_profile_providers.dart`
- `lib/features/profile/presentation/widgets/profile_form_sheet.dart`
- `lib/features/search/presentation/pages/search_page.dart`
- `lib/features/series/presentation/pages/series_details_page.dart`
- `guezs_films_site/pubspec.yaml`
- `guezs_films_site/lib/main.dart`
- `guezs_films_site/lib/core/routes/app_router.dart`
- `guezs_films_site/lib/features/auth/domain/usecases/delete_account_usecase.dart`
- `guezs_films_site/lib/features/auth/presentation/pages/login_page.dart`
- `guezs_films_site/lib/features/downloads/data/services/download_service.dart`
- `guezs_films_site/lib/features/player/presentation/pages/player_page.dart`
- `guezs_films_site/web/manifest.json`
- `guezs_films_site/test/widget_test.dart`

En plus de ces lectures directes, les chemins sous `lib/`, `guezs_films_site/lib/`, `web/`, `android/`, `ios/`, `functions/`, `scripts/` et `test/` ont ete scans avec `rg` pour imports, routing, Firebase, responsive, player et marqueurs de prototype.

## 10 actions prioritaires a lancer ensuite

1. Fusionner ou supprimer `guezs_films_site` pour revenir a un seul codebase.
2. Supprimer `dart:io` du graphe Web via imports conditionnels et services plateforme.
3. Remplacer le routing player `state.extra` par des routes watch par ID.
4. Supprimer le fallback `sample-videos.com` et gerer les erreurs player explicitement.
5. Remplacer le code promo hardcode par validation serveur + entitlement.
6. Arreter les medias Storage publics et ajouter Storage rules/App Check/URLs signees.
7. Refactorer home/search/favorites/details/profile en layout responsive avec breakpoints reels.
8. Ajouter pagination Firestore et `limit()` sur catalogue/recherche.
9. Corriger la suppression de compte avec Cloud Function admin idempotente.
10. Remplacer les tests placeholder par smoke tests app, routing, auth mockee, Firestore emulator et test Web build.

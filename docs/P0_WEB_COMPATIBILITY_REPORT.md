# Rapport P0 - Compatibilite Flutter Web

Date: 2026-06-11  
Depot: `C:\projets\FlutterProjects\guezs_films`  
Objectif: lever les blocages P0 Web sans refonte visuelle ni changement majeur de comportement produit.

## Resume executif

Le projet racine compile maintenant en Web release. Les usages directs de `dart:io`, `Platform`, `File`, `Directory`, `path_provider` et `VideoPlayerController.file` ont ete retires du graphe Web applicatif et deplaces derriere des exports conditionnels ou des abstractions de plateforme.

Le build Web JavaScript est valide. Le build Wasm n'est pas encore compatible, principalement a cause de `flutter_secure_storage_web` qui depend encore de `dart:html`, `dart:js` et `dart:js_util`.

## Fichiers modifies ou ajoutes

| Fichier | Type | Role |
| --- | --- | --- |
| `lib/core/platform/platform_capabilities.dart` | Ajout | Capacites par plateforme sans `dart:io`. |
| `lib/features/auth/presentation/pages/login_page.dart` | Modification | Suppression de `dart:io` / `Platform`; boutons sociaux via `PlatformCapabilities`. |
| `lib/features/downloads/data/services/download_service.dart` | Modification | Export conditionnel Web/native. |
| `lib/features/downloads/data/services/download_service_io.dart` | Ajout | Implementation native avec `dart:io`, `path_provider`, notifications et `Dio.download`. |
| `lib/features/downloads/data/services/download_service_web.dart` | Ajout | Implementation Web explicite: offline downloads non supportes, suppression Hive autorisee. |
| `lib/features/details/presentation/pages/details_page.dart` | Modification | Garde utilisateur quand les telechargements ne sont pas supportes. |
| `lib/features/player/data/video_controller_factory.dart` | Ajout | Export conditionnel du factory video. |
| `lib/features/player/data/video_controller_factory_io.dart` | Ajout | Lecture locale native via `VideoPlayerController.file` uniquement hors Web. |
| `lib/features/player/data/video_controller_factory_web.dart` | Ajout | Lecture Web via `VideoPlayerController.networkUrl`; fichiers locaux refuses. |
| `lib/features/player/presentation/pages/player_page.dart` | Modification | Controller nullable, erreurs propres, plus de fallback sample, orientation limitee mobile. |
| `lib/core/routes/app_router.dart` | Modification | Route player compatible `state.extra` et query params Web. |
| `lib/features/auth/domain/usecases/delete_account_usecase.dart` | Modification | Suppression fichiers locaux via abstraction conditionnelle. |
| `lib/features/auth/domain/usecases/delete_account_local_cleanup.dart` | Ajout | Export conditionnel cleanup local. |
| `lib/features/auth/domain/usecases/delete_account_local_cleanup_io.dart` | Ajout | Suppression fichiers locaux native. |
| `lib/features/auth/domain/usecases/delete_account_local_cleanup_stub.dart` | Ajout | No-op Web. |
| `lib/main.dart` | Modification | Orientation forcee uniquement sur mobile. |
| `lib/features/profile/presentation/pages/profile_selector_page.dart` | Modification | Correction minimale du warning `use_build_context_synchronously` pour que l'analyse globale passe. |
| `docs/GUEZS_FILMS_SITE_MERGE_PLAN.md` | Ajout | Plan de fusion/suppression du sous-projet Web. |
| `docs/P0_WEB_COMPATIBILITY_REPORT.md` | Ajout | Present rapport. |

## Problemes corriges

### Login

- Retrait de `import 'dart:io';`.
- Remplacement de `Platform.isAndroid`, `Platform.isIOS`, `Platform.isWindows` par `PlatformCapabilities`.
- Les boutons Google/Apple ne chargent plus `dart:io` dans le build Web.

### Downloads

- Le service public `download_service.dart` est maintenant un export conditionnel.
- Le Web ne compile plus l'implementation `dart:io`.
- Le Web signale clairement que les telechargements hors-ligne ne sont pas encore disponibles.
- La suppression d'une entree de telechargement reste possible cote repository.

### Player

- Retrait de `dart:io` de la page player.
- Creation d'un factory video conditionnel.
- Les fichiers locaux ne sont lus que sur plateformes natives.
- Le Web utilise uniquement `VideoPlayerController.networkUrl`.
- Le fallback externe `sample-videos.com` a ete supprime.
- Le player affiche un etat d'erreur propre si l'URL video est absente ou invalide.
- Les appels `SystemChrome` orientation/fullscreen sont limites au mobile.

### Routing

- La route `/player` accepte maintenant `state.extra` et les query params `url`, `videoUrl`, `title`, `posterUrl`.
- La page telechargements peut donc ouvrir le player avec une URL encodee sans perdre les donnees.
- Les deep links Web restent encore a refactorer vers des routes metier par ID, mais le blocage immediat est leve.

### Suppression de compte

- Le use case n'importe plus `dart:io`.
- La suppression de fichiers locaux est native-only via export conditionnel.
- Un TODO explicite signale que le nettoyage complet doit migrer vers une Cloud Function admin idempotente.

### Orientation globale

- `main.dart` ne force plus l'orientation sur Web/Desktop.
- Le mode portrait global reste applique sur mobile.

## Resultats des commandes

| Commande | Resultat |
| --- | --- |
| `rg -n "^import 'dart:io'\|Platform\\.\|VideoPlayerController\\.file\|File\\(\|Directory\\(\|getApplicationDocumentsDirectory\|path_provider" lib` | OK. Les usages natifs restants sont limites a `*_io.dart` ou a `TargetPlatform` Web-safe. |
| `flutter analyze --no-pub lib test` | Premier lancement interrompu par timeout apres 124 s. |
| `flutter analyze --no-pub lib test` | Deuxieme lancement: erreurs corrigees dans `download_service_io.dart`, warning corrige dans `details_page.dart`, warning existant corrige dans `profile_selector_page.dart`. |
| `flutter analyze --no-pub lib test` | OK final: `No issues found!` |
| `flutter test --no-pub test\widget_test.dart` | OK: `All tests passed!` |
| `flutter build web --release` | OK: `Built build\web` |

## Avertissements observes

- `flutter build web --release` a telecharge/resolve les dependances car le build Web lance une resolution de packages malgre les commandes precedentes en `--no-pub`.
- 101 packages ont des versions plus recentes incompatibles avec les contraintes actuelles.
- Dry-run Wasm non compatible:
  - `flutter_secure_storage_web` importe `dart:html`.
  - `package:js` importe `dart:js`.
  - `dart:js_util` bloque la compilation Wasm.

Ces avertissements ne bloquent pas le build Web JavaScript actuel, mais ils doivent etre traites avant une strategie Web Wasm.

## Statut de compatibilite Web

| Surface | Statut | Notes |
| --- | --- | --- |
| Compilation Web JavaScript | OK | `flutter build web --release` reussi. |
| Analyse statique | OK | `flutter analyze --no-pub lib test` sans issue. |
| Test widget existant | OK | Test smoke minimal uniquement. |
| Wasm | Non compatible | Blocage dependances `flutter_secure_storage_web` / JS interop. |
| Downloads offline Web | Non supporte | Desactive explicitement, UX informative. |
| Player Web network URL | OK compile | Lecture reelle dependra des URLs, CORS, format et headers. |
| Player fichiers locaux Web | Non supporte | Rejete explicitement. |

## Risques restants

- Le controle d'acces video reste cote client et ne securise pas un produit premium.
- Les URLs video publiques ou durables restent partageables.
- Le player ne gere pas encore HLS/DASH, DRM, sous-titres reels, qualites reelles, resume ou erreurs reseau avancees.
- Les telechargements hors-ligne Web ne sont pas implementes avec IndexedDB/Cache API.
- `guezs_films_site/` reste present dans le depot et peut recreer une derive.
- La suppression de compte reste fragile cote serveur tant que le nettoyage complet n'est pas confie a une Cloud Function admin.
- Les providers Google/Apple doivent etre verifies en conditions reelles sur domaines Firebase autorises.

## Prochaines actions recommandees

1. Migrer l'acces video vers une logique serveur: entitlement, signed URLs courtes, App Check, rules Storage.
2. Remplacer les routes player par `/watch/film/:id` et `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`.
3. Introduire un pipeline streaming HLS/DASH avec CORS, headers et monitoring.
4. Implementer la progression de lecture et la reprise multi-device.
5. Supprimer ou archiver `guezs_films_site/` apres migration des assets/configs utiles.
6. Ajouter des tests widget/navigation pour login, profile selector, details, player error state et route query params.
7. Ajouter un check CI Web: analyze, test, build web.
8. Auditer `flutter_secure_storage_web` et les dependances JS si une cible Wasm devient prioritaire.
9. Ajouter une Cloud Function admin idempotente pour la suppression de compte.
10. Revisiter la strategie de downloads Web uniquement apres securisation du streaming.

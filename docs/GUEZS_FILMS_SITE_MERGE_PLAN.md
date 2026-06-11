# Plan de fusion - guezs_films_site vers projet racine

Date: 2026-06-11  
Projet cible: `C:\projets\FlutterProjects\guezs_films`  
Sous-projet analyse: `guezs_films_site/`

## Resume

`guezs_films_site/` est une copie Flutter quasi complete du projet racine avec quelques adaptations Web. Cette approche corrige partiellement certains problemes, mais elle cree une derive de code: deux routeurs, deux players, deux services de telechargement, deux implementations auth, deux configurations Web potentielles.

La strategie retenue pour le P0 est de reintegrer les corrections Web utiles dans le projet racine via des abstractions de plateforme, pas de maintenir une deuxieme application.

## Corrections utiles identifiees dans guezs_films_site

| Zone | Correction observee | Evaluation |
| --- | --- | --- |
| Login | Remplacement de `dart:io` / `Platform` par une logique Web-safe. | Utile, mais la version site affiche les boutons sociaux de facon plus brute. La version racine utilise maintenant `PlatformCapabilities`. |
| Player | Usage de `VideoPlayerController.networkUrl` sur Web. | Utile, mais la version site conserve un fallback sample video, force l'orientation Web et garde un `late VideoPlayerController` fragile. |
| Downloads | Guard `kIsWeb` pour neutraliser les telechargements. | Idee utile, mais insuffisante: le fichier importe encore des plugins natifs. Le projet racine utilise maintenant des exports conditionnels. |
| Delete account | Evite la suppression de fichiers locaux sur Web. | Utile, mais la version site perd la suppression native. Le projet racine garde la suppression mobile via implementation conditionnelle. |

## Corrections reintegrees dans le projet racine

| Sujet | Fichier racine | Etat |
| --- | --- | --- |
| Capacites plateforme centralisees | `lib/core/platform/platform_capabilities.dart` | Ajoute |
| Login sans `dart:io` | `lib/features/auth/presentation/pages/login_page.dart` | Corrige |
| Downloads par plateforme | `lib/features/downloads/data/services/download_service.dart` + `_io.dart` + `_web.dart` | Corrige |
| Player par plateforme | `lib/features/player/data/video_controller_factory.dart` + `_io.dart` + `_web.dart` | Corrige |
| Player sans fallback sample | `lib/features/player/presentation/pages/player_page.dart` | Corrige |
| Deep links player query params | `lib/core/routes/app_router.dart` | Corrige |
| Suppression fichiers locaux Web-safe | `lib/features/auth/domain/usecases/delete_account_local_cleanup*.dart` | Corrige |
| Orientation Web non forcee | `lib/main.dart` et `player_page.dart` | Corrige |
| Download non supporte Web explicite | `lib/features/details/presentation/pages/details_page.dart` | Corrige |

## Choix non repris depuis guezs_films_site

- Ne pas garder un service `download_service.dart` unique avec `kIsWeb` si le fichier importe encore `dart:io`, `path_provider` ou `flutter_local_notifications`.
- Ne pas garder le fallback video `sample-videos.com`: un player premium doit afficher une erreur propre si l'URL metier est absente.
- Ne pas forcer l'orientation landscape sur Web: le navigateur doit rester maitre du viewport.
- Ne pas rendre les telechargements Web silencieusement no-op: l'utilisateur doit recevoir un message clair.
- Ne pas conserver deux packages Flutter (`guezs_films` et `guezs_films_site`) pour la meme surface produit.

## Divergences restantes a auditer avant suppression du sous-projet

- `guezs_films_site/web/` peut contenir des variations PWA/manifest/index a comparer avec `web/`.
- Les assets propres au sous-projet doivent etre compares avant suppression.
- Les fichiers Firebase/env du sous-projet, s'ils existent, doivent etre inventories.
- Les correctifs UI ou auth presents uniquement dans le sous-projet doivent etre listes par diff avant archivage.
- Les imports `package:guezs_films_site/...` empechent toute reutilisation directe: la migration doit se faire par cherry-pick logique, pas par copie brute.

## Strategie de suppression ou archivage

1. Geler `guezs_films_site/`: aucune nouvelle feature ne doit y etre ajoutee.
2. Comparer `web/`, assets, Firebase config et scripts entre racine et sous-projet.
3. Migrer uniquement les elements uniques et utiles dans le projet racine.
4. Ajouter une verification CI minimale: `flutter analyze --no-pub lib test`, `flutter test --no-pub test/widget_test.dart`, `flutter build web --release`.
5. Si aucun element unique ne reste, supprimer `guezs_films_site/` du depot.
6. Si le sous-projet sert encore de reference temporaire, le deplacer hors du code applicatif actif ou l'archiver dans une branche/tag.

## Validation actuelle

- Le projet racine compile maintenant en Web release JavaScript.
- Les imports `dart:io` detectes dans `lib/` sont limites aux implementations conditionnelles natives.
- Le sous-projet n'est plus necessaire pour corriger les blocages P0 Web identifies.

## Risques si le sous-projet reste dans le depot

- Regressions Web recurrentes car les corrections peuvent etre faites dans le mauvais arbre.
- Confusion sur le projet a builder/deployer.
- Duplication des bugs auth/player/downloads.
- Augmentation du cout de refactorisation UI/UX.
- Risque de publier une version Web differente de la version mobile.

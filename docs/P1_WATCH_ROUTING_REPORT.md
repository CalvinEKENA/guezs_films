# Rapport P1 - Watch routing par ID métier

Date: 2026-06-11  
Depot: `C:\projets\FlutterProjects\guezs_films`  
Objectif: remplacer le lancement principal du player par des routes profondes, partageables et compatibles refresh Web.

## Résumé exécutif

Le player n'est plus appelé comme route principale avec `state.extra` ou des query params transportant `videoUrl`, `title` et `posterUrl`. Les parcours film et épisode utilisent désormais des routes métier par ID:

- `/watch/film/:filmId`
- `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`

Ces routes chargent les données depuis le repository Firestore existant, puis transmettent au `PlayerPage` uniquement les données résolues nécessaires à la lecture. La route legacy `/player` reste disponible, documentée comme deprecated, et limitée aux téléchargements locaux ou anciens liens.

## Routes créées

| Route | Page | Source des données | Refresh Web |
| --- | --- | --- | --- |
| `/watch/film/:filmId` | `WatchFilmPage` | `filmDetailsProvider(filmId)` | Oui, l'ID est dans le chemin. |
| `/watch/series/:seriesId/season/:seasonId/episode/:episodeId` | `WatchEpisodePage` | `episodeDetailsProvider(...)` + `seriesDetailsProvider(seriesId)` | Oui, les IDs sont dans le chemin. |

## Route legacy conservée

| Route | Statut | Usage restant |
| --- | --- | --- |
| `/player` | Deprecated | Compatibilité temporaire et lecture de fichiers locaux depuis `DownloadsPage`. |

`/player` accepte encore `state.extra` et les query params `url`, `videoUrl`, `title`, `posterUrl`, mais ce n'est plus le chemin principal depuis Home, Details ou Series. Le commentaire de dépréciation est présent dans `app_router.dart` et `route_constants.dart`.

## Modèle d'entrée player

Ajout de `PlayerContentRequest`:

- `contentType`: `film` ou `episode`
- `filmId`
- `seriesId`
- `seasonId`
- `episodeId`

Ce modèle accompagne les lectures résolues et prépare les prochains sprints: entitlement serveur, analytics de lecture, reprise multi-device et contrôle d'accès par contenu.

## Chargement des données

### Film

`WatchFilmPage`:

- lit `filmId` depuis la route;
- charge le film via `filmDetailsProvider`;
- vérifie que `videoUrl` est disponible;
- affiche `loading`, `contenu introuvable`, `accès impossible`, `erreur réseau` ou `vidéo indisponible`;
- affiche `PlayerPage` avec `videoUrl`, `title`, `posterUrl` résolus.

### Épisode

`WatchEpisodePage`:

- lit `seriesId`, `seasonId`, `episodeId` depuis la route;
- charge l'épisode via `episodeDetailsProvider`;
- charge la série via `seriesDetailsProvider` pour le fallback poster et le retour vers détails;
- vérifie que `videoUrl` est disponible;
- affiche `loading`, `épisode introuvable`, `accès impossible`, `erreur réseau` ou `vidéo indisponible`;
- affiche `PlayerPage` avec `videoUrl`, `title`, `posterUrl` résolus.

## Anciens chemins remplacés

| Ancien appel | Nouveau comportement |
| --- | --- |
| Home hero film -> `Routes.player` + `state.extra` | Home hero film -> `Routes.filmWatchPath(film.id)` |
| DetailsPage bouton Lire -> `Routes.player` + `state.extra` | DetailsPage bouton Lire -> `Routes.filmWatchPath(film.id)` |
| DetailsPage bouton play backdrop -> `Routes.player` + `state.extra` | DetailsPage bouton play backdrop -> `Routes.filmWatchPath(film.id)` |
| SeriesDetailsPage épisode -> `Routes.player` + `state.extra` | SeriesDetailsPage épisode -> `Routes.episodeWatchPath(...)` |
| DownloadsPage local file -> query string manuelle `/player?...` | DownloadsPage local file -> `Routes.legacyPlayerPath(...)` |

## Fichiers modifiés

- `lib/core/routes/route_constants.dart`
- `lib/core/routes/app_router.dart`
- `lib/core/data/firebase_content_datasource.dart`
- `lib/core/data/repositories/content_repository_impl.dart`
- `lib/core/domain/repositories/content_repository.dart`
- `lib/core/providers/content_providers.dart`
- `lib/features/player/domain/entities/player_content_request.dart`
- `lib/features/player/presentation/pages/watch_film_page.dart`
- `lib/features/player/presentation/pages/watch_episode_page.dart`
- `lib/features/player/presentation/widgets/watch_state_view.dart`
- `lib/features/player/presentation/pages/player_page.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/details/presentation/pages/details_page.dart`
- `lib/features/series/presentation/pages/series_details_page.dart`
- `lib/features/downloads/presentation/pages/downloads_page.dart`
- `test/widget_test.dart`
- `docs/P1_WATCH_ROUTING_REPORT.md`

## Comportement Web refresh

Les nouvelles routes sont refresh-safe parce que le chemin contient les IDs métier. Après refresh Web:

- le routeur reconstruit `WatchFilmPage` ou `WatchEpisodePage`;
- Riverpod recharge les documents Firestore;
- le player reçoit les données résolues;
- aucun `state.extra` n'est requis.

Limite actuelle: si l'utilisateur n'est pas connecté, la redirection auth existante renvoie vers `/login`. La restauration de la destination initiale après login n'est pas encore implémentée.

## Limites restantes

- Les droits de lecture ne sont pas encore validés par serveur d'entitlement.
- `videoUrl` reste stocké dans le document Firestore et transmis au client.
- Le code promo reste côté client.
- Le player lit encore des URLs directes, sans HLS/DASH ni DRM.
- Les erreurs Firestore sont classées par texte (`permission-denied`, `introuvable`), pas encore par un modèle d'erreur métier.
- `/player` reste nécessaire pour les fichiers locaux téléchargés.
- Les routes `/watch` ne mettent pas encore à jour l'historique de lecture ni l'analytics.

## Validation

Commandes exécutées:

- `flutter analyze --no-pub lib test`: OK, `No issues found!`
- `flutter test --no-pub test\widget_test.dart`: OK, `All tests passed!`
- `flutter build web --release`: OK, `Built build\web`

Test ajouté:

- `Watch film route is recognized without navigation extras`
- Monte `/watch/film/test-id` sans `state.extra`;
- vérifie l'état loading de `WatchFilmPage`;
- évite l'initialisation du player vidéo dans le test.

## Prochaines étapes pour sécuriser l'accès vidéo

1. Remplacer `videoUrl` public par une résolution serveur temporaire après vérification des droits.
2. Introduire un endpoint/Cloud Function `createPlaybackSession(contentId)`.
3. Valider abonnement, achat, code promo ou entitlement avant de délivrer une URL.
4. Utiliser des URLs signées courtes ou une passerelle CDN tokenisée.
5. Activer Firebase App Check et durcir les rules Storage.
6. Ajouter un journal serveur des sessions de lecture.
7. Remplacer les codes promo hardcodés par des documents/claims vérifiés côté serveur.
8. Ajouter des tests de redirection Web refresh pour film et épisode.
9. Ajouter la reprise de lecture par `PlayerContentRequest`.
10. Préparer l'introduction HLS/DASH sans changer les routes publiques.

# Rapport P6 - Pages détails premium

Date: 2026-06-11  
Projet: `C:\projets\FlutterProjects\guezs_films`  
Objectif: transformer les détails films et séries en pages premium, émotionnelles, responsive et orientées vers la lecture.

## Résumé

Les pages détails utilisent désormais une présentation cinématographique commune:

- backdrop immersif;
- poster 2:3;
- hiérarchie éditoriale forte;
- badges premium;
- métadonnées lisibles;
- CTA doré;
- états de chargement, erreur et contenu vide;
- adaptation mobile, tablette et desktop.

Les routes P1 et l’accès P2 sont conservés. Aucun contenu catalogue ne repasse par `/player`.

## Fichiers modifiés

- `lib/features/details/presentation/pages/details_page.dart`
- `lib/features/series/presentation/pages/series_details_page.dart`
- `lib/core/widgets/gradient_button.dart`
- `test/widget_test.dart`

Les entités et modèles préparés pour P6 restent rétrocompatibles:

- `lib/core/domain/entities/film_entity.dart`
- `lib/core/domain/entities/series_entity.dart`
- `lib/core/domain/entities/episode_entity.dart`
- `lib/core/data/models/film_model.dart`
- `lib/core/data/models/series_model.dart`
- `lib/core/data/models/episode_model.dart`

## Nouveaux fichiers

- `lib/core/widgets/premium_details.dart`
- `docs/P6_DETAILS_PAGES_REPORT.md`
- `docs/CONTENT_SCHEMA_RECOMMENDATIONS.md`

## Nouveaux composants

`premium_details.dart` centralise:

- `PremiumDetailsBackdrop`;
- `PremiumDetailBadge`;
- `PremiumMetadataPill`;
- `PremiumGenreChip`;
- `PremiumIconAction`;
- `PremiumDetailsSection`;
- `PremiumFactsPanel`;
- `PremiumDetailsStateView`;
- `PremiumDetailsSkeleton`;
- `PremiumStickyCta`.

Ces composants évitent de dupliquer le langage visuel film/série.

## Page film

La page affiche:

- backdrop avec fallback poster;
- poster encadré;
- titre prestige;
- année, durée, note, classification et qualité;
- genres;
- synopsis;
- CTA `Entrer en salle`;
- bande-annonce si `trailerUrl` existe;
- ajout/retrait des favoris;
- téléchargement uniquement quand la plateforme et `videoUrl` le permettent;
- réalisateur, casting, pays, langue, sous-titres, qualité et année de production;
- badges Original, Exclusivité, Sélection, Nouveau, Primé et Accès requis.

La lecture utilise exclusivement:

`Routes.filmWatchPath(film.id)`

## Page série

La page affiche:

- hero et poster;
- titre, description, genres et métadonnées;
- badges éditoriaux et d’accès;
- sélection horizontale des saisons;
- grille responsive d’épisodes;
- état verrouillé sur les épisodes;
- état série sans saison;
- état saison vide;
- état erreur par section;
- CTA `Commencer la série` vers le premier épisode disponible.

La lecture utilise exclusivement:

`Routes.episodeWatchPath(...)`

Le bouton `Épisode suivant` n’est pas simulé: il dépend d’une progression utilisateur fiable, absente du projet actuel.

## Accès premium

- Un invité voit une indication de connexion requise.
- Le CTA conduit toujours vers `WatchFilmPage` ou `WatchEpisodePage`.
- Le code d’accès et l’entitlement restent gérés dans les pages Watch.
- Les badges `Accès requis` et `Code requis` sont seulement éditoriaux.
- Aucun paiement n’a été ajouté.

## Champs optionnels

Champs pris en charge sans migration obligatoire:

- `trailerUrl`;
- `director`;
- `cast`;
- `country`;
- `language`;
- `maturityRating`;
- `subtitles`;
- `qualityVideo`;
- `isOriginal`;
- `isExclusive`;
- `awards`;
- `productionYear`;
- `requiresAccess`;
- `accessMode`;
- `accessLabel`;
- `isLocked` pour les épisodes.

Les modèles utilisent des valeurs par défaut et n’écrivent les nouveaux champs que lorsqu’ils sont renseignés.

## Responsive

### Mobile

- composition verticale;
- poster centré;
- sections empilées;
- CTA lecture sticky;
- cartes épisodes en une colonne;
- actions tactiles.

### Tablette

- poster et informations côte à côte à partir de `720px` disponibles;
- sections encore majoritairement verticales;
- largeur de contenu limitée;
- cartes épisodes adaptées à l’espace réel.

### Desktop

- backdrop proche du ratio `21:9`;
- largeur maximale centrée;
- poster et informations en deux colonnes;
- synopsis et fiche technique en deux colonnes;
- épisodes en deux colonnes;
- actions principales visibles rapidement.

## États UX

- skeleton complet;
- film introuvable;
- série introuvable;
- erreur réseau;
- image absente via `CachedImage`;
- série sans saison;
- saison sans épisode;
- erreur de chargement des saisons;
- erreur de chargement des épisodes;
- épisode verrouillé.

## Tests ajoutés

- rendu premium d’un film avec champs optionnels et accès requis;
- rendu d’une série avec saison et épisode verrouillé;
- absence du libellé historique `D/L`;
- présence des CTA métier.

## Validation

- `flutter analyze --no-pub lib test`: OK, aucune issue.
- `flutter test --no-pub test\widget_test.dart`: OK, 4 tests passés.
- `flutter build web --release`: OK, build généré dans `build\web`.

Vérification navigateur local:

- build Web servi sur `localhost`;
- route série profonde ouverte;
- redirection vers la connexion conforme pour une session invitée;
- aucune erreur console détectée.

Le dry-run Wasm conserve l’avertissement connu de `flutter_secure_storage_web` concernant `dart:html`, `dart:js` et `dart:js_util`. Le build Web JavaScript release reste valide.

## Limites restantes

- pas de progression persistante;
- pas de bouton `Épisode suivant` fiable;
- pas de reprise multi-appareil;
- bande-annonce ouverte via URL externe, sans player trailer intégré;
- téléchargement limité aux plateformes mobiles déjà supportées;
- les badges d’accès ne remplacent pas l’entitlement serveur;
- `videoUrl` public reste présent pendant la transition P2.

## Prochaines étapes

1. Ajouter un repository de progression par utilisateur et profil.
2. Alimenter `Continuer la lecture` et `Épisode suivant`.
3. Ajouter une barre de progression sur les épisodes.
4. Introduire un lecteur de bande-annonce dédié si nécessaire.
5. Ajouter une source de recommandations liées au contenu.
6. Remplacer progressivement `videoUrl` par `assetId`.
7. Ajouter des captures de régression aux largeurs clés.

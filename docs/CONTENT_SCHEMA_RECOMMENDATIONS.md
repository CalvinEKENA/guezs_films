# Recommandations de schéma contenu

Date: 2026-06-11  
Projet: `C:\projets\FlutterProjects\guezs_films`

## Principe de compatibilité

Les champs décrits ici sont optionnels. Leur absence ne doit jamais empêcher la lecture des anciens documents Firestore.

Les modèles Flutter:

- utilisent des valeurs par défaut;
- acceptent les anciennes données sans migration immédiate;
- n’écrivent les nouveaux champs que lorsqu’ils ont une valeur utile;
- conservent `videoQuality` comme alias de lecture pour `qualityVideo`.

Aucune règle Firestore ne doit rendre ces champs obligatoires pendant la transition.

## Films

Collection: `/films/{filmId}`

| Champ | Type recommandé | Défaut Flutter | Usage |
| --- | --- | --- | --- |
| `trailerUrl` | `string` | `""` | Ouvre la bande-annonce externe. |
| `director` | `string` | `""` | Réalisateur ou réalisatrice. |
| `cast` | `array<string>` | `[]` | Distribution principale. |
| `country` | `string` | `""` | Pays ou zone de production. |
| `language` | `string` | `""` | Langue originale principale. |
| `maturityRating` | `string` | `""` | Exemple: `12+`, `16+`, `Tous publics`. |
| `subtitles` | `array<string>` | `[]` | Langues de sous-titres disponibles. |
| `qualityVideo` | `string` | `""` | Exemple: `HD`, `Full HD`, `4K`. |
| `isOriginal` | `bool` | `false` | Badge `GUEZS Original`. |
| `isExclusive` | `bool` | `false` | Badge d’exclusivité. |
| `awards` | `array<string>` | `[]` | Prix et sélections éditoriales. |
| `productionYear` | `number` | `0` | Année de production, distincte de l’année d’ajout. |
| `requiresAccess` | `bool` | `false` | Indication éditoriale d’accès requis. |
| `accessMode` | `string` | `""` | Exemple: `code_required`, `premium`. |
| `accessLabel` | `string` | `""` | Libellé public court, sans logique métier. |

Exemple partiel:

```json
{
  "trailerUrl": "https://example.com/trailer",
  "director": "Nom de la réalisatrice",
  "cast": ["Interprète A", "Interprète B"],
  "country": "Cameroun",
  "language": "Français",
  "maturityRating": "12+",
  "subtitles": ["Français", "Anglais"],
  "qualityVideo": "4K",
  "isOriginal": true,
  "isExclusive": false,
  "awards": ["Sélection officielle 2026"],
  "productionYear": 2026,
  "requiresAccess": true,
  "accessMode": "code_required",
  "accessLabel": "Accès requis"
}
```

## Séries

Collection: `/series/{seriesId}`

Les mêmes champs éditoriaux que les films sont recommandés:

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
- `accessLabel`.

`director` peut représenter le créateur principal ou la direction artistique tant qu’aucun champ `creator` dédié n’est introduit.

## Épisodes

Collection:

`/series/{seriesId}/seasons/{seasonId}/episodes/{episodeId}`

| Champ | Type recommandé | Défaut Flutter | Usage |
| --- | --- | --- | --- |
| `maturityRating` | `string` | `""` | Classification spécifique à l’épisode. |
| `subtitles` | `array<string>` | `[]` | Sous-titres de l’épisode. |
| `qualityVideo` | `string` | `""` | Qualité disponible. |
| `requiresAccess` | `bool` | `false` | Indication éditoriale d’accès. |
| `isLocked` | `bool` | `false` | Affichage verrouillé dans la liste. |
| `accessMode` | `string` | `""` | Mode d’accès indicatif. |
| `accessLabel` | `string` | `""` | Exemple: `Code requis`. |

`isLocked` et `requiresAccess` ne remplacent pas l’entitlement serveur. Ils servent uniquement à préparer l’interface. `WatchEpisodePage` reste responsable de la vérification effective.

## Progression utilisateur

La progression ne doit pas être stockée dans les documents catalogue, car elle dépend de l’utilisateur et du profil.

Structure future recommandée:

`/users/{userId}/profiles/{profileId}/watch_progress/{contentKey}`

Champs possibles:

| Champ | Type | Usage |
| --- | --- | --- |
| `contentType` | `string` | `film` ou `episode`. |
| `filmId` | `string?` | Identifiant film. |
| `seriesId` | `string?` | Identifiant série. |
| `seasonId` | `string?` | Identifiant saison. |
| `episodeId` | `string?` | Identifiant épisode. |
| `positionSec` | `number` | Position de reprise. |
| `durationSec` | `number` | Durée connue au moment de l’écriture. |
| `progress` | `number` | Valeur normalisée de `0` à `1`. |
| `completed` | `bool` | Contenu considéré comme terminé. |
| `updatedAt` | `timestamp` | Synchronisation multi-appareil. |

Cette structure permettra:

- `Continuer la lecture`;
- le bouton `Épisode suivant`;
- une barre de progression sur les cartes;
- la reprise multi-appareil;
- un historique par profil.

## Champs futurs optionnels

À envisager sans les rendre obligatoires:

- `editorialSubtitle`;
- `badges`;
- `releaseDate`;
- `contentWarnings`;
- `audioTracks`;
- `creators`;
- `writers`;
- `runtimeLabel`;
- `availabilityStartAt`;
- `availabilityEndAt`;
- `assetId` pour remplacer progressivement les URL vidéo publiques.

## Règles de migration

1. Ajouter les champs progressivement dans l’outil d’administration ou les scripts de seed.
2. Ne pas lancer de migration bloquante sur tout le catalogue.
3. Conserver les valeurs par défaut côté Flutter.
4. Valider les types côté outil d’administration.
5. Ne pas utiliser les badges catalogue comme preuve d’autorisation.
6. Remplacer à terme `videoUrl` par un identifiant d’asset résolu après entitlement.

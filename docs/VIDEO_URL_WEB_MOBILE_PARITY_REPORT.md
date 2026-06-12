# Rapport de parité des URLs vidéo Web/mobile

Date: 2026-06-12

## Diagnostic

Les pages `WatchFilmPage` et `WatchEpisodePage` construisent la source finale
dans cet ordre:

1. `access.playbackUrl`, lorsque la session Watch fournit une URL;
2. l'URL vidéo lue depuis le document catalogue.

La Function `createWatchSession` accorde actuellement l'accès avec:

```js
playbackUrl: null
```

Ce comportement est volontaire tant que `getSignedVideoUrl` n'est pas relié à
un stockage privé ou à un CDN signé. L'application dépend donc encore de la
source présente dans Firestore.

Avant cette correction, les modèles ne lisaient que `videoUrl`. Un contenu
stocké sous `videoURL`, `video_url`, `playbackUrl`, `streamUrl`, `sourceUrl` ou
`url` était considéré comme sans source sur Web.

## Corrections Flutter

### Lecture compatible des anciennes données

`FilmModel` et `EpisodeModel` utilisent maintenant la priorité suivante:

1. `videoUrl`
2. `videoURL`
3. `video_url`
4. `playbackUrl`
5. `streamUrl`
6. `sourceUrl`
7. `url`

Le premier champ texte non vide est utilisé. Aucune migration Firestore n'est
requise pour continuer à lire les anciennes données.

### État utilisateur

Lorsque l'accès est accordé mais que la session et le document catalogue ne
fournissent aucune URL, les pages Watch affichent maintenant:

> Source vidéo non configurée

Le sous-message précise si la source manque pour un film ou un épisode. Les
routes `/watch/...`, l'authentification, les entitlements et le player restent
inchangés.

### Logs debug

En mode debug uniquement, les pages Watch journalisent:

- `contentId`;
- `access.allowed`;
- `access.status`;
- présence ou absence de `access.playbackUrl`;
- présence ou absence de l'URL directe;
- état du fallback direct MVP.

Les URLs elles-mêmes ne sont pas imprimées.

## Scripts Admin

### Audit en lecture seule

Fichier:

`scripts/admin/audit_video_urls.js`

Commande:

```powershell
node scripts/admin/audit_video_urls.js --project guezs-films
```

Le script:

- scanne la collection `films`;
- scanne toutes les collections `episodes` via `collectionGroup`;
- indique le chemin, le titre, le statut et le champ effectivement utilisé;
- liste séparément les contenus sans source;
- liste les contenus normalisables depuis un champ alternatif;
- ne révèle pas les URLs complètes;
- ne modifie aucun document.

### Normalisation optionnelle

Fichier:

`scripts/admin/normalize_video_urls.js`

Rapport sans modification:

```powershell
node scripts/admin/normalize_video_urls.js --project guezs-films
```

Normalisation confirmée:

```powershell
node scripts/admin/normalize_video_urls.js `
  --project guezs-films `
  --confirm-normalize-video-urls
```

Le script:

- affiche un rapport avant modification;
- ne continue sans le drapeau de confirmation exact;
- remplit uniquement un `videoUrl` vide;
- copie le premier champ alternatif valide;
- relit les documents avant écriture;
- ne supprime jamais le champ historique;
- affiche un rapport après modification.

Les scripts peuvent aussi être lancés depuis `scripts/admin` avec:

```powershell
npm run audit:video-urls
npm run normalize:video-urls
```

Le second script reste sans mutation sans confirmation explicite.

## Fichiers modifiés

- `lib/core/data/models/video_url_field_reader.dart`
- `lib/core/data/models/film_model.dart`
- `lib/core/data/models/episode_model.dart`
- `lib/features/player/domain/services/mvp_playback_fallback.dart`
- `lib/features/player/presentation/utils/watch_source_debug.dart`
- `lib/features/player/presentation/pages/watch_film_page.dart`
- `lib/features/player/presentation/pages/watch_episode_page.dart`
- `scripts/admin/_video_url_admin_utils.js`
- `scripts/admin/audit_video_urls.js`
- `scripts/admin/normalize_video_urls.js`
- `scripts/admin/package.json`
- `test/widget_test.dart`
- `docs/VIDEO_URL_WEB_MOBILE_PARITY_REPORT.md`

## Validation

Commandes exécutées:

```powershell
node --check scripts/admin/audit_video_urls.js
node --check scripts/admin/normalize_video_urls.js
node --check scripts/admin/_video_url_admin_utils.js
node --check functions/index.js
flutter analyze --no-pub lib test
flutter test --no-pub test\widget_test.dart
flutter build web --release `
  --dart-define=ALLOW_DIRECT_VIDEO_FALLBACK_MVP=false `
  --no-wasm-dry-run
```

Résultats:

- syntaxe Node: OK;
- analyse Flutter: aucune anomalie;
- tests Flutter: 33 réussis;
- build Web release avec fallback direct désactivé: OK;
- sortie Web: `build/web`.

Les scripts Admin ont été validés syntaxiquement mais n'ont pas été exécutés
contre Firebase pendant cette intervention. Aucune donnée live n'a été modifiée.

## Limites restantes

- les documents réellement sans aucun champ vidéo resteront non lisibles;
- `createWatchSession` ne fournit toujours pas d'URL signée;
- `getSignedVideoUrl` reste un stub;
- une URL MP4 peut fonctionner sur mobile mais échouer sur Web si le serveur ne
  fournit pas les bons en-têtes CORS, `Content-Type` ou requêtes `Range`;
- Hostinger doit servir l'application SPA correctement, mais il ne peut pas
  réparer une source vidéo absente ou un serveur vidéo sans CORS.

## Recommandations

1. Exécuter d'abord `audit_video_urls.js` avec des identifiants Admin autorisés.
2. Relire le rapport avant toute normalisation.
3. Normaliser uniquement après sauvegarde Firestore.
4. Tester les URLs détectées depuis un navigateur avec CORS et requêtes Range.
5. À terme, connecter `getSignedVideoUrl` à un stockage privé ou CDN signé.

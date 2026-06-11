# Stratégie de sécurité vidéo - Guezs Films

Date: 2026-06-11

## Pourquoi les URLs publiques sont insuffisantes

Une URL vidéo publique ou durable peut être copiée, partagée, indexée, téléchargée ou appelée hors de l'application. Même si Firestore exige un utilisateur connecté pour lire le catalogue, une URL déjà exposée reste utilisable tant que Storage/CDN l'autorise.

Pour une application premium, l'accès au document catalogue ne doit pas être confondu avec l'accès au flux vidéo.

## Pourquoi la validation client ne suffit pas

Un contrôle côté Flutter peut être contourné:

- modification de l'APK ou du bundle Web;
- appel direct du player avec une URL connue;
- manipulation du local storage;
- reconstitution des requêtes réseau;
- bypass d'un code promo hardcodé.

Le client doit demander une décision au serveur. Le serveur doit vérifier l'identité, les droits, l'expiration et créer une session courte.

## Architecture cible

1. L'utilisateur ouvre `/watch/film/:filmId` ou `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`.
2. Flutter charge les métadonnées et appelle `createWatchSession`.
3. Cloud Functions vérifie Firebase Auth, `content_access_rules` et `user_entitlements`.
4. Si refusé, Flutter affiche une demande d'accès/code.
5. Si un code est saisi, Flutter appelle `validateAccessCode`.
6. Cloud Functions valide le code en transaction et crée un entitlement.
7. Flutter relance `createWatchSession`.
8. À terme, Cloud Functions renvoie une URL signée courte ou un manifeste HLS protégé.

## Options techniques

### URLs signées courtes Storage

Approche simple pour MVP:

- stockage privé;
- Cloud Function génère une URL signée à courte durée;
- `watch_sessions` trace l'émission;
- expiration en minutes.

Limites:

- l'URL reste partageable jusqu'à expiration;
- contrôle limité sur le streaming adaptatif;
- pas de DRM.

### Cloud CDN signé

Approche plus robuste:

- médias derrière CDN;
- signed cookies ou signed URLs;
- expiration courte;
- meilleure performance globale.

Limites:

- configuration infrastructure plus lourde;
- demande une stratégie de cache, origin et invalidation.

### Cloud Functions comme passerelle

Approche possible pour tokens et sessions, pas idéale pour servir la vidéo brute:

- bonne pour vérifier droits;
- bonne pour créer une session;
- mauvaise pour proxy vidéo longue durée à cause des coûts, timeouts et performances.

### HLS/DASH

Nécessaire pour une expérience streaming premium:

- bitrate adaptatif;
- démarrage plus rapide;
- meilleure gestion réseau;
- sous-titres et pistes audio plus propres.

HLS seul ne sécurise pas le contenu. Il doit être couplé à des manifests/segments protégés ou signés.

### DRM futur

Pour un catalogue premium sensible:

- Widevine Android/Web;
- FairPlay iOS/Safari;
- PlayReady selon cible;
- fournisseur DRM ou packager compatible.

Ce n'est pas requis dans le sprint P2, mais l'architecture `/watch` + `watch_sessions` prépare cette évolution.

## App Check

Firebase App Check doit être activé pour réduire les appels automatisés non légitimes:

- App Attest / DeviceCheck iOS;
- Play Integrity Android;
- reCAPTCHA Enterprise Web.

App Check ne remplace pas Auth ni les entitlements. C'est une barrière supplémentaire.

## Storage rules

Pour un produit premium:

- ne pas rendre les fichiers vidéo publics;
- interdire les reads directs client sur les chemins vidéo privés;
- servir via signed URL/CDN après validation serveur;
- séparer posters/backdrops publics et fichiers vidéo privés.

## Limites temporaires MVP

Le sprint P2 prépare les fondations, mais le projet peut encore contenir `videoUrl` dans Firestore pendant la transition. Tant que ces URLs sont durables ou publiques, l'accès n'est pas pleinement sécurisé.

La priorité suivante est de remplacer `videoUrl` par un identifiant asset interne, puis de résoudre l'URL de lecture exclusivement via `createWatchSession` / `getSignedVideoUrl`.

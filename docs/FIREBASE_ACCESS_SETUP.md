# Firebase Access Setup - Guezs Films

Date: 2026-06-11  
Objet: exploitation Firebase du système d'accès premium MVP.

## Pré-requis

- Firebase CLI installé et connecté: `firebase login`
- Projet Firebase sélectionné: `firebase use <project-id>`
- Droits admin Firestore/Functions pour les scripts.
- Node.js compatible Firebase Functions.
- Aucun code brut ne doit être commité.

## 1. Installer les dépendances des scripts admin

Les scripts P2.5 sont dans `scripts/admin/` et utilisent `firebase-admin`.

```powershell
cd C:\projets\FlutterProjects\guezs_films\scripts\admin
npm install
```

Authentification recommandée:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\chemin\vers\serviceAccountKey.json"
```

Le fichier de clé doit rester local. `scripts/.gitignore` ignore `serviceAccountKey.json`, `node_modules/` et les fichiers `.env`.

## 2. Créer un code ambassadeur

Exemple film:

```powershell
cd C:\projets\FlutterProjects\guezs_films\scripts\admin
node create_access_code.js `
  --code AMB-MURIEL-2026 `
  --ambassadorName "Muriel Blanche" `
  --grantType ambassadorCode `
  --contentType film `
  --filmId elle-et-moi `
  --maxUses 500 `
  --durationDays 30 `
  --active true
```

Le script:

- normalise le code;
- calcule `sha256(codeNormalisé)`;
- écrit `access_codes/{hash}`;
- ne stocke jamais le code brut.

Mode aperçu sans écriture:

```powershell
node create_access_code.js --code DEMO-CODE --contentType global --dryRun
```

## 3. Créer une règle d'accès

Film nécessitant un code:

```powershell
node create_content_access_rule.js `
  --contentType film `
  --filmId elle-et-moi `
  --accessMode codeRequired `
  --active true
```

Série premium:

```powershell
node create_content_access_rule.js `
  --contentType series `
  --seriesId serie-premium `
  --accessMode premium `
  --active true
```

Épisode gratuit:

```powershell
node create_content_access_rule.js `
  --contentType episode `
  --seriesId serie-a `
  --seasonId saison-1 `
  --episodeId episode-1 `
  --accessMode free
```

Modes supportés:

- `free`
- `codeRequired`
- `premium`
- `purchaseRequired`

## 4. Créer un contenu gratuit

Global gratuit, utile pour démonstration uniquement:

```powershell
node create_content_access_rule.js --contentType global --accessMode free --active true
```

Pour un MVP premium, préférer des règles précises par film/série/épisode plutôt qu'un `global free` permanent.

## 5. Créer des données de démonstration

```powershell
node seed_access_demo.js --confirm-demo
```

Ce script crée:

- une règle `global` gratuite;
- un film démo nécessitant un code;
- un code ambassadeur démo hashé;
- une règle série premium démo.

Les valeurs sont marquées `demo: true` et ne doivent pas être utilisées en production.

## 6. Tester `validateAccessCode`

Avec l'émulateur Functions:

```powershell
firebase emulators:start --only functions,firestore
```

Depuis l'application Flutter connectée à Firebase, ouvrir un contenu `/watch/...`, saisir un code dans le dialogue, puis vérifier:

- `access_codes/{hash}.usedCount` incrémenté;
- création ou mise à jour dans `user_entitlements`;
- aucun code brut stocké.

Pour un test HTTP manuel, utiliser un client capable d'appeler une callable function Firebase avec un token Auth valide. Les callables ne sont pas de simples endpoints REST anonymes.

## 7. Tester `createWatchSession`

Flux attendu:

1. utilisateur connecté;
2. ouverture `/watch/film/:filmId`;
3. Flutter appelle `createWatchSession`;
4. si accès accordé, Firestore reçoit `watch_sessions/{sessionId}`;
5. si accès refusé, l'UI affiche "Débloquer l'accès".

À vérifier dans Firestore:

- `watch_sessions.uid`;
- `contentType`, `filmId` ou `seriesId/seasonId/episodeId`;
- `status = active`;
- `expiresAt` court.

## 8. Déployer les Functions

Validation locale:

```powershell
node --check functions\index.js
```

Déploiement:

```powershell
firebase deploy --only functions
```

Déployer également les rules/indexes:

```powershell
firebase deploy --only firestore:rules,firestore:indexes
```

## 9. Activer App Check plus tard

App Check doit être activé après stabilisation:

- Android: Play Integrity;
- iOS: App Attest / DeviceCheck;
- Web: reCAPTCHA Enterprise.

Ensuite:

- activer enforcement pour Functions;
- activer enforcement pour Firestore/Storage selon besoin;
- surveiller les erreurs avant enforcement strict.

## 10. Passer du MVP aux signed URLs

État MVP:

- `createWatchSession` vérifie les droits;
- `PlayerPage` utilise encore `videoUrl` Firestore si `playbackUrl` est vide.

Étape suivante:

1. retirer les URLs durables des documents publics;
2. stocker un `videoAssetId` privé;
3. implémenter `getSignedVideoUrl`;
4. générer des URLs courtes Storage ou Cloud CDN;
5. retourner `WatchAccessResult.playbackUrl`;
6. expirer les sessions rapidement;
7. journaliser les émissions d'URL.

## 11. Ne jamais publier de codes bruts

À faire:

- distribuer les codes uniquement hors dépôt;
- stocker uniquement `sha256(codeNormalisé)`;
- limiter `maxUses`;
- ajouter `startsAt` et `expiresAt`;
- révoquer via `active=false`.

À ne pas faire:

- commiter une liste de codes;
- mettre un code dans Flutter;
- utiliser le code brut comme document ID;
- rendre `access_codes` lisible côté client.

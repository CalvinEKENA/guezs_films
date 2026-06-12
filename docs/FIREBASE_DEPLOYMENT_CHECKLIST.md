# Checklist de déploiement Firebase

Projet cible: `guezs-films`

## Préparation

```powershell
firebase login
firebase use guezs-films
firebase projects:list
```

Vérifier la région callable dans:

`lib/core/config/firebase_runtime_config.dart`

La valeur actuelle est `us-central1`. Elle doit rester alignée avec la région des Cloud Functions déployées.

## Déploiement

Rules:

```powershell
firebase deploy --only firestore:rules --project guezs-films
```

Indexes:

```powershell
firebase deploy --only firestore:indexes --project guezs-films
```

Functions:

```powershell
node --check functions/index.js
firebase deploy --only functions --project guezs-films
```

Déploiement complet si nécessaire:

```powershell
flutter build web --release
firebase deploy --project guezs-films
```

Vérifier les Functions:

```powershell
firebase functions:list --project guezs-films
```

Les callables suivantes doivent apparaître en `us-central1`:

- `createWatchSession`
- `validateAccessCode`
- `getSignedVideoUrl`
- `deleteMyAccount`

État constaté le 12 juin 2026: seules `generateFilmSearchTokens` et
`generateSeriesSearchTokens` sont déployées. Ne désactivez pas le fallback MVP
avant d’avoir déployé et testé les callables d’accès.

## Déblocage MVP temporaire

Installer les dépendances:

```powershell
npm --prefix scripts/admin install
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\chemin\serviceAccountKey.json"
```

Créer la règle globale gratuite:

```powershell
node scripts/admin/seed_all_content_free_mvp.js
```

Cette règle écrit `content_access_rules/global` avec `accessMode: free`. Elle est réservée aux tests et bêta privée.

Contrôler ensuite le document dans la console Firebase avant de tester la lecture.

Créer une règle nécessitant un code:

```powershell
node scripts/admin/create_content_access_rule.js `
  --contentType film `
  --filmId FILM_ID `
  --accessMode codeRequired
```

Créer un code ambassadeur:

```powershell
node scripts/admin/create_access_code.js `
  --code CODE_PRIVE `
  --contentType film `
  --filmId FILM_ID `
  --durationDays 30 `
  --maxUses 100
```

## Test depuis l’application

1. Se connecter.
2. Ouvrir un film avec une `videoUrl` valide.
3. Utiliser `Routes.filmWatchPath`.
4. Vérifier la création de `watch_sessions`.
5. Tester un contenu `codeRequired`.
6. Vérifier qu’un code invalide ne déclenche aucun fallback.
7. Tester un épisode avec `Routes.episodeWatchPath`.

## Fallback direct MVP

Le fallback direct est activé par défaut pour ce hotfix:

```text
ALLOW_DIRECT_VIDEO_FALLBACK_MVP=true
```

Il s’applique uniquement lorsque:

- la Function est absente (`not-found`);
- ou le service est temporairement indisponible;
- et une `videoUrl` Firestore non vide existe.

Il ne s’applique jamais pour:

- un utilisateur invité;
- un code requis;
- un accès refusé;
- un code invalide ou expiré.

Avant production publique:

```powershell
flutter build web --release `
  --dart-define=ALLOW_DIRECT_VIDEO_FALLBACK_MVP=false
```

Le fallback doit être désactivé après déploiement des Functions, configuration des règles et mise en place des URLs signées ou du CDN sécurisé.

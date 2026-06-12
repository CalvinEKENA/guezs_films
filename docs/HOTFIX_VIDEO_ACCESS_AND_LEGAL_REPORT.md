# Hotfix accès vidéo et pages légales

Date: 2026-06-12

## Cause du blocage vidéo

L’application Flutter cible correctement le projet Firebase `guezs-films`.

Le contrôle live:

```powershell
firebase functions:list --project guezs-films
```

a montré que seules les Functions suivantes étaient déployées:

- `generateFilmSearchTokens`;
- `generateSeriesSearchTokens`.

Les callables attendues par le player étaient absentes:

- `createWatchSession`;
- `validateAccessCode`;
- `getSignedVideoUrl`.

Firebase retournait donc `not-found`. Le repository transformait cette erreur en état générique et les pages Watch bloquaient la lecture avant d’utiliser la `videoUrl` Firestore existante.

Ce diagnostic a été confirmé le 12 juin 2026 sur le projet live
`guezs-films`, en région `us-central1`.

## Corrections accès vidéo

- projet Firebase centralisé: `guezs-films`;
- région Functions explicite: `us-central1`;
- `FirebaseFunctions.instanceFor(region: ...)`;
- mapping clair de `not-found`, `unavailable`, `permission-denied`, `unauthenticated`, `failed-precondition`, `internal` et `deadline-exceeded`;
- aucun code technique `not_found` affiché;
- nouveau statut `serviceNotDeployed`;
- fallback direct MVP contrôlé pour film et épisode;
- décision de fallback centralisée et testable;
- message propre lorsque la source vidéo est absente.

Le fallback ne contourne jamais:

- le login;
- un code requis;
- un accès refusé;
- un code invalide ou expiré.

## Comportement avant et après

Avant:

- `createWatchSession` absent;
- erreur générique “Accès indisponible”;
- lecture bloquée malgré une `videoUrl` valide.

Après:

- erreur Firebase explicite et documentée;
- lecture directe temporaire si le service est absent ou indisponible et si une URL existe;
- architecture `/watch/...` et entitlements conservée;
- refus métier toujours respectés.

## Mise en service Firebase

```powershell
firebase use guezs-films
firebase deploy --only firestore:rules --project guezs-films
firebase deploy --only firestore:indexes --project guezs-films
firebase deploy --only functions --project guezs-films
firebase functions:list --project guezs-films
```

Règle gratuite MVP:

```powershell
node scripts/admin/seed_all_content_free_mvp.js
```

Le script cible explicitement `guezs-films` et écrit:

`content_access_rules/global`

avec `accessMode: free`, `active: true`, `demo: false`.

Ni le déploiement des Functions ni l’écriture de cette règle Firestore n’ont
été exécutés pendant le hotfix. Ces opérations modifient l’environnement live
et restent à déclencher explicitement avec la checklist.

## Pages ajoutées

- Support GUEZS FILMS;
- Politique de confidentialité;
- Conditions d’utilisation.

Les pages sont:

- accessibles depuis “Assistance & légal” dans le profil;
- disponibles sur routes publiques dédiées;
- responsives;
- lisibles sur mobile et Web;
- structurées en cartes;
- dotées d’un retour propre.

## Fichiers principaux modifiés

- `lib/core/config/firebase_runtime_config.dart`
- `lib/features/access/domain/entities/watch_access_result.dart`
- `lib/features/access/data/repositories/cloud_functions_watch_access_repository.dart`
- `lib/features/access/presentation/providers/watch_access_providers.dart`
- `lib/features/player/presentation/pages/watch_film_page.dart`
- `lib/features/player/presentation/pages/watch_episode_page.dart`
- `lib/features/player/domain/services/mvp_playback_fallback.dart`
- `lib/core/routes/route_constants.dart`
- `lib/core/routes/app_router.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/legal/presentation/widgets/legal_page_scaffold.dart`
- `lib/features/legal/presentation/pages/support_page.dart`
- `lib/features/legal/presentation/pages/privacy_policy_page.dart`
- `lib/features/legal/presentation/pages/terms_of_use_page.dart`
- `scripts/admin/_access_admin_utils.js`
- `scripts/admin/package.json`
- `scripts/admin/seed_all_content_free_mvp.js`
- `docs/FIREBASE_DEPLOYMENT_CHECKLIST.md`
- `test/widget_test.dart`

## Limites restantes

- le fallback direct expose une URL durable et n’est pas une sécurité de production;
- `getSignedVideoUrl` reste un stub;
- les vidéos doivent migrer vers un stockage privé ou CDN signé;
- App Check et rate limiting restent à ajouter;
- WhatsApp support doit être renseigné;
- les textes juridiques sont une base de travail à faire valider.

## Recommandations avant production

1. Déployer les callables dans `us-central1`.
2. Configurer les règles d’accès par contenu.
3. Désactiver `ALLOW_DIRECT_VIDEO_FALLBACK_MVP`.
4. Remplacer les URLs directes par des URLs signées courtes.
5. Faire valider les textes par un conseil juridique.
6. Publier une adresse et un numéro Support opérationnels.

## Validation

Commandes exécutées:

```powershell
node --check functions/index.js
node --check scripts/admin/*.js
flutter analyze --no-pub lib test
flutter test --no-pub test\widget_test.dart
flutter build web --release
firebase functions:list --project guezs-films
```

Résultats:

- syntaxe Functions et scripts admin: OK;
- analyse Flutter: aucune anomalie;
- tests: 23 réussis;
- build Web release: OK, sortie `build/web`;
- aucune importation `dart:io` bloquante dans le graphe Web;
- routes locales `/support`, `/privacy-policy` et `/terms-of-use`: HTTP 200;
- Functions live: seules `generateFilmSearchTokens` et
  `generateSeriesSearchTokens` sont actuellement déployées.

Le build signale uniquement les incompatibilités Wasm connues de
`flutter_secure_storage_web`. Elles n’empêchent pas le build JavaScript Web
actuel.

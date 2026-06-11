# Rapport P2 - Fondations d'accès vidéo premium

Date: 2026-06-11  
Branche: `main`  
Objectif: préparer un système d'accès vidéo sécurisé sans paiement réel ni DRM.

## Architecture retenue

P2 ajoute une couche d'accès premium entre les routes `/watch` et `PlayerPage`:

- `WatchFilmPage` et `WatchEpisodePage` chargent le contenu;
- les pages vérifient l'utilisateur connecté;
- elles appellent `createWatchSession` via un repository Flutter;
- si le serveur accorde l'accès, `PlayerPage` reçoit l'URL de lecture;
- si le serveur refuse, l'utilisateur peut saisir un code via un dialogue;
- le dialogue appelle `validateAccessCode`, sans aucun code hardcodé côté client.

La route legacy `/player` reste inchangée pour les téléchargements locaux.

## Fichiers créés

- `lib/features/access/domain/entities/access_scope.dart`
- `lib/features/access/domain/entities/access_grant.dart`
- `lib/features/access/domain/entities/access_code.dart`
- `lib/features/access/domain/entities/entitlement.dart`
- `lib/features/access/domain/entities/watch_access_result.dart`
- `lib/features/access/domain/repositories/watch_access_repository.dart`
- `lib/features/access/data/repositories/cloud_functions_watch_access_repository.dart`
- `lib/features/access/presentation/providers/watch_access_providers.dart`
- `docs/FIRESTORE_ENTITLEMENT_SCHEMA.md`
- `docs/VIDEO_SECURITY_STRATEGY.md`
- `docs/P2_VIDEO_ACCESS_REPORT.md`

## Fichiers modifiés

- `pubspec.yaml`
- `pubspec.lock`
- `functions/index.js`
- `firestore.rules`
- `firestore.indexes.json`
- `lib/core/routes/app_router.dart`
- `lib/core/widgets/promo_code_dialog.dart`
- `lib/features/player/presentation/pages/watch_film_page.dart`
- `lib/features/player/presentation/pages/watch_episode_page.dart`
- `lib/features/details/presentation/pages/details_page.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/series/presentation/pages/series_details_page.dart`
- `test/widget_test.dart`

## Cloud Functions ajoutées

### `validateAccessCode`

- exige Firebase Auth;
- normalise le code;
- cherche `access_codes/{sha256(code)}`;
- vérifie activation, fenêtre temporelle et limite d'utilisation;
- vérifie que le scope du code correspond au contenu demandé;
- crée/merge un document `user_entitlements`;
- incrémente `usedCount` en transaction;
- retourne un `WatchAccessResult` clair.

### `createWatchSession`

- exige une requête contenu par ID métier;
- vérifie `content_access_rules`;
- vérifie les `user_entitlements` actifs de l'utilisateur;
- crée un document `watch_sessions`;
- retourne `sessionId`, expiration courte et résultat d'accès.

### `getSignedVideoUrl`

- stub volontaire;
- retourne `unavailable`;
- documente le point d'extension pour Storage/CDN signé.

## UX d'accès

Le dialogue affiche maintenant:

- "Débloquer l’accès";
- champ code;
- bouton "Valider";
- option "Je n’ai pas de code";
- message refusé;
- message accordé.

Il ne contient plus de code promo hardcodé.

## Ce qui est prêt pour paiement futur

- `AccessGrantType.purchase`;
- `user_entitlements.source = purchase`;
- scope global/film/série/épisode;
- expiration optionnelle;
- session de lecture séparée du moyen d'achat;
- repository Flutter indépendant du futur fournisseur de paiement.

Un futur webhook paiement pourra créer un `user_entitlements` sans changer le player.

## Ce qui est prêt pour signed URLs futures

- `WatchAccessResult.playbackUrl`;
- `watch_sessions`;
- stub `getSignedVideoUrl`;
- `WatchFilmPage` et `WatchEpisodePage` utilisent `playbackUrl` serveur en priorité si elle est renvoyée;
- fallback MVP sur `videoUrl` Firestore conservé temporairement.

## Limites restantes

- Les URLs vidéo Firestore peuvent encore être durables pendant la transition.
- `getSignedVideoUrl` n'est pas encore branchée à Storage/CDN.
- Pas de HLS/DASH.
- Pas de DRM.
- Pas de paiement réel.
- Pas de conservation de la route demandée après login invité.
- Les règles de classification d'erreur restent simples côté Flutter.
- Les fonctions doivent être déployées avant que le flux d'accès premium fonctionne en production.

## Validation exécutée

- `node --check functions/index.js`: OK
- `flutter analyze --no-pub lib test`: OK, `No issues found!`
- `flutter test --no-pub test\widget_test.dart`: OK, `All tests passed!`
- `flutter build web --release`: OK, `Built build\web`

Le build Web JavaScript reste valide. Le dry-run Wasm signale toujours les incompatibilités déjà connues autour de `flutter_secure_storage_web`, `dart:html` et `dart:js`.

## Prochaines étapes

1. Créer les premiers documents `content_access_rules`.
2. Générer les premiers `access_codes` hashés via script admin.
3. Déployer les Cloud Functions.
4. Remplacer `videoUrl` par un asset ID privé.
5. Implémenter `getSignedVideoUrl` avec Storage ou Cloud CDN.
6. Activer Firebase App Check.
7. Ajouter tests unitaires Functions avec emulator.
8. Ajouter conservation du redirect après login.
9. Ajouter analytics de session et reprise de lecture.
10. Préparer l'intégration paiement par création d'entitlements serveur.

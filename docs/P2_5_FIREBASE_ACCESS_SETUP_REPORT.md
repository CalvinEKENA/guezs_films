# Rapport P2.5 - Firebase Access Setup

Date: 2026-06-11  
Objectif: rendre exploitable le système d'accès premium côté Firebase sans paiement réel, sans DRM et sans casser Web.

## Fichiers créés

- `scripts/admin/package.json`
- `scripts/admin/_access_admin_utils.js`
- `scripts/admin/create_access_code.js`
- `scripts/admin/create_content_access_rule.js`
- `scripts/admin/seed_access_demo.js`
- `docs/FIREBASE_ACCESS_SETUP.md`
- `docs/P2_5_FIREBASE_ACCESS_SETUP_REPORT.md`

## Fichiers modifiés

- `firebase.json`
- `firestore.rules`
- `docs/FIRESTORE_ENTITLEMENT_SCHEMA.md`

## Scripts disponibles

### `create_access_code.js`

Crée ou met à jour `access_codes/{sha256(codeNormalisé)}`.

Exemple:

```powershell
node scripts/admin/create_access_code.js --code AMB-TEST-2026 --contentType film --filmId elle-et-moi --durationDays 30 --maxUses 100
```

Le code brut n'est jamais stocké dans Firestore.

### `create_content_access_rule.js`

Crée ou met à jour `content_access_rules/{ruleId}`.

Exemple:

```powershell
node scripts/admin/create_content_access_rule.js --contentType film --filmId elle-et-moi --accessMode codeRequired
```

### `seed_access_demo.js`

Crée des données de démonstration marquées `demo: true`.

Exemple:

```powershell
node scripts/admin/seed_access_demo.js --confirm-demo
```

## Règles Firestore vérifiées

Les collections sensibles sont protégées:

- `access_codes`: aucun accès client;
- `content_access_rules`: aucun accès client;
- `user_entitlements`: lecture uniquement par propriétaire, aucune écriture client;
- `watch_sessions`: lecture uniquement par propriétaire, aucune écriture client.

Les Cloud Functions et scripts admin utilisent l'Admin SDK et ne sont pas bloqués par ces rules.

## Configuration Emulator

`firebase.json` contient maintenant:

- Firestore emulator: port `8080`;
- Functions emulator: port `5001`;
- Emulator UI: port `4000`;
- `singleProjectMode: true`.

Commande:

```powershell
firebase emulators:start --only functions,firestore
```

## Limites restantes

- Les scripts supposent des credentials admin locaux via ADC ou `GOOGLE_APPLICATION_CREDENTIALS`.
- Les tests callable nécessitent un utilisateur Firebase Auth valide.
- `getSignedVideoUrl` reste un stub.
- Le fallback MVP `videoUrl` Firestore est conservé.
- Les scripts ne génèrent pas encore de lots CSV ni de rotation automatique de codes.
- Aucun paiement ni DRM n'est intégré.

## Prochaines étapes

1. Installer `firebase-admin` dans `scripts/admin`.
2. Créer les premières règles `content_access_rules` de production.
3. Générer les codes ambassadeurs réels hors dépôt.
4. Déployer Functions + Firestore rules/indexes.
5. Tester validateAccessCode et createWatchSession dans l'émulateur.
6. Activer App Check en mode monitoring.
7. Remplacer progressivement `videoUrl` par un asset privé.
8. Implémenter `getSignedVideoUrl`.
9. Ajouter tests unitaires Cloud Functions.
10. Ajouter scripts de révocation et audit des codes.

## Résultats de validation

- `node --check functions/index.js`: OK
- `node --check scripts/admin/_access_admin_utils.js`: OK
- `node --check scripts/admin/create_access_code.js`: OK
- `node --check scripts/admin/create_content_access_rule.js`: OK
- `node --check scripts/admin/seed_access_demo.js`: OK
- `flutter analyze --no-pub lib test`: OK, `No issues found!`
- `flutter test --no-pub test\widget_test.dart`: OK, `All tests passed!`
- `flutter build web --release`: OK, `Built build\web`

Le build Web JavaScript reste valide. Le dry-run Wasm signale toujours les limites connues de `flutter_secure_storage_web` avec `dart:html` et `dart:js`.

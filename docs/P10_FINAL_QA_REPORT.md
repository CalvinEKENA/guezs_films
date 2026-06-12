# Rapport P10 - Stabilisation finale et release readiness

Date: 2026-06-12
Périmètre: application Flutter, Web, Android, Firebase, Functions, scripts, documentation et sous-projet historique.

## Conclusion

GUEZS FILMS est prêt pour:

- une démonstration partenaire sérieuse;
- une bêta privée Web et Android;
- une présentation produit avec catalogue, accès et lecture.

Le produit n'est pas encore prêt pour une production publique premium à grande échelle. Les principaux prérequis restants sont les URLs vidéo signées, App Check, des tests Firebase comportementaux et une stratégie HLS/DASH/CDN.

## Commandes exécutées

```powershell
flutter doctor -v
flutter analyze --no-pub lib test
flutter test --no-pub
flutter build web --release
flutter build apk --release
node --check functions/index.js
node --check scripts/admin/*.js
node --check scripts/seed_content.js
node --check scripts/fix_photos.js
firebase emulators:exec --only firestore "cmd /c echo FIRESTORE_RULES_OK"
```

Contrôles complémentaires:

- chargement de `functions/index.js` par Node;
- validation JSON de `firebase.json`, `firestore.indexes.json` et `web/manifest.json`;
- vérification APK avec `apksigner`;
- test Firebase Hosting des routes directes;
- scan des imports `dart:io`;
- scan des secrets et fichiers sensibles suivis par Git;
- comparaison du projet racine avec `guezs_films_site/`.

## Résultats

| Contrôle | Résultat |
| --- | --- |
| Flutter analyze | OK, aucun problème |
| Tests Flutter | OK, 19 tests |
| Build Web release | OK, `build/web` |
| Syntaxe Functions | OK |
| Syntaxe scripts admin | OK |
| Chargement Functions Node | OK |
| Rules Firestore | Émulateur démarré, rules chargées |
| Refresh `/home` | HTTP 200 |
| Refresh `/film/:id` | HTTP 200 |
| Refresh `/series/:id` | HTTP 200 |
| Refresh `/watch/film/:id` | HTTP 200 |
| Refresh épisode | HTTP 200 |
| Build APK release | OK |
| Signature APK | OK, schéma v2, un signataire |
| Build iOS | Non exécuté, environnement Windows |

APK:

- chemin: `build/app/outputs/flutter-apk/app-release.apk`;
- taille: 71 828 480 octets;
- SHA-256: `1431BEEC26425F04FAAE0CD91A261C856FA39D0E1CFB947F0DC5920199DE3E15`.

Le build Web JavaScript est réussi. Le dry run Wasm signale encore `flutter_secure_storage_web` et ses dépendances historiques `dart:html`, `dart:js` et `dart:js_util`.

Le navigateur intégré de l'environnement n'a pas pu ouvrir sa session de contrôle. Le build a néanmoins été validé par tests widget, HTTP local et émulateur Firebase Hosting sur toutes les routes critiques.

## Bugs et risques corrigés

### Web et navigation

- ajout de Firebase Hosting sur `build/web`;
- ajout du rewrite SPA vers `index.html`;
- validation des refresh directs sur les routes métier;
- page introuvable remplacée par un état produit en français;
- suppression de l'URL technique dans l'état 404;
- logs GoRouter limités au mode debug.

### PWA

- titre HTML GUEZS FILMS;
- description, langue, thème et métadonnées sociales;
- manifest renommé et recoloré avec les tokens cinéma;
- suppression de l'orientation portrait forcée dans le manifest;
- icônes existantes conservées.

### Auth et compte

- suppression des messages Firebase/IP techniques sur la page de connexion;
- feedback d'authentification uniformisé;
- suppression de compte déplacée vers la Function idempotente `deleteMyAccount`;
- réauthentification récente obligatoire;
- suppression serveur des profils, favoris, entitlements et sessions;
- suppression Firebase Auth effectuée après le nettoyage serveur;
- nettoyage local conservé.

### Firestore et accès premium

- un utilisateur ne peut plus écrire `isPremium`, rôle ou facturation sur son document;
- champs client du profil explicitement limités;
- codes d'accès bruts non affichés par le script d'administration;
- seeds de démonstration protégés par un flag explicite;
- le script de réparation publique ne publie plus les MP4;
- les fenêtres temporelles des règles gratuites sont maintenant appliquées.

### Performance

- suppression d'un fallback image codé pour un titre précis;
- dimensions de cache mémoire/disque calculées lorsque le widget connaît sa taille;
- wrappers image inutilisés supprimés;
- player confirmé robuste sur timers, listeners, dispose et sauvegarde locale;
- `BackdropFilter` limité à quelques surfaces structurelles, pas aux cellules de listes.

### Accessibilité et UX

- navigation principale focusable;
- profils activables au clavier;
- labels sémantiques et cibles tactiles renforcés;
- états d'erreur, chargement et absence harmonisés;
- fonctions indisponibles présentées honnêtement.

## Tests ajoutés

- stabilité des helpers de routes détails et watch;
- erreurs de configuration Auth non techniques;
- recherche premium et seuil de deux caractères;
- navigation résultat vers détails;
- player sans source;
- route watch film;
- détails film et série;
- états P9;
- branche téléchargements desktop;
- profil invité;
- profils standard/enfant;
- page introuvable sans fuite de chemin technique.

## Risques restants

### Bloquants avant production publique

- `videoUrl` peut encore exposer une URL durable depuis les documents catalogue;
- `getSignedVideoUrl` n'est pas connecté à un stockage privé ou CDN;
- aucun DRM;
- App Check non imposé;
- pas de limitation serveur dédiée contre le brute force des codes;
- pas de tests automatisés des permissions Firestore par identité;
- pas de monitoring de lecture, erreurs Functions ou abus;
- politique de confidentialité et conditions encore non publiées;
- suppression de compte serveur à déployer avant d'exposer l'action en production.

### Acceptables pour bêta privée

- avertissement Wasm, le build JavaScript reste supporté;
- 104 dépendances ont des versions plus récentes incompatibles avec les contraintes actuelles;
- pas de build iOS depuis cet environnement;
- progression de lecture locale uniquement;
- qualité, sous-titres et audio non fonctionnels mais clairement désactivés;
- APK relativement lourd, 68,5 Mio;
- tests d'intégration mobile téléchargements/player encore manuels.

## Firebase readiness

Prêt:

- rules et indexes déclarés;
- Functions syntaxiquement valides;
- codes hashés;
- transactions pour consommation des codes;
- entitlements et sessions serveur;
- suppression de compte serveur;
- scripts Admin avec confirmation.

À faire avant production:

1. Déployer `firestore:rules`, `firestore:indexes` et `functions`.
2. Tester `deleteMyAccount` sur un projet staging.
3. Activer App Check progressivement.
4. Remplacer les vidéos publiques par des assets privés.
5. Ajouter rate limiting, alertes et logs structurés.
6. Tester les rules avec plusieurs identités et cas d'attaque.

## Recommandation `guezs_films_site`

Recommandation: **archiver puis supprimer du tronc principal**.

Constats:

- le sous-projet contient 125 fichiers suivis;
- ses corrections Web utiles ont été réintégrées;
- les assets Play Store existent déjà dans le projet racine;
- le projet racine a largement divergé avec P1 à P10;
- conserver deux applications augmente le risque de mauvais build et de correctifs appliqués au mauvais arbre.

Procédure:

1. créer un tag ou une branche d'archive;
2. vérifier avec l'équipe qu'aucun pipeline externe ne pointe vers ce dossier;
3. supprimer `guezs_films_site/` dans un sprint de nettoyage dédié;
4. conserver `docs/GUEZS_FILMS_SITE_MERGE_PLAN.md` comme trace.

## Recommandations avant bêta privée

1. Déployer sur un projet Firebase staging.
2. Tester connexion, profils, favoris, code, lecture et suppression de compte.
3. Distribuer l'APK par canal privé.
4. Utiliser uniquement des codes limités et expirables.
5. Surveiller Functions, Auth et Firestore quotidiennement.
6. Publier au minimum une politique de confidentialité provisoire.

## Recommandations avant production publique

1. Mettre les vidéos derrière URLs signées ou CDN signé.
2. Ajouter HLS/DASH et protection des manifests.
3. Activer App Check et rate limiting.
4. Ajouter tests Firebase, tests mobiles et CI/CD.
5. Valider iOS sur macOS.
6. Générer AAB, symboles et procédure de rollback.
7. Mettre en place crash reporting, analytics et alertes.
8. Faire relire les règles et le flux d'accès par un audit sécurité externe.

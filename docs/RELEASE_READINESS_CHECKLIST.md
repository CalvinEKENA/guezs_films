# GUEZS FILMS - Release Readiness Checklist

Date de contrôle: 2026-06-12

## Qualité obligatoire

- [x] `flutter analyze --no-pub lib test`
- [x] `flutter test --no-pub`
- [x] `flutter build web --release`
- [x] `node --check functions/index.js`
- [x] scripts Admin syntaxiquement valides
- [x] JSON Firebase, indexes et manifest valides
- [x] APK release généré et signé
- [ ] build iOS validé sur macOS

## Web

- [x] titre et description GUEZS FILMS
- [x] thème PWA cinéma
- [x] icônes PWA présentes
- [x] Firebase Hosting configuré
- [x] rewrite SPA configuré
- [x] refresh `/home`
- [x] refresh `/film/:id`
- [x] refresh `/series/:id`
- [x] refresh `/watch/film/:id`
- [x] refresh route épisode
- [x] pas de `dart:io` dans le graphe Web actif
- [ ] compatibilité Wasm
- [ ] domaine de production et HTTPS final vérifiés

## Mobile

- [x] configuration Android release
- [x] keystore local présent
- [x] APK signé vérifié
- [x] orientation player restaurée
- [x] téléchargements isolés du Web
- [ ] test sur appareil Android physique
- [ ] test reprise/pause/suppression téléchargement
- [ ] build AAB Play Console
- [ ] build et test iOS

## Navigation et UX

- [x] routes détails
- [x] routes watch
- [x] `/player` limité au legacy local
- [x] page introuvable produit
- [x] messages d'erreur non techniques
- [x] états vides/loading/error
- [x] navigation clavier minimale
- [x] cibles tactiles et labels principaux
- [ ] audit accessibilité avec lecteur d'écran réel

## Firebase et sécurité

- [x] rules Firestore chargées par l'émulateur
- [x] indexes déclarés
- [x] catalogue en écriture Admin uniquement
- [x] statut premium protégé des écritures client
- [x] access codes hashés
- [x] aucun code brut stocké par le flux prévu
- [x] sessions watch créées côté serveur
- [x] suppression de compte serveur idempotente
- [x] seeds dangereux protégés par confirmation
- [ ] tests automatisés des rules par rôle
- [ ] Function `deleteMyAccount` testée sur staging
- [ ] App Check activé
- [ ] rate limiting des codes
- [ ] vidéos privées et URLs signées
- [ ] DRM selon exigences partenaires

## Données et exploitation

- [x] README d'installation et déploiement
- [x] documentation accès premium
- [x] limites MVP documentées
- [ ] sauvegardes Firestore planifiées
- [ ] procédure rollback documentée
- [ ] monitoring et alertes configurés
- [ ] politique de rétention des sessions
- [ ] politique de confidentialité publiée
- [ ] conditions d'utilisation publiées
- [ ] support utilisateur réel connecté

## Démonstration partenaire

- [x] build Web
- [x] APK release
- [x] parcours catalogue
- [x] recherche
- [x] détails
- [x] player et reprise
- [x] profils, favoris et téléchargements
- [x] accès par code démontrable
- [ ] compte et données de démonstration staging préparés
- [ ] répétition complète sans dépendance à un réseau instable

## Décision

### Démonstration sérieuse

**GO**, sous réserve d'un projet Firebase staging disponible.

### Bêta privée

**GO conditionnel** après déploiement des nouvelles Functions/rules et test manuel de suppression de compte, accès premium et lecture sur appareils cibles.

### Production publique premium

**NO-GO** tant que les vidéos restent exposables par URL durable, qu'App Check/rate limiting ne sont pas activés et que les tests Firebase/iOS/monitoring ne sont pas terminés.

## Sous-projet historique

- [x] éléments uniques audités
- [x] assets Play Store présents dans le projet racine
- [x] corrections Web utiles réintégrées
- [ ] branche ou tag d'archive créé
- [ ] `guezs_films_site/` supprimé du tronc

Recommandation: geler immédiatement, archiver, puis supprimer dans un changement séparé.

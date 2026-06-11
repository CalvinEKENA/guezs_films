# Rapport P4 - Home premium éditoriale

Date: 2026-06-11  
Depot: `C:\projets\FlutterProjects\guezs_films`  
Objectif: refondre la Home en expérience premium, éditoriale, responsive et cinématographique.

## Résumé exécutif

La Home ne se limite plus à un hero unique et deux rails de séries. Elle présente désormais un “Grand Écran” éditorial avec carousel, des badges éditoriaux, des CTA dorés, des rails de contenus premium et une mise en page responsive mobile/tablette/web.

La refonte conserve Riverpod, les providers Firestore existants, l’accès premium P2 et les routes P1. Aucun retour à `/player` n’a été introduit pour le catalogue.

## Fichiers modifiés

- `lib/features/home/presentation/pages/home_page.dart`

## Composants créés

- `lib/core/widgets/section_header.dart`
  - titre;
  - sous-titre optionnel;
  - action “Tout voir” optionnelle;
  - comportement responsive quand l’espace horizontal est réduit.

- `lib/core/widgets/premium_content_card.dart`
  - poster ratio 2:3;
  - titre et metadata;
  - badge discret;
  - hover web;
  - animation de pression mobile;
  - bordure/glow au hover ou focus;
  - fallback image via `CachedImage`;
  - favori optionnel.

## Hero “Grand Écran”

Le hero a été remplacé par un carousel éditorial basé sur les contenus disponibles:

- films `isFeatured`;
- séries `isFeatured`;
- fallback sur les premiers films/séries si aucun contenu featured n’existe;
- fallback vide premium si aucun contenu catalogue n’est disponible.

Le hero affiche:

- backdrop ou poster en fallback;
- overlay sombre lisible;
- gradient latéral pour lecture desktop;
- halo subtil bleu/or via overlays et bordures, sans BackdropFilter;
- titre;
- description courte;
- metadata;
- badges éditoriaux;
- bouton principal doré;
- bouton secondaire “Détails”.

Navigation:

- film: `Routes.filmWatchPath(film.id)`;
- série: `Routes.seriesDetailsPath(series.id)`, car la Home ne dispose pas encore d’un `seasonId`/`episodeId` fiable pour déclencher `episodeWatchPath`.

## Sections créées

Les sections sont masquées quand elles sont vides:

- `Sous les projecteurs`
- `Sélections officielles`
- `Nouveautés`
- `Recommandés pour vous`
- `Films`
- `Séries`
- `Ciné-club camerounais`

`Continuer la lecture` reste volontairement masquée, faute de provider de progression de lecture fiable dans ce sprint.

## Badges

Les badges sont dérivés des données existantes:

- `Sélection officielle`: contenu featured;
- `Nouveau`: film `isNew` ou série récemment créée;
- `Avant-première`: contenu récemment ajouté ou série courte;
- `Exclusif`: film avec note élevée;
- `GUEZS Original`: fallback éditorial.

Aucun champ Firestore lourd n’a été ajouté.

## États UX

États ajoutés ou améliorés:

- hero loading premium;
- rails loading shimmer;
- erreur catalogue bloquante;
- catalogue vide;
- featured absent;
- image manquante via fallback `CachedImage`;
- sections vides masquées.

## Responsive

Mobile 360px / 430px:

- hero vertical lisible;
- CTA en deux colonnes flexibles;
- cards 2:3 compactes;
- paddings 16px;
- rail horizontal sans overflow.

Tablette:

- hero plus haut;
- paddings 32px;
- cards plus larges;
- rails plus espacés.

Web 1280px / 1440px+:

- largeur de contenu limitée à 1360px;
- paddings 64px;
- hero horizontal avec contenu éditorial à gauche et poster preview à droite;
- cards 176px;
- rails plus respirants;
- app bar plus stable au scroll.

## Performance

- Pas de BackdropFilter dans les rails de contenus.
- Pas d’animations simultanées par item avec `flutter_animate`.
- Le scroll ne reconstruit plus toute la Home à chaque pixel: l’opacité de l’app bar ne déclenche `setState` qu’au-delà d’un seuil.
- Les sections sont dérivées localement depuis les providers existants.
- Les rails masquent les listes vides au lieu de construire des placeholders inutiles.

## Limites restantes

- Pas encore de route “Tout voir” dédiée par section; l’action existante pointe vers Search.
- Pas de provider réel pour `Continuer la lecture`.
- Pas de personnalisation serveur pour `Recommandés pour vous`; la section utilise les films les mieux notés disponibles.
- Pour les séries, la Home ouvre les détails faute d’ID épisode; la lecture directe par `Routes.episodeWatchPath(...)` doit attendre une source de reprise ou un premier épisode fiable.
- Les badges restent dérivés côté client tant que le modèle éditorial Firestore n’a pas de champs dédiés.

## Validation

- `flutter analyze --no-pub lib test`: OK, `No issues found!`
- `flutter test --no-pub test\widget_test.dart`: OK, `All tests passed!`
- `flutter build web --release`: premier essai expiré après 304 s sans erreur retournée; second essai OK, `Built build\web` en 287,6 s.

Avertissement non bloquant conservé: le dry-run Wasm signale toujours les incompatibilités connues de `flutter_secure_storage_web` avec `dart:html`, `dart:js` et `dart:js_util`. Le build Web JavaScript release reste valide.

## Prochaines étapes

1. Créer des routes catalogue dédiées pour `Tout voir`.
2. Ajouter un provider de progression pour `Continuer la lecture`.
3. Ajouter des champs éditoriaux Firestore légers: `badges`, `editorialSubtitle`, `trailerUrl`, `rank`.
4. Ajouter une logique “premier épisode disponible” pour permettre la lecture série depuis la Home.
5. Vérifier visuellement la Home via captures mobile/tablette/web.
6. Ajouter tests widget pour `SectionHeader`, `PremiumContentCard` et état hero vide.
7. Connecter les recommandations à un vrai modèle profil/historique.
8. Harmoniser Search et Details avec les nouveaux composants P4.

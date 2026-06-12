# Rapport de parité plateforme

Date: 2026-06-12

## Objectif

GUEZS FILMS utilise désormais une seule expérience mobile-first sur Android,
iOS, Web et desktop. Le Web n'affiche plus une application catalogue distincte:
sur grand écran, la même interface est centrée dans un cadre premium de `480 px`
maximum.

## Différences supprimées

Avant cette intervention:

- le Web et les tablettes pouvaient afficher une navigation latérale;
- plusieurs écrans choisissaient un layout desktop à plusieurs colonnes;
- l'onboarding avait une composition desktop séparée;
- la page Téléchargements Web utilisait une branche visuelle dédiée;
- les contenus s'étiraient jusqu'aux largeurs desktop.

Après cette intervention:

- la navigation inférieure Accueil, Recherche, Ma liste, Téléchargements et Profil
  est identique partout;
- `UniversalAppShell` centre toutes les routes dans un cadre de `480 px`;
- `MediaQuery` et `ResponsiveValues` exposent la largeur réelle du cadre;
- les anciennes branches desktop deviennent inactives dans le produit;
- l'onboarding utilise exactement la composition mobile sur toutes les cibles;
- l'indisponibilité technique du hors-ligne Web est signalée dans la même page,
  avec le badge `Disponible sur mobile`.

## Fichiers principaux modifiés

- `lib/main.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/responsive/responsive_values.dart`
- `lib/core/widgets/universal_app_shell.dart`
- `lib/core/widgets/main_scaffold.dart`
- `lib/features/auth/presentation/pages/onboarding_page.dart`
- `lib/features/auth/presentation/widgets/onboarding_slide_widget.dart`
- `lib/features/downloads/presentation/pages/downloads_page.dart`
- `lib/core/widgets/premium_content_card.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/core/content/content_presentation.dart`
- `lib/core/data/models/film_model.dart`
- `lib/core/data/models/series_model.dart`
- `lib/core/data/models/episode_model.dart`
- `lib/core/search/search_normalization.dart`
- `scripts/seed_content.js`
- `test/widget_test.dart`

## Stratégie mobile-first

`UniversalAppShell` enveloppe le routeur complet via le `builder` de
`MaterialApp.router`. Il fournit:

- un fond plein écran bleu nuit;
- un cadre central de largeur maximale `480 px`;
- une bordure, une ombre et un halo uniquement lorsque de l'espace extérieur
  existe;
- la taille `MediaQuery` du cadre, afin que les pages détails, player, auth,
  profil et pages légales conservent leur composition mobile;
- les `SafeArea` existantes de chaque écran.

`MainScaffold` n'a plus de rail ni de menu desktop. Le bandeau hors-ligne et la
bottom navigation restent dans la même structure sur toutes les plateformes.

## Onboarding

La variante desktop a été retirée. Les quatre slides, animations, textes et CTA
sont identiques partout et utilisent:

- `assets/images/onboarding/onboarding_cinema_hall.webp`
- `assets/images/onboarding/onboarding_story_cards.webp`
- `assets/images/onboarding/onboarding_private_room.webp`
- `assets/images/onboarding/onboarding_vip_access.webp`

Le dossier `assets/images/onboarding/` est explicitement déclaré dans
`pubspec.yaml`.

## Icônes

La configuration `flutter_launcher_icons` pointe vers la source unique
`assets/icons/icon.png` pour Android, iOS, Web et Windows. Les icônes ont été
régénérées avec:

```powershell
dart run flutter_launcher_icons
```

`web/manifest.json` référence les sorties PWA générées sous `web/icons/`.

## Corrections éditoriales associées

- `LA FEMME DU MBENGUISTE` est présenté comme
  `L'EPOUSE DU MBENGUISTE`;
- `ELLE ET MOI` est présenté comme `ELLE ET MOA`;
- l'ordre éditorial place L'EPOUSE DU MBENGUISTE avant ELLE ET MOA;
- les anciennes valeurs Firestore restent acceptées sans migration bloquante;
- les alias de recherche retrouvent les anciens `searchTokens`;
- la Home utilise un asset local et un cadrage focal spécifique pour ELLE ET MOA.

Les identifiants Firestore et chemins Storage historiques ne sont pas renommés.

## Limites techniques restantes

- le téléchargement réel reste réservé aux plateformes mobiles;
- les APIs fichiers locaux et orientation restent conditionnées à la plateforme;
- le fullscreen Web du player dépend toujours des capacités du navigateur;
- les branches desktop historiques de certains widgets restent dans le code mais
  ne sont plus sélectionnées dans le cadre universel;
- les données Firestore peuvent encore contenir les anciens titres, normalisés
  à la lecture en attendant une mise à jour administrative optionnelle.

## Comportement attendu

### Web

- cadre central de `480 px` maximum;
- fond cinéma autour de l'application;
- bottom navigation identique au mobile;
- aucune sidebar;
- onboarding et pages métier en composition mobile;
- page Téléchargements cohérente avec un badge d'indisponibilité.

### Mobile

- largeur native de l'écran jusqu'à `480 px`;
- aucun cadre ou arrondi artificiel autour de l'application;
- SafeArea, navigation, player et téléchargements mobiles conservés.

## Recommandations avant production

1. Ajouter des captures de régression aux largeurs `360`, `430` et `1440 px`.
2. Tester la navigation au clavier et le player sur Chrome, Edge et Safari.
3. Mettre à jour les titres Firestore lors d'une opération Admin contrôlée.
4. Vérifier les icônes sur un appareil Android et un appareil iOS réels.
5. Continuer à réserver les conditions plateforme aux capacités techniques.

## Validation

Contrôles exécutés:

```powershell
flutter analyze --no-pub lib test
flutter test --no-pub test\widget_test.dart
flutter build web --release
flutter build web --release --dart-define=ALLOW_DIRECT_VIDEO_FALLBACK_MVP=false
flutter build apk --release
node --check scripts/seed_content.js
```

Résultats:

- `flutter analyze --no-pub lib test`: OK, aucune anomalie;
- `flutter test --no-pub test\widget_test.dart`: OK, 30 tests;
- build Web release standard: OK;
- build Web avec fallback vidéo direct désactivé: OK;
- build APK release: OK, `69,5 Mo`;
- syntaxe du seed Node: OK;
- icônes launcher régénérées depuis `assets/icons/icon.png`.

Livrables:

- Web: `build/web/`;
- APK: `build/app/outputs/flutter-apk/app-release.apk`.

Les deux builds Web conservent l'avertissement Wasm connu de
`flutter_secure_storage_web` lié à `dart:html`, `dart:js` et `dart:js_util`.
Le build JavaScript Web demandé est produit correctement.

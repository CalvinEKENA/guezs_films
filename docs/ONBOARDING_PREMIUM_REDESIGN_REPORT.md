# Refonte onboarding premium

Date: 12 juin 2026

## Objectif

L’ancien onboarding automatique a été remplacé par un parcours en quatre
écrans piloté par l’utilisateur. La nouvelle expérience reprend les codes
d’une salle privée GUEZS FILMS: photographie réaliste, bleu nuit, or discret,
progression sobre et contenu éditorial centré sur le cinéma africain.

## Fichiers modifiés

- `lib/features/auth/presentation/pages/onboarding_page.dart`
- `lib/features/auth/presentation/models/onboarding_slide_model.dart`
- `lib/features/auth/presentation/widgets/onboarding_slide_widget.dart`
- `lib/features/auth/presentation/widgets/onboarding_progress_indicator.dart`
- `pubspec.yaml`
- `test/widget_test.dart`
- `docs/ONBOARDING_PREMIUM_REDESIGN_REPORT.md`

## Assets utilisés

Les quatre fichiers WebP sont déclarés explicitement dans `pubspec.yaml`:

- `assets/images/onboarding/onboarding_cinema_hall.webp`
- `assets/images/onboarding/onboarding_story_cards.webp`
- `assets/images/onboarding/onboarding_private_room.webp`
- `assets/images/onboarding/onboarding_vip_access.webp`

Chaque image dispose d’un fallback local bleu nuit avec pictogramme cinéma.
Une image manquante ne casse donc pas la mise en page.

## Structure des slides

1. **Entrer dans le cinéma africain**
   Une salle privée introduit la promesse éditoriale et la place réservée au
   spectateur.
2. **Suivre des histoires qui restent**
   Un collage de scènes modernes traduit la diversité des récits et des
   émotions.
3. **Votre salle privée**
   Une scène nocturne avec téléphone évoque la reprise, les favoris et la
   liberté de regarder à son rythme.
4. **Accès privilégié**
   Une invitation dorée présente les codes privés et les avant-premières sans
   simuler une fonction de paiement.

Les contenus sont centralisés dans `onboardingSlides`. La page ne contient plus
de données éditoriales dispersées.

## Interactions et animations

- navigation horizontale par `PageView`;
- CTA fixe: `Commencer`, `Suivant`, puis `Explorer GUEZS FILMS`;
- bouton précédent à partir du deuxième écran;
- action `Passer` conservant la même finalisation;
- léger scale et fondu de l’image;
- texte affiché par fade et translation verticale;
- carte contextuelle affichée avec translation douce;
- progression segmentée animée;
- transitions courtes, sans filtre flou animé ni animation lourde.

## Responsive

### Mobile et tablette

- composition photographique immersive;
- texte placé dans la zone sombre de l’image;
- carte contextuelle masquée sur les écrans très courts;
- CTA et progression toujours accessibles en bas;
- libellé final adapté aux petites largeurs sans être tronqué.

### Desktop et Web

- contenu centré avec largeur maximale;
- visuel portrait dans une grande carte à gauche;
- promesse éditoriale à droite;
- carte contextuelle superposée au visuel;
- contrôles fixes et espacés en bas.

## Logique de fin

La logique existante reste inchangée:

1. `completeOnboarding()` enregistre la fin dans Hive;
2. l’état Riverpod est mis à jour;
3. la navigation ouvre `/login` avec le mode inscription.

Firebase n’a pas été modifié. Le routing d’authentification normal reste
inchangé.

Après mise à jour d’une installation existante, la valeur Hive de fin
d’onboarding reste volontairement conservée. Une entrée `Revoir
l’introduction` est donc disponible dans le profil et ouvre
`/onboarding?replay=true` sans supprimer les données du compte.

## Couverture de test

- contrôle des quatre chemins WebP;
- parcours complet des quatre écrans sur une largeur mobile de 390 px;
- vérification des trois libellés CTA;
- vérification de la finalisation et de la redirection vers l’inscription.

## Limites restantes

- les textes juridiques et marketing ne sont pas inclus dans les images;
- les images sont des masters portrait uniques, sans variante paysage dédiée;
- le rendu final dépend du chargement local des polices Google déjà utilisées
  par l’application;
- aucune mesure analytique de complétion n’est ajoutée dans ce sprint.

## Recommandations pour les images finales

1. Conserver des masters haute définition avec droits d’utilisation documentés.
2. Faire valider les personnes, vêtements et décors par une direction
   artistique humaine.
3. Produire une variante paysage pour les écrans Web très larges.
4. Vérifier chaque recadrage sur 320 px, 390 px, tablette et desktop.
5. Éviter tout texte, logo tiers ou interface illisible intégré aux photos.
6. Conserver WebP ou AVIF avec une cible inférieure à 250 Ko par image.

## Validation

Commandes exécutées:

```powershell
flutter analyze --no-pub lib test
flutter test --no-pub test\widget_test.dart
flutter build web --release
```

Résultats:

- analyse Flutter: aucune anomalie;
- tests widgets: 25 réussis;
- build Web release: OK, sortie `build/web`;
- les quatre assets WebP sont inclus dans le bundle;
- le parcours mobile complet ne présente aucun overflow dans les tests.
- contrôle visuel Hosting local: OK sur `390x844` et `1280x800`;
- transition du premier au deuxième écran: OK, aucune erreur console.
- APK Android `versionCode 3`: OK;
- les quatre WebP sont présents dans l’APK release;
- relecture depuis le profil après mise à jour: couverte par les tests.

Le build signale uniquement les incompatibilités Wasm déjà connues de
`flutter_secure_storage_web`. Elles n’empêchent pas le build Web JavaScript
actuel.

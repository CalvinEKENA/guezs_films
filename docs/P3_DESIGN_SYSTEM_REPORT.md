# Rapport P3 - Design system GUEZS FILMS

Date: 2026-06-11  
Depot: `C:\projets\FlutterProjects\guezs_films`  
Objectif: poser les fondations visuelles Bleu Nuit / Or premium sans refonte complete des ecrans.

## Resume executif

Le design system P3 remplace la base rouge historique par une identite Bleu Nuit / Or conforme a `docs/DESIGN_TOKENS_GUEZS_FILMS.md`.

Les changements restent concentres sur les tokens, le theme Material 3 et les widgets communs. La Home, le player, les routes P1 et l'acces premium P2 ne sont pas refondus.

## Fichiers modifies

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/gradient_button.dart`
- `lib/core/widgets/glass_card.dart`
- `lib/core/widgets/cached_image.dart`
- `lib/core/widgets/shimmer_loading.dart`
- `lib/core/widgets/promo_code_dialog.dart`
- `lib/features/player/presentation/widgets/watch_state_view.dart`
- `lib/core/routes/app_router.dart`
- `lib/features/details/presentation/pages/details_page.dart`
- `lib/features/downloads/presentation/pages/downloads_page.dart`
- `lib/features/profile/domain/entities/user_profile_entity.dart`
- `lib/features/profile/presentation/pages/profile_selector_page.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/main.dart`
- `docs/P3_DESIGN_SYSTEM_REPORT.md`

## Tokens ajoutes ou mis a jour

- `brandBlue`: `#003366`
- `brandBlueDark`: `#001C3D`
- `brandGold`: `#D4AF37`
- `brandGoldLight`: `#FFEFA6`
- `spotlightBlue`: `#0099FF`
- `bgCinema`: `#030914`
- `bgCinemaDark`: `#00050D`
- `surfaceObsidian`: `#101F33`
- `cardObsidian`: `#12243A`
- `textOnGold`: `#030914`
- `textOnBlue`: `#F9F9F9`
- `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled`
- `success`, `warning`, `error`, `info`
- `divider`, `border`
- `bgGradient`
- `goldGradient`
- `glassBackground(alpha)`
- `glassBorder(alpha)`

## Anciens alias conserves

Les alias existants restent disponibles pour eviter de casser les ecrans:

- `primary` pointe maintenant vers `brandBlue`.
- `primaryDark` pointe maintenant vers `brandBlueDark`.
- `accent` pointe maintenant vers `brandGold`.
- `accentSoft` pointe maintenant vers `brandGoldLight`.
- `background` pointe maintenant vers `bgCinema`.
- `surface` pointe maintenant vers `surfaceObsidian`.
- `card` pointe maintenant vers `cardObsidian`.
- `textOnPrimary` pointe maintenant vers `textOnBlue`.
- `primaryGradient` reste disponible, mais devient un degrade bleu de marque.

## Regles de contraste appliquees

- Les CTA par defaut utilisent l'or (`accent` / `goldGradient`) avec texte sombre `textOnGold`.
- Les surfaces sombres utilisent `textPrimary` ou `textSecondary`.
- Les bordures glass utilisent un or faible via `glassBorder(alpha)`.
- Les boutons secondaires utilisent une surface obsidienne translucide.
- Les erreurs restent rouges uniquement via `AppColors.error`.
- Les indicateurs de chargement et sliders thematiques utilisent l'or pour renforcer le signal premium.

## Theme Material 3

`AppTheme.darkTheme` a ete mis a jour pour:

- `ColorScheme.dark`
- `scaffoldBackgroundColor`
- `AppBarTheme`
- `BottomNavigationBarThemeData`
- `CardThemeData`
- `ElevatedButtonThemeData`
- `OutlinedButtonThemeData`
- `TextButtonThemeData`
- `InputDecorationTheme`
- `ChipThemeData`
- `BottomSheetThemeData`
- `DialogThemeData`
- `SnackBarThemeData`
- `ProgressIndicatorThemeData`
- `SliderThemeData`
- `SwitchThemeData`

## Typographie

- Prestige: `Cinzel` via Google Fonts, sans reference a une police locale Didot.
- UI, boutons, cartes, badges: `Outfit`.
- Corps et descriptions: `Montserrat`.
- Styles ajoutes ou normalises: `displayPrestige`, `heroTitle`, `sectionTitle`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `caption`, `badge`, `buttonLabel`.

## Composants communs adaptes

- `GradientButton`: degrade dore par defaut, texte `textOnGold`, glow discret, feedback haptique leger.
- `OutlinedGradientButton`: surface glass/outline obsidienne.
- `GlassCard`: fond obsidienne translucide, bordure or faible, glow bleu tres subtil.
- `CachedImage`: placeholders et erreurs sur surface obsidienne avec bordure fine.
- `ShimmerLoading`: couleurs shimmer bleu nuit.
- `PromoCodeDialog`: icone et CTA alignes or premium, erreurs conservees via le theme.
- `WatchStateView`: fond cinema sombre degrade, progress indicator or, etats lisibles.
- CTA explicites restants: boutons details/downloads/profil alignes sur `accent` et `textOnGold` quand ils representent une action principale.

## Nettoyage anti-Netflix

Recherche effectuee dans `lib`:

- `E50914`
- `B20710`
- `Netflix`
- `Red color`
- `Colors.red`

Resultat final: aucun marqueur de marque rouge/Netflix restant dans `lib`. Le rouge reste disponible uniquement comme couleur semantique `AppColors.error`.

## Elements volontairement non refaits

- Pas de refonte Home complete.
- Pas de redesign des details, series, profil ou player.
- Pas de changement de routing P1.
- Pas de changement de logique d'acces premium P2.
- Pas de modification du schema Firestore.
- Pas d'ajout d'assets de police.
- Pas d'implementation HLS/DASH, paiement ou DRM.

## Validation

- `flutter analyze --no-pub lib test`: OK, `No issues found!`
- `flutter test --no-pub test\widget_test.dart`: OK, `All tests passed!`
- `flutter build web --release`: OK, `Built build\web`

Avertissement non bloquant conserve: le dry-run Wasm signale toujours les incompatibilites connues de `flutter_secure_storage_web` avec `dart:html`, `dart:js` et `dart:js_util`. Le build Web JavaScript release reste valide.

## Prochaines etapes UI

1. Revoir la Home avec les nouveaux tokens sans changer les routes `/watch`.
2. Harmoniser les CTA directs qui utilisent encore explicitement `AppColors.primary` comme action principale.
3. Creer des composants standardises pour badges premium, rails de contenus et empty states.
4. Auditer les contrastes reels sur mobile et desktop avec captures.
5. Ajouter des tests widget pour `GradientButton`, `PromoCodeDialog` et `WatchStateView`.
6. Definir des breakpoints web/tablette dans les grilles de contenus.
7. Introduire une page catalogue web plus dense sans casser l'experience mobile.
8. Preparer un systeme de tokens d'espacement et d'elevation.
9. Aligner les overlays du player sur le design system P3.
10. Documenter les usages autorises de `primary` versus `accent` pour les prochains sprints.

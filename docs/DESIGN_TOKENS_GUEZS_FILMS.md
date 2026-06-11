# Technical Design Tokens & UI Guidelines — GUEZS FILMS

Ce document contient la spécification technique et l'implémentation des design tokens pour **GUEZS FILMS**. Ce guide est destiné à guider le développement de l'UI et à servir de référence pour la refonte esthétique complète par le développeur/Codex, sans casser le code existant.

---

## 1. Clarification Critique : Brand Color vs CTA Color

Une confusion fréquente en développement mobile est d'associer systématiquement la couleur primaire de marque (`primary`) au bouton d'action principal (CTA). Pour GUEZS FILMS, ces deux rôles sont volontairement dissociés pour préserver l'élégance et assurer un contraste parfait.

> [!IMPORTANT]
> *   **Bleu Impérial (`brandBlue` / `#003366`)** : C'est la couleur de **structure et d'identité**. Elle incarne la marque GUEZS FILMS. Elle ne doit PAS être la couleur des actions prioritaires, afin d'éviter un effet institutionnel/corporate froid.
> *   **Or Métallique (`brandGold` / `#D4AF37`)** : C'est la couleur **d'action principale (CTA)**. Elle symbolise le ticket d'or, le tapis rouge, le statut VIP. Tous les boutons d'engagement majeurs (ex: *Regarder*, *Débloquer*, *S'abonner*) doivent être dorés.
> *   **Règle de Contraste Majeure** : 
>     *   Si le fond est **Or**, le texte doit être **Sombre** (`#030914`).
>     *   Si le fond est **Bleu**, le texte doit être **Clair** (`#F9F9F9`).

---

## 2. Tableaux de Correspondance & Mappings de Contraste

### A. Grille d'Usage des Éléments & Contraste Textuel

| Token | Usage / Rôle | Couleur de Fond | Couleur de Texte Recommandée |
| :--- | :--- | :--- | :--- |
| **`brandGold`** (CTA Principal) | Boutons d'action prioritaires (Regarder, S'abonner) | `#D4AF37` | `#030914` (`textOnGold`) |
| **`brandBlue`** (Brand/Info) | Badges secondaires, boutons info, sliders actifs | `#003366` | `#F9F9F9` (`textOnBlue`) |
| **`bgCinema`** (Fond Principal) | Écran principal, fonds de pages, grand hall | `#030914` | `#F9F9F9` (`textPrimary`) |
| **`surfaceObsidian`** (Surfaces) | Cartes de films, fenêtres modales, formulaires | `#101F33` | `#B8C5D6` (`textSecondary`) |

### B. Mappings de Transition pour Codex (Rétrocompatibilité)

Pour éviter de casser l'existant, nous conservons les variables existantes de la classe `AppColors` mais nous les réaffectons avec des valeurs adaptées aux contrastes :

| Ancien Nom (à conserver) | Code Hex Existant | Code Hex Nouveau | Nouveau Nom (Alias) | Rôle & Correction de Contraste |
| :--- | :--- | :--- | :--- | :--- |
| `AppColors.primary` | `#E50914` (Rouge) | **`#003366`** | `AppColors.brandBlue` | Couleur de marque (Bleu). |
| `AppColors.textOnPrimary` | `#FFFFFF` | **`#F9F9F9`** | `AppColors.textOnBlue` | **Corrigé** : Blanc sur fond bleu (évite le texte noir illisible). |
| `AppColors.accent` | `#FFFFD700` | **`#D4AF37`** | `AppColors.brandGold` | Or Métallique (Bouton CTA principal). |
| `AppColors.accentSoft` | `#D4AF37` | **`#FFEFA6`** | `AppColors.brandGoldLight` | Or Clair (Texte accentué, lueurs). |
| `AppColors.background` | `#0A0A0A` | **`#030914`** | `AppColors.bgCinema` | Fond sombre (Nuit du Sahel). |
| `AppColors.surface` | `#1A1A1A` | **`#101F33`** | `AppColors.surfaceObsidian` | Surface vitrée sombre. |

---

## 3. Définition Technique des Tokens Couleurs (Flutter)

Voici le code Dart officiel de la classe `AppColors` mise à jour :

```dart
import 'package:flutter/material.dart';

/// Système de couleurs Premium GUEZS FILMS
class AppColors {
  AppColors._();

  // 1. TOKENS DE BASE (Noms de Code Créatifs)
  static const Color brandBlue = Color(0xFF003366);       // Bleu Impérial (Marque)
  static const Color brandBlueDark = Color(0xFF001C3D);   // Abysse Cinéma (Profondeur)
  static const Color brandGold = Color(0xFFD4AF37);       // Or Métallique (CTA VIP)
  static const Color brandGoldLight = Color(0xFFFFEFA6);  // Or Clair (Textes & Badges)
  static const Color spotlightBlue = Color(0xFF0099FF);   // Bleu Projecteur (Focus, halos)
  
  static const Color bgCinema = Color(0xFF030914);        // Fond principal sombre
  static const Color bgCinemaDark = Color(0xFF00050D);    // Fond sous-jacent/OLED
  static const Color surfaceObsidian = Color(0xFF101F33); // Surfaces translucides
  static const Color cardObsidian = Color(0xFF12243A);    // Surfaces de cartes

  // 2. TOKENS DE CONTRASTE DÉDIÉS
  static const Color textOnGold = Color(0xFF030914);      // Noir nuit sur bouton doré
  static const Color textOnBlue = Color(0xFFF9F9F9);      // Sable blanc sur fond bleu

  // 3. ALIAS DE COMPATIBILITÉ (Pour ne pas casser le code existant)
  static const Color primary = brandBlue;
  static const Color primaryDark = brandBlueDark;
  static const Color accent = brandGold;
  static const Color accentSoft = brandGoldLight;
  static const Color background = bgCinema;
  static const Color surface = surfaceObsidian;
  static const Color surfaceVariant = Color(0xFF172C47);
  static const Color card = cardObsidian;
  static const Color bottomSheet = Color(0xFF081222);

  // 4. TOKENS TEXTE & DIVISEURS
  static const Color textPrimary = Color(0xFFF9F9F9);     // Sable Blanc
  static const Color textSecondary = Color(0xFFB8C5D6);   // Brume Bleue
  static const Color textTertiary = Color(0xFF7E91A8);    // Bleu Acier
  static const Color textDisabled = Color(0xFF4C5D72);
  static const Color textOnPrimary = textOnBlue;          // Corrigé : Blanc sur Bleu

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFC400);
  static const Color error = Color(0xFFFF3366);
  static const Color info = spotlightBlue;

  static const Color divider = Color(0xFF1B2C42);
  static const Color border = Color(0xFF243A54);

  // 5. DEGRADES & EFFETS PRÉCIS
  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgCinema, bgCinemaDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dégradé doré discret (utilisé pour les boutons VIP)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [brandGold, Color(0xFFF2D172), brandGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Utilisation dynamique du Glassmorphism
  static Color glassBackground(double alpha) => const Color(0xFF101F33).withOpacity(alpha);
  static Color glassBorder(double alpha) => const Color(0xFFD4AF37).withOpacity(alpha);
}
```

---

## 4. Spécification Typographique (Flutter / Google Fonts)

Le système typographique associe prestige et lisibilité :

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- TITRES PRESTIGE (Affiches, Hero, Grand Hall) ---
  static TextStyle displayPrestige({required double fontSize, Color color = AppColors.textPrimary}) {
    return TextStyle(
      fontFamily: 'Didot', // Import local dans les assets de l'application
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // Fallback si Didot n'est pas encore présent dans les assets
  static TextStyle displayPrestigeFallback({required double fontSize, Color color = AppColors.textPrimary}) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // --- TITRES D'INTERFACE & CARTES (OUTFIT) ---
  static TextStyle titleLarge = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle titleMedium = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonLabel = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  // --- PARAGRAPHES & SYNOPSIS (MONTSERRAT) ---
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}
```

---

## 5. Composants UI & Charte de Contraste

### A. Style des Boutons (Buttons)

1.  **Bouton d'Action Principale (Regarder, S'abonner, Continuer)** :
    *   **Fond** : `AppColors.brandGold` (ou `goldGradient`)
    *   **Texte/Icones** : `AppColors.textOnGold` (Couleur sombre `#030914`)
    *   **Graisse** : `FontWeight.w600` (Outfit)
    *   **Coins** : Arrondis `R: 8`
2.  **Bouton Secondaire / Info** :
    *   **Fond** : `AppColors.glassBackground(0.4)` (Verre obsidienne)
    *   **Bordure** : Fine de `0.8dp` en `AppColors.glassBorder(0.3)`
    *   **Texte/Icones** : `AppColors.textPrimary` (Sable Blanc `#F9F9F9`)

### B. Mini-Checklist de Contraste (Obligatoire pour Codex)
- [ ] **Bouton Doré** $\rightarrow$ Texte **Nuit** (`#030914`). *Interdiction de mettre du blanc ou du jaune clair.*
- [ ] **Bouton/Badge Bleu** $\rightarrow$ Texte **Blanc** (`#F9F9F9`). *Interdiction de mettre du noir.*
- [ ] **Surface Sombre (Obsidienne)** $\rightarrow$ Texte **Sable/Brume** (`#F9F9F9` / `#B8C5D6`).
- [ ] **Badge Doré** $\rightarrow$ Texte **Nuit** si le badge est plein, ou Texte **Or Clair** (`#FFEFA6`) sur fond transparent avec bordure or.

---

## 6. Recommandations Spécifiques pour Codex

> [!CAUTION]
> **Instructions cruciales pour Codex :**
> 1.  **Ne pas assumer que `primary` équivaut au bouton principal** : La variable historique `primary` a été redirigée vers `brandBlue`. Si Codex utilise `primary` directement comme fond pour les boutons d'action clés, ils apparaîtront bleus au lieu de dorés.
> 2.  **Utiliser explicitement `AppColors.accent` ou `AppColors.brandGold`** pour le background de tous les boutons d'action de type CTA (Play, Login, Subscribe).
> 3.  **Appliquer `textOnGold` comme couleur de texte** sur tous ces boutons dorés.

---

## 7. Recommandations Responsive & Adaptabilité

*   **Paddings Horizontaux de Page** :
    *   Mobile : `16dp`
    *   Tablette : `32dp`
    *   Web/Desktop : `64dp` (ou largeur max centrée à `1200dp`).
*   **Vignettes Films (Grilles)** :
    *   Mobile : `2` à `3` colonnes horizontales ou verticales.
    *   Tablette : `4` à `5` colonnes.
    *   Web : `6` à `7` colonnes avec espacement `gap: 20dp`.

---

## 8. Règles d'Usage & Pièges "Netflix-like" à Éviter

*   **Pas de rouge dominant** : Le rouge n'est autorisé que pour les erreurs critiques de validation ou les boutons de suppression destructeurs.
*   **Profondeur de fond** : Le fond de l'application est un dégradé très sombre (`#030914` vers `#00050D`). Le bleu ne doit pas saturer l'écran mais agir comme un halo d'ambiance ou une fine ligne de contour.
*   **Asymétrie des listes** : Casser la monotonie des lignes horizontales en alternant les formats d'images (Affiche portrait `2:3` vs bannière large `21:9`).

---

## 9. Checklist Finale d'Implémentation

Lorsqu'il appliquera cette charte graphique, Codex devra valider chaque étape suivante :

- [ ] Rediriger `AppColors.primary` vers `brandBlue` (`#003366`).
- [ ] Mettre à jour `AppColors.textOnPrimary` vers `textOnBlue` (`#F9F9F9`).
- [ ] Configurer `AppColors.accent` avec `brandGold` (`#D4AF37`).
- [ ] Remplacer les boutons principaux d'action par un fond `accent` / `brandGold` et un texte `textOnGold` (`#030914`).
- [ ] Mettre à jour le fond général de l'application en intégrant le dégradé radial/linéaire basé sur `bgCinema` (`#030914`).
- [ ] Configurer le fallback typographique de Didot vers `Cinzel` / `Playfair Display` dans `AppTextStyles`.
- [ ] Valider l'ensemble des écrans pour s'assurer du respect des règles de contraste (Checklist section 5.B).

# Rapport P9 - Écrans secondaires premium

Date: 2026-06-12
Objectif: aligner Profil, Favoris, Téléchargements et les états transversaux sur le niveau de qualité des écrans principaux.

## Résumé

Les écrans secondaires utilisent maintenant une présentation cinéma cohérente, des états explicites et des actions honnêtes. Les fonctions sans backend ne sont plus simulées: elles sont décrites comme indisponibles ou à venir.

Les changements préservent:

- l'authentification existante;
- les téléchargements mobiles et leur player local legacy;
- les routes détails pour les favoris;
- la compatibilité Web sans import `dart:io`;
- le projet `guezs_films_site`.

## Fichiers modifiés

- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/main_scaffold.dart`
- `lib/core/widgets/offline_banner.dart`
- `lib/features/favorites/presentation/pages/favorites_page.dart`
- `lib/features/downloads/presentation/pages/downloads_page.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/profile/presentation/pages/profile_selector_page.dart`
- `lib/features/profile/presentation/widgets/profile_form_sheet.dart`
- `test/widget_test.dart`

## Fichiers créés

- `lib/core/widgets/premium_states.dart`
- `lib/core/widgets/premium_feedback.dart`
- `docs/P9_SECONDARY_SCREENS_POLISH_REPORT.md`

## Widgets communs

### États

- `PremiumPageHeader`: titre, sous-titre et action optionnelle;
- `PremiumEmptyState`: état vide avec action principale et secondaire;
- `PremiumErrorState`: erreur lisible avec nouvelle tentative;
- `PremiumLoadingState`: chargement premium complet ou compact.

### Feedbacks

- `showPremiumSnackBar`: information, succès, avertissement et erreur;
- `showPremiumConfirmationDialog`: confirmation standard ou destructive;
- `showPremiumInfoSheet`: fiche explicative pour les fonctions non disponibles.

Le thème commun renforce aussi les boutons remplis, les snackbars flottantes et les bottom sheets arrondies.

## Favoris

La page Favoris propose:

- un en-tête premium et un compteur;
- une grille responsive basée sur les cartes de contenu communes;
- l'ouverture des pages détails Film ou Série;
- une suppression directe avec possibilité d'annuler;
- des états de chargement et d'erreur;
- l'état vide “Votre fauteuil VIP vous attend” avec accès au catalogue.

Les images absentes conservent les fallbacks communs. Une fiche détail est relue uniquement lorsque le favori local ne contient pas déjà son poster.

## Téléchargements

### Mobile

- liste centrée et lisible;
- poster, titre, statut, progression et taille;
- pause, reprise ou nouvelle tentative selon l'état réel;
- suppression confirmée;
- lecture locale uniquement pour un fichier terminé et présent;
- navigation par `Routes.legacyPlayerPath`, réservée au cas téléchargement local.

### Web et desktop

Le service de téléchargement n'est pas initialisé. La page affiche:

> Les téléchargements hors-ligne sont réservés à l’application mobile pour le moment.

Cette séparation évite d'ouvrir Hive ou un service natif sur une plateforme non supportée.

## Profil

La page Profil contient maintenant:

- une carte utilisateur ou invité;
- avatar, nom, email et statut de session;
- statut premium issu du provider existant;
- gestion des profils standard et enfant;
- qualité vidéo automatique présentée sans faux sélecteur;
- langue actuelle;
- notifications désactivées tant qu'aucun backend n'existe;
- fiches Support, Politique de confidentialité et Conditions d'utilisation;
- modification du nom;
- déconnexion confirmée;
- suppression de compte avec avertissement, réauthentification et confirmation destructive.

Les anciennes offres, prix et options de facturation simulées ont été retirés. Aucun paiement n'est ajouté.

## Sélecteur de profils

Le sélecteur:

- utilise uniquement les profils Firestore existants;
- distingue les profils Standard et Enfant;
- propose création et gestion sans contenu promotionnel codé en dur;
- couvre session absente, chargement, erreur et liste vide;
- adapte les cartes aux largeurs mobile, tablette et desktop;
- fournit focus visible, activation clavier et labels sémantiques.

Le formulaire de profil utilise des cibles accessibles pour la couleur et l'avatar, ainsi que les feedbacks communs.

## Bannière hors-ligne

La bannière devient un indicateur discret:

- pilule centrée dans la zone sûre;
- couleur d'avertissement non agressive;
- message court;
- région sémantique annoncée aux technologies d'assistance;
- aucune animation intrusive.

## Responsive et accessibilité

- contenu limité en largeur sur desktop;
- grilles et listes adaptées à la largeur disponible;
- sections empilées sur mobile;
- profil en deux colonnes sur desktop;
- actions principales d'au moins 44 px;
- textes longs flexibles et non tronqués dans les zones critiques;
- navigation principale basée sur `InkWell`, donc focusable au clavier;
- profils activables avec Entrée ou Espace;
- rôles, libellés et états sélectionnés exposés aux lecteurs d'écran.

## États vides couverts

- Favoris vide;
- Téléchargements mobiles vides;
- Téléchargements non disponibles sur Web/desktop;
- Aucun profil;
- Session requise;
- erreurs de compte, profils, favoris et téléchargements;
- chargements de profil, favoris et profils secondaires.

## Limites restantes

- qualité vidéo, langue et notifications ne sont pas encore persistées;
- Support, Politique de confidentialité et Conditions utilisent des contenus placeholder;
- aucun centre de notifications;
- pas de synchronisation cloud spécifique des préférences;
- la taille finale d'un téléchargement dépend des métadonnées disponibles;
- pas de téléchargement Web;
- les erreurs réseau restent génériques faute de typologie métier commune;
- le statut premium reste limité à la donnée fournie par le backend existant.

## Prochaines étapes

1. Ajouter un repository de préférences local puis synchronisé.
2. Publier les documents juridiques versionnés et leurs routes dédiées.
3. Connecter un canal support réel.
4. Ajouter une typologie d'erreurs commune réseau, auth et stockage.
5. Instrumenter favoris, téléchargements et gestion de profils avec des analytics respectueux de la vie privée.
6. Ajouter des tests d'intégration mobile pour pause, reprise, suppression et lecture locale.

## Validation

- `flutter test --no-pub test\widget_test.dart`: 16 tests réussis;
- `flutter analyze --no-pub lib test`: aucun problème;
- `flutter build web --release`: build généré dans `build/web`;
- contrôle HTTP local du build: réponse `200 OK`;
- scan P9: aucun import `dart:io` hors de l'implémentation mobile conditionnelle `download_service_io.dart`.

Le dry run Wasm conserve l'avertissement connu lié à `flutter_secure_storage_web` et ses imports historiques `dart:html`, `dart:js` et `dart:js_util`. Le build Web JavaScript demandé reste réussi.

La vérification visuelle automatisée n'a pas pu être lancée car le navigateur intégré de l'environnement n'a pas établi sa session locale. Les tests widget couvrent les états communs, la branche Téléchargements desktop, le profil invité et le sélecteur de profils.

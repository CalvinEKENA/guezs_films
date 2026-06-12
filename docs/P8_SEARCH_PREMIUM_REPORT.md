# Rapport P8 - Recherche premium

Date: 2026-06-12
Objectif: transformer la recherche en expérience de découverte rapide, éditoriale et responsive, sans moteur externe.

## Résumé

La page Recherche propose maintenant:

- un champ de recherche premium;
- un seuil minimal de deux caractères;
- un debounce de 300 ms;
- un historique local;
- une sélection de tendances;
- des filtres éditoriaux et de catalogue;
- une grille responsive de résultats enrichis;
- des états de chargement, erreur, absence de résultat et catalogue vide.

Les résultats ouvrent uniquement les pages détails métier. Aucun contenu de catalogue ne lance `/player`.

## Fichiers modifiés

- `lib/features/search/presentation/pages/search_page.dart`
- `lib/core/data/firebase_content_datasource.dart`
- `lib/core/providers/content_providers.dart`
- `functions/index.js`
- `test/widget_test.dart`

## Fichiers créés

- `lib/core/search/search_normalization.dart`
- `lib/core/widgets/search_result_card.dart`
- `docs/P8_SEARCH_PREMIUM_REPORT.md`
- `docs/SEARCH_UX.md`

## Nouveaux composants

### `SearchResultCard`

La carte affiche:

- poster avec fallback existant;
- type Film ou Série;
- titre;
- année;
- note lorsqu'elle existe;
- badge éditorial premium;
- hover et focus Web;
- feedback de pression mobile;
- animation courte sans dépendance lourde.

### Normalisation de recherche

`search_normalization.dart` centralise:

- minuscules;
- espaces;
- suppression des accents pour la variante normalisée;
- génération de termes Firestore;
- correspondance multi-mots locale;
- seuil minimal de deux caractères.

## Filtres

Filtres principaux:

- Tous;
- Films;
- Séries;
- Nouveautés;
- Populaires;
- Exclusifs, uniquement lorsque le catalogue contient cette donnée.

Filtres secondaires:

- genres disponibles dans le catalogue;
- pays disponibles;
- langues disponibles.

Les champs optionnels vides sont ignorés. Les anciennes données restent valides.

Le filtre Populaires utilise les signaux disponibles: note film supérieure ou égale à 7, ou contenu mis en avant. Cette règle devra être remplacée par un vrai score de popularité lorsque des analytics seront disponibles.

## Logique Firestore

Les collections `films` et `series` continuent d'utiliser `searchTokens`.

Évolution de la requête:

- aucune requête avant deux caractères;
- une requête par collection nécessaire;
- `arrayContainsAny` sur les mots et variantes normalisées;
- maximum de 60 documents récupérés par collection;
- filtrage multi-mots et classement final côté Flutter.

Cette approche permet à une recherche comme `grand voyage` de récupérer les candidats portant l'un des termes, puis de conserver localement ceux qui correspondent à l'ensemble des mots.

## Extension progressive des tokens

Les Cloud Functions génèrent maintenant des tokens pour:

- titre;
- réalisateur;
- casting;
- pays;
- langue;
- tags lorsqu'ils existent.

Les variantes accentuées et sans accents sont conservées.

Il n'y a aucune migration bloquante. Les anciens documents restent recherchables par leurs tokens de titre actuels. Les métadonnées supplémentaires seront indexées lors d'une prochaine écriture du document ou d'un éventuel backfill administratif futur.

## Découverte éditoriale

Lorsque le champ est vide, la page affiche:

- historique local;
- état historique vide;
- tendances calculées depuis le catalogue Riverpod;
- badges Original, Exclusivité, Nouveau ou Sélection.

Le score de découverte combine les signaux actuellement disponibles: mise en avant, exclusivité, original, nouveauté, note et récence.

## Navigation

- film: `Routes.filmDetailsPath(film.id)`;
- série: `Routes.seriesDetailsPath(series.id)`.

Les routes `/watch/...` et l'accès premium ne sont pas modifiés.

## Responsive

- moins de 430 px: 2 colonnes;
- mobile large: 3 colonnes;
- tablette: 4 ou 5 colonnes;
- desktop: 6 colonnes;
- desktop large: 7 colonnes;
- largeur maximale centrée;
- filtres horizontaux défilables;
- filtres pays/langue repliés en menus;
- clavier masqué lors du scroll ou de la navigation.

## Performance

- debounce de 300 ms;
- seuil de deux caractères;
- une requête Firestore par type de contenu;
- providers de recherche `autoDispose`;
- réutilisation des providers catalogue Riverpod pour tendances et filtres;
- filtrage local après récupération des candidats;
- limite Firestore de 60 résultats par collection;
- animations limitées à des transformations légères.

## Limites actuelles

- pas de tolérance aux fautes de frappe;
- pas de pertinence linguistique avancée;
- pas de synonymes;
- pas de stemming;
- pas de pagination Firestore pour les résultats;
- les anciens documents n'indexent pas automatiquement les nouveaux champs avant une écriture;
- le score Populaires est éditorial, pas analytique;
- les séries ne possèdent pas encore de note commune;
- `arrayContainsAny` produit une présélection OR, affinée ensuite côté client.

## Recommandations Algolia ou Meilisearch

Un moteur externe devient pertinent lorsque le catalogue, les langues ou les exigences de pertinence dépassent les capacités de `searchTokens`.

Migration future recommandée:

1. conserver Firestore comme source de vérité;
2. synchroniser films et séries vers un index unifié via Cloud Functions;
3. indexer titre, titre alternatif, casting, réalisateur, genres, pays, langue et tags;
4. configurer fautes de frappe, synonymes, ranking et facettes;
5. ne retourner au client que les IDs et métadonnées publiques;
6. conserver les routes détails actuelles;
7. prévoir une clé de recherche publique limitée, jamais une clé d'administration.

Algolia offre un service managé et une recherche instantanée mature. Meilisearch offre davantage de contrôle d'hébergement. Aucun des deux n'est ajouté dans P8.

## Validation

- `flutter analyze --no-pub lib test`: aucun problème;
- `flutter test --no-pub test\widget_test.dart`: 12 tests réussis;
- `flutter build web --release`: build généré dans `build/web`;
- `node --check functions/index.js`: syntaxe Cloud Functions valide.
- contrôle HTTP local du build: `200 OK`.

Le dry run Wasm conserve l'avertissement connu lié à `flutter_secure_storage_web` et ses imports historiques `dart:html`, `dart:js` et `dart:js_util`. Le build Web JavaScript demandé reste réussi.

La vérification visuelle automatisée n'a pas pu être lancée car le navigateur intégré de l'environnement n'a pas établi sa connexion locale. Les tests widget couvrent la découverte, les filtres, le seuil de recherche et la navigation vers les détails.

# Search UX

Ce document définit l'expérience de recherche et de découverte GUEZS FILMS.

## Intention

La recherche doit aider l'utilisateur à trouver un titre connu, mais aussi à découvrir un contenu lorsqu'il n'a pas encore de choix précis.

## Champ de recherche

Placeholder:

`Rechercher un film, une série, un réalisateur…`

Comportement:

- aucune requête pour zéro ou un caractère;
- lancement après 300 ms sans saisie;
- touche Recherche du clavier pour valider immédiatement;
- bouton d'effacement lorsque le champ contient du texte;
- fermeture du clavier au scroll ou à l'ouverture d'une fiche.

## Vue découverte

Quand aucune recherche et aucun filtre ne sont actifs:

- afficher les recherches récentes;
- expliquer clairement un historique vide;
- afficher les tendances du moment;
- conserver les filtres immédiatement accessibles.

## Historique

- stockage local Hive;
- maximum défini par `AppConstants.searchHistoryLimit`;
- déduplication insensible aux accents et à la casse;
- résultat le plus récent en premier;
- suppression unitaire;
- action Tout effacer;
- la recherche reste fonctionnelle si le stockage local est indisponible.

## Filtres

Les filtres Tous, Films, Séries, Nouveautés, Populaires et Exclusifs modifient la même grille.

Les genres sont présentés comme des chips défilables. Les pays et langues sont présentés dans des menus afin d'éviter une rangée trop longue.

Un filtre optionnel n'est visible que lorsque le catalogue possède au moins une valeur exploitable.

## Résultats

Chaque carte doit rendre visibles:

- la nature Film ou Série;
- le poster;
- le titre;
- l'année;
- la note si elle existe;
- le signal éditorial principal.

L'ordre privilégie:

1. les titres commençant par la requête;
2. les signaux éditoriaux;
3. la note;
4. la récence.

## États

| État | Présentation |
| --- | --- |
| Recherche vide | Historique et tendances |
| Un caractère | Invitation à saisir deux caractères |
| Chargement | Grille skeleton |
| Aucun résultat | Suggestion de modifier la recherche ou les filtres |
| Erreur réseau | Message lisible et bouton Réessayer |
| Catalogue vide | Message éditorial et action Actualiser |
| Historique vide | Explication compacte, sans écran bloquant |

## Responsive

| Largeur | Colonnes |
| --- | --- |
| Mobile compact | 2 |
| Mobile large | 3 |
| Tablette | 4 à 5 |
| Desktop | 6 |
| Desktop large | 7 |

La largeur du contenu est limitée par le système responsive global. Les filtres peuvent défiler horizontalement sans provoquer d'overflow.

## Navigation

- Film vers sa page détails;
- Série vers sa page détails;
- jamais de lancement direct du player depuis une carte de résultat.

## Accessibilité

- focus visible;
- curseur pointer sur Web;
- labels et tooltips sur les actions;
- contraste élevé;
- zones tactiles lisibles;
- animations de 140 à 160 ms;
- aucun mouvement continu.

## Limites Firestore

La recherche par tokens n'est pas un moteur full-text complet. Elle ne gère pas correctement les fautes, synonymes ou formes grammaticales. La page doit donc éviter de promettre une recherche intelligente tant qu'un moteur spécialisé n'est pas connecté.

# Player UX

Ce document définit le comportement attendu du player GUEZS FILMS.

## Principes

- Une séance commence dans un environnement noir cinéma, sans texte technique.
- Le titre et la sortie restent toujours accessibles lorsque les contrôles sont visibles.
- Les contrôles disparaissent après une courte inactivité pendant la lecture.
- Une fonctionnalité non connectée ne doit jamais sembler active.
- Une erreur doit proposer une action claire: réessayer ou revenir.

## États

| État | Message | Action principale |
| --- | --- | --- |
| Initialisation | Préparation de la séance | Aucune |
| Buffer | Connexion en cours | Attente courte |
| Source absente | Vidéo indisponible | Réessayer |
| Réseau ou format | Lecture indisponible | Réessayer |
| Reprise disponible | Reprendre la séance | Reprendre |
| Fin | Fin de la séance | Revoir |
| Accès refusé | Géré avant le player | Connexion ou code |

## Contrôles tactiles

- tap: afficher ou masquer les contrôles;
- double tap à gauche: reculer de 10 secondes;
- double tap à droite: avancer de 10 secondes;
- slider: naviguer dans la vidéo;
- verrou mobile: masquer les contrôles accidentels;
- tap sur l'icône de déverrouillage: restaurer les contrôles.

## Contrôles clavier

| Touche | Action |
| --- | --- |
| Espace | Lecture ou pause |
| Flèche gauche | Recul de 10 secondes |
| Flèche droite | Avance de 10 secondes |
| `F` | Basculer le plein écran si supporté |
| `Escape` | Quitter le plein écran, masquer les contrôles ou revenir |

Les raccourcis ne s'exécutent pas lorsqu'une fiche de réglages est ouverte.

## Reprise

La reprise locale est attachée à l'identité métier du film ou de l'épisode, pas à son URL vidéo. L'utilisateur choisit explicitement entre:

- `Reprendre`;
- `Recommencer`.

Les contenus vus presque jusqu'à la fin ne déclenchent pas de reprise.

## Fonctions indisponibles

Qualité, pistes audio et sous-titres restent désactivés tant que le flux ne fournit pas de variantes réellement sélectionnables. Les fiches associées expliquent que la fonction arrivera avec les flux adaptés.

## Orientation et sortie

- Mobile: séance en paysage immersif, restauration du mode système au retour.
- Web et desktop: aucune orientation forcée.
- Toute sortie sauvegarde la position utile.
- Le passage en arrière-plan met la lecture en pause et sauvegarde la position.

## Accessibilité et lisibilité

- tooltips sur les boutons;
- zones tactiles d'au moins 44 pixels pour les actions principales;
- contraste élevé sur fond vidéo;
- progression bleue projecteur et thumb doré;
- intitulés français compréhensibles;
- animations limitées à des fondus courts.

## Contrat futur des médias

Un contenu adaptatif devra fournir au minimum:

- une URL de manifeste compatible;
- le type de flux;
- les variantes de qualité réellement disponibles;
- les pistes audio;
- les pistes de sous-titres;
- les codecs;
- les règles CORS Web;
- les informations de session ou licence DRM lorsque nécessaire.

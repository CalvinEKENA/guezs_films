# Rapport P7 - Player premium

Date: 2026-06-12
Objectif: rendre la lecture vidéo plus fiable, lisible et premium sur mobile, desktop et Web, sans modifier les fondations d'accès P2.

## Résumé

Le player possède maintenant une interface cinéma dédiée, des contrôles honnêtes, une gestion explicite des états de lecture et une première reprise locale par contenu.

Les routes catalogue restent inchangées:

- `/watch/film/:filmId`
- `/watch/series/:seriesId/season/:seasonId/episode/:episodeId`

La route legacy `/player` reste compatible avec les téléchargements locaux sur les plateformes qui les supportent.

## Fichiers modifiés

- `lib/features/player/presentation/pages/player_page.dart`
- `lib/features/player/data/video_controller_factory_io.dart`
- `lib/features/player/data/video_controller_factory_web.dart`
- `lib/features/player/domain/entities/player_content_request.dart`
- `pubspec.yaml`
- `pubspec.lock`
- `test/widget_test.dart`

## Fichiers créés

- `lib/features/player/data/player_progress_store.dart`
- `lib/features/player/data/player_fullscreen_controller.dart`
- `lib/features/player/data/player_fullscreen_controller_stub.dart`
- `lib/features/player/data/player_fullscreen_controller_web.dart`
- `docs/P7_PLAYER_PREMIUM_REPORT.md`
- `docs/PLAYER_UX.md`

## Nouveaux composants

- `PlayerProgressStore`: persistance locale et règles de reprise;
- `PlayerFullscreenController`: abstraction conditionnelle du plein écran Web;
- panneaux d'état premium: chargement, erreur, reprise et fin;
- contrôles dédiés: actions circulaires, barre de progression, réglages et fiches d'indisponibilité.

## Contrôles disponibles

- lecture et pause;
- recul et avance de 10 secondes;
- double tap gauche/droite;
- barre de progression avec buffer visible;
- durée écoulée et durée totale;
- réglage de vitesse;
- son et mode muet;
- retour avec sauvegarde de progression;
- verrouillage des contrôles sur mobile;
- plein écran mobile et plein écran navigateur lorsque l'API est disponible.

Les contrôles qualité, sous-titres et pistes audio sont visuellement désactivés. Une fiche “Bientôt disponible” explique la limite au lieu de simuler une fonction.

## États UX

- préparation de la séance;
- buffer différé pour éviter les flashs visuels;
- source vide ou URL invalide;
- erreur de connexion ou format indisponible;
- reprise de lecture;
- contrôles verrouillés;
- fin de vidéo avec actions “Revoir” et “Quitter”.

Les refus d'accès, les codes requis et les invités restent gérés par `WatchFilmPage` et `WatchEpisodePage`, avant la création du player.

## Reprise de lecture

`PlayerProgressStore` utilise `SharedPreferences` avec une clé stable issue de `PlayerContentRequest`:

- `film:<filmId>`;
- `episode:<seriesId>:<seasonId>:<episodeId>`.

La position est enregistrée périodiquement, lors des interruptions de cycle de vie et à la sortie. Une reprise est proposée uniquement:

- après 30 secondes;
- si plus de 120 secondes restent à regarder;
- avant 90 % du contenu.

La progression est supprimée lors d'une lecture terminée ou lorsque la position n'est plus utile.

## Mobile, desktop et Web

### Mobile

- passage en paysage et interface système immersive pendant la séance;
- bouton de verrouillage;
- restauration du mode système et du portrait à la sortie;
- sauvegarde lors du passage en arrière-plan.

### Desktop et Web

- aucune orientation forcée;
- raccourcis clavier: espace, flèches gauche/droite, `F`, `Escape`;
- plein écran via l'API navigateur quand elle est disponible;
- barre d'actions défilable sur les petites largeurs.

## Robustesse

- timers annulés au changement de source et au `dispose`;
- contrôleur précédent détaché et libéré avant réinitialisation;
- garde de génération contre les initialisations asynchrones obsolètes;
- vérifications `mounted` centralisées;
- rafraîchissement de position limité à des pas de 250 ms;
- sauvegarde locale limitée à un intervalle de 10 secondes;
- validation de source avant création du contrôleur;
- aucun import `dart:io` dans le graphe Web.

## HLS, DASH et sécurité

Les URLs HTTP(S) ne sont plus supposées être uniquement des MP4. La factory native fournit un indice de format pour `.m3u8` et `.mpd`. Sur Web, la compatibilité réelle dépend du navigateur, de `video_player`, des codecs, de CORS et du serveur média.

Cette préparation ne constitue pas une protection de contenu. Les URLs signées courtes, les manifests protégés, la télémétrie de session et le DRM restent à implémenter côté plateforme vidéo.

## Limites restantes

- pas de sélection effective de qualité;
- pas de pistes audio multiples;
- pas de sous-titres connectés;
- pas de reprise synchronisée entre appareils;
- pas de lecture suivante automatique;
- pas de PiP, Chromecast ou AirPlay;
- pas de DRM;
- pas de stratégie de retry réseau avancée.

## Validation

- `flutter analyze --no-pub lib test`: aucun problème;
- `flutter test --no-pub test\widget_test.dart`: 8 tests réussis;
- `flutter build web --release`: build généré dans `build/web`;
- contrôle HTTP local du build: réponse `200 OK`.

Le dry run Wasm signale encore des dépendances Web historiques basées sur `dart:html` et `dart:js`, notamment `flutter_secure_storage_web`. Le build JavaScript Web demandé reste réussi et le player n'ajoute aucun `dart:io` au graphe Web.

## Prochaines étapes

1. Connecter des manifests HLS/DASH multi-variantes et leurs métadonnées.
2. Ajouter les pistes de sous-titres et audio réelles.
3. Remplacer progressivement les URLs directes par des sessions et URLs signées.
4. Synchroniser la progression avec le compte utilisateur.
5. Ajouter analytics de démarrage, buffer, erreur, complétion et abandon.
6. Évaluer une couche DRM par plateforme et fournisseur de contenu.

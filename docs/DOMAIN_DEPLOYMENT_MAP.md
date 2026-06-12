# Cartographie des domaines GUEZS

## Domaines publics

| Domaine | Application | Source | Build |
| --- | --- | --- | --- |
| `https://guezs-house.com` | Site institutionnel GUEZS HOUSE | `guezs_house_web/` | `npm run build` puis `guezs_house_web/out/` |
| `https://films.guezs-house.com` | Plateforme GUEZS FILMS | racine Flutter | `flutter build web --release` puis `build/web/` |

## Déploiement

### GUEZS HOUSE

Le site Next.js utilise un export statique compatible avec Hostinger:

```powershell
cd guezs_house_web
npm ci
npm run lint
npm run build
```

Publier le contenu du dossier `out/` à la racine de `guezs-house.com`.

### GUEZS FILMS

```powershell
flutter build web --release
firebase deploy --only hosting
```

Le sous-domaine `films.guezs-house.com` doit pointer vers le site Firebase
Hosting du projet `guezs-films`.

## Règles de dépôt

- Ne pas commiter `guezs_house_hostinger.zip`, `out/`, `.next/` ou `node_modules/`.
- Conserver les URL canoniques propres à chaque domaine.
- Les liens institutionnels vers la plateforme cinéma utilisent
  `https://films.guezs-house.com`.

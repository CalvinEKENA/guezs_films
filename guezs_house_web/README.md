# GUEZS HOUSE Web

Site institutionnel Next.js de GUEZS HOUSE, publié sur
`https://guezs-house.com`.

La plateforme cinéma est une application distincte disponible sur
`https://films.guezs-house.com`.

## Développement

```powershell
npm ci
npm run dev
```

## Validation

```powershell
npm run lint
npm run build
```

Le projet utilise `output: "export"`. Le build statique est produit dans
`out/` pour le déploiement Hostinger.

## Déploiement Hostinger

1. Exécuter `npm run build`.
2. Publier le contenu de `out/` dans le dossier public de `guezs-house.com`.
3. Ne pas commiter les archives ZIP de déploiement, `.next/`, `out/` ou
   `node_modules/`.

Les variables Firebase publiques nécessaires au formulaire d'avant-première
doivent être fournies au moment du build. Les secrets SMTP ne doivent jamais
être intégrés au bundle statique.

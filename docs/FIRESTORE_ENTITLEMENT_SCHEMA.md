# Schéma Firestore - Entitlements et accès vidéo

Date: 2026-06-11  
Objectif: préparer un contrôle d'accès premium sans exposer de logique sensible au client.

## Principes

- Le client ne lit jamais les codes d'accès.
- Le client ne décide jamais seul qu'un contenu est débloqué.
- Les droits sont validés par Cloud Functions avec Firebase Auth.
- Les URLs vidéo durables ne doivent pas être le modèle final.
- Les collections ci-dessous sont une base MVP extensible vers paiement, pass, achats et URLs signées.

## 1. `access_codes`

Collection serveur pour codes ambassadeur, codes campagne, pass temporaires.

### ID document

`sha256(normalizedCode)`, où `normalizedCode` est le code trim/uppercase sans espaces.

Ne pas utiliser le code lisible comme ID.

### Champs

| Champ | Type | Description |
| --- | --- | --- |
| `label` | string | Nom interne lisible, ex. `Muriel lancement juin`. |
| `active` | bool | Active ou désactive le code. |
| `grantType` | string | `ambassadorCode`, `pass`, `purchase`, `global`, `free`. |
| `contentType` | string | `global`, `film`, `series`, `episode`. |
| `filmId` | string? | Requis pour un code film. |
| `seriesId` | string? | Requis pour un code série/épisode. |
| `seasonId` | string? | Requis pour un code épisode. |
| `episodeId` | string? | Requis pour un code épisode. |
| `startsAt` | timestamp? | Début de validité. |
| `expiresAt` | timestamp? | Fin de validité du code. |
| `durationDays` | number? | Durée d'entitlement créée à partir de la validation. |
| `entitlementExpiresAt` | timestamp? | Expiration fixe du droit accordé. |
| `maxUses` | number? | Limite globale d'utilisation. |
| `usedCount` | number | Compteur incrémenté en transaction serveur. |
| `createdAt` | timestamp | Date de création. |
| `createdBy` | string? | UID admin ou outil. |

### Exemple

```json
{
  "label": "AMBASSADEUR-JUIN",
  "active": true,
  "grantType": "ambassadorCode",
  "contentType": "film",
  "filmId": "elle-et-moi",
  "startsAt": "2026-06-01T00:00:00Z",
  "expiresAt": "2026-07-01T00:00:00Z",
  "durationDays": 30,
  "maxUses": 500,
  "usedCount": 0
}
```

### Règles recommandées

- Lecture client: interdite.
- Écriture client: interdite.
- Lecture/écriture admin uniquement.
- Les Cloud Functions utilisent Admin SDK et ne dépendent pas des rules.

## 2. `user_entitlements`

Droits accordés à un utilisateur après code, pass, achat futur ou accès global.

### ID document

`{uid}_{sourceId}_{scopeKey}` ou ID auto si plusieurs droits du même type doivent coexister.

### Champs

| Champ | Type | Description |
| --- | --- | --- |
| `uid` | string | UID Firebase Auth. |
| `active` | bool | Droit actif. |
| `grantType` | string | `ambassadorCode`, `pass`, `purchase`, `global`, `free`. |
| `source` | string | `access_code`, `purchase`, `admin`, `campaign`. |
| `sourceId` | string? | ID du code, achat, pass ou opération admin. |
| `contentType` | string | `global`, `film`, `series`, `episode`. |
| `filmId` | string? | Scope film. |
| `seriesId` | string? | Scope série/épisode. |
| `seasonId` | string? | Scope épisode. |
| `episodeId` | string? | Scope épisode. |
| `createdAt` | timestamp | Création serveur. |
| `updatedAt` | timestamp | Dernière mise à jour. |
| `expiresAt` | timestamp? | Fin du droit. |

### Exemple

```json
{
  "uid": "USER_UID",
  "active": true,
  "grantType": "ambassadorCode",
  "source": "access_code",
  "sourceId": "HASHED_CODE_ID",
  "contentType": "film",
  "filmId": "elle-et-moi",
  "createdAt": "SERVER_TIMESTAMP",
  "updatedAt": "SERVER_TIMESTAMP",
  "expiresAt": "2026-07-11T00:00:00Z"
}
```

### Index

- `uid ASC, active ASC`
- Futur: `uid ASC, contentType ASC, active ASC`
- Futur: `uid ASC, expiresAt ASC`

### Règles recommandées

- L'utilisateur peut lire uniquement ses propres entitlements.
- Aucune écriture client.
- Les créations/mises à jour passent par Cloud Functions ou admin.

## 3. `watch_sessions`

Session courte créée quand un utilisateur a le droit de lancer la lecture.

### Champs

| Champ | Type | Description |
| --- | --- | --- |
| `uid` | string | UID utilisateur. |
| `contentType` | string | `film` ou `episode`. |
| `filmId` | string? | Film demandé. |
| `seriesId` | string? | Série demandée. |
| `seasonId` | string? | Saison demandée. |
| `episodeId` | string? | Épisode demandé. |
| `status` | string | `active`, `expired`, `revoked`. |
| `grant` | map? | Résumé du droit utilisé. |
| `createdAt` | timestamp | Création serveur. |
| `expiresAt` | timestamp | Expiration courte, ex. 10 minutes. |
| `playbackProvider` | string? | `storage`, `cdn`, `hls`, `drm` futur. |
| `signedUrlIssued` | bool? | Indique si une URL courte a été créée. |

### Exemple

```json
{
  "uid": "USER_UID",
  "contentType": "film",
  "filmId": "elle-et-moi",
  "status": "active",
  "grant": {
    "type": "ambassadorCode",
    "contentType": "film",
    "filmId": "elle-et-moi"
  },
  "createdAt": "SERVER_TIMESTAMP",
  "expiresAt": "2026-06-11T12:10:00Z"
}
```

### Index

- `uid ASC, createdAt DESC`
- Futur monitoring: `contentType ASC, createdAt DESC`
- Futur sécurité: `uid ASC, status ASC, expiresAt ASC`

### Règles recommandées

- L'utilisateur peut lire ses propres sessions si nécessaire.
- Aucune création client.
- Aucune mise à jour client.

## 4. `content_access_rules`

Règles par contenu pour définir si un contenu est gratuit, premium, réservé à un code, ou ouvert globalement.

### ID document recommandé

- `global`
- `film_{filmId}`
- `series_{seriesId}`
- `episode_{seriesId}_{seasonId}_{episodeId}`

### Champs

| Champ | Type | Description |
| --- | --- | --- |
| `active` | bool | Règle active. |
| `accessMode` | string | `free`, `codeRequired`, `premium`, `purchaseRequired`. |
| `contentType` | string | `global`, `film`, `series`, `episode`. |
| `filmId` | string? | Scope film. |
| `seriesId` | string? | Scope série/épisode. |
| `seasonId` | string? | Scope épisode. |
| `episodeId` | string? | Scope épisode. |
| `startsAt` | timestamp? | Début de règle. |
| `expiresAt` | timestamp? | Fin de règle. |
| `updatedAt` | timestamp | Dernière mise à jour. |

### Exemple

```json
{
  "active": true,
  "accessMode": "codeRequired",
  "contentType": "film",
  "filmId": "elle-et-moi",
  "updatedAt": "SERVER_TIMESTAMP"
}
```

### Règles recommandées

- Lecture client: admin uniquement pour commencer.
- Écriture client: admin uniquement.
- Si l'app doit afficher des badges publics plus tard, créer une projection publique sans données sensibles.

## Limites de sécurité côté client

- Un client modifié peut appeler directement une fonction callable.
- Un client modifié peut lire une URL durable si elle est stockée dans Firestore.
- Un code validé côté client n'a aucune valeur de sécurité.
- Les règles Firestore protègent les documents, pas les fichiers vidéo publics déjà exposés.
- La vraie protection vidéo exige des URLs signées courtes, un CDN signé, HLS/DRM selon la maturité produit, et App Check.

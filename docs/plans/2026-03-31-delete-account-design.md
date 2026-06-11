# Design : Suppression du compte utilisateur

**Date :** 2026-03-31
**Contexte :** Google Play Store exige que les apps proposant la création de compte permettent aussi la suppression des données utilisateur depuis l'app (politique DDA).

---

## Objectif

Permettre à l'utilisateur de supprimer définitivement son compte et ses données depuis la page Profil, en conformité avec les exigences Play Store.

---

## Architecture — Option C retenue

### Nouveaux fichiers

| Fichier | Rôle |
|---------|------|
| `lib/features/auth/domain/usecases/delete_account_usecase.dart` | Orchestre la suppression complète |

### Fichiers modifiés

| Fichier | Modification |
|---------|-------------|
| `lib/features/auth/data/datasources/auth_remote_data_source.dart` | Ajouter `deleteAccount(AuthCredential)` |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Ajouter `deleteAccount()` |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Implémenter `deleteAccount()` |
| `lib/features/auth/presentation/providers/auth_providers.dart` | Ajouter `deleteAccount()` dans `AuthController` |
| `lib/features/profile/presentation/pages/profile_page.dart` | Bouton + dialogs |

---

## Flux de suppression

```
profile_page
  → Étape 1 : Re-auth dialog (email/Google/Apple)
  → Étape 2 : Choix downloads (garder / supprimer)
  → Étape 3 : Confirmation finale (bottom sheet)
  → AuthController.deleteAccount(credential, deleteDownloads)
      → DeleteAccountUseCase.execute()
          ├── Firestore: delete /users/{uid}/favorites/* (batch)
          ├── Firestore: delete /users/{uid}/profiles/* (batch)
          ├── Firestore: delete /users/{uid}
          ├── Hive: clear favorites_box, download_box, search_history
          ├── [si deleteDownloads] Supprimer fichiers locaux téléchargés
          └── FirebaseAuth: user.reauthenticate(credential) → user.delete()
  → context.go(Routes.login)
```

---

## UX Flow

### Étape 1 — Re-authentification
- Email/password → `AlertDialog` avec champ mot de passe masqué
- Google → relance `GoogleSignIn().signIn()` → `GoogleAuthProvider.credential()`
- Apple → relance flux Apple → `OAuthProvider('apple.com').credential()`

### Étape 2 — Choix téléchargements
- `AlertDialog` : "Voulez-vous aussi supprimer vos fichiers téléchargés ?"
- Boutons : "Oui, tout supprimer" / "Non, garder les fichiers"

### Étape 3 — Confirmation finale
- Bottom sheet avec avertissement rouge
- Message : "Cette action est irréversible. Votre compte, vos profils et vos favoris seront définitivement supprimés."
- Boutons : "Supprimer définitivement" (rouge) / "Annuler"

---

## Gestion d'erreurs

| Erreur | Comportement |
|--------|-------------|
| `wrong-password` | SnackBar "Mot de passe incorrect" |
| `network-request-failed` | SnackBar "Vérifiez votre connexion" |
| Firestore échec partiel | Continuer (Auth supprimé quand même) |
| `user-not-found` | Redirect login |

---

## Point d'entrée UI

Bouton "Supprimer mon compte" ajouté dans `profile_page.dart`, sous le bouton "Se déconnecter", styling rouge/outlined identique.

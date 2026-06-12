class AuthErrorMapper {
  AuthErrorMapper._();

  static String map(String code, [String? originalMessage]) {
    // Si le message original contient des erreurs JS spécifiques au Web (cas hybride)
    if (originalMessage != null && originalMessage.contains('JSObject')) {
      return "Une erreur technique s'est produite. Veuillez réessayer.";
    }

    switch (code) {
      case 'invalid-email':
        return "L'adresse e-mail n'est pas valide.";
      case 'user-disabled':
        return "Ce compte a été désactivé.";
      case 'user-not-found':
        return "Aucun compte ne correspond à cet e-mail.";
      case 'wrong-password':
        return "Le mot de passe saisi est incorrect.";
      case 'email-already-in-use':
        return "Cette adresse e-mail est déjà utilisée par un autre compte.";
      case 'operation-not-allowed':
        return "L'opération d'authentification n'est pas autorisée.";
      case 'weak-password':
        return "Le mot de passe choisi est trop faible (6 caractères minimum).";
      case 'network-request-failed':
        return "Problème de connexion. Veuillez vérifier votre internet.";
      case 'too-many-requests':
        return "Trop de tentatives. Veuillez patienter un instant avant de réessayer.";
      case 'invalid-credential':
        return "Les identifiants ne sont pas valides ou ont expiré.";
      case 'account-exists-with-different-credential':
        return "Un compte existe déjà avec cet e-mail mais utilise une méthode de connexion différente.";
      case 'requires-recent-login':
        return "Cette action nécessite une connexion récente. Veuillez vous reconnecter.";
      case 'popup-closed-by-user':
        return "La fenêtre de connexion a été fermée avant la fin de l'opération.";
      case 'cancelled-popup-request':
        return "Une autre fenêtre de connexion a été ouverte. Veuillez réessayer.";
      case 'apple-auth-error':
        return "Erreur lors de la connexion avec Apple. Veuillez réessayer.";
      case 'redirect_uri_mismatch':
        return "La connexion avec ce fournisseur n'est pas disponible pour le moment.";
      default:
        // Si le message original contient des termes techniques, on retourne un message générique
        if (originalMessage != null &&
            (originalMessage.contains('Firebase') ||
                originalMessage.contains('Exception') ||
                originalMessage.contains('null') ||
                originalMessage.contains('redirect_uri_mismatch'))) {
          if (originalMessage.contains('redirect_uri_mismatch')) {
            return "La connexion avec ce fournisseur n'est pas disponible pour le moment.";
          }
          return "Une erreur est survenue. Veuillez vérifier vos informations et réessayer.";
        }
        return originalMessage ?? "Une erreur d'authentification est survenue.";
    }
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider surveillant l'état de la connexion réseau.
/// Utilise connectivity_plus pour déterminer si l'appareil est hors-ligne.
final connectivityProvider = StreamProvider<bool>((ref) {
  // on retourne 'true' si hors ligne, 'false' si connecté
  return Connectivity().onConnectivityChanged.map((event) {
    if (event.contains(ConnectivityResult.none)) {
      return true; // Hors ligne
    }
    return false; // Connecté
  });
});

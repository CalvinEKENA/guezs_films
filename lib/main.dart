import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:guezs_films/firebase_options.dart';
import 'package:guezs_films/features/favorites/data/models/favorite_movie_model.dart';
import 'package:guezs_films/features/downloads/data/models/download_item_model.dart';
import 'core/platform/platform_capabilities.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/universal_app_shell.dart';

/// Guezs Films - Premium Streaming Application
/// Premium streaming app with cinematic mobile and web experiences.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteMovieModelAdapter());
  Hive.registerAdapter(DownloadItemModelAdapter());
  await Hive.openBox<String>(AppConstants.searchHistoryBox);
  await Hive.openBox(AppConstants.settingsBox);

  if (PlatformCapabilities.shouldForcePortrait) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: GuezFilmsApp()));
}

/// Main application widget
class GuezFilmsApp extends ConsumerWidget {
  const GuezFilmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Guezs Films',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      builder: (context, child) =>
          UniversalAppShell(child: child ?? const SizedBox.shrink()),

      // Router configuration
      routerConfig: router,
    );
  }
}

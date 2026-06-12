import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/firebase_runtime_config.dart';
import '../../../player/domain/entities/player_content_request.dart';
import '../../data/repositories/cloud_functions_watch_access_repository.dart';
import '../../domain/entities/watch_access_result.dart';
import '../../domain/repositories/watch_access_repository.dart';

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(
    region: FirebaseRuntimeConfig.functionsRegion,
  );
});

final watchAccessRepositoryProvider = Provider<WatchAccessRepository>((ref) {
  return CloudFunctionsWatchAccessRepository(
    ref.watch(firebaseFunctionsProvider),
  );
});

final watchAccessProvider =
    FutureProvider.family<WatchAccessResult, PlayerContentRequest>((
      ref,
      request,
    ) async {
      return ref
          .watch(watchAccessRepositoryProvider)
          .createWatchSession(request);
    });

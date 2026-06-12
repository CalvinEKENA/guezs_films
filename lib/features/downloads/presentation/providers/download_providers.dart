import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/download_repository.dart';
import '../../data/repositories/download_repository_impl.dart';
import '../../data/services/download_service.dart';
import '../../domain/entities/download_item.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  return DownloadRepositoryImpl();
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref.watch(downloadRepositoryProvider));
});

final activeDownloadsProvider = StreamProvider<List<DownloadItem>>((ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchDownloads();
});

final downloadStateProvider = StreamProvider.family<DownloadItem?, String>((
  ref,
  id,
) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchDownload(id);
});

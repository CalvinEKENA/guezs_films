import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';

class DownloadService {
  DownloadService(this._repository);

  final DownloadRepository _repository;

  Future<void> startDownload(DownloadItem item) async {
    throw UnsupportedError(
      'Les téléchargements hors-ligne ne sont pas encore disponibles sur Web.',
    );
  }

  Future<void> pauseDownload(String id) async {}

  Future<void> deleteDownload(String id, String localPath) async {
    await _repository.deleteDownload(id);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/download_item.dart';

abstract class DownloadRepository {
  Future<Either<Failure, List<DownloadItem>>> getAllDownloads();
  Future<Either<Failure, DownloadItem>> getDownload(String id);
  Future<Either<Failure, void>> saveDownload(DownloadItem item);
  Future<Either<Failure, void>> deleteDownload(String id);
  Stream<List<DownloadItem>> watchDownloads();
  Stream<DownloadItem?> watchDownload(String id);
}

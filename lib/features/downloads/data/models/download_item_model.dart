import 'package:hive/hive.dart';

import '../../../../core/content/content_presentation.dart';
import '../../domain/entities/download_item.dart';

part 'download_item_model.g.dart';

@HiveType(typeId: 1)
class DownloadItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String videoUrl;

  @HiveField(4)
  final String localPath;

  @HiveField(5)
  final double progress;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final int totalSize;

  @HiveField(8)
  final int downloadedSize;

  DownloadItemModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.videoUrl,
    required this.localPath,
    required this.progress,
    required this.status,
    required this.totalSize,
    required this.downloadedSize,
  });

  factory DownloadItemModel.fromEntity(DownloadItem entity) {
    return DownloadItemModel(
      id: entity.id,
      title: canonicalContentTitle(entity.title),
      posterPath: entity.posterPath,
      videoUrl: entity.videoUrl,
      localPath: entity.localPath,
      progress: entity.progress,
      status: entity.status.toString(),
      totalSize: entity.totalSize,
      downloadedSize: entity.downloadedSize,
    );
  }

  DownloadItem toEntity() {
    DownloadStatus parsedStatus;
    try {
      parsedStatus = DownloadStatus.values.firstWhere(
        (e) => e.toString() == status,
      );
    } catch (_) {
      parsedStatus = DownloadStatus.failed;
    }

    return DownloadItem(
      id: id,
      title: canonicalContentTitle(title),
      posterPath: posterPath,
      videoUrl: videoUrl,
      localPath: localPath,
      progress: progress,
      status: parsedStatus,
      totalSize: totalSize,
      downloadedSize: downloadedSize,
    );
  }
}

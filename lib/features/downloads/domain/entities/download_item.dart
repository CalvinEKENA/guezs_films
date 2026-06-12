import 'package:equatable/equatable.dart';

enum DownloadStatus { pending, downloading, completed, paused, failed }

class DownloadItem extends Equatable {
  final String id; // video id
  final String title;
  final String posterPath;
  final String videoUrl;
  final String localPath;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final int totalSize; // in bytes
  final int downloadedSize; // in bytes

  const DownloadItem({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.videoUrl,
    required this.localPath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.totalSize = 0,
    this.downloadedSize = 0,
  });

  DownloadItem copyWith({
    String? id,
    String? title,
    String? posterPath,
    String? videoUrl,
    String? localPath,
    double? progress,
    DownloadStatus? status,
    int? totalSize,
    int? downloadedSize,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      videoUrl: videoUrl ?? this.videoUrl,
      localPath: localPath ?? this.localPath,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      totalSize: totalSize ?? this.totalSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    posterPath,
    videoUrl,
    localPath,
    progress,
    status,
    totalSize,
    downloadedSize,
  ];
}

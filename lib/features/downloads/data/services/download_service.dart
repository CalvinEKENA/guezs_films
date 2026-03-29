import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';

class DownloadService {
  final DownloadRepository _repository;
  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadService(this._repository) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> _showProgressNotification(int id, String title, int progress, int maxProgress) async {
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Téléchargements',
      channelDescription: 'Progression des téléchargements',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      onlyAlertOnce: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      id: id,
      title: 'Téléchargement: $title',
      body: '${(progress / maxProgress * 100).toStringAsFixed(0)}%',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _showCompletionNotification(int id, String title, bool success) async {
    final androidDetails = AndroidNotificationDetails(
      'download_channel_complete',
      'Téléchargements terminés',
      importance: Importance.high,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: id,
      title: success ? 'Téléchargement terminé' : 'Échec du téléchargement',
      body: title,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> startDownload(DownloadItem item) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      // Création du sous-dossier sécurisé
      final downloadsDir = Directory('${appDocDir.path}/guezs_downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = '${item.id}.mp4';
      final savePath = '${downloadsDir.path}/$fileName';

      // Vérifier si déjà téléchargé
      if (await File(savePath).exists()) {
        final existingItem = item.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          localPath: savePath,
        );
        await _repository.saveDownload(existingItem);
        return;
      }

      final cancelToken = CancelToken();
      _cancelTokens[item.id] = cancelToken;

      var currentItem = item.copyWith(
        status: DownloadStatus.downloading,
        localPath: savePath,
      );
      await _repository.saveDownload(currentItem);

      final notifId = item.id.hashCode;

      await _dio.download(
        item.videoUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final progress = received / total;
            
            currentItem = currentItem.copyWith(
              progress: progress,
              totalSize: total,
              downloadedSize: received,
            );
            
            // On limite les mises à jour base de données/notifs (debounce) basé sur des seuils de %
            if (received % (1024 * 512) < 65536) { // Update approx every 512KB
               await _repository.saveDownload(currentItem);
               await _showProgressNotification(notifId, item.title, received, total);
            }
          }
        },
      );

      // Succès
      currentItem = currentItem.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
      );
      await _repository.saveDownload(currentItem);
      _cancelTokens.remove(item.id);
      
      await _notificationsPlugin.cancel(id: notifId);
      await _showCompletionNotification(notifId, item.title, true);

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        final canceledItem = item.copyWith(status: DownloadStatus.paused);
        await _repository.saveDownload(canceledItem);
      } else {
        final failedItem = item.copyWith(status: DownloadStatus.failed);
        await _repository.saveDownload(failedItem);
        await _showCompletionNotification(item.id.hashCode, item.title, false);
      }
      _cancelTokens.remove(item.id);
    }
  }

  Future<void> pauseDownload(String id) async {
    if (_cancelTokens.containsKey(id)) {
      _cancelTokens[id]?.cancel();
      _cancelTokens.remove(id);
    }
  }

  Future<void> deleteDownload(String id, String localPath) async {
    pauseDownload(id);
    await _repository.deleteDownload(id);
    
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

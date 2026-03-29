import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../models/download_item_model.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  Future<Box<DownloadItemModel>> get _box async {
    if (Hive.isBoxOpen(AppConstants.downloadBox)) {
      return Hive.box<DownloadItemModel>(AppConstants.downloadBox);
    }
    return await Hive.openBox<DownloadItemModel>(AppConstants.downloadBox);
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getAllDownloads() async {
    try {
      final box = await _box;
      final items = box.values.map((model) => model.toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la lecture des téléchargements: $e'));
    }
  }

  @override
  Future<Either<Failure, DownloadItem>> getDownload(String id) async {
    try {
      final box = await _box;
      final model = box.get(id);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(CacheFailure('Téléchargement non trouvé'));
    } catch (e) {
      return Left(CacheFailure('Erreur d\'accès au cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDownload(DownloadItem item) async {
    try {
      final box = await _box;
      final model = DownloadItemModel.fromEntity(item);
      await box.put(item.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la sauvegarde du téléchargement: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(String id) async {
    try {
      final box = await _box;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la suppression: $e'));
    }
  }

  @override
  Stream<List<DownloadItem>> watchDownloads() async* {
    final box = await _box;
    yield box.values.map((model) => model.toEntity()).toList();
    yield* box.watch().map((_) {
      return box.values.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Stream<DownloadItem?> watchDownload(String id) async* {
    final box = await _box;
    yield box.get(id)?.toEntity();
    yield* box.watch(key: id).map((event) {
      if (event.deleted) return null;
      return (event.value as DownloadItemModel).toEntity();
    });
  }
}

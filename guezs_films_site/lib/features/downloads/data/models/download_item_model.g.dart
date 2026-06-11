// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadItemModelAdapter extends TypeAdapter<DownloadItemModel> {
  @override
  final int typeId = 1;

  @override
  DownloadItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      posterPath: fields[2] as String,
      videoUrl: fields[3] as String,
      localPath: fields[4] as String,
      progress: fields[5] as double,
      status: fields[6] as String,
      totalSize: fields[7] as int,
      downloadedSize: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.videoUrl)
      ..writeByte(4)
      ..write(obj.localPath)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.totalSize)
      ..writeByte(8)
      ..write(obj.downloadedSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

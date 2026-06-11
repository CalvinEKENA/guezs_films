// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteMovieModelAdapter extends TypeAdapter<FavoriteMovieModel> {
  @override
  final int typeId = 0;

  @override
  FavoriteMovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMovieModel(
      id: fields[0] as String,
      title: fields[1] as String,
      posterPath: fields[2] as String,
      contentType: fields[3] as String,
      addedAt: fields[4] as String,
      isDeleted: fields[5] == null ? false : fields[5] as bool,
      updatedAt: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMovieModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.contentType)
      ..writeByte(4)
      ..write(obj.addedAt)
      ..writeByte(5)
      ..write(obj.isDeleted)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatPieceAdapter extends TypeAdapter<StatPiece> {
  @override
  final int typeId = 1;

  @override
  StatPiece read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatPiece(
      timeFinished: fields[0] as int,
      timeToSolve: fields[1] as int,
      difficulty: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StatPiece obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timeFinished)
      ..writeByte(1)
      ..write(obj.timeToSolve)
      ..writeByte(2)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatPieceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

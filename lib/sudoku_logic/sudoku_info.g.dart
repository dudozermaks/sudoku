// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SudokuInfoAdapter extends TypeAdapter<SudokuInfo> {
  @override
  final int typeId = 0;

  @override
  SudokuInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SudokuInfo(
      uniqueSolution: fields[0] as String?,
      difficulty: fields[1] as int,
      usedMethods: (fields[2] as Map).cast<String, int>(),
      humanEngineSolved: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SudokuInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uniqueSolution)
      ..writeByte(1)
      ..write(obj.difficulty)
      ..writeByte(2)
      ..write(obj.usedMethods)
      ..writeByte(3)
      ..write(obj.humanEngineSolved);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SudokuInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

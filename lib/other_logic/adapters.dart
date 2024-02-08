import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 11;

  @override
  ThemeMode read(BinaryReader reader) {
		return ThemeMode.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }
}

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  int typeId = 12;

  @override
  Duration read(BinaryReader reader) {
    return Duration(milliseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj){
    writer.writeInt(obj.inMilliseconds);
  }
}

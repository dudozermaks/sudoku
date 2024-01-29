import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

// class ColorAdapter extends TypeAdapter<Color> {
//   // 0 is statistics adapter, starting with 10 to reserve some space
//   @override
//   final typeId = 10;
//
//   @override
//   Color read(BinaryReader reader) {
//     return Color(reader.readInt());
//   }
//
//   @override
//   void write(BinaryWriter writer, Color obj) {
//     writer.writeInt(obj.value);
//   }
// }
//
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

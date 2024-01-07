// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.12.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

import 'api/sudoku.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.io.dart' if (dart.library.html) 'frb_generated.web.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class RustLib extends BaseEntrypoint<RustLibApi, RustLibApiImpl, RustLibWire> {
  @internal
  static final instance = RustLib._();

  RustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    RustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
    );
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<RustLibApiImpl, RustLibWire> get apiImplConstructor =>
      RustLibApiImpl.new;

  @override
  WireConstructor<RustLibWire> get wireConstructor =>
      RustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {
    await api.initApp();
  }

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
    stem: 'rust_lib',
    ioDirectory: 'rust/target/release/',
    webPrefix: 'pkg/',
  );
}

abstract class RustLibApi extends BaseApi {
  String generateSudoku({dynamic hint});

  (int, Map<String, int>, bool) getRating(
      {required String sudokuString, dynamic hint});

  String? getUniqueSolution({required String sudokuString, dynamic hint});

  Future<void> initApp({dynamic hint});
}

class RustLibApiImpl extends RustLibApiImplPlatform implements RustLibApi {
  RustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  String generateSudoku({dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        return wire.wire_generate_sudoku();
      },
      codec: DcoCodec(
        decodeSuccessData: dco_decode_String,
        decodeErrorData: null,
      ),
      constMeta: kGenerateSudokuConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGenerateSudokuConstMeta => const TaskConstMeta(
        debugName: "generate_sudoku",
        argNames: [],
      );

  @override
  (int, Map<String, int>, bool) getRating(
      {required String sudokuString, dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        var arg0 = cst_encode_String(sudokuString);
        return wire.wire_get_rating(arg0);
      },
      codec: DcoCodec(
        decodeSuccessData: dco_decode_record_u_32_map_string_u_32_bool,
        decodeErrorData: null,
      ),
      constMeta: kGetRatingConstMeta,
      argValues: [sudokuString],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetRatingConstMeta => const TaskConstMeta(
        debugName: "get_rating",
        argNames: ["sudokuString"],
      );

  @override
  String? getUniqueSolution({required String sudokuString, dynamic hint}) {
    return handler.executeSync(SyncTask(
      callFfi: () {
        var arg0 = cst_encode_String(sudokuString);
        return wire.wire_get_unique_solution(arg0);
      },
      codec: DcoCodec(
        decodeSuccessData: dco_decode_opt_String,
        decodeErrorData: null,
      ),
      constMeta: kGetUniqueSolutionConstMeta,
      argValues: [sudokuString],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kGetUniqueSolutionConstMeta => const TaskConstMeta(
        debugName: "get_unique_solution",
        argNames: ["sudokuString"],
      );

  @override
  Future<void> initApp({dynamic hint}) {
    return handler.executeNormal(NormalTask(
      callFfi: (port_) {
        return wire.wire_init_app(port_);
      },
      codec: DcoCodec(
        decodeSuccessData: dco_decode_unit,
        decodeErrorData: null,
      ),
      constMeta: kInitAppConstMeta,
      argValues: [],
      apiImpl: this,
      hint: hint,
    ));
  }

  TaskConstMeta get kInitAppConstMeta => const TaskConstMeta(
        debugName: "init_app",
        argNames: [],
      );

  @protected
  Map<String, int> dco_decode_Map_String_u_32(dynamic raw) {
    return Map.fromEntries(dco_decode_list_record_string_u_32(raw)
        .map((e) => MapEntry(e.$1, e.$2)));
  }

  @protected
  String dco_decode_String(dynamic raw) {
    return raw as String;
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    return raw as bool;
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    return raw as Uint8List;
  }

  @protected
  List<(String, int)> dco_decode_list_record_string_u_32(dynamic raw) {
    return (raw as List<dynamic>).map(dco_decode_record_string_u_32).toList();
  }

  @protected
  String? dco_decode_opt_String(dynamic raw) {
    return raw == null ? null : dco_decode_String(raw);
  }

  @protected
  (String, int) dco_decode_record_string_u_32(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2) {
      throw Exception('Expected 2 elements, got ${arr.length}');
    }
    return (
      dco_decode_String(arr[0]),
      dco_decode_u_32(arr[1]),
    );
  }

  @protected
  (int, Map<String, int>, bool) dco_decode_record_u_32_map_string_u_32_bool(
      dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 3) {
      throw Exception('Expected 3 elements, got ${arr.length}');
    }
    return (
      dco_decode_u_32(arr[0]),
      dco_decode_Map_String_u_32(arr[1]),
      dco_decode_bool(arr[2]),
    );
  }

  @protected
  int dco_decode_u_32(dynamic raw) {
    return raw as int;
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    return;
  }

  @protected
  Map<String, int> sse_decode_Map_String_u_32(SseDeserializer deserializer) {
    var inner = sse_decode_list_record_string_u_32(deserializer);
    return Map.fromEntries(inner.map((e) => MapEntry(e.$1, e.$2)));
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  List<(String, int)> sse_decode_list_record_string_u_32(
      SseDeserializer deserializer) {
    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <(String, int)>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_record_string_u_32(deserializer));
    }
    return ans_;
  }

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer) {
    if (sse_decode_bool(deserializer)) {
      return (sse_decode_String(deserializer));
    } else {
      return null;
    }
  }

  @protected
  (String, int) sse_decode_record_string_u_32(SseDeserializer deserializer) {
    var var_field0 = sse_decode_String(deserializer);
    var var_field1 = sse_decode_u_32(deserializer);
    return (var_field0, var_field1);
  }

  @protected
  (int, Map<String, int>, bool) sse_decode_record_u_32_map_string_u_32_bool(
      SseDeserializer deserializer) {
    var var_field0 = sse_decode_u_32(deserializer);
    var var_field1 = sse_decode_Map_String_u_32(deserializer);
    var var_field2 = sse_decode_bool(deserializer);
    return (var_field0, var_field1, var_field2);
  }

  @protected
  int sse_decode_u_32(SseDeserializer deserializer) {
    return deserializer.buffer.getUint32();
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {}

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    return deserializer.buffer.getInt32();
  }

  @protected
  bool cst_encode_bool(bool raw) {
    return raw;
  }

  @protected
  int cst_encode_u_32(int raw) {
    return raw;
  }

  @protected
  int cst_encode_u_8(int raw) {
    return raw;
  }

  @protected
  void cst_encode_unit(void raw) {
    return raw;
  }

  @protected
  void sse_encode_Map_String_u_32(
      Map<String, int> self, SseSerializer serializer) {
    sse_encode_list_record_string_u_32(
        self.entries.map((e) => (e.key, e.value)).toList(), serializer);
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer) {
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_list_record_string_u_32(
      List<(String, int)> self, SseSerializer serializer) {
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_record_string_u_32(item, serializer);
    }
  }

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer) {
    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_String(self, serializer);
    }
  }

  @protected
  void sse_encode_record_string_u_32(
      (String, int) self, SseSerializer serializer) {
    sse_encode_String(self.$1, serializer);
    sse_encode_u_32(self.$2, serializer);
  }

  @protected
  void sse_encode_record_u_32_map_string_u_32_bool(
      (int, Map<String, int>, bool) self, SseSerializer serializer) {
    sse_encode_u_32(self.$1, serializer);
    sse_encode_Map_String_u_32(self.$2, serializer);
    sse_encode_bool(self.$3, serializer);
  }

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer) {
    serializer.buffer.putUint32(self);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {}

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    serializer.buffer.putInt32(self);
  }
}

import 'package:hive_flutter/adapters.dart';

class FakeBox<E> extends Box<E> {
  final _storage = <dynamic, dynamic>{};
  var _nextIndex = 0;

  // Do not know what to return here
  @override
  Future<int> add(value) {
    _storage[_nextIndex] = value;
    _nextIndex += 1;
    return Future.value(_nextIndex - 1);
  }

  @override
  Future<Iterable<int>> addAll(Iterable values) {
    throw UnimplementedError();
  }

  // Do not know what to return here
  @override
  Future<int> clear() {
    _storage.clear();
    return Future.value(0);
  }

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> compact() {
    throw UnimplementedError();
  }

  @override
  bool containsKey(key) {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete(key) {
    _storage.remove(key);
    return Future.value();
  }

  @override
  Future<void> deleteAll(Iterable keys) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAt(int index) {
    _storage.remove(index);
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFromDisk() {
    throw UnimplementedError();
  }

  @override
  Future<void> flush() {
    throw UnimplementedError();
  }

  @override
  get(key, {defaultValue}) {
    return _storage[key] ?? defaultValue;
  }

  @override
  getAt(int index) {
    return _storage[index];
  }

  @override
  bool get isEmpty => _storage.isEmpty;

  @override
  bool get isNotEmpty => _storage.isNotEmpty;

  @override
  bool get isOpen => throw UnimplementedError();

  @override
  keyAt(int index) {
    throw UnimplementedError();
  }

  @override
  Iterable get keys => throw UnimplementedError();

  @override
  bool get lazy => throw UnimplementedError();

  @override
  int get length => _storage.length;

  @override
  String get name => throw UnimplementedError();

  @override
  String? get path => throw UnimplementedError();

  @override
  Future<void> put(key, value) {
    _storage[key] = value;
    return Future.value();
  }

  @override
  Future<void> putAll(Map entries) {
    throw UnimplementedError();
  }

  @override
  Future<void> putAt(int index, value) {
    throw UnimplementedError();
  }

  @override
  Map<dynamic, E> toMap() {
    throw UnimplementedError();
  }

  @override
  Iterable<E> get values => throw UnimplementedError();

  @override
  Iterable<E> valuesBetween({startKey, endKey}) {
    throw UnimplementedError();
  }

  @override
  Stream<BoxEvent> watch({key}) {
    return const Stream.empty();
  }
}

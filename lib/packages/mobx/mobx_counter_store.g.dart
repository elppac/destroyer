// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobx_counter_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CounterStore on _CounterStore, Store {
  late final _$countAtom = Atom(name: '_CounterStore.count', context: context);

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  late final _$count2Atom =
      Atom(name: '_CounterStore.count2', context: context);

  @override
  int get count2 {
    _$count2Atom.reportRead();
    return super.count2;
  }

  @override
  set count2(int value) {
    _$count2Atom.reportWrite(value, super.count2, () {
      super.count2 = value;
    });
  }

  late final _$dataAtom = Atom(name: '_CounterStore.data', context: context);

  @override
  Map<String, dynamic> get data {
    _$dataAtom.reportRead();
    return super.data;
  }

  @override
  set data(Map<String, dynamic> value) {
    _$dataAtom.reportWrite(value, super.data, () {
      super.data = value;
    });
  }

  late final _$_CounterStoreActionController =
      ActionController(name: '_CounterStore', context: context);

  @override
  void increment() {
    final _$actionInfo = _$_CounterStoreActionController.startAction(
        name: '_CounterStore.increment');
    try {
      return super.increment();
    } finally {
      _$_CounterStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void increment2() {
    final _$actionInfo = _$_CounterStoreActionController.startAction(
        name: '_CounterStore.increment2');
    try {
      return super.increment2();
    } finally {
      _$_CounterStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
count: ${count},
count2: ${count2},
data: ${data}
    ''';
  }
}

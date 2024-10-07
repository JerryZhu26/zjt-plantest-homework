// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Timeline on _Timeline, Store {
  late final _$lineAtom = Atom(name: '_Timeline.line', context: context);

  @override
  ObservableList<Map<int, Set<ObjectId>>> get line {
    _$lineAtom.reportRead();
    return super.line;
  }

  @override
  set line(ObservableList<Map<int, Set<ObjectId>>> value) {
    _$lineAtom.reportWrite(value, super.line, () {
      super.line = value;
    });
  }

  late final _$tksAtom = Atom(name: '_Timeline.tks', context: context);

  @override
  ObservableMap<ObjectId, TK> get tks {
    _$tksAtom.reportRead();
    return super.tks;
  }

  @override
  set tks(ObservableMap<ObjectId, TK> value) {
    _$tksAtom.reportWrite(value, super.tks, () {
      super.tks = value;
    });
  }

  late final _$tdsTodayAtom =
      Atom(name: '_Timeline.tdsToday', context: context);

  @override
  ObservableList<TD> get tdsToday {
    _$tdsTodayAtom.reportRead();
    return super.tdsToday;
  }

  @override
  set tdsToday(ObservableList<TD> value) {
    _$tdsTodayAtom.reportWrite(value, super.tdsToday, () {
      super.tdsToday = value;
    });
  }

  late final _$_TimelineActionController =
      ActionController(name: '_Timeline', context: context);

  @override
  void initialize() {
    final _$actionInfo =
        _$_TimelineActionController.startAction(name: '_Timeline.initialize');
    try {
      return super.initialize();
    } finally {
      _$_TimelineActionController.endAction(_$actionInfo);
    }
  }

  @override
  void add(ObjectId id, Time startTime, Time endTime, Side side) {
    final _$actionInfo =
        _$_TimelineActionController.startAction(name: '_Timeline.add');
    try {
      return super.add(id, startTime, endTime, side);
    } finally {
      _$_TimelineActionController.endAction(_$actionInfo);
    }
  }

  @override
  void remove(ObjectId id, Time startTime, Time endTime, Side side) {
    final _$actionInfo =
        _$_TimelineActionController.startAction(name: '_Timeline.remove');
    try {
      return super.remove(id, startTime, endTime, side);
    } finally {
      _$_TimelineActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
line: ${line},
tks: ${tks},
tdsToday: ${tdsToday}
    ''';
  }
}

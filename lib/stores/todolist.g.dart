// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todolist.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Todolist on _Todolist, Store {
  late final _$tdsAtom = Atom(name: '_Todolist.tds', context: context);

  @override
  ObservableMap<ObjectId, TD> get tds {
    _$tdsAtom.reportRead();
    return super.tds;
  }

  @override
  set tds(ObservableMap<ObjectId, TD> value) {
    _$tdsAtom.reportWrite(value, super.tds, () {
      super.tds = value;
    });
  }

  late final _$pjsAtom = Atom(name: '_Todolist.pjs', context: context);

  @override
  ObservableMap<ObjectId, PJ> get pjs {
    _$pjsAtom.reportRead();
    return super.pjs;
  }

  @override
  set pjs(ObservableMap<ObjectId, PJ> value) {
    _$pjsAtom.reportWrite(value, super.pjs, () {
      super.pjs = value;
    });
  }

  late final _$rootsAtom = Atom(name: '_Todolist.roots', context: context);

  @override
  ObservableList<ObjectId> get roots {
    _$rootsAtom.reportRead();
    return super.roots;
  }

  @override
  set roots(ObservableList<ObjectId> value) {
    _$rootsAtom.reportWrite(value, super.roots, () {
      super.roots = value;
    });
  }

  late final _$hierarchyAtom =
      Atom(name: '_Todolist.hierarchy', context: context);

  @override
  ObservableMap<ObjectId, TodosHierarchyItem> get hierarchy {
    _$hierarchyAtom.reportRead();
    return super.hierarchy;
  }

  @override
  set hierarchy(ObservableMap<ObjectId, TodosHierarchyItem> value) {
    _$hierarchyAtom.reportWrite(value, super.hierarchy, () {
      super.hierarchy = value;
    });
  }

  late final _$tdsNoPjAtom = Atom(name: '_Todolist.tdsNoPj', context: context);

  @override
  ObservableList<ObjectId> get tdsNoPj {
    _$tdsNoPjAtom.reportRead();
    return super.tdsNoPj;
  }

  @override
  set tdsNoPj(ObservableList<ObjectId> value) {
    _$tdsNoPjAtom.reportWrite(value, super.tdsNoPj, () {
      super.tdsNoPj = value;
    });
  }

  late final _$filterTypeAtom =
      Atom(name: '_Todolist.filterType', context: context);

  @override
  FilterType get filterType {
    _$filterTypeAtom.reportRead();
    return super.filterType;
  }

  @override
  set filterType(FilterType value) {
    _$filterTypeAtom.reportWrite(value, super.filterType, () {
      super.filterType = value;
    });
  }

  late final _$sortTypeAtom =
      Atom(name: '_Todolist.sortType', context: context);

  @override
  SortType get sortType {
    _$sortTypeAtom.reportRead();
    return super.sortType;
  }

  @override
  set sortType(SortType value) {
    _$sortTypeAtom.reportWrite(value, super.sortType, () {
      super.sortType = value;
    });
  }

  late final _$updateCounterAtom =
      Atom(name: '_Todolist.updateCounter', context: context);

  @override
  int get updateCounter {
    _$updateCounterAtom.reportRead();
    return super.updateCounter;
  }

  @override
  set updateCounter(int value) {
    _$updateCounterAtom.reportWrite(value, super.updateCounter, () {
      super.updateCounter = value;
    });
  }

  late final _$parentAtom = Atom(name: '_Todolist.parent', context: context);

  @override
  ObjectId? get parent {
    _$parentAtom.reportRead();
    return super.parent;
  }

  @override
  set parent(ObjectId? value) {
    _$parentAtom.reportWrite(value, super.parent, () {
      super.parent = value;
    });
  }

  late final _$_TodolistActionController =
      ActionController(name: '_Todolist', context: context);

  @override
  void initialize() {
    final _$actionInfo =
        _$_TodolistActionController.startAction(name: '_Todolist.initialize');
    try {
      return super.initialize();
    } finally {
      _$_TodolistActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addPj(PJ pj) {
    final _$actionInfo =
        _$_TodolistActionController.startAction(name: '_Todolist.addPj');
    try {
      return super.addPj(pj);
    } finally {
      _$_TodolistActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removePj(ObjectId id) {
    final _$actionInfo =
        _$_TodolistActionController.startAction(name: '_Todolist.removePj');
    try {
      return super.removePj(id);
    } finally {
      _$_TodolistActionController.endAction(_$actionInfo);
    }
  }

  @override
  void fetchTodos(
      FilterType newFilterType, SortType newSortType, ObjectId? newParent) {
    final _$actionInfo =
        _$_TodolistActionController.startAction(name: '_Todolist.fetchTodos');
    try {
      return super.fetchTodos(newFilterType, newSortType, newParent);
    } finally {
      _$_TodolistActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
tds: ${tds},
pjs: ${pjs},
roots: ${roots},
hierarchy: ${hierarchy},
tdsNoPj: ${tdsNoPj},
filterType: ${filterType},
sortType: ${sortType},
updateCounter: ${updateCounter},
parent: ${parent}
    ''';
  }
}

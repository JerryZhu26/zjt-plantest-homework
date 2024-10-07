// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class RDate extends _RDate with RealmEntity, RealmObjectBase, EmbeddedObject {
  RDate(
    int year,
    int month,
    int day,
  ) {
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'month', month);
    RealmObjectBase.set(this, 'day', day);
  }

  RDate._();

  @override
  int get year => RealmObjectBase.get<int>(this, 'year') as int;
  @override
  set year(int value) => RealmObjectBase.set(this, 'year', value);

  @override
  int get month => RealmObjectBase.get<int>(this, 'month') as int;
  @override
  set month(int value) => RealmObjectBase.set(this, 'month', value);

  @override
  int get day => RealmObjectBase.get<int>(this, 'day') as int;
  @override
  set day(int value) => RealmObjectBase.set(this, 'day', value);

  @override
  Stream<RealmObjectChanges<RDate>> get changes =>
      RealmObjectBase.getChanges<RDate>(this);

  @override
  Stream<RealmObjectChanges<RDate>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RDate>(this, keyPaths);

  @override
  RDate freeze() => RealmObjectBase.freezeObject<RDate>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'year': year.toEJson(),
      'month': month.toEJson(),
      'day': day.toEJson(),
    };
  }

  static EJsonValue _toEJson(RDate value) => value.toEJson();
  static RDate _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'year': EJsonValue year,
        'month': EJsonValue month,
        'day': EJsonValue day,
      } =>
        RDate(
          fromEJson(year),
          fromEJson(month),
          fromEJson(day),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RDate._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, RDate, 'RDate', [
      SchemaProperty('year', RealmPropertyType.int),
      SchemaProperty('month', RealmPropertyType.int),
      SchemaProperty('day', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RTime extends _RTime with RealmEntity, RealmObjectBase, EmbeddedObject {
  RTime(
    int hour,
    int minute,
  ) {
    RealmObjectBase.set(this, 'hour', hour);
    RealmObjectBase.set(this, 'minute', minute);
  }

  RTime._();

  @override
  int get hour => RealmObjectBase.get<int>(this, 'hour') as int;
  @override
  set hour(int value) => RealmObjectBase.set(this, 'hour', value);

  @override
  int get minute => RealmObjectBase.get<int>(this, 'minute') as int;
  @override
  set minute(int value) => RealmObjectBase.set(this, 'minute', value);

  @override
  Stream<RealmObjectChanges<RTime>> get changes =>
      RealmObjectBase.getChanges<RTime>(this);

  @override
  Stream<RealmObjectChanges<RTime>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RTime>(this, keyPaths);

  @override
  RTime freeze() => RealmObjectBase.freezeObject<RTime>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'hour': hour.toEJson(),
      'minute': minute.toEJson(),
    };
  }

  static EJsonValue _toEJson(RTime value) => value.toEJson();
  static RTime _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'hour': EJsonValue hour,
        'minute': EJsonValue minute,
      } =>
        RTime(
          fromEJson(hour),
          fromEJson(minute),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RTime._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, RTime, 'RTime', [
      SchemaProperty('hour', RealmPropertyType.int),
      SchemaProperty('minute', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RDateTime extends _RDateTime
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  RDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) {
    RealmObjectBase.set(this, 'year', year);
    RealmObjectBase.set(this, 'month', month);
    RealmObjectBase.set(this, 'day', day);
    RealmObjectBase.set(this, 'hour', hour);
    RealmObjectBase.set(this, 'minute', minute);
  }

  RDateTime._();

  @override
  int get year => RealmObjectBase.get<int>(this, 'year') as int;
  @override
  set year(int value) => RealmObjectBase.set(this, 'year', value);

  @override
  int get month => RealmObjectBase.get<int>(this, 'month') as int;
  @override
  set month(int value) => RealmObjectBase.set(this, 'month', value);

  @override
  int get day => RealmObjectBase.get<int>(this, 'day') as int;
  @override
  set day(int value) => RealmObjectBase.set(this, 'day', value);

  @override
  int get hour => RealmObjectBase.get<int>(this, 'hour') as int;
  @override
  set hour(int value) => RealmObjectBase.set(this, 'hour', value);

  @override
  int get minute => RealmObjectBase.get<int>(this, 'minute') as int;
  @override
  set minute(int value) => RealmObjectBase.set(this, 'minute', value);

  @override
  Stream<RealmObjectChanges<RDateTime>> get changes =>
      RealmObjectBase.getChanges<RDateTime>(this);

  @override
  Stream<RealmObjectChanges<RDateTime>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RDateTime>(this, keyPaths);

  @override
  RDateTime freeze() => RealmObjectBase.freezeObject<RDateTime>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'year': year.toEJson(),
      'month': month.toEJson(),
      'day': day.toEJson(),
      'hour': hour.toEJson(),
      'minute': minute.toEJson(),
    };
  }

  static EJsonValue _toEJson(RDateTime value) => value.toEJson();
  static RDateTime _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'year': EJsonValue year,
        'month': EJsonValue month,
        'day': EJsonValue day,
        'hour': EJsonValue hour,
        'minute': EJsonValue minute,
      } =>
        RDateTime(
          fromEJson(year),
          fromEJson(month),
          fromEJson(day),
          fromEJson(hour),
          fromEJson(minute),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RDateTime._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.embeddedObject, RDateTime, 'RDateTime', [
      SchemaProperty('year', RealmPropertyType.int),
      SchemaProperty('month', RealmPropertyType.int),
      SchemaProperty('day', RealmPropertyType.int),
      SchemaProperty('hour', RealmPropertyType.int),
      SchemaProperty('minute', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class RHour extends _RHour with RealmEntity, RealmObjectBase, EmbeddedObject {
  RHour(
    int which,
    int rate,
    String comment,
  ) {
    RealmObjectBase.set(this, 'which', which);
    RealmObjectBase.set(this, 'rate', rate);
    RealmObjectBase.set(this, 'comment', comment);
  }

  RHour._();

  @override
  int get which => RealmObjectBase.get<int>(this, 'which') as int;
  @override
  set which(int value) => RealmObjectBase.set(this, 'which', value);

  @override
  int get rate => RealmObjectBase.get<int>(this, 'rate') as int;
  @override
  set rate(int value) => RealmObjectBase.set(this, 'rate', value);

  @override
  String get comment => RealmObjectBase.get<String>(this, 'comment') as String;
  @override
  set comment(String value) => RealmObjectBase.set(this, 'comment', value);

  @override
  Stream<RealmObjectChanges<RHour>> get changes =>
      RealmObjectBase.getChanges<RHour>(this);

  @override
  Stream<RealmObjectChanges<RHour>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<RHour>(this, keyPaths);

  @override
  RHour freeze() => RealmObjectBase.freezeObject<RHour>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'which': which.toEJson(),
      'rate': rate.toEJson(),
      'comment': comment.toEJson(),
    };
  }

  static EJsonValue _toEJson(RHour value) => value.toEJson();
  static RHour _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'which': EJsonValue which,
        'rate': EJsonValue rate,
        'comment': EJsonValue comment,
      } =>
        RHour(
          fromEJson(which),
          fromEJson(rate),
          fromEJson(comment),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RHour._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, RHour, 'RHour', [
      SchemaProperty('which', RealmPropertyType.int),
      SchemaProperty('rate', RealmPropertyType.int),
      SchemaProperty('comment', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TK extends _TK with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TK(
    ObjectId id,
    String ownerId,
    String name, {
    RDate? date,
    RTime? startTime,
    RTime? endTime,
    String? comment,
    String? tag,
    Iterable<String> more = const [],
    PJ? project,
    String color = "TaskColor.green",
    String side = "Side.left",
    bool isRest = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TK>({
        'color': "TaskColor.green",
        'side': "Side.left",
        'isRest': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'startTime', startTime);
    RealmObjectBase.set(this, 'endTime', endTime);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'comment', comment);
    RealmObjectBase.set(this, 'tag', tag);
    RealmObjectBase.set<RealmList<String>>(
        this, 'more', RealmList<String>(more));
    RealmObjectBase.set(this, 'project', project);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'side', side);
    RealmObjectBase.set(this, 'isRest', isRest);
  }

  TK._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  RDate? get date => RealmObjectBase.get<RDate>(this, 'date') as RDate?;
  @override
  set date(covariant RDate? value) => RealmObjectBase.set(this, 'date', value);

  @override
  RTime? get startTime =>
      RealmObjectBase.get<RTime>(this, 'startTime') as RTime?;
  @override
  set startTime(covariant RTime? value) =>
      RealmObjectBase.set(this, 'startTime', value);

  @override
  RTime? get endTime => RealmObjectBase.get<RTime>(this, 'endTime') as RTime?;
  @override
  set endTime(covariant RTime? value) =>
      RealmObjectBase.set(this, 'endTime', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get comment =>
      RealmObjectBase.get<String>(this, 'comment') as String?;
  @override
  set comment(String? value) => RealmObjectBase.set(this, 'comment', value);

  @override
  String? get tag => RealmObjectBase.get<String>(this, 'tag') as String?;
  @override
  set tag(String? value) => RealmObjectBase.set(this, 'tag', value);

  @override
  RealmList<String> get more =>
      RealmObjectBase.get<String>(this, 'more') as RealmList<String>;
  @override
  set more(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  PJ? get project => RealmObjectBase.get<PJ>(this, 'project') as PJ?;
  @override
  set project(covariant PJ? value) =>
      RealmObjectBase.set(this, 'project', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

  @override
  String get side => RealmObjectBase.get<String>(this, 'side') as String;
  @override
  set side(String value) => RealmObjectBase.set(this, 'side', value);

  @override
  bool get isRest => RealmObjectBase.get<bool>(this, 'isRest') as bool;
  @override
  set isRest(bool value) => RealmObjectBase.set(this, 'isRest', value);

  @override
  Stream<RealmObjectChanges<TK>> get changes =>
      RealmObjectBase.getChanges<TK>(this);

  @override
  Stream<RealmObjectChanges<TK>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TK>(this, keyPaths);

  @override
  TK freeze() => RealmObjectBase.freezeObject<TK>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'date': date.toEJson(),
      'startTime': startTime.toEJson(),
      'endTime': endTime.toEJson(),
      'name': name.toEJson(),
      'comment': comment.toEJson(),
      'tag': tag.toEJson(),
      'more': more.toEJson(),
      'project': project.toEJson(),
      'color': color.toEJson(),
      'side': side.toEJson(),
      'isRest': isRest.toEJson(),
    };
  }

  static EJsonValue _toEJson(TK value) => value.toEJson();
  static TK _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
        'name': EJsonValue name,
      } =>
        TK(
          fromEJson(id),
          fromEJson(ownerId),
          fromEJson(name),
          date: fromEJson(ejson['date']),
          startTime: fromEJson(ejson['startTime']),
          endTime: fromEJson(ejson['endTime']),
          comment: fromEJson(ejson['comment']),
          tag: fromEJson(ejson['tag']),
          more: fromEJson(ejson['more']),
          project: fromEJson(ejson['project']),
          color: fromEJson(ejson['color'], defaultValue: "TaskColor.green"),
          side: fromEJson(ejson['side'], defaultValue: "Side.left"),
          isRest: fromEJson(ejson['isRest'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TK._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, TK, 'TK', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.object,
          optional: true, linkTarget: 'RDate'),
      SchemaProperty('startTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RTime'),
      SchemaProperty('endTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RTime'),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('comment', RealmPropertyType.string, optional: true),
      SchemaProperty('tag', RealmPropertyType.string, optional: true),
      SchemaProperty('more', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('project', RealmPropertyType.object,
          optional: true, linkTarget: 'PJ'),
      SchemaProperty('color', RealmPropertyType.string),
      SchemaProperty('side', RealmPropertyType.string),
      SchemaProperty('isRest', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class DA extends _DA with RealmEntity, RealmObjectBase, RealmObject {
  DA(
    ObjectId id,
    String ownerId, {
    RDate? date,
    Iterable<RHour> hours = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set<RealmList<RHour>>(
        this, 'hours', RealmList<RHour>(hours));
  }

  DA._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  RDate? get date => RealmObjectBase.get<RDate>(this, 'date') as RDate?;
  @override
  set date(covariant RDate? value) => RealmObjectBase.set(this, 'date', value);

  @override
  RealmList<RHour> get hours =>
      RealmObjectBase.get<RHour>(this, 'hours') as RealmList<RHour>;
  @override
  set hours(covariant RealmList<RHour> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<DA>> get changes =>
      RealmObjectBase.getChanges<DA>(this);

  @override
  Stream<RealmObjectChanges<DA>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<DA>(this, keyPaths);

  @override
  DA freeze() => RealmObjectBase.freezeObject<DA>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'date': date.toEJson(),
      'hours': hours.toEJson(),
    };
  }

  static EJsonValue _toEJson(DA value) => value.toEJson();
  static DA _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
      } =>
        DA(
          fromEJson(id),
          fromEJson(ownerId),
          date: fromEJson(ejson['date']),
          hours: fromEJson(ejson['hours']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(DA._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, DA, 'DA', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.object,
          optional: true, linkTarget: 'RDate'),
      SchemaProperty('hours', RealmPropertyType.object,
          linkTarget: 'RHour', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class NT extends _NT with RealmEntity, RealmObjectBase, RealmObject {
  NT(
    ObjectId id,
    String ownerId,
    String name, {
    RDate? date,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'name', name);
  }

  NT._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  RDate? get date => RealmObjectBase.get<RDate>(this, 'date') as RDate?;
  @override
  set date(covariant RDate? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  Stream<RealmObjectChanges<NT>> get changes =>
      RealmObjectBase.getChanges<NT>(this);

  @override
  Stream<RealmObjectChanges<NT>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<NT>(this, keyPaths);

  @override
  NT freeze() => RealmObjectBase.freezeObject<NT>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'date': date.toEJson(),
      'name': name.toEJson(),
    };
  }

  static EJsonValue _toEJson(NT value) => value.toEJson();
  static NT _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
        'name': EJsonValue name,
      } =>
        NT(
          fromEJson(id),
          fromEJson(ownerId),
          fromEJson(name),
          date: fromEJson(ejson['date']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(NT._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, NT, 'NT', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.object,
          optional: true, linkTarget: 'RDate'),
      SchemaProperty('name', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PJ extends _PJ with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PJ(
    ObjectId id,
    String ownerId,
    String name, {
    Iterable<ObjectId> children = const [],
    ObjectId? parent,
    String color = "TaskColor.green",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PJ>({
        'color': "TaskColor.green",
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set<RealmList<ObjectId>>(
        this, 'children', RealmList<ObjectId>(children));
    RealmObjectBase.set(this, 'parent', parent);
    RealmObjectBase.set(this, 'color', color);
  }

  PJ._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<ObjectId> get children =>
      RealmObjectBase.get<ObjectId>(this, 'children') as RealmList<ObjectId>;
  @override
  set children(covariant RealmList<ObjectId> value) =>
      throw RealmUnsupportedSetError();

  @override
  ObjectId? get parent =>
      RealmObjectBase.get<ObjectId>(this, 'parent') as ObjectId?;
  @override
  set parent(ObjectId? value) => RealmObjectBase.set(this, 'parent', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

  @override
  Stream<RealmObjectChanges<PJ>> get changes =>
      RealmObjectBase.getChanges<PJ>(this);

  @override
  Stream<RealmObjectChanges<PJ>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<PJ>(this, keyPaths);

  @override
  PJ freeze() => RealmObjectBase.freezeObject<PJ>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'name': name.toEJson(),
      'children': children.toEJson(),
      'parent': parent.toEJson(),
      'color': color.toEJson(),
    };
  }

  static EJsonValue _toEJson(PJ value) => value.toEJson();
  static PJ _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
        'name': EJsonValue name,
      } =>
        PJ(
          fromEJson(id),
          fromEJson(ownerId),
          fromEJson(name),
          children: fromEJson(ejson['children']),
          parent: fromEJson(ejson['parent']),
          color: fromEJson(ejson['color'], defaultValue: "TaskColor.green"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PJ._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, PJ, 'PJ', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('children', RealmPropertyType.objectid,
          collectionType: RealmCollectionType.list),
      SchemaProperty('parent', RealmPropertyType.objectid, optional: true),
      SchemaProperty('color', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TD extends _TD with RealmEntity, RealmObjectBase, RealmObject {
  TD(
    ObjectId id,
    String ownerId,
    String name, {
    RDate? date,
    RTime? startTime,
    RTime? endTime,
    RDateTime? finishTime,
    String? comment,
    String? repetition,
    Iterable<String> more = const [],
    PJ? project,
    String? color,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'startTime', startTime);
    RealmObjectBase.set(this, 'endTime', endTime);
    RealmObjectBase.set(this, 'finishTime', finishTime);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'comment', comment);
    RealmObjectBase.set(this, 'repetition', repetition);
    RealmObjectBase.set<RealmList<String>>(
        this, 'more', RealmList<String>(more));
    RealmObjectBase.set(this, 'project', project);
    RealmObjectBase.set(this, 'color', color);
  }

  TD._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  RDate? get date => RealmObjectBase.get<RDate>(this, 'date') as RDate?;
  @override
  set date(covariant RDate? value) => RealmObjectBase.set(this, 'date', value);

  @override
  RTime? get startTime =>
      RealmObjectBase.get<RTime>(this, 'startTime') as RTime?;
  @override
  set startTime(covariant RTime? value) =>
      RealmObjectBase.set(this, 'startTime', value);

  @override
  RTime? get endTime => RealmObjectBase.get<RTime>(this, 'endTime') as RTime?;
  @override
  set endTime(covariant RTime? value) =>
      RealmObjectBase.set(this, 'endTime', value);

  @override
  RDateTime? get finishTime =>
      RealmObjectBase.get<RDateTime>(this, 'finishTime') as RDateTime?;
  @override
  set finishTime(covariant RDateTime? value) =>
      RealmObjectBase.set(this, 'finishTime', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get comment =>
      RealmObjectBase.get<String>(this, 'comment') as String?;
  @override
  set comment(String? value) => RealmObjectBase.set(this, 'comment', value);

  @override
  String? get repetition =>
      RealmObjectBase.get<String>(this, 'repetition') as String?;
  @override
  set repetition(String? value) =>
      RealmObjectBase.set(this, 'repetition', value);

  @override
  RealmList<String> get more =>
      RealmObjectBase.get<String>(this, 'more') as RealmList<String>;
  @override
  set more(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  PJ? get project => RealmObjectBase.get<PJ>(this, 'project') as PJ?;
  @override
  set project(covariant PJ? value) =>
      RealmObjectBase.set(this, 'project', value);

  @override
  String? get color => RealmObjectBase.get<String>(this, 'color') as String?;
  @override
  set color(String? value) => RealmObjectBase.set(this, 'color', value);

  @override
  Stream<RealmObjectChanges<TD>> get changes =>
      RealmObjectBase.getChanges<TD>(this);

  @override
  Stream<RealmObjectChanges<TD>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TD>(this, keyPaths);

  @override
  TD freeze() => RealmObjectBase.freezeObject<TD>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'date': date.toEJson(),
      'startTime': startTime.toEJson(),
      'endTime': endTime.toEJson(),
      'finishTime': finishTime.toEJson(),
      'name': name.toEJson(),
      'comment': comment.toEJson(),
      'repetition': repetition.toEJson(),
      'more': more.toEJson(),
      'project': project.toEJson(),
      'color': color.toEJson(),
    };
  }

  static EJsonValue _toEJson(TD value) => value.toEJson();
  static TD _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
        'name': EJsonValue name,
      } =>
        TD(
          fromEJson(id),
          fromEJson(ownerId),
          fromEJson(name),
          date: fromEJson(ejson['date']),
          startTime: fromEJson(ejson['startTime']),
          endTime: fromEJson(ejson['endTime']),
          finishTime: fromEJson(ejson['finishTime']),
          comment: fromEJson(ejson['comment']),
          repetition: fromEJson(ejson['repetition']),
          more: fromEJson(ejson['more']),
          project: fromEJson(ejson['project']),
          color: fromEJson(ejson['color']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TD._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, TD, 'TD', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.object,
          optional: true, linkTarget: 'RDate'),
      SchemaProperty('startTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RTime'),
      SchemaProperty('endTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RTime'),
      SchemaProperty('finishTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RDateTime'),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('comment', RealmPropertyType.string, optional: true),
      SchemaProperty('repetition', RealmPropertyType.string, optional: true),
      SchemaProperty('more', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('project', RealmPropertyType.object,
          optional: true, linkTarget: 'PJ'),
      SchemaProperty('color', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AH extends _AH with RealmEntity, RealmObjectBase, RealmObject {
  AH(
    ObjectId id,
    String ownerId,
    String name, {
    RDateTime? createTime,
    Iterable<String> ask = const [],
    Iterable<String> ans = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'ownerId', ownerId);
    RealmObjectBase.set(this, 'createTime', createTime);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set<RealmList<String>>(this, 'ask', RealmList<String>(ask));
    RealmObjectBase.set<RealmList<String>>(this, 'ans', RealmList<String>(ans));
  }

  AH._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get ownerId => RealmObjectBase.get<String>(this, 'ownerId') as String;
  @override
  set ownerId(String value) => RealmObjectBase.set(this, 'ownerId', value);

  @override
  RDateTime? get createTime =>
      RealmObjectBase.get<RDateTime>(this, 'createTime') as RDateTime?;
  @override
  set createTime(covariant RDateTime? value) =>
      RealmObjectBase.set(this, 'createTime', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<String> get ask =>
      RealmObjectBase.get<String>(this, 'ask') as RealmList<String>;
  @override
  set ask(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get ans =>
      RealmObjectBase.get<String>(this, 'ans') as RealmList<String>;
  @override
  set ans(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AH>> get changes =>
      RealmObjectBase.getChanges<AH>(this);

  @override
  Stream<RealmObjectChanges<AH>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AH>(this, keyPaths);

  @override
  AH freeze() => RealmObjectBase.freezeObject<AH>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'ownerId': ownerId.toEJson(),
      'createTime': createTime.toEJson(),
      'name': name.toEJson(),
      'ask': ask.toEJson(),
      'ans': ans.toEJson(),
    };
  }

  static EJsonValue _toEJson(AH value) => value.toEJson();
  static AH _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'ownerId': EJsonValue ownerId,
        'name': EJsonValue name,
      } =>
        AH(
          fromEJson(id),
          fromEJson(ownerId),
          fromEJson(name),
          createTime: fromEJson(ejson['createTime']),
          ask: fromEJson(ejson['ask']),
          ans: fromEJson(ejson['ans']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AH._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, AH, 'AH', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('ownerId', RealmPropertyType.string),
      SchemaProperty('createTime', RealmPropertyType.object,
          optional: true, linkTarget: 'RDateTime'),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('ask', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('ans', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

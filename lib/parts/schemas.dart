import 'package:realm/realm.dart';
import 'package:timona_ec/main.dart';

part 'schemas.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _RDate {
  late int year, month, day;
}

@RealmModel(ObjectType.embeddedObject)
class _RTime {
  late int hour, minute;
}

@RealmModel(ObjectType.embeddedObject)
class _RDateTime {
  late int year, month, day;
  late int hour, minute;
}

@RealmModel(ObjectType.embeddedObject)
class _RHour {
  late int which, rate;
  late String comment;
}

@RealmModel()
// TK for TasK
class _TK {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late _RDate? date;
  late _RTime? startTime, endTime;
  late String name;
  late String? comment, tag;
  late List<String> more;
  late _PJ? project;
  String color = "TaskColor.green";
  String side = "Side.left";
  bool isRest = false;
}

@RealmModel()
// DA for DAy
class _DA {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late _RDate? date;
  late List<_RHour> hours;
}

@RealmModel()
// NT for Notice
class _NT {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late _RDate? date;
  late String name;
}

@RealmModel()
// PJ for Project
class _PJ {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late String name;
  late List<ObjectId> children;
  ObjectId? parent;
  String color = "TaskColor.green";
}

@RealmModel()
// TD for To-Do
class _TD {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late _RDate? date;
  late _RTime? startTime, endTime;
  late _RDateTime? finishTime;
  late String name;
  late String? comment, repetition;
  late List<String> more;
  late _PJ? project;

  String? color;
}

@RealmModel()
// AH for Ai History
class _AH {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String ownerId;

  late _RDateTime? createTime;
  late String name;
  late List<String> ask, ans;
}

Configuration configRealm() {
  int schemaVersion = 14;
  List<SchemaObject> schemas = [
    TK.schema,
    DA.schema,
    NT.schema,
    TD.schema,
    PJ.schema,
    AH.schema,
    RDate.schema,
    RTime.schema,
    RDateTime.schema,
    RHour.schema,
  ];
  void Function(Migration, int) migCall = ((mig, oldSchemaVersion) {
    print("Migrate: $oldSchemaVersion => $schemaVersion");
    if (oldSchemaVersion < 5 && schemaVersion >= 5) {
      final oldTKs = mig.oldRealm.all('TK');
      for (final oldTK in oldTKs) {
        final newTK = mig.findInNewRealm<TK>(oldTK);
        if (newTK == null) continue;
        if (newTK.id.toString() == '000000000000000000000000') {
          newTK.id = ObjectId();
        }
        newTK.ownerId = ECApp.userId();
      }
      final oldDAs = mig.oldRealm.all('DA');
      for (final oldDA in oldDAs) {
        final newDA = mig.findInNewRealm<DA>(oldDA);
        if (newDA == null) continue;
        if (newDA.id.toString() == '000000000000000000000000') {
          newDA.id = ObjectId();
        }
        newDA.ownerId = ECApp.userId();
      }
      if (oldSchemaVersion >= 2) {
        final oldNTs = mig.oldRealm.all('NT');
        for (final oldNT in oldNTs) {
          final newNT = mig.findInNewRealm<NT>(oldNT);
          if (newNT == null) continue;
          if (newNT.id.toString() == '000000000000000000000000') {
            newNT.id = ObjectId();
          }
          newNT.ownerId = ECApp.userId();
        }
      }
    } else if (oldSchemaVersion < 6 && schemaVersion >= 6) {
      final oldTKs = mig.oldRealm.all('TK');
      for (final oldTK in oldTKs) {
        final newTK = mig.findInNewRealm<TK>(oldTK);
        if (newTK == null) continue;
        newTK.project = null;
      }
    }
  });
  return Configuration.local(schemas,
      schemaVersion: schemaVersion, migrationCallback: migCall);
}

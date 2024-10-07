part of 'package:timona_ec/parts/general.dart';

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors
// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables

/// Get Storage 信息汇总
/// 1. Global
///   rateByHour：用小时还是任务来评价
///   whichScreen：当前在那个页面
/// 2. Timer
///   timer.start：计时的起始时间
///   timer.changeTime：当前的 changeTime 列表
///   timer.changeType：当前的 changeType 列表
///   timer.beginTaskName：开始计时的任务名称

enum Place { todos, central, history, my, timer }

/// 任务信息保存实例
class Task {
  String name;
  Time startTime, endTime;
  Date date;
  String? tag, comment, flag;
  Side side;
  TaskColor taskColor;
  bool isRest;
  PJ? project;

  Task({
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.side,
    this.tag,
    this.comment,
    this.isRest = false,
    this.taskColor = TaskColor.green,
    this.flag,
    this.project,
  });

  @override
  String toString() {
    return tag != null
        ? "\"$name($tag)\": $date $startTime~$endTime ${side.name} ${taskColor.name} ${comment ?? ''}"
        : "\"$name\": $date $startTime~$endTime ${side.name} ${taskColor.name} ${comment ?? ''}";
  }

  String get s => toString();

  TK toRealm() {
    return TK(
      ObjectId(),
      ECApp.userId(),
      name,
      date: date.r,
      startTime: startTime.r,
      endTime: endTime.r,
      side: side.name,
      comment: comment,
      tag: tag,
      color: taskColor.name,
      isRest: isRest,
      project: project,
    );
  }

  TK get r => toRealm();

  static Task fromRealm(TK tk) {
    return Task(
      name: tk.name,
      date: Date.fr(tk.date ?? Date.now().r),
      startTime: Time.fr(tk.startTime ?? Time.now().r),
      endTime: Time.fr(tk.endTime ?? Time.now().r),
      side: Side.values.byName(tk.side),
      comment: tk.comment,
      tag: tk.tag,
      taskColor: TaskColor.values.byName(tk.color),
      isRest: tk.isRest,
      project: tk.project,
    );
  }

  static Task fr(TK tk) {
    return Task.fromRealm(tk);
  }

  Piece toPiece(
    Util util, {
    (double, double)? dragPlace,
    bool? toDelete,
    Function? onToggle,
    Function? onDelete,
    List<(Time, Time)>? taskStacks,
  }) {
    return Piece(
      title: name,
      date: date,
      startTime: startTime,
      endTime: endTime,
      comment: comment,
      side: side,
      taskColor: taskColor,
      util: util,
      tag: tag,
      isRest: isRest,
      project: project,
      dragPlace: dragPlace,
      toDelete: toDelete,
      onToggle: onToggle,
      onDelete: onDelete,
      taskStacks: taskStacks ?? [],
    );
  }

  Piece p(
    Util util, {
    (double, double)? dragPlace,
    bool? toDelete,
    Function? onToggle,
    Function? onDelete,
    List<(Time, Time)>? taskStacks,
  }) {
    return toPiece(
      util,
      dragPlace: dragPlace,
      toDelete: toDelete,
      onToggle: onToggle,
      onDelete: onDelete,
      taskStacks: taskStacks,
    );
  }
}

class Todo {
  String name;
  PJ? project;
  Time? startTime, endTime;
  DateTime? finishTime;
  Date? date;
  String? comment, repetition;
  ObjectId? objectId;
  TaskColor? taskColor;

  Todo({
    required this.name,
    this.project,
    this.startTime,
    this.endTime,
    this.finishTime,
    this.date,
    this.comment,
    this.repetition,
    this.objectId,
    this.taskColor,
  });

  TD toRealm() {
    return TD(
      objectId ?? ObjectId(),
      ECApp.userId(),
      name,
      project: project,
      comment: comment,
      startTime: startTime?.r,
      endTime: endTime?.r,
      finishTime: dateTimeR(finishTime),
      date: date?.r,
      repetition: repetition,
      color: taskColor?.name,
    );
  }

  TD get r => toRealm();

  static Todo fromRealm(TD td) {
    return Todo(
      objectId: td.id,
      name: td.name,
      project: td.project,
      startTime: Time.frn(td.startTime),
      endTime: Time.frn(td.endTime),
      finishTime: dateTimeFR(td.finishTime),
      date: Date.frn(td.date),
      comment: td.comment,
      repetition: td.repetition,
      taskColor: td.color != null ? TaskColor.values.byName(td.color!) : null,
    );
  }

  static Todo fr(TD td) {
    return Todo.fromRealm(td);
  }

  @override
  String toString() {
    return "Todo: $name";
  }
}

class Proj {
  PJ project;
  String name;
  TaskColor taskColor;

  Proj({
    required this.project,
    required this.name,
    this.taskColor = TaskColor.green,
  });

  PJ toRealm() {
    return project;
  }

  PJ get r => toRealm();

  static Proj fromRealm(PJ pj) {
    return Proj(
      project: pj,
      name: pj.name,
      taskColor: TaskColor.values.byName(pj.color),
    );
  }

  static Proj fr(PJ pj) {
    return Proj.fromRealm(pj);
  }
}

RDateTime? dateTimeR(DateTime? d) {
  if (d == null) return null;
  return RDateTime(d.year, d.month, d.day, d.hour, d.minute);
}

DateTime? dateTimeFR(RDateTime? d) {
  if (d == null) return null;
  return DateTime(d.year, d.month, d.day, d.hour, d.minute);
}

String dateTimeSS(DateTime? d) {
  if (d == null) return "";
  return '${d.month}.${d.day} ${d.hour}:${d.minute}';
}

String dateTimeSSWY(DateTime? d) {
  if (d == null) return "";
  return '${d.year}.${d.month}.${d.day} ${itow(d.hour)}:${itow(d.minute)}';
}

// Aihist == Ai History <=> AH
class Aihist {
  DateTime createTime;
  String name;
  List<String> ask, ans;
  ObjectId? objectId;

  Aihist({
    required this.createTime,
    required this.name,
    required this.ask,
    required this.ans,
    this.objectId,
  });

  AH toRealm() {
    return AH(
      objectId ?? ObjectId(),
      ECApp.userId(),
      name,
      createTime: dateTimeR(createTime),
      ask: ask,
      ans: ans,
    );
  }

  AH get r => toRealm();

  static Aihist fromRealm(AH ah) {
    return Aihist(
      createTime: dateTimeFR(ah.createTime)!,
      name: ah.name,
      ask: ah.ask,
      ans: ah.ans,
      objectId: ah.id,
    );
  }

  static Aihist fr(AH ah) {
    return Aihist.fromRealm(ah);
  }

  @override
  String toString() {
    return "Ai History: \"$name\" on ${dateTimeSS(createTime)}";
  }
}

/// 一个只包含 Date，不包含 Time 的类
class Date {
  int year;
  int month;
  int day;

  Date({required this.year, required this.month, required this.day})
      : assert(month >= 1 && month <= 12),
        assert(day >= 1 && day <= _daysInMonth(year, month));

  @override
  String toString() {
    return '$year-${_addLeadingZero(month)}-${_addLeadingZero(day)}';
  }

  String get s => toString();

  String toShortString() {
    return '$month.$day';
  }

  String get ss => toShortString();

  String toShortStringWithYear() {
    return '${year % 100}.$month.$day';
  }

  String get sswy => toShortStringWithYear();

  RDate toRDate() {
    return RDate(year, month, day);
  }

  RDate get r => toRDate();

  static Date fromRealm(RDate date) {
    return Date(year: date.year, month: date.month, day: date.day);
  }

  static Date fr(RDate date) {
    return fromRealm(date);
  }

  static Date? fromRealmNullable(RDate? date) {
    if (date == null) return null;
    return Date(year: date.year, month: date.month, day: date.day);
  }

  static Date? frn(RDate? date) {
    return fromRealmNullable(date);
  }

  static Date fromDateTime(DateTime dateTime) {
    return Date(year: dateTime.year, month: dateTime.month, day: dateTime.day);
  }

  DateTime toDateTime() {
    DateTime dnow = DateTime.now();
    return DateTime(year, month, day, dnow.hour, dnow.minute);
  }

  DateTime get d => toDateTime();

  int get weekday => toDateTime().weekday;

  static Date now() {
    return Date(
      year: DateTime.now().year,
      month: DateTime.now().month,
      day: DateTime.now().day,
    );
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  static String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : value.toString();
  }

  void add(Date date) {
    day += date.day;
    if (day > _daysInMonth(year, month)) {
      day -= _daysInMonth(year, month);
      month++;
      if (month > 12) {
        month -= 12;
        year++;
      }
    }
  }

  int toComparable() {
    return year * 10000 + month * 100 + day;
  }

  factory Date.fromNoYearShortString(String str) {
    return Date(
      year: DateTime.now().year,
      month: int.tryParse(str.split('.')[0]) ?? 0,
      day: int.tryParse(str.split('.')[1]) ?? 0,
    );
  }

  bool operator >(Date tm) {
    if (year > tm.year) return true;
    if (year == tm.year && month > tm.month) return true;
    if (year == tm.year && month == tm.month && day > tm.day) return true;
    return false;
  }

  bool operator <(Date tm) {
    if (year < tm.year) return true;
    if (year == tm.year && month < tm.month) return true;
    if (year == tm.year && month == tm.month && day < tm.day) return true;
    return false;
  }

  bool equal(Date tm) {
    return year == tm.year && month == tm.month && day == tm.day;
  }

  bool operator >=(Date tm) {
    if (year > tm.year) return true;
    if (year == tm.year && month > tm.month) return true;
    if (year == tm.year && month == tm.month && day > tm.day) return true;
    if (equal(tm)) return true;
    return false;
  }

  bool operator <=(Date tm) {
    if (year < tm.year) return true;
    if (year == tm.year && month < tm.month) return true;
    if (year == tm.year && month == tm.month && day < tm.day) return true;
    if (equal(tm)) return true;
    return false;
  }
}

/// 一个只包含 Time，不包含 Date 的类
class Time {
  int hour;
  int minute;

  Time({required this.hour, required this.minute})
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  @override
  String toString() {
    return '$hour:${_addLeadingZero(minute)}';
  }

  String get s => toString();

  String toShortString() {
    return '$hour:${_addLeadingZero(minute)}';
  }

  String get ss => toShortString();

  RTime toRTime() {
    return RTime(hour, minute);
  }

  RTime get r => toRTime();

  DateTime toDateTime(Date date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime d(Date date) {
    return toDateTime(date);
  }

  int toComparable() {
    return hour * 60 + minute;
  }

  get comparable => hour * 60 + minute;

  factory Time.fromRealm(RTime time) {
    return Time(hour: time.hour, minute: time.minute);
  }

  static Time fr(RTime time) {
    return Time.fromRealm(time);
  }

  static Time? fromRealmNullable(RTime? time) {
    if (time == null) return null;
    return Time(hour: time.hour, minute: time.minute);
  }

  static Time? frn(RTime? time) {
    return Time.fromRealmNullable(time);
  }

  factory Time.fromDateTime(DateTime dateTime) {
    return Time(hour: dateTime.hour, minute: dateTime.minute);
  }

  factory Time.fromPreciseTime(PreciseTime time) {
    return Time(hour: time.hour, minute: time.minute);
  }

  factory Time.fromString(String str) {
    if (str.length != 4) {
      return Time(
        hour: int.tryParse(str.substring(0, 2)) ?? 0,
        minute: int.tryParse(str.substring(3, 5)) ?? 0,
      );
    } else {
      return Time(
        hour: int.tryParse(str.substring(0, 1)) ?? 0,
        minute: int.tryParse(str.substring(2, 4)) ?? 0,
      );
    }
  }

  factory Time.fromShortString(String str) {
    if (str.split(':').length > 1)
      return Time(
        hour: int.tryParse(str.split(':')[0]) ?? 0,
        minute: int.tryParse(str.split(':')[1]) ?? 0,
      );
    else
      return Time(
        hour: int.tryParse(str.split('.')[0]) ?? 0,
        minute: int.tryParse(str.split('.')[1]) ?? 0,
      );
  }

  factory Time.fromComparable(int comp) {
    return comp >= 1439
        ? Time(hour: 23, minute: 59)
        : Time(hour: comp ~/ 60, minute: comp % 60);
  }

  static Time fc(int comp) {
    return Time.fromComparable(comp);
  }

  /// In Realm form, from String form
  static RTime rfs(String str) {
    return Time.fromString(str).r;
  }

  static Time now() {
    return Time(
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
    );
  }

  static String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : value.toString();
  }

  bool operator >(Time tm) {
    if (hour > tm.hour) return true;
    if (hour == tm.hour && minute > tm.minute) return true;
    return false;
  }

  bool operator <(Time tm) {
    print(tm);
    if (hour < tm.hour) return true;
    if (hour == tm.hour && minute < tm.minute) return true;
    return false;
  }

  bool equal(Time tm) {
    return hour == tm.hour && minute == tm.minute;
  }

  int operator -(Time tm) {
    return -(tm.hour - hour) * 60 - (tm.minute - minute);
  }
}

class PreciseTime {
  int hour;
  int minute;
  int second;

  PreciseTime({required this.hour, required this.minute, this.second = 0})
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60),
        assert(second >= 0 && second < 60);

  @override
  String toString() {
    return '${_addLeadingZero(hour)}:${_addLeadingZero(minute)}:${_addLeadingZero(second)}';
  }

  String get s => toString();

  factory PreciseTime.fromDateTime(DateTime dateTime) {
    return PreciseTime(
        hour: dateTime.hour, minute: dateTime.minute, second: dateTime.second);
  }

  factory PreciseTime.fromTime(Time time, {required int second}) {
    return PreciseTime(hour: time.hour, minute: time.minute, second: second);
  }

  factory PreciseTime.fromSeconds(int seconds) {
    return PreciseTime.fromDateTime(
        DateTime(0).add(Duration(seconds: seconds)));
  }

  factory PreciseTime.fromString(String str) {
    return PreciseTime(
      hour: int.tryParse(str.substring(0, 2)) ?? 0,
      minute: int.tryParse(str.substring(3, 5)) ?? 0,
      second: int.tryParse(str.substring(6, 8)) ?? 0,
    );
  }

  DateTime toDateTime(Date date) {
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  DateTime d(Date date) {
    return toDateTime(date);
  }

  static PreciseTime now() {
    return PreciseTime(
      hour: DateTime.now().hour,
      minute: DateTime.now().minute,
      second: DateTime.now().second,
    );
  }

  Duration difference(PreciseTime b) {
    return toDateTime(Date.now()).difference(b.toDateTime(Date.now()));
  }

  static String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : value.toString();
  }

  bool operator >(PreciseTime tm) {
    if (hour > tm.hour) return true;
    if (hour == tm.hour && minute > tm.minute) return true;
    if (hour == tm.hour && minute == tm.minute && second > tm.second)
      return true;
    return false;
  }

  bool operator <(PreciseTime tm) {
    if (hour < tm.hour) return true;
    if (hour == tm.hour && minute < tm.minute) return true;
    if (hour == tm.hour && minute == tm.minute && second < tm.second)
      return true;
    return false;
  }

  bool operator >=(PreciseTime tm) {
    if (hour >= tm.hour) return true;
    if (hour == tm.hour && minute >= tm.minute) return true;
    if (hour == tm.hour && minute == tm.minute && second >= tm.second)
      return true;
    return false;
  }

  bool operator <=(PreciseTime tm) {
    if (hour <= tm.hour) return true;
    if (hour == tm.hour && minute <= tm.minute) return true;
    if (hour == tm.hour && minute == tm.minute && second <= tm.second)
      return true;
    return false;
  }
}

class Hour {
  int which;
  int rate;
  String comment;

  Hour(this.which, {this.rate = 3, this.comment = ""});

  @override
  String toString() {
    return "$which: $rate $comment";
  }

  String get s => toString();

  void update(int newRate, String newComment) {
    rate = newRate;
    comment = newComment;
  }

  RHour toRealm() {
    return RHour(which, rate, comment);
  }

  RHour get r => toRealm();

  static Hour fromRealm(RHour rHour) {
    return Hour(rHour.which, rate: rHour.rate, comment: rHour.comment);
  }

  static Hour? getFromRList(int theWhich, RealmList<RHour> hours) {
    for (var i = 0; i < hours.length; i++) {
      if (hours[i].which == theWhich) {
        return Hour.fromRealm(hours[i]);
      }
    }
    return null;
  }

  static RealmList<RHour> replaceFromRList(
      int theWhich, Hour toReplace, RealmList<RHour> hours) {
    RealmList<RHour> edited = hours;
    bool flag = false;
    for (var i = 0; i < hours.length; i++) {
      if (edited[i].which == theWhich) {
        edited[i] = toReplace.r;
        flag = true;
      }
    }
    if (!flag) {
      edited.add(toReplace.r);
    }
    return edited;
  }
}

/// 关于今天是哪一天
class DayAt {
  Date day;

  DayAt(this.day);

  @override
  String toString() {
    return day.toString();
  }

  String get s => toString();
}

/// 可暂停的，关于目前的计时情况
class TimingState {
  PreciseTime? start;
  int seconds = 0;

  // Pause = False, Resume = True
  List changeType = [];
  List changeTime = [];

  TimingState(this.start, {this.seconds = 0});

  TimingState.notStarted();

  TimingState.recorded(this.start, this.changeType, this.changeTime) {
    calcSeconds();
  }

  @override
  String toString() {
    return start.toString();
  }

  String get s => toString();

  void change(bool type, PreciseTime time) {
    changeType.add(type);
    changeTime.add(time.s);
  }

  void startTiming() {
    start = PreciseTime.now();
    seconds = 0;
    changeType = [];
    changeTime = [];
  }

  void tick() {
    seconds++;
  }

  void calcSeconds() {
    if (start != null) {
      seconds =
          DateTime.now().difference(start!.toDateTime(Date.now())).inSeconds;
      PreciseTime former = PreciseTime.now(), ending = PreciseTime.now();
      for (int i = 0; i < changeType.length; i++) {
        if (changeType[i] == false) {
          former = PreciseTime.fromString(changeTime[i]);
        } else {
          ending = PreciseTime.fromString(changeTime[i]);
          seconds -= ending.difference(former).inSeconds;
        }
      }
      if (changeType.lastOrNull == false)
        seconds -= PreciseTime.now().difference(former).inSeconds;
    }
  }

  void permanent(GetStorage box) {
    box.write("timer.start", start?.s);
    box.write("timer.changeType", changeType);
    box.write("timer.changeTime", changeTime);
  }

  void cleanPermanent(GetStorage box) {
    try {
      box.remove("timer.start");
      box.remove("timer.changeType");
      box.remove("timer.changeTime");
    } catch (_) {}
  }

  static TimingState recordedDefault(GetStorage box) {
    return TimingState.recorded(
        box.read("timer.start") != null
            ? PreciseTime.fromString(box.read("timer.start"))
            : null,
        box.read("timer.changeType") ?? [],
        box.read("timer.changeTime") ?? []);
  }

  get formatted => PreciseTime.fromSeconds(seconds).s;
}

class TimerEvent {}

class TimerStartEvent extends TimerEvent {}

class TimerEndEvent extends TimerEvent {}

class TimerPauseEvent extends TimerEvent {}

class TimerResumeEvent extends TimerEvent {}

class BarEvent {}

class BarShowTodoEvent extends BarEvent {}

class BarHideTodoEvent extends BarEvent {}

class BarFirstClickEvent extends BarEvent {}

class BarSecondClickEvent extends BarEvent {}

class TodosEvent {}

class TodosFilterEvent extends TodosEvent {}

class TodosSortEvent extends TodosEvent {}

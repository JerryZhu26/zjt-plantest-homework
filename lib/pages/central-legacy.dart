// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_event_bus/get_event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/libraries/override/refresh_indicator.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

/// 主页的主体部分
class CentralLegacy extends StatefulWidget {
  const CentralLegacy({super.key});

  @override
  State<CentralLegacy> createState() => CentralLegacyState();
}

class CentralLegacyState extends State<CentralLegacy> {
  CentralLegacyState();

  // 标准常量
  static double leftStart = 60.w, rightStart = 215.w;
  static double sideWidth = 137.w, hourHeight = 90.h;

  // 标准常量简称
  late double hh;

  // 普通变量
  (double, double) dragPlace = (0, 0);

  List<Widget> hours = [];
  List<Widget> lefts = [];
  List<Widget> rights = [];
  List<TodayTodoPiece> dayTodos = [];
  List<BasePiece> timedTodos = [];
  DA? theDay;

  // 状态变量
  bool waitingForNext = false;
  bool lastBuildHappened = false;
  bool lastBuildIsInDark = false;
  bool showTodos = true;

  // 加载变量
  late List<(Time, Time)> leftTaskStacks, rightTaskStacks;
  late TextEditingController noco;
  late RealmResults<TD> todos;
  late RealmResults<TK> tasks;
  late Time previousClick;
  late Side previousSide;
  late DayAt dayAt;
  late Util util;
  late int startHour;

  // 旧版兼容性变量
  /// sW：屏幕宽度，hW: 左侧宽度，gW：右侧宽度
  late double sW, hW, gW;

  final box = GetStorage();
  final standard = Standard();

  @override
  void initState() {
    super.initState();
    // 变量的赋值
    hh = hourHeight;
    noco = TextEditingController();
    showTodos = box.read("showTodos") ?? true;
    // 今天的加载
    dayAt = Get.find();
    theDay = ECApp.realm.query<DA>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]).firstOrNull;
    if (theDay == null) {
      theDay = DA(ObjectId(), ECApp.userId(), date: dayAt.day.r);
      ECApp.realm.write(() => ECApp.realm.add(theDay!));
    }
    print(1.w);
    // 小时的加载
    startHour = box.read("startHour") ?? 6;
    util = Util(startHour: startHour, hh: hh);
    fetchHours();
    registerBarTodoEvents();
    // 预设的加入
    List<Map> selectedPreset =
        List<Map>.from(box.read("preset${dayAt.day.d.weekday}") ?? []);
    if (selectedPreset.isNotEmpty ||
        (box.read("presetVersion${dayAt.day.sswy}") ?? 0) <
            (box.read("presetVersion${dayAt.day.d.weekday}") ?? 0)) {
      print(box.read("presetVersion${dayAt.day.d.weekday}") ?? 1);
      print(box.read("presetVersion${dayAt.day.sswy}") ?? 0);
      if (dayAt.day >= Date.now()) {
        if ((box.read("presetVersion${dayAt.day.sswy}") ?? 0) <
                (box.read("presetVersion${dayAt.day.d.weekday}") ?? 1) ||
            (box.read("presetVersion${dayAt.day.sswy}") ?? 0) == 0) {
          // 删除已有内容
          RealmResults<TK> tasksToDelete = ECApp.realm.query<TK>(
              'date.year = \$0 AND date.month = \$1 AND date.day = \$2 AND name CONTAINS \$3',
              [dayAt.day.year, dayAt.day.month, dayAt.day.day, '\$p\$']);
          print(tasksToDelete);
          ECApp.realm.write(() => ECApp.realm.deleteMany(tasksToDelete));
          print(selectedPreset);
          // 重新插入新版本
          for (var one in selectedPreset) {
            Task presetTask = Task(
              name: one['name'],
              date: dayAt.day,
              startTime: Time.fromComparable(one['start']),
              endTime: Time.fromComparable(one['end']),
              side: Side.left,
              comment: "",
              taskColor: TaskColor.values
                  .byName(box.read("presetColor") ?? TaskColor.green.name),
              tag: null,
              isRest: false,
            );
            ECApp.realm.write(() => ECApp.realm.add(presetTask.r));
          }
          box.write("presetVersion${dayAt.day.sswy}",
              (box.read("presetVersion${dayAt.day.d.weekday}") ?? 1));
        }
      }
    }
    // 任务的获取
    fetchTasks();
    fetchTodos();
  }

  void fullRefresh() {
    dayAt = Get.find();
    lefts = [];
    timedTodos = [];
    rights = [];
    hours = [];
    fetchHours();
    fetchTasks();
    fetchTodos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    if (Pantone.isDarkMode(context) != lastBuildIsInDark && lastBuildHappened) {
      fullRefresh();
    }
    lastBuildHappened = true;
    lastBuildIsInDark = Pantone.isDarkMode(context);
    return Positioned(
      bottom: 0.h,
      top: 10.h,
      left: 15.w,
      right: 2.w,
      child: OverrideRefreshIndicator.customIndicator(
        customIndicator: Text(
          "下拉新建提醒与待办",
          style: TextStyle(
            color: Pantone.greenSemiLight,
            fontSize: 14.sp,
            fontFamily: "PingFang SC",
          ),
        ),
        onRefresh: () async => floatWindow(noco, () {
          var name = noco.text;
          noco.clear();
          context.pop();
          if (name == '') {
            showHudC(ProgressHudType.error, "输入不能为空", context);
          } else {
            TD td = TD(ObjectId(), ECApp.userId(), name, date: dayAt.day.r);
            ECApp.realm.write(() => ECApp.realm.add(td));
            dayTodos
                .add(TodayTodoPiece(name: name, id: td.id, showProject: true));
            setState(() {});
          }
        }, context, "新建提醒", "请输入与提醒或待办\n相关的标题与信息"),
        child: SizedBox(
          height: 1.sh - 10.h,
          width: 1.sw - 17.w,
          child: ListView(
            shrinkWrap: true,
            controller: ScrollController(),
            physics: BouncingScrollPhysics(),
            children: [
              if (showTodos) Column(children: dayTodos),
              GestureDetector(
                onTapUp: (detail) => tapUp(detail),
                onHorizontalDragDown: (detail) {
                  dragPlace =
                      (detail.globalPosition.dx, detail.localPosition.dy);
                },
                onHorizontalDragEnd: (detail) => horizontalDragEnd(detail),
                onLongPress: () {},
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(color: Pantone.white),
                      ),
                      // 左侧时间栏
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hours,
                      ),
                      // 主体部分 - 中央
                      Positioned(
                        left: standard.leftStart,
                        right: dispCalc(Side.left, disp, 12.w, 370.w, 164.w),
                        top: 0.h,
                        bottom: 0.h,
                        child: Stack(children: lefts),
                      ),
                      // 左侧 - Todos
                      Positioned(
                        left: standard.leftStart,
                        right: dispCalc(Side.left, disp, 12.w, 370.w, 164.w),
                        top: 0.h,
                        bottom: 0.h,
                        child: Stack(children: timedTodos),
                      ),
                      // 右侧 - Timing
                      TimingPiece(side: Side.right, util: util),
                      // 主体部分 - 右侧
                      Positioned(
                        left: dispCalc(Side.right, disp, standard.leftStart,
                            370.w, rightStart),
                        right: 6.w,
                        top: 0.h,
                        bottom: 0.h,
                        child: Stack(children: rights),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
    );
  }

  void horizontalDragEnd(DragEndDetails detail) {
    if (dragPlace.$1 > standard.leftStart) {
      if (detail.velocity.pixelsPerSecond.dx < -270) {
        // 从右往左
        Get.replace(DayAt(Date.fromDateTime(
          dayAt.day.toDateTime().add(Duration(days: 1)),
        )));
        goReload(context, box, holdUp: false, direction: Side.left);
      } else if (detail.velocity.pixelsPerSecond.dx > 270) {
        // 从左往右
        Get.replace(DayAt(Date.fromDateTime(
          dayAt.day.toDateTime().add(Duration(days: -1)),
        )));
        goReload(context, box, holdUp: false);
      }
    }
  }

  Future<void> tapUp(TapUpDetails detail) async {
    Side clickSide =
        detail.localPosition.dx < rightStart ? Side.left : Side.right;
    Util util = Util(startHour: startHour, hh: hh);
    Time click = util.position2Time(detail.localPosition.dy);
    if (disp == Display.all ||
        (disp == Display.left && clickSide == Side.left) ||
        (disp == Display.right && clickSide == Side.right)) {
      if (!waitingForNext) {
        previousClick = click;
        previousSide = clickSide;
        waitingForNext = true;
        var indicator = Positioned(
          top: util.time2Position(click),
          left: disp == Display.right ? rightStart - standard.leftStart : 0,
          width: sideWidth,
          child: beginYIndicator(sideWidth),
        );
        if (clickSide == Side.left) {
          lefts.add(indicator);
        } else {
          rights.add(indicator);
        }
        setState(() {});
      } else {
        waitingForNext = false;
        if (previousSide == Side.left) {
          lefts.removeLast();
        } else {
          rights.removeLast();
        }
        setState(() {});
        if (clickSide == previousSide && click - previousClick > 3) {
          Get.replace(Task(
            name: '',
            date: dayAt.day,
            startTime: previousClick,
            endTime: click,
            side: clickSide,
          ));
          await context.push('/add');
          try {
            fetchTasks(
                reloadFromRealm: false, adding: true, tk: Get.find<TK>());
            Get.delete<TK>();
            setState(() {});
          } catch (_) {}
        }
      }
    }
  }

  void fetchHours() {
    hours = [];
    hours.add(HourPad(
      hour: Hour.getFromRList(startHour, theDay!.hours) ?? Hour(startHour),
    ));
    for (int i = startHour + 1; i <= 23; i++) {
      hours.add(HourDeck(hour: i));
      hours.add(HourPad(
        hour: Hour.getFromRList(i, theDay!.hours) ?? Hour(i),
      ));
    }
  }

  void fetchTasks({
    bool reloadFromRealm = true,
    // When adding, always get a TK along
    bool adding = false,
    TK? tk,
    // When deleting, always get a TK id along
    // But now deleting is done by make it invisible
    // so there is no reason to still doing deletion
    bool deleting = false,
    ObjectId? tkId,
  }) {
    if (reloadFromRealm) {
      tasks = ECApp.realm.query<TK>(
          'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
          [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
    }
    List<TK> tasksToProceed = tasks.toList();
    for (var task in tasks) {
      print("${task.name}: ${task.id}");
    }
    lefts = [];
    rights = [];
    leftTaskStacks = [];
    rightTaskStacks = [];
    for (var atk in tasksToProceed) {
      layTaskStacks(atk);
    }
    if (adding) {
      layTaskStacks(tk!);
    }
    sortTaskStack();
    for (var atk in tasksToProceed) {
      refreshData(atk);
    }
    if (adding) {
      refreshData(tk!);
    }
  }

  void fetchTodos() {
    todos = ECApp.realm.query<TD>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
    dayTodos = [];
    timedTodos = [];
    for (var todo in todos) {
      dayTodos.add(TodayTodoPiece(
        name: todo.name,
        id: todo.id,
        showProject: true,
        place: Place.central,
        onEdited: (x) {
          fetchTodos();
          setState(() {});
        },
      ));
      if (todo.startTime != null && todo.endTime != null) {
        // TODO: 使用 key: ValueKey(DateTime.now()) 优化其他的代码，减少重新生成
        timedTodos.add(Piece(
          key: ValueKey(DateTime.now()),
          isTodo: true,
          title: todo.name,
          startTime: Time.fr(todo.startTime!),
          endTime: Time.fr(todo.endTime!),
          taskColor: TaskColor.values
              .byName(todo.color ?? todo.project?.color ?? 'green'),
          side: Side.left,
          date: Date.fr(todo.date!),
          util: util,
          taskStacks: [],
        ));
      } else if (todo.startTime != null || todo.endTime != null) {
        timedTodos.add(LinePiece(
          key: ValueKey(DateTime.now()),
          isTodo: true,
          title: todo.name,
          date: Date.fr(todo.date!),
          time: Time.fr(todo.startTime ?? todo.endTime!),
          taskColor: TaskColor.values
              .byName(todo.color ?? todo.project?.color ?? 'green'),
          side: Side.left,
          util: util,
        ));
      }
      print(timedTodos);
    }
  }

  void layTaskStacks(TK atk) {
    if (atk.startTime != null && atk.endTime != null) {
      if (atk.side == Side.left.name) {
        Task tsk = Task.fr(atk);
        bool isVisiblePreset = true;
        if (tsk.name.contains("\$p\$")) {
          isVisiblePreset = checkTaskTodayVisible(tsk.name, tsk.date.d);
        }
        if (isVisiblePreset) {
          leftTaskStacks.add((Time.fr(atk.startTime!), Time.fr(atk.endTime!)));
        }
      } else if (atk.side == Side.right.name) {
        rightTaskStacks.add((Time.fr(atk.startTime!), Time.fr(atk.endTime!)));
      }
    }
  }

  void sortTaskStack() {
    leftTaskStacks.sort((a, b) => a.$1.comparable.compareTo(b.$1.comparable));
    rightTaskStacks.sort((a, b) => a.$1.comparable.compareTo(b.$1.comparable));
  }

  void onPieceToggle() {
    if (waitingForNext) {
      waitingForNext = false;
      if (previousSide == Side.left) {
        lefts.removeLast();
      } else {
        rights.removeLast();
      }
      setState(() {});
    }
  }

  void refreshData(TK tk, {(double, double)? dragPlace}) {
    final taskData = Task.fr(tk);
    final piece = taskData.p(
      Util(startHour: startHour, hh: hh),
      dragPlace: dragPlace,
      onToggle: onPieceToggle,
      onDelete: (ObjectId tkId) {
        fetchTasks(deleting: true, tkId: tkId);
        setState(() {});
      },
      taskStacks: taskData.side == Side.left ? leftTaskStacks : rightTaskStacks,
    );
    if (taskData.side == Side.left) {
      lefts.add(piece);
      print(lefts);
    } else {
      rights.add(piece);
    }
  }

  void cleanAll() {
    ECApp.realm.write(() => ECApp.realm.deleteAll<TK>());
  }

  void registerBarTodoEvents() {
    Get.bus.on<BarShowTodoEvent>((event) {
      box.write("showTodos", true);
      showTodos = true;
      if (mounted) setState(() {});
    }, cancelOnError: true);
    Get.bus.on<BarHideTodoEvent>((event) {
      box.write("showTodos", false);
      showTodos = false;
      if (mounted) setState(() {});
    }, cancelOnError: true);
  }
}

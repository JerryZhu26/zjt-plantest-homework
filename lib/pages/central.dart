// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
import 'package:timona_ec/parts/central_pieces.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/stores/timeline.dart';

final timeline = Timeline();

/// 主页的主体部分
class Central extends StatefulWidget {
  const Central({super.key});

  @override
  State<Central> createState() => CentralState();
}

class CentralState extends State<Central> {
  CentralState();

  // 标准常量简称
  late double hh;

  // 普通变量
  List<Widget> hours = [];
  List<Widget> indicators = [];
  DA? theDay;

  (double, double) dragPlace = (0, 0);
  bool showTodos = true;
  bool waitingForNext = false;

  late TextEditingController noco;
  late RealmResults<TD> todos;
  late RealmResults<TK> tasks;
  late DayAt dayAt;
  late Util util;
  late Standard standard;
  late int startHour;
  late Time previousClick;
  late Side previousSide;

  // 旧版兼容性变量
  // sW：屏幕宽度，hW: 左侧宽度，gW：右侧宽度
  late double sW, hW, gW;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    // 变量的赋值
    standard = Standard();
    hh = standard.hourHeight;
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
    // 任务的加载
    fetchTasks();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
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
            timeline.tdsToday.add(td);
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
              if (showTodos)
                Observer(builder: (_) {
                  List<Widget> todayTodoPieces =
                      todoPiecesFromTodayTds(timeline, fetchTodos);
                  return Column(children: todayTodoPieces);
                }),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hours,
                      ),
                      Positioned(
                        left: standard.leftStart,
                        right: 6.w,
                        top: 0.h,
                        bottom: 0.h,
                        child: Stack(children: indicators),
                      ),
                      Positioned(
                        left: standard.leftStart,
                        right: 6.w,
                        top: 0.h,
                        bottom: 0.h,
                        child: Observer(
                          builder: (_) {
                            List<Widget> pieces = piecesFromTimeline(timeline,
                                util, standard, context, box, fetchTasks);
                            return Stack(children: pieces);
                          },
                        ),
                      ),
                      TimingPiece(side: Side.right, util: util),
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
        detail.localPosition.dx < standard.rightStart ? Side.left : Side.right;
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
          left: clickSide == Side.right
              ? standard.rightStart - standard.leftStart
              : 0,
          width: standard.sideWidth,
          child: beginYIndicator(standard.sideWidth),
        );
        indicators.add(indicator);
        Get.bus.fire(BarFirstClickEvent());
        setState(() {});
      } else {
        waitingForNext = false;
        indicators.removeLast();
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
            Get.bus.fire(BarSecondClickEvent());
            fetchTasks();
            Get.delete<TK>();
            setState(() {});
          } catch (_) {}
        } else {
          Get.bus.fire(BarSecondClickEvent());
        }
      }
    }
  }

  void fetchHours() {
    hours.clear();
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

  void fetchTasks() {
    tasks = ECApp.realm.query<TK>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
    List<TK> tasksToProceed = tasks.toList();
    for (var task in tasks) {
      print("${task.name}: ${task.id}");
    }
    timeline.initialize();
    for (var task in tasksToProceed) {
      if (task.startTime != null && task.endTime != null) {
        if (task.side == Side.left.name) {
          bool isVisiblePreset = true;
          if (task.name.contains("\$p\$")) {
            isVisiblePreset = checkTaskTodayVisible(
              task.name,
              Date.frn(task.date)!.d,
            );
          }
          if (isVisiblePreset) {
            timeline.add(task.id, Time.frn(task.startTime)!,
                Time.frn(task.endTime)!, Side.left);
            timeline.tks[task.id] = task;
          }
        } else if (task.side == Side.right.name) {
          timeline.add(task.id, Time.frn(task.startTime)!,
              Time.frn(task.endTime)!, Side.right);
          timeline.tks[task.id] = task;
        }
      }
    }
  }

  void fetchTodos() {
    todos = ECApp.realm.query<TD>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
    timeline.tdsToday.clear();
    for (var todo in todos) {
      timeline.tdsToday.add(todo);
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

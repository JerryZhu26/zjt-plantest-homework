// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

part of 'package:timona_ec/parts/general.dart';

/// 正在计时中的计时器可复用组件
class TimingPiece extends StatefulWidget {
  const TimingPiece({
    super.key,
    required this.side,
    required this.util,
  });

  final Side side;
  final Util util;

  @override
  TimingPieceState createState() => TimingPieceState();
}

class TimingPieceState extends State<TimingPiece> with WidgetsBindingObserver {
  final box = GetStorage();
  final MethodChannel channel = MethodChannel('scris.plnm/alarm');

  Time startTime = Time.now(), endTime = Time.now();
  PausableTimer? timer, timerMinutely;
  bool visible = false, timing = false;
  RxString displayTime = "Loading".obs;
  Standard standard = Standard();
  late TimingState state;
  late double height;

  @override
  void initState() {
    super.initState();
    registerTimerEvents();
    WidgetsBinding.instance.addObserver(this);
    state = TimingState.recordedDefault(box);
    visible = state.start != null;
    if (!visible) {
      timing = false;
    } else {
      timer = PausableTimer(Duration(seconds: 1), () => tick());
      timerMinutely = PausableTimer(Duration(minutes: 1), () {
        timerMinutely!
          ..reset()
          ..start();
        setState(() {});
        print(Time.now());
      });
      DateTime startSecond =
          DateTime.now().add(-Duration(seconds: state.seconds));
      startTime = Time.fromPreciseTime(state.start!);
      if (state.changeType.lastOrNull == false) {
        endTime = Time.fromPreciseTime(PreciseTime.fromString(
            state.changeTime.lastOrNull ?? PreciseTime.now()));
      } else {
        endTime = Time.now();
      }
      if (state.changeType.isNotEmpty) {
        if (state.changeType.last != false) {
          timer!.start();
          timerMinutely!.start();
          timing = true;
          showOverlay(startSecond.add(-Duration(milliseconds: 500)), false, '',
              channel, box);
        } else {
          timing = false;
        }
      } else {
        timer!.start();
        timerMinutely!.start();
        timing = true;
        showOverlay(startSecond.add(-Duration(milliseconds: 500)), false, '',
            channel, box);
      }
      displayTime(state.formatted);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState alState) {
    super.didChangeAppLifecycleState(alState);
    if (alState == AppLifecycleState.resumed) {
      state.calcSeconds();
      displayTime(state.formatted);
      if (state.changeType.lastOrNull == false) {
        endTime = Time.fromPreciseTime(
          PreciseTime.fromString(
            state.changeTime.lastOrNull ?? PreciseTime.now(),
          ),
        );
      } else {
        endTime = Time.now();
      }
      height = math.max(
          widget.util.time2Position(endTime) -
              widget.util.time2Position(startTime) -
              2.h,
          22.2.h);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    state = TimingState.recordedDefault(box);
    if (state.changeType.lastOrNull == false) {
      endTime = Time.fromPreciseTime(
        PreciseTime.fromString(
          state.changeTime.lastOrNull ?? PreciseTime.now(),
        ),
      );
    } else {
      endTime = Time.now();
    }
    height = math.max(
        widget.util.time2Position(endTime) -
            widget.util.time2Position(startTime) -
            2.h,
        22.2.h);
    return Positioned(
      top: widget.util.time2Position(startTime),
      left: dispCalc(Side.right, disp, standard.leftStart, 374.w,
              standard.rightStart) +
          6.w,
      width: dispCalc(widget.side, disp, 303.w, 0.w, 145.w) - 8.w,
      height: height - 2.h,
      child: Visibility(
        visible: visible,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              context.push('/timer');
            },
            onLongPress: () {
              context.push('/timer');
            },
            child: Container(
              width: dispCalc(widget.side, disp, 303.w, 0.w, 145.w),
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: taskColors[(
                    TaskColor.green,
                    Pantone.isDarkMode(context)
                  )]!
                      .bgColor,
                  border: Border.all(
                      color: taskColors[(
                        TaskColor.green,
                        Pantone.isDarkMode(context)
                      )]!
                          .commentLeftColor
                          .lighten(17)
                          .withOpacity(0.2),
                      width: Pantone.isDarkMode(context) ? 0 : 2.r),
                  boxShadow: [
                    BoxShadow(
                      color: Pantone.greenShadow!,
                      blurRadius: 4.r,
                      offset: Offset(0.w, 0.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  left: 25.w,
                  right: 25.w,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (height > 70.h)
                          Container(
                            width: 22.w,
                            height: 22.h,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 1.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Pantone.greenTiming,
                            ),
                            child: SvgPicture.asset(
                              'lib/assets/timer.svg',
                              height: 13.5.r,
                            ),
                          ),
                        if (height > 70.h)
                          SizedBox(height: height > 90.h ? 10.h : 5.h),
                        Obx(
                          () => Text(
                            (timing ? "计时中" : "已暂停") +
                                (height > 36.h
                                    ? "\n$displayTime"
                                    : " $displayTime"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Pantone.greenText,
                              fontSize: height > 60.h
                                  ? 13.sp
                                  : height > 40.h
                                      ? 11.sp
                                      : 10.sp,
                              fontFamily: "PingFang SC",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerTimerEvents() {
    Get.bus.on<TimerStartEvent>((event) {
      timer = PausableTimer(Duration(seconds: 1), () => tick())..start();
      state = TimingState.recordedDefault(box);
      if (state.start != null) {
        showTimingPiece(state.start!, widget.util, growable: true);
      }
    }, cancelOnError: true);
    Get.bus.on<TimerPauseEvent>((event) {
      if (timer != null) {
        timer!.pause();
      }
      if (timerMinutely != null) {
        timerMinutely!.pause();
      }
      state = TimingState.recordedDefault(box);
      if (state.start != null) {
        showTimingPiece(
          state.start!,
          widget.util,
          growable: false,
          end: PreciseTime.fromString(state.changeTime.last),
        );
      }
    }, cancelOnError: true);
    Get.bus.on<TimerResumeEvent>((event) {
      if (timer != null) {
        timer!.start();
      }
      if (timerMinutely != null) {
        timerMinutely!.start();
      }
      state = TimingState.recordedDefault(box);
      if (state.start != null) {
        showTimingPiece(state.start!, widget.util, growable: true);
      }
    }, cancelOnError: true);
    Get.bus.on<TimerEndEvent>((event) {
      if (timer != null) {
        timer!
          ..reset()
          ..pause();
      }
      if (timerMinutely != null) {
        timerMinutely!
          ..reset()
          ..pause();
      }
      hideTimingPiece();
    }, cancelOnError: true);
  }

  void showTimingPiece(PreciseTime start, Util util,
      {PreciseTime? end, bool? growable}) {
    visible = true;
    startTime = Time.fromPreciseTime(start);
    endTime = !(growable ?? false)
        ? Time.fromPreciseTime(end ?? PreciseTime.now())
        : Time.now();
    timing = growable ?? false;
    if (mounted) setState(() {});
  }

  void hideTimingPiece() {
    visible = false;
    if (mounted) setState(() {});
  }

  void tick() {
    state.tick();
    timer!
      ..reset()
      ..start();
    displayTime(state.formatted);
  }
}

/// 主页左侧，小时对应的方框
class HourPad extends StatefulWidget {
  const HourPad({super.key, required this.hour});

  final Hour hour;

  @override
  HourPadState createState() => HourPadState();
}

class HourPadState extends State<HourPad> {
  late Hour hour;
  late Color color;

  @override
  void initState() {
    super.initState();
    hour = widget.hour;
  }

  @override
  Widget build(BuildContext context) {
    color = getColor();
    return Column(
      children: [
        SizedBox(
          width: isIPad(context) ? 40.w : 45.w,
          height: 66.h,
          child: Bounceable(
            onTap: () async {
              Get.replace(hour);
              await context.push('/rate/hour');
              hour = Get.find();
              color = getColor();
              setState(() {});
            },
            duration: 55.ms,
            reverseDuration: 55.ms,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: color,
                border: Border.all(color: color.lighten(2), width: 2.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h)
      ],
    );
  }

  Color getColor() {
    bool d = Pantone.isDarkMode(context);
    return hour.rate == 3
        // 3
        ? hour.which % 2 == 1
            ? d
                ? Pantone.greenWhiteDarker!
                : Pantone.greenWhiteDarker!
            : d
                ? Pantone.greenWhite!
                : Pantone.greenWhite!
        : hour.rate > 3
            ? hour.rate == 4
                // 4
                ? hour.which % 2 == 1
                    ? d
                        ? Colors.greenAccent.shade700
                            .withOpacity(0.3)
                            .lighten(15)
                            .desaturate(20)
                        : Colors.greenAccent.shade100.withOpacity(0.57)
                    : d
                        ? Colors.greenAccent.shade700
                            .withOpacity(0.4)
                            .lighten(20)
                            .desaturate(20)
                        : Colors.greenAccent.shade100.withOpacity(0.4)
                // 5
                : hour.which % 2 == 1
                    ? d
                        ? Colors.blue.shade600
                            .withOpacity(0.5)
                            .lighten(5)
                            .desaturate(20)
                        : Colors.blue.shade100.withOpacity(0.55)
                    : d
                        ? Colors.blue.shade700
                            .withOpacity(0.45)
                            .lighten(15)
                            .desaturate(15)
                        : Colors.blue.shade50
            : hour.rate == 2
                // 2
                ? hour.which % 2 == 1
                    ? d
                        ? Colors.lime.shade700
                            .withOpacity(0.6)
                            .lighten(10)
                            .desaturate(20)
                        : Colors.lime.shade100.withOpacity(0.8)
                    : d
                        ? Colors.lime.shade700
                            .withOpacity(0.6)
                            .lighten(12)
                            .desaturate(20)
                        : Colors.lime.shade50
                : hour.rate == 1
                    // 1
                    ? hour.which % 2 == 1
                        ? d
                            ? Colors.amber.shade700
                                .withOpacity(0.6)
                                .desaturate(50)
                            : Colors.amber.shade100.withOpacity(0.65)
                        : d
                            ? Colors.amber.shade800
                                .desaturate(60)
                                .withOpacity(0.75)
                            : Colors.amber.shade50
                    // 0
                    : hour.which % 2 == 1
                        ? d
                            ? Colors.red.shade700
                                .withOpacity(0.6)
                                .desaturate(50)
                            : Colors.red.shade100.withOpacity(0.6)
                        : d
                            ? Colors.red.shade800
                                .withOpacity(0.75)
                                .desaturate(60)
                            : Colors.red.shade50.withOpacity(0.8);
  }
}

/// 主页左侧，小时对应的文字
class HourDeck extends StatefulWidget {
  const HourDeck({super.key, required this.hour});

  final int hour;

  @override
  HourDeckState createState() => HourDeckState();
}

class HourDeckState extends State<HourDeck> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 16.h,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${(widget.hour % 12 != 0 ? widget.hour % 12 : 12).toString().padLeft(2, '0')}:00${widget.hour > 12 ? 'PM' : 'AM'}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Pantone.isDarkMode(context)
                    ? Pantone.green!.lighten(10).desaturate(5)
                    : Pantone.green,
                fontSize: 10.sp,
              ),
            ),
            SizedBox(width: 3.3.w),
            Container(
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Pantone.greenExtremeLight,
              ),
            ),
            Container(
              width: 310.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: Pantone.greenExtremeLight,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 4.h),
    ]);
  }
}

/// 基于 TaskColor 的颜色选择器
class ColorTabs extends StatefulWidget {
  final TaskColor selected;
  final Function(TaskColor) onSelect;

  const ColorTabs(this.selected, this.onSelect, {super.key});

  @override
  ColorTabsState createState() => ColorTabsState();
}

class ColorTabsState extends State<ColorTabs> {
  late TaskColor selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  Widget forColor(BuildContext context, TaskColor color) {
    return Bounceable(
      onTap: () {
        selected = color;
        widget.onSelect(color);
        setState(() {});
      },
      child: Container(
        width: 20.r,
        height: 20.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Pantone.isDarkMode(context)
              ? taskColors[(color, Pantone.isDarkMode(context))]!
                  .bgColor
                  .tint(20)
                  .saturate(5)
              : taskColors[(color, Pantone.isDarkMode(context))]!.bgColor,
          border: selected == color
              ? Border.all(
                  color: taskColors[(color, Pantone.isDarkMode(context))]!
                      .iconColor,
                  width: 2.r,
                )
              : Border(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        forColor(context, TaskColor.green),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.purple),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.orange),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.blue),
      ],
    );
  }
}

/// 选填的的颜色选择器
class SelectiveColorTabs extends StatefulWidget {
  final TaskColor? selected;
  final Function(TaskColor?) onSelect;

  const SelectiveColorTabs(this.selected, this.onSelect, {super.key});

  @override
  SelectiveColorTabsState createState() => SelectiveColorTabsState();
}

class SelectiveColorTabsState extends State<SelectiveColorTabs> {
  TaskColor? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  Widget forColor(BuildContext context, TaskColor color) {
    return Bounceable(
      onTap: () {
        selected = color;
        widget.onSelect(color);
        setState(() {});
      },
      child: Container(
        width: 20.r,
        height: 20.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Pantone.isDarkMode(context)
              ? taskColors[(color, Pantone.isDarkMode(context))]!
                  .bgColor
                  .tint(20)
                  .saturate(5)
              : taskColors[(color, Pantone.isDarkMode(context))]!.bgColor,
          border: selected == color
              ? Border.all(
                  color: taskColors[(color, Pantone.isDarkMode(context))]!
                      .iconColor,
                  width: 2.r,
                )
              : Border(),
        ),
      ),
    );
  }

  Widget forDefault(BuildContext context) {
    return Bounceable(
      onTap: () {
        selected = null;
        widget.onSelect(null);
        setState(() {});
      },
      child: Container(
        width: 40.r,
        height: 20.r,
        padding: EdgeInsets.symmetric(horizontal: 6.5.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Pantone.grey300,
          border: selected == null
              ? Border.all(color: Pantone.grey300border!, width: 2.r)
              : Border.all(color: Pantone.grey300!, width: 2.r),
        ),
        child: Text(
          '默认',
          style: TextStyle(color: Pantone.grey600, fontSize: 11.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        forDefault(context),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.green),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.purple),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.orange),
        SizedBox(width: 20.w),
        forColor(context, TaskColor.blue),
      ],
    );
  }
}

class Jump extends StatefulWidget {
  const Jump(this.where, {super.key, this.flag});

  final String where;
  final String? flag;

  @override
  JumpState createState() => JumpState();
}

class JumpState extends State<Jump> {
  late String flag;

  @override
  void initState() {
    super.initState();
    flag = widget.flag ?? "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!flag.contains('animate')) {
        context.replace(widget.where);
      } else {
        if (!flag.contains('left')) {
          context.pushReplacement('${widget.where}--animate-left');
        } else {
          context.pushReplacement('${widget.where}--animate-right');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: topDeco,
        child: SafeArea(
          bottom: false,
          child: Container(
            color: Pantone.white,
            child: Column(children: [
              TopBar(initialHoldUp: widget.where == '/--tbhu'),
              flag.contains('history')
                  ? Expanded(
                      child: Stack(children: [
                        History(),
                        BottomBar(click: () {}),
                        BottomAdd(),
                      ]),
                    )
                  : Expanded(
                      child: Stack(children: []),
                    ),
            ]),
          ),
        ),
      ),
    );
  }
}

List checkPresetString(String text, DateTime day) {
  if (text.split("\$p\$").length == 2) {
    String repeatInterval = text.split("\$p\$")[1].split("-")[0];
    String repeatWay = text.split("\$p\$")[1].split("-")[1];
    if (repeatWay == "WE") {
      repeatWay = "周";
    } else if (repeatWay == "MO") {
      repeatWay = "月";
    } else if (repeatWay == "YE") {
      repeatWay = "年";
    }
    String startDay = text.split("\$p\$")[1].split("-")[2];
    String endDay = text.split("\$p\$")[1].split("-")[3];
    DateTime sdd, edd;
    int sdi = int.parse(startDay);
    int edi = int.parse(endDay);
    int ndi = day.month * 100 + DateTime.now().day;
    if (sdi < edi) {
      sdd = DateTime(day.year, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    } else if (ndi > edi) {
      sdd = DateTime(day.year, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year + 1, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    } else {
      sdd = DateTime(day.year - 1, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    }
    return [int.parse(repeatInterval), repeatWay, sdd, edd];
  }
  return [];
}

bool checkTaskTodayVisible(String text, DateTime day) {
  if (text.split("\$p\$").length == 2) {
    String startDay = text.split("\$p\$")[1].split("-")[2];
    String endDay = text.split("\$p\$")[1].split("-")[3];
    DateTime sdd, edd;
    int sdi = int.parse(startDay);
    int edi = int.parse(endDay);
    int ndi = day.month * 100 + DateTime.now().day;
    if (sdi < edi) {
      sdd = DateTime(day.year, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    } else if (ndi > edi) {
      sdd = DateTime(day.year, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year + 1, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    } else {
      sdd = DateTime(day.year - 1, int.parse(startDay.substring(0, 2)),
          int.parse(startDay.substring(2, 4)), 0, 0);
      edd = DateTime(day.year, int.parse(endDay.substring(0, 2)),
          int.parse(endDay.substring(2, 4)), 23, 59);
    }
    if (sdd.isAfter(day) || edd.isBefore(day)) {
      return false;
    }
    if (sdi == edi && ndi != sdi) return false;
    return true;
  }
  return true;
}

Future<void> scheduleNotifications(String title, String body, DateTime time,
    GetStorage box, BuildContext context) async {
  bool granted = false;
  String channelId = 'task-notification';
  if (!isIOS() && !isAndroid()) {
    granted = true;
  } else {
    final PermissionStatus status = await Permission.notification.status;
    granted = status.isGranted;
  }
  if (isAndroid()) {
    List<AndroidNotificationChannel>? channels =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.getNotificationChannels();
    bool hasChannel = false;
    if (channels != null) {
      for (int i = 0; i < channels.length; i++) {
        if (channels[i].id == channelId) {
          hasChannel = true;
          break;
        }
      }
    }
    if (!hasChannel) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
            channelId,
            'Notification for Tasks',
            importance: Importance.high,
          ));
    }
  }
  if (granted) {
    int notificationId = box.read("notificationId") ?? 1;
    try {
      await ECApp.notifier.zonedSchedule(
        notificationId + 1,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Notification for Tasks',
            channelDescription:
                'This channel occurs when a user-triggered task notification is on.',
          ),
        ),
        payload: '${tz.TZDateTime.from(time, tz.local)}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      box.write("notificationId", notificationId + 1);
      showHudC(ProgressHudType.success, "提醒添加成功", context);
    } catch (e) {
      showHudC(ProgressHudType.error, "提醒添加失败：$e", context);
    }
  } else {
    showHudC(ProgressHudType.error, "提醒添加失败：您没有允许应用进行通知", context);
  }
}

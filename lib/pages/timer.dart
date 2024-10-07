// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ftoast/ftoast.dart';
import 'package:get/get.dart';
import 'package:get_event_bus/get_event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:timona_ec/libraries/pausable_timer/pausable_timer.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/panels/timer_together.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';

final supabase = sb.Supabase.instance.client;

/// 计时器
class Timer extends StatefulWidget {
  const Timer({super.key, this.from, this.together = false});

  final String? from;
  final bool together;

  @override
  TimerState createState() => TimerState();
}

class TimerState extends State<Timer> with WidgetsBindingObserver {
  TimerState();

  final MethodChannel channel = MethodChannel('scris.plnm/alarm');
  final box = GetStorage();

  late ScrollController faco;
  late TimingState states;
  late DayAt dayAt;
  late bool together;
  bool timing = false;
  bool timingStarted = false;
  RxString displayTime = "Loading".obs;
  PausableTimer? timer;
  bool afterCompanionChannelDel = false;
  String? timerName, timerTag;

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    together = widget.together;
    states = TimingState.recordedDefault(box);
    states.calcSeconds();
    faco = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    if (states.start == null) {
      timingStarted = false;
      timing = false;
      displayTime("00:00:00");
    } else {
      timer = PausableTimer(Duration(seconds: 1), () => tick());
      timingStarted = true;
      if (states.changeType.isNotEmpty) {
        if (states.changeType.last != false) {
          timer!.start();
          timing = true;
        } else {
          timing = false;
        }
      } else {
        timer!.start();
        timing = true;
      }
      displayTime(states.formatted);
    }
    togetherInitStream(
      box,
      onUpdate: (payload) {
        if (states.start == null) {
          startAsTogetherResponse(payload['seconds']);
          states.seconds = payload['seconds'];
          box.write('timer.beginTaskName', payload['task_name']);
          if (payload['paused']) {
            pauseAsTogetherResponse();
          }
        } else {
          if (payload['paused']) {
            pauseAsTogetherResponse();
          } else {
            resumeAsTogetherResponse();
          }
        }
        setState(() {});
      },
      onDelete: (payload) {
        endAsTogetherResponse();
        box.write("duringTogether", false);
        if (ECApp.togetherChannel != null) {
          supabase.removeChannel(ECApp.togetherChannel!);
          ECApp.togetherChannel = null;
        }
        saveResults("其他参与房间的人点击了计时结束。是否要保存计时结果？");
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (ECApp.companionChannel != null) {
      supabase.removeChannel(ECApp.companionChannel!);
      ECApp.companionChannel = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timerName = box.read('timer.beginTaskName');
    timerTag = box.read('timer.beginTaskTag');
    return ProgressHud(
      isGlobalHud: true,
      child: Container(
        color: Pantone.green,
        child: Stack(children: [
          Background(),
          // 多人按钮
          Positioned(
            left: 130.w,
            right: 130.w,
            top: isIOS() ? 70.h : 50.h,
            height: 37.h,
            child: Visibility(
              visible: !timingStarted || withTogether(box),
              child: Bounceable(
                onTap: () {
                  if (withTogether(box)) {
                    showHud(ProgressHudType.success,
                        "输入这一计时码，加入计时房间\n结束计时后，房间将自动解散");
                  } else {
                    context.replace('/timer/together');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Pantone.greenTimerShadowAlt1!,
                        blurRadius: 15.r,
                        offset: Offset(0.w, 6.h),
                      ),
                    ],
                    color: Pantone.greenInputBg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'lib/assets/together-sw4.svg',
                        height: 18.r,
                        colorFilter: ColorFilter.mode(
                          Pantone.greenTimerText!,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        withTogether(box)
                            ? "  ${ECApp.togetherChannelName!}"
                            : "  一起计时",
                        style: TextStyle(color: Pantone.greenTimerText),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 计时框
          Positioned(
            left: 40.w,
            right: 40.w,
            top: 190.h,
            child: Container(
              width: 308.w,
              height: 132.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Pantone.greenTimerShadowAlt1!,
                    blurRadius: 15.r,
                    offset: Offset(0.w, 6.h),
                  ),
                ],
                color: Pantone.greenInputBg,
              ),
              child: Column(
                mainAxisAlignment: timerName != null
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: isDesktop() ? 3.r : 5.r,
                    ),
                    child: Obx(
                      () => Text(
                        "$displayTime",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Pantone.greenTimerText,
                          fontSize: 58.sp,
                          fontFamily: "PingFang SC",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (timerName != null)
                    Container(
                      width: 310.w,
                      height: 29.r,
                      decoration: BoxDecoration(
                        color: Pantone.greenExtremeLight,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(19.r),
                          bottomRight: Radius.circular(19.r),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: isDesktop() ? 5.r : 3.5.r,
                        left: 25.w,
                        right: 25.w,
                      ),
                      child: Center(
                        child: FadingEdgeScrollView.fromSingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: faco,
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: Text(
                                timerTag != null
                                    ? "$timerTag $timerName"
                                    : "$timerName",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Pantone.isDarkMode(context)
                                      ? Pantone.greenTimerText
                                      : Pantone.greenButton,
                                  fontSize: 14.sp,
                                  fontFamily: "PingFang SC",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          // 返回按钮
          Positioned(
            left: 0.w,
            right: 0.w,
            bottom: 50.h,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (states.start == null) box.remove('timer.beginTaskName');
                  context.pop();
                },
                child: Container(
                  width: 56.w,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Pantone.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4.r),
                        blurRadius: 15.r,
                        color: Pantone.greenTimerShadowAlt2!,
                      )
                    ],
                  ),
                  child: SvgPicture.asset(
                    'lib/assets/timer_arrow_down.svg',
                    height: 21.r,
                  ),
                ),
              ),
            ),
          ),
          // 操作栏
          Positioned(
            top: 373.h,
            left: 0,
            right: 0,
            child: Container(
              height: 50.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Bounceable(
                    onTap: () => !timingStarted
                        ? start()
                        : timing
                            ? pause()
                            : resume(),
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Pantone.greenInputBg,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4.r),
                            blurRadius: 15.r,
                            color: Pantone.greenTimerShadow!,
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          timing
                              ? 'lib/assets/pause.svg'
                              : 'lib/assets/start.svg',
                          height: 21.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                  Bounceable(
                    onTap: () {
                      if (isMobile()) {
                        context.push("/camera/--from-timer");
                      } else {
                        FToast.toast(context, msg: "当前平台暂不支持拍照功能");
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Pantone.greenInputBg,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4.r),
                            blurRadius: 15.r,
                            color: Pantone.greenTimerShadow!,
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'lib/assets/camera.svg',
                          height: 22.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                  Bounceable(
                    onTap: () => end(),
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Pantone.greenInputBg,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4.r),
                            blurRadius: 15.r,
                            color: Pantone.greenTimerShadow!,
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'lib/assets/end.svg',
                          height: 21.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // markSplits(),
        ]),
      ),
    );
  }

  Future<void> companionInit(void Function() thenFunc) async {
    if (ECApp.companionChannel == null) {
      afterCompanionChannelDel = false;
      ECApp.companionChannel ??= supabase.channel(ECApp.userId());
      ECApp.companionChannel!.subscribe((status, error) => thenFunc());
    } else {
      thenFunc();
    }
  }

  Future<void> companionSend(
      int seconds, String? name, String? tag, bool paused) async {
    if (withCompanion(box)) {
      await companionInit(() async {
        if (!afterCompanionChannelDel) {
          sb.ChannelResponse resp =
              await ECApp.companionChannel!.sendBroadcastMessage(
            event: 'timer-update',
            payload: {
              'user': ECApp.userId(),
              'seconds': seconds,
              'task_name': name,
              'task_tag': tag,
              'paused': paused,
            },
          );
          print('Companion send resp: $resp');
          if (resp != sb.ChannelResponse.ok) {
            showHud(ProgressHudType.error, '计时伴侣服务出错：${resp.name}');
          }
        }
      });
    }
  }

  Future<void> companionDelete() async {
    if (withCompanion(box)) {
      await companionInit(() async {
        if (!afterCompanionChannelDel) {
          sb.ChannelResponse resp =
              await ECApp.companionChannel!.sendBroadcastMessage(
            event: 'timer-delete',
            payload: {},
          );
          print('Companion del resp: $resp');
          afterCompanionChannelDel = true;
          if (ECApp.companionChannel != null) {
            supabase.removeChannel(ECApp.companionChannel!);
          }
          if (resp != sb.ChannelResponse.ok) {
            showHud(ProgressHudType.error, '计时伴侣服务出错：${resp.name}');
          }
        }
        ECApp.companionChannel = null;
      });
    }
  }

  void start() {
    startAsTogetherResponse(0);
    togetherSend(0, timerName, timerTag, false, box);
    setState(() {});
  }

  void startAsTogetherResponse(int seconds) {
    timingStarted = true;
    timing = true;
    states.startTiming();
    states.permanent(box);
    timer = PausableTimer(Duration(seconds: 1), () => tick())..start();
    widgetTimingStart(DateTime.now(), "计时器");
    Get.bus.fire(TimerStartEvent());
    showOverlay(DateTime.now(), false, timerName ?? '', channel, box);
    companionSend(seconds, timerName, timerTag, false);
  }

  void pause() {
    pauseAsTogetherResponse();
    togetherSend(states.seconds, timerName, timerTag, true, box);
    setState(() {});
  }

  void pauseAsTogetherResponse() {
    timing = false;
    if (timer != null) {
      timer!
        ..reset()
        ..pause();
    }
    states.change(false, PreciseTime.now());
    states.permanent(box);
    widgetTimingPause();
    Get.bus.fire(TimerPauseEvent());
    hideOverlay(channel, box);
    states.calcSeconds();
    companionSend(states.seconds, timerName, timerTag, true);
  }

  void resume() {
    resumeAsTogetherResponse();
    togetherSend(states.seconds, timerName, timerTag, false, box);
    setState(() {});
  }

  void resumeAsTogetherResponse() {
    timing = true;
    if (timer != null) timer!.start();
    states.change(true, PreciseTime.now());
    states.permanent(box);
    DateTime startSecond =
        DateTime.now().add(-Duration(seconds: states.seconds));
    widgetTimingStart(startSecond, "计时器");
    Get.bus.fire(TimerResumeEvent());
    showOverlay(startSecond.add(-Duration(milliseconds: 500)), false,
        timerName ?? '', channel, box);
    states.calcSeconds();
    companionSend(states.seconds, timerName, timerTag, false);
  }

  void end() {
    endAsTogetherResponse();
    togetherDelete(box);
    saveResults("是否要保存计时结果？");
    setState(() {});
  }

  void endAsTogetherResponse() {
    timing = false;
    timingStarted = false;
    if (timer != null) {
      timer!
        ..reset()
        ..pause();
    }
    displayTime("00:00:00");
    states.cleanPermanent(box);
    widgetTimingFinish();
    hideOverlay(channel, box);
    companionDelete();
    Get.bus.fire(TimerEndEvent());
  }

  void saveResults(String indicate) {
    states.calcSeconds();
    if (states.seconds >= 180) {
      showChooseSheet(indicate, "之后手动保存", "直接保存", context, (int select) async {
        if (select != 1) {
          Get.replace(Task(
            name: timerName ?? '',
            tag: timerTag,
            date: dayAt.day,
            startTime: Time.fromPreciseTime(states.start!),
            endTime: Time.now(),
            side: Side.right,
            taskColor: timerTag != null
                ? TaskColor.values
                    .byName(box.read("tagColor$timerTag") ?? "green")
                : TaskColor.green,
            flag: 'from-timer',
          ));
          box.remove('timer.beginTaskName');
          box.remove('timer.beginTaskTag');
          await context.push('/add');
          context.replace('/');
        }
      });
    } else {
      box.remove('timer.beginTaskName');
      box.remove('timer.beginTaskTag');
      if (states.seconds > 0) {
        showHud(ProgressHudType.error, "时间过短，无法保存");
      } else {
        showHud(ProgressHudType.error, "请先开始计时");
      }
    }
  }

  void tick() {
    states.tick();
    displayTime(states.formatted);
    timer!
      ..reset()
      ..start();
  }

  Future<void> widgetTimingStart(DateTime precise, String title) async {
    if (isIOS()) {
      int start = precise.millisecondsSinceEpoch ~/ 1000;
      try {
        await channel.invokeMethod("widgetTiming", [start, title]);
      } on PlatformException catch (e) {
        print("Set Widget Error: $e");
      }
    }
  }

  Future<void> widgetTimingFinish() async {
    if (isIOS()) {
      try {
        await channel.invokeMethod("widgetSessionFinished");
      } on PlatformException catch (e) {
        print("Set Widget Error: $e");
      }
    }
  }

  Future<void> widgetTimingPause() async {
    if (isIOS()) {
      try {
        await channel.invokeMethod("widgetSessionPaused");
      } on PlatformException catch (e) {
        print("Set Widget Error: $e");
      }
    }
  }

  Widget aBookmark(String time, {bool last = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 28.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4.r),
                blurRadius: 15.r,
                color: Pantone.greenTimerShadowAlt2!,
              )
            ],
          ),
          child: SvgPicture.asset(
            'lib/assets/bookmark.svg',
            height: 21.r,
          ),
        ),
        SizedBox(width: 18.w),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
        ),
      ]),
    );
  }

  Widget markSplits() {
    return // 书签栏
        Positioned(
      top: 459.h,
      left: 87.w,
      right: 80.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            aBookmark("13:23 (00:49)"),
            aBookmark("13:37 (01:03)"),
            aBookmark("13:47 (01:13)"),
            aBookmark("14:00 (01:26)", last: true),
          ]),
          Bounceable(
            onTap: () {},
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [
                  BoxShadow(
                    color: Pantone.greenTimerShadowAlt3!,
                    blurRadius: 15.r,
                    offset: Offset(0.w, 4.h),
                  ),
                ],
                color: Pantone.white,
              ),
              child: Container(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'lib/assets/small_add.svg',
                  height: 16.r,
                  colorFilter: ColorFilter.mode(
                    Pantone.greenButton!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      states.calcSeconds();
      displayTime(states.formatted);
      setState(() {});
    }
  }
}

bool withCompanion(GetStorage box) {
  return box.read("useCompanion") ?? false;
}

bool withTogether(GetStorage box) {
  return box.read("duringTogether") ?? false;
}

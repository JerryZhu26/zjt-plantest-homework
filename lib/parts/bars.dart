// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables
// ignore_for_file: non_constant_identifier_names, use_key_in_widget_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_event_bus/get_event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:realm/realm.dart';
import 'package:spaces2/spaces2.dart';
import 'package:timona_ec/libraries/adopt_calendar/adoptive_calendar.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/ai_create.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:window_manager/window_manager.dart';

/// 顶栏
class TopBar extends StatefulWidget {
  TopBar({
    super.key,
    this.initialHoldUp,
    this.whichScreen = 3,
  });

  final bool? initialHoldUp;
  final int whichScreen;

  @override
  TopBarState createState() => TopBarState();
}

BoxDecoration topDeco = BoxDecoration(
  gradient: LinearGradient(colors: [Pantone.bg!, Pantone.bgSemiLight!]),
);

class TopBarState extends State<TopBar> {
  Date? initial;
  bool clickIndicating = false;
  bool holdUp = false;
  bool showTodo = false;
  TaskColor tempTaskColor = TaskColor.green;

  final box = GetStorage();
  late DayAt dayAt;
  late Color fontColor;
  late TextEditingController naco;

  @override
  void initState() {
    super.initState();
    holdUp = widget.initialHoldUp ?? false;
    dayAt = Get.find();
    initial = dayAt.day;
    fontColor = Colors.white;
    showTodo = box.read("showTodos") ?? true;
    naco = TextEditingController();
    registerBarClickEvents();
  }

  @override
  Widget build(BuildContext context) {
    topDeco = BoxDecoration(
      gradient: LinearGradient(colors: [Pantone.bg!, Pantone.bgSemiLight!]),
    );
    return Column(children: [
      Container(
        width: 390.w,
        height: isDesktop() ? 33.72.h : 0,
        decoration: topDeco,
        child: isDesktop() ? nav() : Container(),
      ),
      GestureDetector(
        onTap: () {
          holdUp = true;
          setState(() {});
        },
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 1) {
            // Drag Down
            holdUp = true;
            setState(() {});
          }
          if (details.delta.dy < -1) {
            // Drag Up
            holdUp = false;
            setState(() {});
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 1000) {
            // Right Drag
            dayAt.day = Date.fromDateTime(
                dayAt.day.toDateTime().add(Duration(days: -1)));
            Get.replace(dayAt);
            goReload(context, box, holdUp: holdUp);
          }
          if (details.velocity.pixelsPerSecond.dx < -1000) {
            // Left Drag
            dayAt.day = Date.fromDateTime(
                dayAt.day.toDateTime().add(Duration(days: 1)));
            Get.replace(dayAt);
            goReload(context, box, holdUp: holdUp, direction: Side.left);
          }
        },
        child: MouseRegion(
          cursor:
              isDesktop() ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Container(
            width: 1.sw,
            height: isDesktop() ? 16.h : 48.h,
            decoration: topDeco,
            padding: EdgeInsets.only(bottom: 16.h, top: 5.h),
            child: initial != null
                ? isDesktop()
                    ? Container()
                    : nav()
                : Container(),
          ),
        ),
      ),
    ]);
  }

  EdgeInsets rightIconPadding = EdgeInsets.only(
    top: isDesktop() ? 16.8.h : 8.3.h,
    right: 15.w,
  );

  void registerBarClickEvents() {
    Get.bus.on<BarFirstClickEvent>((event) {
      clickIndicating = true;
      if (mounted) setState(() {});
    }, cancelOnError: true);
    Get.bus.on<BarSecondClickEvent>((event) {
      clickIndicating = false;
      if (mounted) setState(() {});
    }, cancelOnError: true);
  }

  Widget nav() {
    int dayType = box.read("dayType${dayAt.day.sswy}") ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            padding: EdgeInsets.only(
                left: isMacOS()
                    ? 84.w
                    : isDesktop()
                        ? 10.w
                        : 8.w,
                top: isDesktop() ? 16.8.h : 8.3.h),
            child: Visibility(
              visible: !dayAt.day.equal(Date.now()) && !clickIndicating,
              child: GestureDetector(
                onTap: () {
                  dayAt.day = Date.now();
                  Get.replace(dayAt);
                  goReload(context, box, holdUp: holdUp, direction: Side.left);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: SvgPicture.asset(
                        'lib/assets/back-to.svg',
                        height: 20.r,
                        colorFilter:
                            ColorFilter.mode(fontColor, BlendMode.srcIn),
                      ),
                    ),
                    Text(
                      "返回今日",
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: isDesktop() ? 10.w : 8.w, top: isDesktop() ? 13.h : 5.h),
            child: Bounceable(
              onTap: () {
                holdUp = true;
                calendarFloatWindow(
                  child: AdoptiveCalendar(
                    useTime: false,
                    iconColor: Pantone.greenButtonAlt,
                    selectedColor: Pantone.greenButtonAlt,
                    initialDate: dayAt.day.d,
                    minYear: dayAt.day.d.year - 2,
                    maxYear: dayAt.day.d.year + 2,
                    onClick: (dt) {
                      if (dt != null) {
                        context.pop();
                        dayAt.day = Date.fromDateTime(dt);
                        Get.replace(dayAt);
                        goReload(context, box, holdUp: holdUp);
                      }
                    },
                  ),
                  context: context,
                );
                setState(() {});
              },
              child: Row(children: [
                Text(
                  clickIndicating
                      ? "点击结束时间处完成新建"
                      : "${dayAt.day.month}月${dayAt.day.day}日",
                  style: TextStyle(
                    color: fontColor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Visibility(
                  visible: dayType != 0,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 4.2.h),
                    child: barCapsule(dayType == 1 ? '休息' : '事务',
                        fontColor.withOpacity(0.75)),
                  ),
                ),
              ]),
            ),
          ),
        ]),
        Row(children: [
          if (widget.whichScreen == 1)
            Padding(
              padding: rightIconPadding,
              child: Bounceable(
                onTap: () {
                  List<String> contents = ['设为工作日', '设为休息日', '设为事务日'];
                  showSelectSheet('请选择今日的种类', contents, context, (val) {
                    if (val != null) {
                      box.write("dayType${dayAt.day.sswy}", val);
                      setState(() {});
                      showHud(ProgressHudType.success, '已成功${contents[val]}');
                    }
                  }, result0SentFunc: true);
                },
                child: barCapsule('编辑', fontColor.withOpacity(0.75)),
              ),
            ),
          if (widget.whichScreen == 2)
            Padding(
              padding: rightIconPadding,
              child: Bounceable(
                onTap: () {
                  if (showTodo) {
                    Get.bus.fire(BarHideTodoEvent());
                    showTodo = false;
                  } else {
                    Get.bus.fire(BarShowTodoEvent());
                    showTodo = true;
                  }
                  setState(() {});
                },
                child: SvgPicture.asset(
                  showTodo
                      ? 'lib/assets/up-sw4.svg'
                      : 'lib/assets/down-sw4.svg',
                  height: 25.r,
                ),
              ),
            ),
          if (widget.whichScreen == 3)
            Padding(
              padding: rightIconPadding,
              child: SpacedRow(spaceBetween: 8.w, children: [
                Bounceable(
                  onTap: () async {
                    floatWindowSecondLine(
                      naco,
                      () async {
                        Navigator.of(context).pop();
                        showHud(ProgressHudType.success, "新建项目成功");
                        Get.delete<Proj>();
                        PJ pj = PJ(
                          ObjectId(),
                          ECApp.userId(),
                          naco.text,
                          parent: null,
                          children: [],
                          color: tempTaskColor.name,
                        );
                        ECApp.realm.write(() => ECApp.realm.add(pj));
                        naco.clear();
                        context.replace('/--reload');
                      },
                      context,
                      "新建项目",
                      "请输入项目名称\n",
                      Container(
                        height: 37.8.h,
                        padding: EdgeInsets.only(left: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ColorTabs(
                              tempTaskColor,
                              (TaskColor tc) {
                                tempTaskColor = tc;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'lib/assets/add_folder-sw4.svg',
                    height: 25.r,
                  ), // Not necessarily an icon widget
                ),
                Bounceable(
                  onTap: () async {
                    Get.delete<Todo>();
                    Get.delete<Proj>();
                    await context.push('/todos/add');
                    context.replace('/--reload');
                  },
                  child: SvgPicture.asset(
                    'lib/assets/add-sw2.svg',
                    height: 15.r,
                  ), // Not necessarily an icon widget
                ),
              ]),
            ),
          if (isWindows())
            Padding(
                padding: rightIconPadding,
                child: SpacedRow(
                  spaceBetween: 8.w,
                  children: [
                    Bounceable(
                      onTap: () async {
                        windowManager.minimize();
                      },
                      child: SvgPicture.asset(
                        'lib/assets/window-minimize.svg',
                        height: 20.r,
                      ), // Not necessarily an icon widget
                    ),
                    Bounceable(
                      onTap: () async {
                        windowManager.close();
                      },
                      child: SvgPicture.asset(
                        'lib/assets/window-close.svg',
                        height: 20.r,
                      ), // Not necessarily an icon widget
                    ),
                  ],
                )),
        ]),
      ],
    );
  }
}

Widget barCapsule(String text, Color bgColor) {
  return Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(2.sp),
    ),
    height: 18.sp,
    width: 30.sp,
    padding: EdgeInsets.symmetric(horizontal: 3.5.sp, vertical: 0.5.sp),
    child: Text(
      text,
      style: TextStyle(
        color: Pantone.bg!,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void goReload(BuildContext context, GetStorage box,
    {required bool holdUp, Side? direction}) {
  if (holdUp) {
    context.replace('/--reload-tbhu');
  } else {
    if ((direction ?? Side.right) == Side.left) {
      context.replace('/--reload-animate-left');
    } else {
      context.replace('/--reload-animate-right');
    }
  }
}

PieTheme pieTheme = PieTheme(
  delayDuration: 100.ms,
  hoverDuration: 100.ms,
  fadeDuration: 150.ms,
  buttonSize: 56.r,
  childBounceDuration: 110.ms,
  childBounceCurve: Curves.decelerate,
  childBounceFactor: 0.95,
  pointerDecoration: BoxDecoration(color: Pantone.whitetransparent),
  buttonTheme: PieButtonTheme(
    backgroundColor: Pantone.green,
    iconColor: Pantone.white,
  ),
  buttonThemeHovered: PieButtonTheme(
    backgroundColor: Colors.greenAccent.shade700,
    iconColor: Pantone.white,
  ),
);

/// 底栏 + 按钮
class BottomAdd extends StatefulWidget {
  BottomAdd({super.key});

  @override
  BottomAddState createState() => BottomAddState();
}

class BottomAddState extends State<BottomAdd>
    with SingleTickerProviderStateMixin {
  final box = GetStorage();

  bool opened = false;
  bool invoken = false;
  late TextEditingController naco;

  @override
  void initState() {
    super.initState();
    naco = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.5.sw - 23.w,
      right: 0.5.sw - 23.w,
      bottom: isIOS() ? 10.h : 0.h,
      child: PieMenu(
        theme: pieTheme.copyWith(
            brightness: Pantone.isDarkMode(context)
                ? Brightness.dark
                : Brightness.light),
        onPressed: () async {
          if (box.read('whichScreen') != 3) {
            DayAt dayAt = Get.find();
            floatWindow(
              naco,
              () => nlpSubmit(naco.text, naco, box, () {}, context, ECApp.realm,
                  dayAt.day.d),
              context,
              "新建任务",
              "请输入任务名称\n与任务的起止时间",
            );
          } else {
            Get.delete<Todo>();
            await context.push('/todos/add');
            context.replace('/--reload');
          }
        },
        actions: [
          PieAction(
            tooltip: Text('手动输入新建'),
            onSelect: () async {
              if (box.read('whichScreen') != 3) {
                Get.delete<Task>();
                await context.push('/add');
                context.replace('/--reload');
              } else {
                Get.delete<Todo>();
                Get.delete<Proj>();
                await context.push('/todos/add');
                context.replace('/--reload');
              }
            },
            child: SvgPicture.asset(
              'lib/assets/add_nl.svg',
              height: 25.r,
            ), // Not necessarily an icon widget
          ),
          PieAction(
            tooltip: Text('计时器'),
            onSelect: () {
              context.push('/timer');
            },
            child: SvgPicture.asset(
              'lib/assets/add_timer.svg',
              height: 25.r,
            ), // Not necessarily an icon widget
          ),
          PieAction(
            tooltip: Text('一起计时'),
            onSelect: () {
              context.push('/timer/together');
            },
            child: SvgPicture.asset(
              'lib/assets/add_together.svg',
              height: 25.r,
            ), // Not necessarily an icon widget
          ),
          if (Platform.isAndroid || Platform.isIOS)
            PieAction(
              tooltip: Text('语音输入'),
              onSelect: () {
                baseFloatWindow(
                  height: isIOS()
                      ? 150.h
                      : isMobile()
                          ? 134.h
                          : 140.h,
                  context: context,
                  child: VoiceWidget(fatherContext: context),
                );
              },
              child: SvgPicture.asset(
                'lib/assets/add_mic.svg',
                height: 25.r,
              ), // Not necessarily an icon widget
            ),
        ],
        child: Column(children: [
          Container(
            height: 130.h,
            child: Stack(children: [
              Positioned(
                top: 68.h,
                child: Container(
                  height: 56.h,
                  child: Container(
                    width: 46.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Pantone.bg!,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'lib/assets/add.svg',
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// 底栏组件
class BottomBar extends StatefulWidget {
  BottomBar({super.key, required this.click});

  final Function click;

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  BottomBarState();

  final box = GetStorage();
  int selected = 2;

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    selected = box.read('whichScreen') ?? 2;
    ColorFilter greenFilter = ColorFilter.mode(Pantone.green!, BlendMode.srcIn);
    ColorFilter greyFilter = selected != 4
        ? ColorFilter.mode(Pantone.grey!, BlendMode.srcIn)
        : ColorFilter.mode(Pantone.greenBottomUnselected!, BlendMode.srcIn);
    return Positioned.fill(
      child: Column(children: [
        Expanded(child: Container()),
        Container(
          height: isIOS() ? 76.15.h : 66.15.h,
          child: Column(children: [
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                color: selected != 4 ? Pantone.white : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 102.w,
                    height: isIOS() ? 76.h : 66.h,
                    padding: EdgeInsets.only(bottom: isIOS() ? 10.h : 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 计时
                        Bounceable(
                          onTap: () {
                            //context.push('/timer/--index');
                            selected = 3;
                            widget.click(3);
                            setState(() {});
                          },
                          duration: 55.ms,
                          reverseDuration: 55.ms,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            child: SvgPicture.asset(
                              //'lib/assets/ip4-timer.svg',
                              'lib/assets/ip4-list.svg',
                              colorFilter:
                                  selected == 3 ? greenFilter : greyFilter,
                            ),
                          ),
                        ),
                        SizedBox(width: 38.w),
                        // 计划
                        Bounceable(
                          onTap: () {
                            selected = 2;
                            widget.click(2);
                            setState(() {});
                          },
                          duration: 55.ms,
                          reverseDuration: 55.ms,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            child: SvgPicture.asset(
                              'lib/assets/ip4-plan.svg',
                              colorFilter:
                                  selected == 2 ? greenFilter : greyFilter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 108.w),
                  Container(
                    width: 102.w,
                    height: isIOS() ? 76.h : 66.h,
                    padding: EdgeInsets.only(bottom: isIOS() ? 10.h : 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 回顾
                        Bounceable(
                          onTap: () {
                            selected = 1;
                            widget.click(1);
                            setState(() {});
                          },
                          duration: 55.ms,
                          reverseDuration: 55.ms,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            child: SvgPicture.asset(
                              'lib/assets/ip4-history.svg',
                              colorFilter:
                                  selected == 1 ? greenFilter : greyFilter,
                            ),
                          ),
                        ),
                        SizedBox(width: 38.w),
                        // 设置
                        Bounceable(
                          onTap: () {
                            selected = 4;
                            widget.click(4);
                            setState(() {});
                          },
                          duration: 55.ms,
                          reverseDuration: 55.ms,
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            child: SvgPicture.asset(
                              'lib/assets/ip4-user.svg',
                              colorFilter:
                                  selected == 4 ? greenFilter : greyFilter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class AntiRRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0.h, size.width, size.height + 1.h));
    final radius = 0.h;
    final roundedRect = RRect.fromLTRBR(
        0.w, 0.h, size.width - 0.w, size.height - 0.h, Radius.circular(radius));
    path.addRRect(roundedRect);
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Future<Object?> calendarFloatWindow(
    {double? height, required Widget child, required BuildContext context}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return Container(
        height: 100.sh,
        width: 100.sw,
        child: Stack(children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Pantone.white!.withOpacity(0.8)),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            top: isMobile() ? 100.h : 60.h,
            height: height ?? 0.41.sh,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                border: Pantone.isDarkMode(context)
                    ? Border.all(
                        color: Pantone.black!.withOpacity(0.1), width: 1.5.r)
                    : null,
                boxShadow: [
                  if (!Pantone.isDarkMode(context))
                    BoxShadow(
                      color: Pantone.greenShadow!,
                      blurRadius: 8.r,
                      offset: Offset(0.w, 1.h),
                    ),
                ],
                color: Pantone.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  body: child,
                ),
              ),
            ),
          ),
        ]),
      );
    },
  );
}

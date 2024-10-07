// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'dart:math' as math;

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:d_chart/d_chart.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get_event_bus/get_event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:realm/realm.dart';
import 'package:spaces2/spaces2.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timona_ec/libraries/override/checkbox.dart';
import 'package:timona_ec/libraries/pausable_timer/pausable_timer.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/pages/history.dart';
import 'package:timona_ec/parts/ai_conclude.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/ui_widgets.dart';
import 'package:timona_ec/stores/timeline.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:url_launcher/url_launcher.dart';

part 'package:timona_ec/parts/central_general.dart';

part 'package:timona_ec/parts/central_piece-legacy.dart';

part 'package:timona_ec/parts/define_general.dart';

part 'package:timona_ec/parts/history_general.dart';

part 'package:timona_ec/parts/todo_general.dart';

/// 这是用于传递的 Position <> Time 库，目的是降低耦合程度
class Util {
  late int startHour;
  late double hh;

  Util({required this.startHour, required this.hh});

  Time position2Time(double dy) {
    double edy = dy + 2.h;
    int clickHour = startHour + (edy / hh).floor();
    int clickMin = ((edy - (edy / hh).floor() * hh) / hh * 60).round();
    if (clickMin == 60) {
      clickHour = (clickHour + 1) % 24;
      clickMin = 0;
    }
    return Time(hour: clickHour, minute: clickMin);
  }

  double time2Position(Time tm) {
    return (-startHour * hh + tm.hour * hh + tm.minute * hh / 60) - 10.h;
  }

  double comparable2Position(int ctm) {
    return (-startHour * hh + (ctm ~/ 60) * hh + (ctm % 60) * hh / 60) - 10.h;
  }
}

/// 标准常量
class Standard {
  double leftStart = 60.w, rightStart = 215.w;
  double sideWidth = 137.w, hourHeight = 90.h;
}

class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  ArcPainter(this.startAngle, this.sweepAngle, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(covariant ArcPainter oldDelegate) {
    return startAngle != oldDelegate.startAngle ||
        sweepAngle != oldDelegate.sweepAngle;
  }
}

class HistoryArcs extends StatelessWidget {
  const HistoryArcs({
    super.key,
    required this.bgColor,
    required this.onColor,
    required this.offColor,
    required this.textColor,
    required this.text,
    this.smaller = false,
    this.int = false,
  });

  final Color bgColor, onColor, offColor, textColor;
  final double text;
  final bool smaller, int;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: smaller ? 44.r : 54.7.r,
        height: smaller ? 44.r : 54.7.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: offColor,
        ),
        child: CustomPaint(
          painter: ArcPainter(
              -math.pi / 2,
              text <= 5 ? math.pi / 5 * text * 2 : math.pi / 50 * text,
              onColor),
        ),
      ),
      Container(
        width: smaller ? 37.r : 46.r,
        height: smaller ? 37.r : 46.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
        ),
      ),
      Text(
        text <= 5
            ? int
                ? text.toInt().toString()
                : text.toPrecision(1).toString()
            : "${text.toInt()}%",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: smaller
              ? text <= 5
                  ? int
                      ? 19.sp
                      : 16.sp
                  : 11.sp
              : text <= 5 && !int
                  ? 19.sp
                  : 20.sp,
          fontFamily: "PingFang SC",
          fontWeight: FontWeight.w600,
        ),
      ),
    ]);
  }
}

Widget rightArrow({Color? color, String? iconName}) {
  return Container(
    width: 20.w,
    height: 20.h,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 18.w,
          height: 18.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: color ?? Pantone.greenAlt1,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconName ?? 'lib/assets/my_arrow_right.svg',
            height: 9.r,
          ),
        ),
      ],
    ),
  );
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.w,
      right: 0.w,
      top: -100.h,
      child: SvgPicture.asset(
        'lib/assets/my_bg.svg',
        colorFilter: Pantone.isDarkMode(context)
            ? ColorFilter.mode(
                Pantone.green!.withOpacity(0.3),
                BlendMode.darken,
              )
            : null,
      ),
    );
  }
}

class ModalPage extends StatelessWidget {
  const ModalPage({
    super.key,
    required this.title,
    this.titleTap,
    this.titleSvg,
    this.rightSvg,
    this.rightSvgs,
    required this.child,
    this.rightSvgTap,
    this.rightSvgTaps,
    this.borderRadius = true,
    this.returnTap,
    this.leftSvg,
    this.leftSvgTap,
  });

  final String title;
  final String? titleSvg;
  final Function? titleTap;
  final Function? returnTap;
  final String? leftSvg;
  final Function? leftSvgTap;
  final String? rightSvg;
  final List<String?>? rightSvgs;
  final Function? rightSvgTap;
  final List<Function?>? rightSvgTaps;
  final Widget child;
  final bool borderRadius;

  @override
  Widget build(BuildContext context) {
    List<Widget> rightSvgsWidget = [];
    if (rightSvgs != null) {
      for (var i = 0; i < rightSvgs!.length; i++) {
        rightSvgsWidget.add(Bounceable(
          onTap: () => rightSvgTaps![i] != null ? rightSvgTaps![i]!() : null,
          child: SvgPicture.asset(
            rightSvgs![i]!,
            height: 18.r,
          ),
        ));
        if (rightSvgs!.length - i != 1) {
          rightSvgsWidget.add(SizedBox(width: 16.r));
        }
      }
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(isIPad(context) ? 0.82 : 1.0)),
      child: Scaffold(
        body: Container(
          height: 1.sh,
          color: Pantone.green,
          child: Stack(children: [
            Positioned(
              left: 0.w,
              right: 0.w,
              top: isDesktop() ? -100.h : -50.h,
              child: GestureDetector(
                onVerticalDragEnd: (detail) {
                  if (detail.velocity.pixelsPerSecond.dy > 1000) {
                    if (context.canPop()) context.pop();
                  }
                },
                child: SvgPicture.asset(
                  'lib/assets/my_bg.svg',
                ),
              ),
            ),
            Container(
              width: 1.sw,
              height: 90.h,
              padding: EdgeInsets.only(
                top: isDesktop() ? 50.h : 55.h,
                left: 20.w,
                right: 20.w,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 20.h,
                    child: Row(children: [
                      Bounceable(
                        onTap: returnTap != null
                            ? () => returnTap!()
                            : () => context.pop(),
                        duration: 55.ms,
                        reverseDuration: 55.ms,
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            color: Pantone.white,
                          ),
                          padding: EdgeInsets.only(
                            top: 4.5.r,
                            bottom: 4.5.r,
                          ),
                          child: SvgPicture.asset(
                            'lib/assets/back.svg',
                            height: 12.r,
                          ),
                        ),
                      ),
                      if (leftSvg != null) SizedBox(width: 8.r),
                      if (leftSvg != null)
                        Bounceable(
                          onTap: () =>
                              leftSvgTap != null ? leftSvgTap!() : null,
                          child: SvgPicture.asset(
                            leftSvg!,
                            height: 18.r,
                          ),
                        )
                    ]),
                  ),
                  Expanded(
                    child: Bounceable(
                      onTap: titleTap != null ? () => titleTap!() : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10.w),
                          Flexible(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Pantone.greenTagDark,
                                fontSize: 22.sp,
                                fontFamily: "PingFang SC",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (titleSvg != null)
                            Padding(
                              padding: EdgeInsets.only(left: 5.w, bottom: 12.h),
                              child: SvgPicture.asset(titleSvg!, height: 11.r),
                            ),
                          SizedBox(width: 10.w),
                        ],
                      ),
                    ),
                  ),
                  rightSvg != null
                      ? Bounceable(
                          onTap: () =>
                              rightSvgTap != null ? rightSvgTap!() : null,
                          child: SvgPicture.asset(
                            rightSvg!,
                            height: 18.r,
                          ),
                        )
                      : rightSvgs != null
                          ? Row(children: rightSvgsWidget)
                          : Container(height: 18.r, width: 16.r),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 390.w,
                height: 735.h - MediaQuery.of(context).viewInsets.bottom,
                decoration: BoxDecoration(
                  color: Pantone.white,
                  borderRadius: borderRadius
                      ? BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        )
                      : BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: Pantone.greenShadowAlt1!,
                      blurRadius: 8.r,
                      offset: Offset(0.w, -6.h),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ModalFormBox extends StatelessWidget {
  const ModalFormBox(
      {super.key, required this.child, this.borderRadius = true});

  final Widget child;
  final bool borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: isDesktop()
            ? borderRadius
                ? 49.h
                : 25.h
            : 0,
        bottom: 29.h,
      ),
      child: child,
    );
  }
}

TextStyle defaultTextStyle = const TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.bold,
);

GoRoute route(
  String path, {
  Widget? child,
  Widget Function(BuildContext, GoRouterState)? builder,
  Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder,
}) {
  return GoRoute(
    path: path,
    builder: builder ??
        (child != null
            ? (context, state) =>
                DefaultTextStyle(style: defaultTextStyle, child: child)
            : null),
    pageBuilder: pageBuilder,
  );
}

class ModalButton extends StatelessWidget {
  const ModalButton({super.key, required this.name, required this.onTap});

  final String name;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => onTap(),
      duration: 55.ms,
      reverseDuration: 55.ms,
      child: Container(
        width: 101.w,
        height: 37.h,
        child: Container(
          width: 101.w,
          height: 37.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            color: Pantone.greenButton,
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Pantone.white,
              fontSize: 18.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class FullButton extends StatelessWidget {
  const FullButton(
      {super.key,
      required this.name,
      required this.onTap,
      required this.width});

  final String name;
  final Function onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => onTap(),
      duration: 55.ms,
      reverseDuration: 55.ms,
      child: Container(
        width: width,
        height: 51.h,
        child: Container(
          width: width,
          height: 51.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pantone.green!.lighten(36).desaturate(27),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Pantone.white,
              fontSize: 18.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  const SmallButton(
      {super.key, required this.name, required this.onTap, this.fontSize});

  final String name;
  final Function onTap;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => onTap(),
      duration: 55.ms,
      reverseDuration: 55.ms,
      child: Container(
        width: 70.w,
        height: 21.h,
        child: Container(
          width: 70.w,
          height: 21.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Pantone.green!.lighten(20).desaturate(24),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Pantone.white,
              fontSize: fontSize ?? 13.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class PageMyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, 130.h);
    var firstControlPoint = Offset(size.width / 4, 0.h);
    var firstEndPoint = Offset(size.width / 2, 50.h);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 4 * 3 + 20.w, 160.h);
    var secondEndPoint = Offset(size.width, 40.h);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 80.h);
    path.lineTo(size.width, size.height);

    path = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Future<void> showCheckSheet(String title, BuildContext context, Function func,
    {String? confirm, String? cancel}) async {
  final result = await showModalActionSheet<String>(
    context: context,
    title: title,
    actions: [
      SheetAction(label: confirm ?? '确定', key: 'confirm'),
    ],
    cancelLabel: cancel ?? '取消',
  );
  if (result == 'confirm') func();
}

Future<void> showChooseSheet(String title, String choiceA, String choiceB,
    BuildContext context, Function func,
    {String? cancel}) async {
  final result = await showModalActionSheet<int>(
    context: context,
    title: title,
    actions: [
      SheetAction(label: choiceA, key: 1),
      SheetAction(label: choiceB, key: 2),
    ],
    cancelLabel: cancel ?? '取消',
  );
  if (result == 1) func(1);
  if (result == 2) func(2);
}

Future<void> showSelectSheet(
    String title, List<String> contents, BuildContext context, Function func,
    {String? cancel, bool result0SentFunc = false}) async {
  List<SheetAction<int>> actions = [];
  for (int index = 0; index < contents.length; index++) {
    actions.add(SheetAction(
      label: contents[index],
      key: index,
    ));
  }
  final result = await showModalActionSheet<int>(
    context: context,
    title: title,
    actions: actions,
    cancelLabel: cancel ?? '取消',
  );
  if (result != 0 || result0SentFunc) func(result);
}

bool isDesktop() {
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

bool isWindows() {
  return Platform.isWindows;
}

bool isMacOS() {
  return Platform.isMacOS;
}

bool isMobile() {
  return !isDesktop();
}

bool isIPad(BuildContext context) {
  if (isDesktop()) return false;
  return MediaQuery.of(context).size.width /
          MediaQuery.of(context).size.height >=
      0.61;
}

bool isIOS() {
  return Platform.isIOS;
}

bool isAndroid() {
  return Platform.isAndroid;
}

Future<bool> isIpadAsync(BuildContext context) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo info = await deviceInfo.iosInfo;
  if (info.name.toLowerCase().contains("ipad")) {
    return true;
  }
  return false;
}

Future<void> showHud(ProgressHudType type, String text) async {
  await Future.delayed(Duration(milliseconds: 240));
  ProgressHud.showAndDismiss(type, text);
}

Future<void> showHudC(
    ProgressHudType type, String text, BuildContext context) async {
  await Future.delayed(Duration(milliseconds: 240));
  if (!context.mounted) return;
  ProgressHud.of(context)?.showAndDismiss(type, text);
}

Future<void> showHudNoDismiss(ProgressHudType type, String text) async {
  await Future.delayed(Duration(milliseconds: 240));
  ProgressHud.show(type, text);
}

Future<void> showHudNoDismissC(
    ProgressHudType type, String text, BuildContext context) async {
  await Future.delayed(Duration(milliseconds: 240));
  if (!context.mounted) return;
  ProgressHud.of(context)?.show(type, text);
}

Future<void> dismissHud() async {
  ProgressHud.dismiss();
}

Future<void> dismissHudC(BuildContext context) async {
  if (!context.mounted) return;
  ProgressHud.of(context)?.dismiss();
}

Widget tag(int index, String name, BuildContext context, GetStorage box,
    Function(Function() fn) setState, Function(String name) setTag) {
  return GestureDetector(
    onTap: () {
      setTag(name);
      List<String> tags = (box.read("tags") ?? []).cast<String>();
      tags.remove(name);
      tags.insert(0, name);
      box.write("tags", tags);
      setState(() {});
    },
    onLongPress: () {
      showCheckSheet("确定要删除 $name 吗？不可撤销，但过往任务不会受影响", context, () {
        List<String> tags = (box.read("tags") ?? []).cast<String>();
        tags.remove(name);
        box.write("tags", tags);
        setState(() {});
      });
    },
    child: Container(
      padding: EdgeInsets.only(right: 11.w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: index % 3 == 0
              ? Pantone.greenTag1
              : index % 3 == 1
                  ? Pantone.greenTag2
                  : Pantone.greenTag3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 11.w,
          vertical: 2.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Pantone.isDarkMode(context)
                    ? Pantone.greenTagDark
                    : Pantone.greenTag,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget tags(GetStorage box, BuildContext context,
    Function(Function() fn) setState, Function(String name) setTag) {
  List<String> tags = (box.read("tags") ?? []).cast<String>();
  List<Widget> tagWidgets = [];
  for (var i = 0; i < tags.length; i++) {
    tagWidgets.add(tag(i, tags[i], context, box, setState, setTag));
  }
  tagWidgets.add(
    Bounceable(
      onTap: () async {
        final result = await showTextInputDialog(
          context: context,
          title: "请输入想新建的tag",
          message: "不需要包括“#”符号",
          textFields: [DialogTextField()],
        );
        if (result != null) {
          tags.insert(0, "#${result[0]}");
          box.write("tags", tags);
          setState(() {});
        }
      },
      duration: 55.ms,
      reverseDuration: 55.ms,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: Pantone.greenTag3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 5.w,
          vertical: 3.4.h,
        ),
        child: SvgPicture.asset(
          'lib/assets/add.svg',
          height: 11.r,
          colorFilter: ColorFilter.mode(
            Pantone.isDarkMode(context)
                ? Pantone.greenTagDark!
                : Pantone.green!,
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
  return Container(
    width: 354.w,
    height: 20.h,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: tagWidgets,
    ),
  );
}

Widget workRest(bool value, void Function(bool) onToggle) {
  return Row(children: [
    GestureDetector(
      onTap: () => onToggle(false),
      child: Text(
        "工作",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Pantone.greenLineLabel,
          fontSize: 15.sp,
          fontFamily: "PingFang SC",
        ),
      ),
    ),
    SizedBox(width: 8.w),
    FlutterSwitch(
      value: value,
      width: 50.w,
      height: 25.h,
      valueFontSize: 12.sp,
      toggleSize: 18.r,
      activeColor: Pantone.green!.withOpacity(0.8),
      inactiveColor: Pantone.grey350!,
      onToggle: onToggle,
    ),
    SizedBox(width: 8.w),
    GestureDetector(
      onTap: () => onToggle(true),
      child: Text(
        "休息",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Pantone.greenLineLabel,
          fontSize: 15.sp,
          fontFamily: "PingFang SC",
        ),
      ),
    ),
  ]);
}

String tow(String original) {
  if (original.length == 1) {
    return "0$original";
  } else {
    return original;
  }
}

String itow(int originalInt) {
  String original = originalInt.toString();
  if (original.length == 1) {
    return "0$original";
  } else {
    return original;
  }
}

/// 安全的子字串方法
String substr(String str, int end) {
  if (str.length <= end) {
    return str;
  } else {
    return str.substring(0, end);
  }
}

String combineStrings(List<String> all) {
  return all.where((s) => s.isNotEmpty).join(' ');
}

Future<Null> showOverlay(DateTime tAA, bool isCountDown, String name,
    MethodChannel channel, GetStorage box) async {
  if (Platform.isAndroid) {
    if (box.read("useTimingOverlay") ?? false) {
      String formatted =
          "${tAA.year}-${itow(tAA.month)}-${itow(tAA.day)}-${itow(tAA.hour)}-${itow(tAA.minute)}-${itow(tAA.second)}";
      try {
        await channel.invokeMethod(
          "showOverlay",
          {'time': formatted, 'countdown': isCountDown, 'name': name},
        );
      } on PlatformException catch (e) {
        print("Show Overlay Failed: $e");
      }
    }
  }
}

Future<Null> hideOverlay(MethodChannel channel, GetStorage box) async {
  if (Platform.isAndroid) {
    if (box.read("useTimingOverlay") ?? false) {
      try {
        await channel.invokeMethod("hideOverlay");
      } on PlatformException catch (e) {
        print("Hide Overlay Failed: $e");
      }
    }
  }
}

Future<void> openUrl(String url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
  }
}

/// General Float Window
Future<Object?> floatWindow(TextEditingController teco, Function onTap,
    BuildContext context, String strNew, String placeholder,
    {int? maxLine, double? fontSize}) {
  return baseFloatWindow(
    height: isIOS()
        ? 154.h
        : isMobile()
            ? 138.h
            : 144.h,
    context: context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Input(
          placeholder: placeholder,
          backgroundColor: Colors.transparent,
          fontSize: fontSize ?? 24.sp,
          width: 310.w,
          minLine: 1,
          maxLine: maxLine ?? 2,
          teco: teco,
          autoSize: false,
          autoFocus: true,
          onChanged: (str) {
            if (str.endsWith('\n')) onTap();
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 12.h, right: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "回车$strNew",
                style: TextStyle(
                  color: Pantone.green!.lighten(36).desaturate(33),
                  fontSize: 12.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SmallButton(
                name: strNew,
                fontSize: strNew.length >= 5 ? 11.8.sp : 13.sp,
                onTap: () => onTap(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// General Float Window with 2 Inputs
Future<Object?> floatWindowSecondLine(
  TextEditingController teco,
  Function onTap,
  BuildContext context,
  String strNew,
  String placeholder,
  Widget second,
) {
  return baseFloatWindow(
    height: isIOS()
        ? 154.h
        : isMobile()
            ? 138.h
            : 144.h,
    context: context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Input(
          placeholder: placeholder,
          backgroundColor: Colors.transparent,
          fontSize: 24.sp,
          width: 310.w,
          minLine: 1,
          maxLine: 1,
          teco: teco,
          autoSize: false,
          autoFocus: true,
          onChanged: (str) {
            if (str.endsWith('\n')) onTap();
          },
        ),
        second,
        Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 12.h, right: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "回车$strNew",
                style: TextStyle(
                  color: Pantone.green!.lighten(36).desaturate(33),
                  fontSize: 12.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SmallButton(
                name: strNew,
                onTap: () => onTap(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Base Float Window
Future<Object?> baseFloatWindow(
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
            bottom: isMobile() ? 380.h : 340.h,
            height: height ?? 163.h,
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

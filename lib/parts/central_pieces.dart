// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/stores/timeline.dart';
import 'package:tinycolor2/tinycolor2.dart';

List<Widget> piecesFromTimeline(Timeline timeline, Util util, Standard standard,
    BuildContext context, GetStorage box, void Function() fetchTasks) {
  final List<Widget> pieces = [];
  for (int i = 0; i <= 1; i++) {
    int startPosition = -1;
    int endPosition = -1;
    for (int j = 0; j < 60 * 24; j++) {
      if (timeline.line[i][j]!.isEmpty && startPosition == -1) continue;
      if (timeline.line[i][j]!.isNotEmpty && startPosition == -1) {
        startPosition = j;
      }
      if (j == 0) continue;
      Set<ObjectId> differenceDelete =
          timeline.line[i][j - 1]!.difference(timeline.line[i][j]!);
      Set<ObjectId> differenceAdd =
          timeline.line[i][j]!.difference(timeline.line[i][j - 1]!);
      Set<ObjectId> difference = differenceDelete.union(differenceAdd);
      if (difference.isNotEmpty && timeline.line[i][j - 1]!.isNotEmpty) {
        endPosition = j - 1;
        if (timeline.tks[difference.first] == null) continue;
        if (timeline.line[i][j - 1]!.length == 1) {
          TK tempTk = timeline.tks[timeline.line[i][j - 1]!.first]!;
          pieces.add(TKPiece(
            tk: tempTk,
            context: context,
            timeline: timeline,
            box: box,
            standard: standard,
            side: i == 1 ? Side.right : Side.left,
            top: util.comparable2Position(startPosition),
            width: dispCalc(
                i == 1 ? Side.right : Side.left, disp, 303.w, 0.w, 137.w),
            height: math.max(
              0,
              util.comparable2Position(endPosition) -
                  util.comparable2Position(startPosition),
            ),
            minutes: endPosition - startPosition,
            fetchTasks: fetchTasks,
          ));
        } else {
          List<TK> tks = [];
          for (var item in timeline.line[i][j - 1]!) {
            tks.add(timeline.tks[item]!);
          }
          pieces.add(TKMultiple(
            tks,
            side: i == 1 ? Side.right : Side.left,
            minutes: endPosition - startPosition,
            top: util.comparable2Position(startPosition),
            width: dispCalc(
                i == 1 ? Side.right : Side.left, disp, 303.w, 0.w, 137.w),
            height: math.max(
              0,
              util.comparable2Position(endPosition) -
                  util.comparable2Position(startPosition),
            ),
            timeline: timeline,
            standard: standard,
          ));
        }
        startPosition = -1;
      }
    }
  }
  return pieces;
}

class TKPiece extends StatelessWidget {
  final TK tk;
  final Side side;
  final BuildContext context;
  final GetStorage box;
  final int minutes;
  final double top, width, height;
  final Timeline timeline;
  final Standard standard;
  final void Function()? fetchTasks;

  const TKPiece({
    super.key,
    required this.tk,
    required this.top,
    required this.width,
    required this.height,
    required this.context,
    required this.side,
    required this.minutes,
    required this.box,
    required this.timeline,
    required this.standard,
    this.fetchTasks,
  });

  @override
  Widget build(BuildContext context) {
    TaskColor taskColor = TaskColor.values.byName(tk.color);
    return Positioned(
      top: top,
      left: side == Side.left
          ? 6.h
          : dispCalc(Side.right, disp, standard.leftStart, 370.w,
                  standard.rightStart) +
              6.h -
              standard.leftStart,
      width: width,
      child: PieMenu(
        theme: pieTheme.copyWith(
            childBounceEnabled: false,
            brightness: Pantone.isDarkMode(context)
                ? Brightness.dark
                : Brightness.light),
        actions: [
          PieAction(
            tooltip: Text("任务详情"),
            onSelect: () async {
              Get.replace(Task(
                name: tk.name,
                date: Date.fr(tk.date!),
                startTime: Time.fr(tk.startTime!),
                endTime: Time.fr(tk.endTime!),
                comment: tk.comment,
                side: side,
                taskColor: taskColor,
                tag: tk.tag,
                isRest: tk.isRest,
              ));
              ObjectId id = tk.id;
              Time startTime = Time.fr(tk.startTime!);
              Time endTime = Time.fr(tk.endTime!);
              await context.push('/detail');
              try {
                String? status = Get.find<String>(tag: 'status');
                if (status == 'delete') {
                  timeline.tks.remove(id);
                  timeline.remove(id, startTime, endTime, side);
                } else if (status == 'edit') {
                  TK? edited = Get.find<TK?>(tag: 'edited');
                  Get.delete<TK?>(tag: 'edited');
                  timeline.tks.remove(id);
                  timeline.tks[id] = edited!;
                  timeline.remove(id, startTime, endTime, side);
                  timeline.add(id, Time.fr(edited.startTime!),
                      Time.fr(edited.endTime!), side);
                }
                Get.delete<String>(tag: 'status');
              } catch (_) {}
            },
            child: SvgPicture.asset(
              'lib/assets/piemenu_detail.svg',
              height: 25.r,
            ),
          ),
          PieAction(
            tooltip: Text("删除"),
            onSelect: () {
              showCheckSheet(
                  tk.name != ""
                      ? "确定删除 ${tk.name.split("\$p\$")[0]} 吗？不可撤销"
                      : "确定删除任务吗？不可撤销",
                  context, () async {
                ObjectId id = tk.id;
                Time startTime = Time.fr(tk.startTime!);
                Time endTime = Time.fr(tk.endTime!);
                ECApp.realm.write(() {
                  ECApp.realm.delete<TK>(tk);
                });
                timeline.tks.remove(id);
                timeline.remove(id, startTime, endTime, side);
              });
            },
            child: SvgPicture.asset(
              // The pie menu icons are from IconPark
              // With size 24, thickness 3
              'lib/assets/piemenu_trash.svg',
              height: 25.r,
            ),
          ),
          PieAction(
            tooltip: Text("转为计时任务"),
            onSelect: () {
              box.write('timer.beginTaskName', tk.name);
              box.write('timer.beginTaskTag', tk.tag);
              context.push('/timer');
            },
            child: SvgPicture.asset(
              'lib/assets/piemenu_timer.svg',
              height: 25.r,
            ),
          ),
          if (side == Side.left)
            PieAction(
              tooltip: Text("转为时间记录"),
              onSelect: () async {
                Get.replace(Task(
                  name: tk.name,
                  date: Date.fr(tk.date!),
                  startTime: Time.fr(tk.startTime!),
                  endTime: Time.fr(tk.endTime!),
                  comment: tk.comment,
                  side: Side.right,
                  taskColor: taskColor,
                  tag: tk.tag,
                  isRest: tk.isRest,
                ));
                await context.push('/add');
                if (fetchTasks != null) fetchTasks!();
                Get.delete<TK>();
              },
              child: SvgPicture.asset(
                'lib/assets/piemenu_do.svg',
                height: 25.r,
              ),
            ),
          if (side == Side.left &&
              !isWindows() &&
              Date.fr(tk.date!) >= Date.now())
            PieAction(
              tooltip: Text("添加提醒"),
              onSelect: () {
                showSelectSheet(
                  "请选择具体的提醒时间",
                  ["任务开始时", "提前5分钟", "提前10分钟", "提前15分钟", "提前半小时"],
                  context,
                  (result) {
                    int minute = 0;
                    if (result == 1) {
                      minute = 5;
                    } else if (result == 2) {
                      minute = 10;
                    } else if (result == 3) {
                      minute = 15;
                    } else if (result == 4) {
                      minute = 30;
                    }
                    DateTime notifyTime = Time.fr(tk.startTime!)
                        .d(Date.fr(tk.date!))
                        .add(Duration(minutes: -minute));
                    if (notifyTime.isAfter(DateTime.now())) {
                      scheduleNotifications(
                          tk.name,
                          result == 0
                              ? "当前已到这一任务的开始时间"
                              : "按照计划，这一任务将于$minute分钟后开始",
                          notifyTime,
                          box,
                          context);
                    } else {
                      showHudC(ProgressHudType.error, "只能在未来的时间新建提醒", context);
                    }
                  },
                  cancel: "取消",
                  result0SentFunc: true,
                );
              },
              child: SvgPicture.asset(
                'lib/assets/piemenu_notify.svg',
                height: 25.r,
              ),
            )
        ],
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Pantone.isDarkMode(context)
                      ? taskColors[(taskColor, true)]!
                          .bgColor
                          .tint(tk.isRest ? 40 : 15)
                      : taskColors[(taskColor, false)]!
                          .bgColor
                          .tint(tk.isRest ? 30 : 0),
                  taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .bgColor
                      .tint(tk.isRest ? 30 : 0)
                ]),
            border: Border.all(
                color: Pantone.isDarkMode(context)
                    ? taskColors[(taskColor, false)]!
                        .bgColor
                        .lighten(tk.isRest ? 22 : 17)
                        .withOpacity(0.2)
                    : taskColors[(taskColor, false)]!
                        .commentLeftColor
                        .lighten(tk.isRest ? 22 : 17)
                        .withOpacity(0.2),
                width: 2.r),
            boxShadow: [
              BoxShadow(
                color: Pantone.greenShadow!,
                blurRadius: 4.r,
                offset: Offset(0.w, 0.h),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(children: [
            Stack(children: [
              Positioned(
                left: 6.w,
                top: height * 0.09,
                child: Container(
                  height: height * 0.82,
                  width: 2.5.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5.r),
                    color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                        .commentLeftColor
                        .lighten(Pantone.isDarkMode(context)
                            ? 0
                            : tk.isRest
                                ? 20
                                : 15),
                  ),
                ),
              ),
              Container(
                height: math.max(height - 4.r, 0),
                alignment: Alignment.center,
                child: FadingEdgeScrollView.fromSingleChildScrollView(
                  gradientFractionOnEnd: 0.5,
                  gradientFractionOnStart: 0.5,
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: SizedBox(
                      width: dispCalc(side, disp, 270.w, 0.w, 121.w),
                      child: minutes >= 27
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 8.w),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          titlePart(taskColor),
                                          Text(
                                            "${Time.frn(tk.startTime)} - ${Time.frn(tk.endTime)}",
                                            style: TextStyle(
                                              color: taskColors[(
                                                taskColor,
                                                Pantone.isDarkMode(context)
                                              )]!
                                                  .textColor
                                                  .withOpacity(
                                                      tk.isRest ? 0.6 : 1),
                                              fontSize: 10.sp,
                                              fontFamily: "PingFang SC",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ])
                                  ],
                                ),
                                if (tk.comment != null && minutes >= 40)
                                  if (tk.comment != "")
                                    SizedBox(
                                        height: minutes >= 50 ? 11.h : 6.h),
                                if (tk.comment != null && minutes >= 40)
                                  if (tk.comment != "") commentPiece(taskColor),
                              ],
                            )
                          : titlePart(taskColor),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // Piece 的标题栏
  Widget titlePart(TaskColor taskColor) {
    String titleForShow = tk.name;
    if (titleForShow.contains("\$p\$")) {
      titleForShow = titleForShow.split("\$p\$")[0];
    }
    return SizedBox(
      width: 109.w,
      child: FadingEdgeScrollView.fromSingleChildScrollView(
        gradientFractionOnEnd: 0.3,
        gradientFractionOnStart: 0.3,
        child: SingleChildScrollView(
          controller: ScrollController(),
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.only(left: minutes >= 27 ? 0 : 8.w),
            child: Row(children: [
              if (tk.comment != null && height < 40)
                if (tk.comment != '')
                  Container(
                    padding: EdgeInsets.only(right: minutes >= 27 ? 5.w : 3.w),
                    child: SvgPicture.asset(
                      'lib/assets/comment.svg',
                      height: minutes >= 27 ? 13.sp : 8.sp,
                      colorFilter: ColorFilter.mode(
                        taskColors[(taskColor, Pantone.isDarkMode(context))]!
                            .textColor
                            .tint(tk.isRest ? 30 : 0),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              if (tk.tag != null)
                Container(
                  padding: EdgeInsets.only(top: 1.2.h),
                  child: Text(
                    tk.tag!,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      color:
                          taskColors[(taskColor, Pantone.isDarkMode(context))]!
                              .textColor
                              .withOpacity(tk.name != "" ? 0.8 : 1)
                              .tint(tk.isRest ? 30 : 0),
                      fontSize: tk.name != ""
                          ? minutes >= 27
                              ? 12.sp
                              : 7.sp
                          : minutes >= 27
                              ? 15.sp
                              : 9.sp,
                      fontFamily: "PingFang SC",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (tk.tag != null) Container(width: 4.w),
              Text(
                titleForShow,
                textAlign: TextAlign.start,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: TextStyle(
                  color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .textColor
                      .tint(tk.isRest ? 30 : 0),
                  fontSize: minutes >= 27 ? 15.sp : 9.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // Piece 的 comment 部分
  Widget commentPiece(TaskColor taskColor, {double? fontSize}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(children: [
            Expanded(
              child: Container(
                width: 1.5.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.50.r),
                  color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .commentLeftColor
                      .tint(tk.isRest ? 30 : 0),
                ),
              ),
            )
          ]),
          SizedBox(width: 5.w),
          Container(
            width: dispCalc(side, disp, 210.w, 0.w, 100.w),
            child: Text(
              tk.comment ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                    .commentColor,
                fontSize: fontSize ?? (minutes > 60 ? 9.sp : 6.sp),
                fontFamily: "PingFang SC",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TKMultiple extends StatelessWidget {
  final List<TK> tks;
  final Side side;
  final int minutes;
  final double top, width, height;
  final Timeline timeline;
  final Standard standard;

  const TKMultiple(this.tks,
      {super.key,
      required this.side,
      required this.minutes,
      required this.top,
      required this.width,
      required this.height,
      required this.timeline,
      required this.standard});

  @override
  Widget build(BuildContext context) {
    const taskColor = TaskColor.grey;
    tks.sort((a, b) =>
        Time.fr(a.startTime!).comparable - Time.fr(b.startTime!).comparable);
    String tkNames = "";
    for (int i = 0; i < tks.length; i++) {
      if (i != 0) tkNames += ", ";
      tkNames += tks[i].name;
    }
    return Positioned(
      top: top,
      left: side == Side.left
          ? 6.h
          : dispCalc(Side.right, disp, standard.leftStart, 370.w,
                  standard.rightStart) +
              6.h -
              standard.leftStart,
      width: width,
      child: GestureDetector(
        onTap: () => {},
        onLongPress: () => {},
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Pantone.isDarkMode(context)
                        ? taskColors[(taskColor, true)]!.bgColor.tint(15)
                        : taskColors[(taskColor, false)]!.bgColor.tint(0),
                    taskColors[(taskColor, Pantone.isDarkMode(context))]!
                        .bgColor
                        .tint(0)
                  ]),
              border: Border.all(
                  color: Pantone.isDarkMode(context)
                      ? taskColors[(taskColor, false)]!
                          .bgColor
                          .lighten(17)
                          .withOpacity(0.2)
                      : taskColors[(taskColor, false)]!
                          .commentLeftColor
                          .lighten(17)
                          .withOpacity(0.2),
                  width: 2.r),
              boxShadow: [
                BoxShadow(
                  color: Pantone.greenShadow!,
                  blurRadius: 4.r,
                  offset: Offset(0.w, 0.h),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 8.5.w, right: 4.w),
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                gradientFractionOnEnd: 0.3,
                gradientFractionOnStart: 0.3,
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    tkNames,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color:
                          taskColors[(taskColor, Pantone.isDarkMode(context))]!
                              .textColor
                              .tint(0),
                      fontSize: minutes >= 27 ? 15.sp : 9.sp,
                      fontFamily: "PingFang SC",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

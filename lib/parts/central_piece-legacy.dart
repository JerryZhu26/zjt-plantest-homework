// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

part of 'package:timona_ec/parts/general.dart';

/// 当前显示左侧，右侧还是两侧
enum Display { all, left, right }

Display disp = Display.all;

/// 这个组件位于左侧还是右侧
enum Side { left, right }

int sideIndex(Side side) {
  return side == Side.left ? 0 : 1;
}

/// 这个组件目前正常，拉伸，还是消缩
enum RealDisp { normal, stretch, vanish }

class BasePiece extends StatefulWidget {
  const BasePiece({
    super.key,
    required this.title,
    required this.taskColor,
    required this.side,
    required this.date,
    required this.util,
    this.isRest = false,
    this.isTodo = false,
    this.project,
  });

  final String title;
  final Date date;
  final TaskColor taskColor;
  final Side side;
  final Util util;
  final bool isRest;
  final bool isTodo;
  final PJ? project;

  @override
  State<StatefulWidget> createState() => BasePieceState();
}

class BasePieceState extends State<BasePiece> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// 时间框复用组件
class Piece extends BasePiece {
  const Piece({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.taskColor,
    required this.side,
    required this.date,
    required this.util,
    required this.taskStacks,
    this.tag,
    this.comment,
    this.dragPlace,
    this.toDelete,
    this.onToggle,
    this.onDelete,
    this.isRest = false,
    this.isTodo = false,
    this.project,
  }) : super(
          title: title,
          taskColor: taskColor,
          side: side,
          date: date,
          util: util,
        );

  final String title;
  final Date date;
  final Time startTime; // 10:25
  final Time endTime; // 11:10
  final String? tag, comment; // "图书馆514研讨间，提前15分钟刷卡签到"
  final TaskColor taskColor;
  final Side side;
  final Util util;
  final (double, double)? dragPlace;
  final Function? onToggle, onDelete;
  final List<(Time, Time)> taskStacks;
  final PJ? project;
  final bool isRest;
  final bool isTodo;

  // Dialed when Left/Right Horizontal Drag Happened
  // Currently Deprecated with no Usage
  final bool? toDelete;

  @override
  State<Piece> createState() => PieceState();

  @override
  String toString({DiagnosticLevel? minLevel}) {
    return "Piece: $title on $date";
  }
}

class PieceState extends State<Piece> {
  bool deleted = false;
  late String title;
  late Time startTime, endTime;
  late String? comment, tag;
  late TaskColor taskColor;
  late bool isRest, isVisible;

  late List<(Time, Time)> taskStacks, earlierStacked, laterStacked;

  late Time availableStartPoint, availableEndPoint;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    title = widget.title;
    startTime = widget.startTime;
    endTime = widget.endTime;
    availableStartPoint = startTime;
    availableEndPoint = endTime;
    comment = widget.comment;
    tag = widget.tag;
    taskColor = widget.taskColor;
    isRest = widget.isRest;
    isVisible = true;
    if (title.contains("\$p\$")) {
      isVisible = checkTaskTodayVisible(title, widget.date.d);
    }
    if (isVisible) {
      updateTaskStack(initializing: true);
    }
  }

  void updateTaskStack({bool initializing = false}) {
    if (initializing) {
      taskStacks = [...widget.taskStacks];
      taskStacks
          .removeWhere((t) => t.$1.equal(startTime) && t.$2.equal(endTime));
    }
    earlierStacked = [];
    laterStacked = [];
    availableStartPoint = startTime;
    availableEndPoint = endTime;
    for (var stacked in taskStacks) {
      if (stacked.$2.comparable < endTime.comparable &&
          stacked.$2.comparable > startTime.comparable) {
        earlierStacked.add(stacked);
        if (stacked.$2.comparable > availableStartPoint.comparable) {
          availableStartPoint = stacked.$2;
        }
      }
      if (stacked.$1.comparable > startTime.comparable &&
          stacked.$1.comparable < endTime.comparable) {
        laterStacked.add(stacked);
        if (stacked.$1.comparable < availableEndPoint.comparable) {
          availableEndPoint = stacked.$1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool isStretch = realDisp(widget.side, disp) == RealDisp.stretch;
    bool isStretch = false;
    double leftSidePosition =
        availableStartPoint.comparable != startTime.comparable ? 8.w : 0;

    double height(Time end, Time start) {
      return math.max(
          widget.util.time2Position(end) - widget.util.time2Position(start), 0);
    }

    return Positioned(
      top: widget.util.time2Position(startTime) -
          (widget.side == Side.right ? 4.h : 0),
      left: leftSidePosition + 6.h,
      width: dispCalc(widget.side, disp, 303.w, 0.w, 137.w) - leftSidePosition,
      child: Visibility(
        visible: !deleted && isVisible,
        child: PieMenu(
          theme: pieTheme.copyWith(
              childBounceEnabled: false,
              brightness: Pantone.isDarkMode(context)
                  ? Brightness.dark
                  : Brightness.light),
          onToggle: (_) {
            if (widget.onToggle != null) {
              widget.onToggle!();
            }
          },
          actions: widget.isTodo
              ? []
              : [
                  PieAction(
                    tooltip: Text("任务详情"),
                    onSelect: () async {
                      Get.replace(Task(
                        name: title,
                        date: widget.date,
                        startTime: startTime,
                        endTime: endTime,
                        comment: comment,
                        side: widget.side,
                        taskColor: taskColor,
                        tag: tag,
                        isRest: isRest,
                      ));
                      await context.push('/detail');
                      try {
                        String? status = Get.find<String>(tag: 'status');
                        if (status == 'delete') {
                          deleted = true;
                          setState(() {});
                        } else if (status == 'edit') {
                          TK? edited = Get.find<TK?>(tag: 'edited');
                          Get.delete<TK?>(tag: 'edited');
                          title = edited!.name;
                          startTime = Time.fr(edited.startTime!);
                          endTime = Time.fr(edited.endTime!);
                          comment = edited.comment;
                          tag = edited.tag;
                          taskColor = TaskColor.values.byName(edited.color);
                          isRest = edited.isRest;
                          updateTaskStack();
                          setState(() {});
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
                          widget.title != ""
                              ? "确定删除 ${widget.title.split("\$p\$")[0]} 吗？不可撤销"
                              : "确定删除任务吗？不可撤销",
                          context, () async {
                        TK? tk = ECApp.realm.query<TK>(
                            'date.year = \$0 AND date.month = \$1 AND date.day = \$2 AND name = \$3 '
                            'AND startTime.hour = \$4 AND startTime.minute = \$5 AND side = \$6',
                            [
                              widget.date.year,
                              widget.date.month,
                              widget.date.day,
                              widget.title,
                              widget.startTime.hour,
                              widget.startTime.minute,
                              widget.side.name,
                            ]).firstOrNull;
                        ObjectId? tkId = tk?.id;
                        ECApp.realm.write(() {
                          ECApp.realm.delete<TK>(tk!);
                        });
                        deleted = true;
                        if (widget.onDelete != null) {
                          print("${widget.title}: $tkId");
                          widget.onDelete!(tkId);
                        }
                        setState(() {});
                      });
                    },
                    child: SvgPicture.asset(
                      // The pie menu icons are from IconPark
                      // With size 24, thickness 3
                      'lib/assets/piemenu_trash.svg',
                      height: 25.r,
                    ),
                  ),
                  /*PieAction(
              tooltip: Text("拖拽"),
              onSelect: () {},
              child: SvgPicture.asset(
                'lib/assets/piemenu_drag.svg',
                height: 25.r,
              ),
            ),*/
                  PieAction(
                    tooltip: Text("转为计时任务"),
                    onSelect: () {
                      box.write('timer.beginTaskName', widget.title);
                      box.write('timer.beginTaskTag', widget.tag);
                      context.push('/timer');
                    },
                    child: SvgPicture.asset(
                      'lib/assets/piemenu_timer.svg',
                      height: 25.r,
                    ),
                  ),
                  if (widget.side == Side.left)
                    PieAction(
                      tooltip: Text("转为时间记录"),
                      onSelect: () async {
                        Get.replace(Task(
                          name: title.split('\$p\$')[0],
                          date: widget.date,
                          startTime: startTime,
                          endTime: endTime,
                          side: Side.right,
                          comment: comment,
                          tag: tag,
                          isRest: isRest,
                          taskColor: taskColor,
                        ));
                        await context.push('/add');
                      },
                      child: SvgPicture.asset(
                        'lib/assets/piemenu_do.svg',
                        height: 25.r,
                      ),
                    ),
                  if (widget.side == Side.left &&
                      !isWindows() &&
                      widget.date >= Date.now())
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
                            DateTime notifyTime = startTime
                                .d(widget.date)
                                .add(Duration(minutes: -minute));
                            if (notifyTime.isAfter(DateTime.now())) {
                              scheduleNotifications(
                                  title,
                                  result == 0
                                      ? "当前已到这一任务的开始时间"
                                      : "按照计划，这一任务将于$minute分钟后开始",
                                  notifyTime,
                                  box,
                                  context);
                            } else {
                              showHudC(ProgressHudType.error, "只能在未来的时间新建提醒",
                                  context);
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
            width: dispCalc(widget.side, disp, 303.w, 0.w, 145.w) -
                leftSidePosition,
            height: height(endTime, startTime),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Pantone.isDarkMode(context)
                        ? taskColors[(taskColor, true)]!
                            .bgColor
                            .tint(isRest ? 40 : 15)
                        : taskColors[(taskColor, false)]!
                            .bgColor
                            .tint(isRest ? 30 : 0),
                    taskColors[(taskColor, Pantone.isDarkMode(context))]!
                        .bgColor
                        .tint(isRest ? 30 : 0)
                  ]),
              border: Border.all(
                  color: Pantone.isDarkMode(context)
                      ? taskColors[(taskColor, false)]!
                          .bgColor
                          .lighten(isRest ? 22 : 17)
                          .withOpacity(0.2)
                      : taskColors[(taskColor, false)]!
                          .commentLeftColor
                          .lighten(isRest ? 22 : 17)
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
                  top: height(availableEndPoint, startTime) * 0.15,
                  child: Container(
                    height: height(availableEndPoint, startTime) * 0.7,
                    width: 2.5.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5.r),
                      color:
                          taskColors[(taskColor, Pantone.isDarkMode(context))]!
                              .commentLeftColor
                              .lighten(Pantone.isDarkMode(context)
                                  ? 0
                                  : isRest
                                      ? 20
                                      : 15),
                    ),
                  ),
                ),
                Container(
                  height: math.max(
                      widget.util.time2Position(availableEndPoint) -
                          widget.util.time2Position(startTime) -
                          4.r,
                      0),
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
                        width: dispCalc(
                                widget.side,
                                disp,
                                270.w,
                                0.w,
                                availableStartPoint == startTime
                                    ? 121.w
                                    : 126.w) -
                            leftSidePosition,
                        child: availableEndPoint - startTime >= 27
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 8.w),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            titlePart(),
                                            Text(
                                              "$startTime - $endTime",
                                              style: TextStyle(
                                                color: taskColors[(
                                                  taskColor,
                                                  Pantone.isDarkMode(context)
                                                )]!
                                                    .textColor
                                                    .withOpacity(
                                                        isRest ? 0.6 : 1),
                                                fontSize: 10.sp,
                                                fontFamily: "PingFang SC",
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ])
                                    ],
                                  ),
                                  if (!isStretch &&
                                      comment != null &&
                                      availableEndPoint - startTime >= 40)
                                    if (comment != "")
                                      SizedBox(
                                          height:
                                              availableEndPoint - startTime >=
                                                      50
                                                  ? 11.h
                                                  : 6.h),
                                  if (!isStretch &&
                                      comment != null &&
                                      availableEndPoint - startTime >= 40)
                                    if (comment != "")
                                      commentPiece(isStretch,
                                          minutes:
                                              availableEndPoint - startTime),
                                ],
                              )
                            : titlePart(),
                      ),
                    ),
                  ),
                ),
              ]),
              Container(height: height(endTime, availableEndPoint)),
            ]),
          ),
        ),
      ),
    );
  }

  // Piece 的未伸展状态标题栏
  Widget titlePart() {
    String titleForShow = title;
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
            padding: EdgeInsets.only(
                left: availableEndPoint - startTime >= 27 ? 0 : 8.w),
            child: Row(children: [
              if (comment != null && availableEndPoint - startTime < 40)
                if (comment != '')
                  Container(
                    padding: EdgeInsets.only(
                        right: availableEndPoint - startTime >= 27 ? 5.w : 3.w),
                    child: SvgPicture.asset(
                      'lib/assets/comment.svg',
                      height:
                          availableEndPoint - startTime >= 27 ? 13.sp : 8.sp,
                      colorFilter: ColorFilter.mode(
                        taskColors[(taskColor, Pantone.isDarkMode(context))]!
                            .textColor
                            .tint(isRest ? 30 : 0),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              if (tag != null)
                Container(
                  padding: EdgeInsets.only(top: 1.2.h),
                  child: Text(
                    tag!,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      color:
                          taskColors[(taskColor, Pantone.isDarkMode(context))]!
                              .textColor
                              .withOpacity(title != "" ? 0.8 : 1)
                              .tint(isRest ? 30 : 0),
                      fontSize: title != ""
                          ? availableEndPoint - startTime >= 27
                              ? 12.sp
                              : 7.sp
                          : availableEndPoint - startTime >= 27
                              ? 15.sp
                              : 9.sp,
                      fontFamily: "PingFang SC",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (tag != null) Container(width: 4.w),
              Text(
                titleForShow,
                textAlign: TextAlign.start,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: TextStyle(
                  color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .textColor
                      .tint(isRest ? 30 : 0),
                  fontSize: availableEndPoint - startTime >= 27 ? 15.sp : 9.sp,
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
  Widget commentPiece(bool isStretch, {double? fontSize, int? minutes}) {
    double _minutes = (minutes ?? 50).toDouble();
    return IntrinsicHeight(
      child: Row(
        children: [
          if (isStretch) SizedBox(width: 1.w) else SizedBox(width: 10.w),
          Column(children: [
            Expanded(
              child: Container(
                width: 1.5.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.50.r),
                  color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .commentLeftColor
                      .tint(isRest ? 30 : 0),
                ),
              ),
            )
          ]),
          SizedBox(width: 5.w),
          Container(
            width: dispCalc(widget.side, disp, 210.w, 0.w, 100.w),
            child: Text(
              comment ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                    .commentColor,
                fontSize: fontSize ?? (_minutes > 60 ? 9.sp : 6.sp),
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

/// A：展开，B：缩失；C：正常
double dispCalc(Side side, Display displ, double a, double b, double c) {
  return side == Side.left && displ == Display.left ||
          side == Side.right && displ == Display.right
      ? a
      : side == Side.left && displ == Display.right ||
              side == Side.right && displ == Display.left
          ? b
          : c;
}

RealDisp realDisp(Side side, Display displ) {
  return side == Side.left && displ == Display.left ||
          side == Side.right && displ == Display.right
      ? RealDisp.stretch
      : side == Side.left && displ == Display.right ||
              side == Side.right && displ == Display.left
          ? RealDisp.vanish
          : RealDisp.normal;
}

/// 第一次点击标记器
Widget beginYIndicator(double lineWidth,
    {bool withBottomPart = true, Function? func}) {
  return Stack(children: [
    Column(children: [
      Container(
        height: 1.h,
        width: lineWidth,
        decoration: BoxDecoration(
          color: Pantone.green!,
          boxShadow: [
            withBottomPart
                ? BoxShadow(
                    color: Pantone.black12!,
                    spreadRadius: 2.r,
                    blurRadius: 14.r,
                    offset: Offset(0, 10.h),
                  )
                : BoxShadow(
                    color: Pantone.black12!,
                    spreadRadius: 2.r,
                    blurRadius: 14.r,
                    offset: Offset(0, -10.h),
                  )
          ],
        ),
      ),
      withBottomPart
          ? Row(children: [
              Container(
                height: 9.h,
                width: 1.w,
                decoration: BoxDecoration(color: Pantone.green!),
              ),
              Container(
                height: 9.h,
                width: lineWidth - 2.w,
              ),
              Container(
                height: 9.h,
                width: 1.w,
                decoration: BoxDecoration(color: Pantone.green!),
              ),
            ])
          : Container(),
    ]),
    Container(height: 24.h, width: lineWidth, color: Colors.transparent),
  ]);
}

class LinePiece extends BasePiece {
  const LinePiece({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.taskColor,
    required this.side,
    required this.util,
    this.isRest = false,
    this.isTodo = false,
    this.project,
  }) : super(
          title: title,
          taskColor: taskColor,
          side: side,
          date: date,
          util: util,
        );

  final String title;
  final Date date;
  final Time time;
  final TaskColor taskColor;
  final bool isRest;
  final bool isTodo;
  final PJ? project;
  final Side side;
  final Util util;

  @override
  LinePieceState createState() => LinePieceState();
}

class LinePieceState extends State<LinePiece> {
  bool deleted = false;
  late String title;
  late Time time;
  late TaskColor taskColor;
  late bool isRest, isVisible;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    title = widget.title;
    time = widget.time;
    taskColor = widget.taskColor;
    isRest = widget.isRest;
    isVisible = true;
    if (title.contains("\$p\$")) {
      isVisible = checkTaskTodayVisible(title, widget.date.d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.util.time2Position(time) -
          (widget.side == Side.right ? 4.h : 0) -
          25.h,
      left: 8.h,
      width: dispCalc(widget.side, disp, 299.w, 0.w, 133.w),
      child: Visibility(
        visible: !deleted && isVisible,
        child: PieMenu(
          theme: pieTheme.copyWith(
              childBounceEnabled: false,
              brightness: Pantone.isDarkMode(context)
                  ? Brightness.dark
                  : Brightness.light),
          onToggle: (_) {},
          actions: widget.isTodo
              ? []
              : [
                  PieAction(
                    tooltip: Text("任务详情"),
                    onSelect: () async {},
                    child: SvgPicture.asset(
                      'lib/assets/piemenu_detail.svg',
                      height: 25.r,
                    ),
                  ),
                  PieAction(
                    tooltip: Text("删除"),
                    onSelect: () {},
                    child: SvgPicture.asset(
                      // The pie menu icons are from IconPark
                      // With size 24, thickness 3
                      'lib/assets/piemenu_trash.svg',
                      height: 25.r,
                    ),
                  ),
                ],
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Pantone.whitetransparent!,
                  Pantone.white!,
                  Pantone.white!,
                  Pantone.whitetransparent!,
                ],
                stops: [0, 0.3, 0.9, 1],
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 134.w,
                  height: 20.h,
                  child: FadingEdgeScrollView.fromSingleChildScrollView(
                    gradientFractionOnEnd: 0.3,
                    gradientFractionOnStart: 0.3,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        SizedBox(width: 1.7.w),
                        Text(
                          "$time",
                          style: TextStyle(
                            color: taskColors[(
                              taskColor,
                              Pantone.isDarkMode(context)
                            )]!
                                .textColor
                                .withOpacity(isRest ? 0.6 : 1),
                            fontSize: 10.sp,
                            fontFamily: "PingFang SC",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          title.replaceAll('\$ok\$', ''),
                          style: TextStyle(
                            color: taskColors[(
                              taskColor,
                              Pantone.isDarkMode(context)
                            )]!
                                .textColor
                                .tint(isRest ? 30 : 0),
                            fontSize: 14.sp,
                            fontFamily: "PingFang SC",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                Container(
                  height: 2.h,
                  color: taskColors[(taskColor, Pantone.isDarkMode(context))]!
                      .commentLeftColor
                      .lighten(Pantone.isDarkMode(context)
                          ? 0
                          : isRest
                              ? 20
                              : 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

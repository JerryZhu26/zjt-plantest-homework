// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

part of 'package:timona_ec/parts/general.dart';

Widget avatar({bool bigger = false}) {
  return Container(
    width: bigger ? 101.r : 75.r,
    height: bigger ? 101.r : 75.r,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 2.h),
          blurRadius: 3,
          color: Pantone.black12!,
        )
      ],
    ),
    child: const Image(image: AssetImage('lib/assets/avatar.png')),
  );
}

Widget topCentral() {
  return SizedBox(
    height: 88.h,
    width: 40.w,
    child: Stack(children: [
      Positioned(
        left: 7.w,
        top: 41.6.h,
        child: SvgPicture.asset(
          'lib/assets/history_polygon.svg',
          height: 6.r,
        ),
      ),
      Positioned(
        top: 2.4.h,
        left: 9.w,
        child: SvgPicture.asset(
          'lib/assets/history_message.svg',
          height: 22.r,
        ),
      ),
      Positioned(
        left: 15.w,
        top: 37.3.h,
        child: SvgPicture.asset(
          'lib/assets/history_star.svg',
          height: 22.r,
        ),
      ),
      Positioned(
        bottom: -5.h,
        left: 9.w,
        child: SvgPicture.asset(
          'lib/assets/history_heart.svg',
          height: 22.r,
        ),
      )
    ]),
  );
}

Widget rateMean(
    double rate, GetStorage box, BuildContext context, Function setState) {
  Color textColor =
      Pantone.isDarkMode(context) ? Color(0xffe5a47b) : Color(0xffa87554);
  return Container(
    width: 322.w,
    height: 87.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color:
          Pantone.isDarkMode(context) ? Color(0xff5a4938) : Color(0xfffff4de),
      border: Border.all(
          color: Pantone.isDarkMode(context)
              ? Color(0xff7b6234)
              : Color(0x44f5bc61),
          width: 2.r),
    ),
    padding: EdgeInsets.only(
      top: 9.h,
      left: 15.w,
      right: 15.w,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TodayDescriptionWidget(),
        Bounceable(
          onTap: () => showChooseSheet(
              "请在“小时评分”和“任务评分”两种模式中进行选择", "小时评分", "任务均分", context,
              (int select) {
            if (select == 1) {
              box.write("rateByHour", true);
              setState(() {});
            } else {
              box.write("rateByHour", false);
              setState(() {});
            }
          }),
          duration: 55.ms,
          reverseDuration: 55.ms,
          child: Column(
            children: [
              HistoryArcs(
                onColor: Pantone.isDarkMode(context)
                    ? Color(0xff8e5800)
                    : Color(0xfff5bc61),
                offColor: Pantone.isDarkMode(context)
                    ? Color(0xffda9203)
                    : Color(0xfff8e6c2),
                textColor: textColor,
                bgColor: Pantone.isDarkMode(context)
                    ? Color(0xff5a4938)
                    : Color(0xfffff4de),
                text: rate,
                smaller: true,
              ),
              SizedBox(height: 5.h),
              Text(
                (box.read("rateByHour") ?? true) ? "小时均分" : "任务均分",
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class TodayDescriptionWidget extends StatefulWidget {
  const TodayDescriptionWidget({super.key});

  @override
  TodayDescriptionWidgetState createState() => TodayDescriptionWidgetState();
}

class TodayDescriptionWidgetState extends State<TodayDescriptionWidget> {
  final box = GetStorage();
  late TextEditingController coco;
  late DayAt dayAt;
  late bool written;
  String content = '';

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    written = box.read('todayDescriptionGot${dayAt.day}') ?? false;
    content = box.read('todayDescription${dayAt.day}') ?? '';
    coco = TextEditingController(text: content);
  }

  @override
  Widget build(BuildContext context) {
    Color textColor =
        Pantone.isDarkMode(context) ? Color(0xffe5a47b) : Color(0xffa87554);
    return Container(
      width: 230.w,
      padding: EdgeInsets.only(right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "今日描述",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Bounceable(
                onTap: () => floatWindow(coco, () async {
                  await showHudC(ProgressHudType.success, "生成成功！", context);
                  written = true;
                  content = coco.text;
                  box.write('todayDescriptionGot${dayAt.day}', true);
                  box.write('todayDescription${dayAt.day}', content);
                  context.pop();
                  setState(() {});
                }, context, "保存描述", "在此处输入您对今日的描述\n\n",
                    fontSize: 18.6.sp, maxLine: 3),
                duration: 55.ms,
                reverseDuration: 55.ms,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/write.svg',
                      height: 17.r,
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                    Text(
                      " 输入",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 6.h),
          if (!written || content == '')
            Text(
              "您可在此输入您对今日情况的描述与评价，以供日后查看。",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Pantone.isDarkMode(context)
                    ? textColor.lighten(5).saturate(5)
                    : textColor.lighten(20),
              ),
            )
          else
            SizedBox(
              height: 38.h,
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Pantone.isDarkMode(context)
                      ? textColor.lighten(5).saturate(5)
                      : textColor.lighten(20),
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget dailyReport(
    bool ifIpad, double dayRate, RealmResults<TK> tasks, BuildContext context) {
  return Container(
    width: 322.w,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: Pantone.isDarkMode(context)
          ? Color(0xFF14465D)
          : Color(0xFFD6F0FC).lighten(4),
      border: Border.all(
          color: Pantone.isDarkMode(context)
              ? Color(0xFF386176)
              : Color(0xFF6FBDE1).lighten(20),
          width: 2.r),
    ),
    child: Conclusion(dayRate: dayRate, tasks: tasks),
  );
}

Widget daily4Blocks(List<String> params, bool ifIpad, BuildContext context) {
  return Container(
    width: 1.sw,
    height: 72.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color:
          Pantone.isDarkMode(context) ? Color(0xff29575b) : Color(0xffdcf1f2),
      border: Border.all(
          color: Pantone.isDarkMode(context)
              ? Color(0x337dc4cc)
              : Color(0x3331b6c3),
          width: 2.r),
    ),
    child: Stack(children: [
      Positioned(
        right: -32.w,
        top: 10.h,
        child: SvgPicture.asset(
          'lib/assets/chem-2.svg',
          height: 110.r,
          colorFilter: Pantone.isDarkMode(context)
              ? ColorFilter.mode(Color(0x555abbc7), BlendMode.srcIn)
              : null,
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          subBlock(params[0], "计划工作时", context),
          subBlock(params[1], "实际工作时", context, darker: true),
          subBlock(params[2], "计划作息比", context),
          subBlock(params[3], "实际作息比", context, darker: true),
        ]),
      ),
    ]),
  );
}

Widget subBlock(String percent, String name, BuildContext context,
    {bool darker = false}) {
  Color color = darker
      ? Pantone.isDarkMode(context)
          ? Color(0xd164c1ce)
          : Color(0xd1106874)
      : Pantone.isDarkMode(context)
          ? Color(0xff5abbc7)
          : Color(0xff108a99);
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          percent,
          style: TextStyle(
            color: color,
            fontSize: 18.sp,
            fontFamily: "PingFang SC",
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontFamily: "PingFang SC",
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget daysWorkTimeChart(
    List<TimeData> data, bool ifIpad, BuildContext context) {
  return Container(
    width: 1.sw,
    height: 174.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color:
          Pantone.isDarkMode(context) ? Color(0xff6a3339) : Color(0xffffeaec),
      border: Border.all(color: Color(0x33fc788c), width: 2.r),
    ),
    child: Stack(children: [
      Positioned(
        right: -2.w,
        top: 10.h,
        child: SvgPicture.asset(
          'lib/assets/chem-1.svg',
          height: 60.r,
          colorFilter: Pantone.isDarkMode(context)
              ? ColorFilter.mode(Color(0x55e396a1), BlendMode.srcIn)
              : null,
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(children: [
          Text(
            "每日工作时长图",
            style: TextStyle(
              color: Pantone.isDarkMode(context)
                  ? Color(0xffe38693)
                  : Color(0xddb34555),
              fontSize: 13.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            height: 128.h,
            padding: EdgeInsets.only(left: 12.w),
            child: AspectRatio(
              aspectRatio: 24 / 9,
              child: DChartBarT(
                animate: true,
                configRenderBar: ConfigRenderBar(
                  showBarLabel: true,
                  barLabelDecorator: BarLabelDecorator(
                    barLabelPosition: BarLabelPosition.outside,
                    outsideLabelStyle: LabelStyle(
                      color: Pantone.isDarkMode(context)
                          ? Color(0xffe38693)
                          : Color(0xddb34555),
                      fontSize: 8.7.sp.toInt(),
                    ),
                  ),
                ),
                barLabelValue: (group, data, index) =>
                    Time.fc(data.measure.toInt()).ss,
                measureAxis: MeasureAxis(
                  showLine: false,
                  tickLabelFormatter: (value) =>
                      Time.fc(value?.toInt() ?? 0).ss,
                  labelStyle: LabelStyle(
                    color: Pantone.isDarkMode(context)
                        ? Color(0xffe38693)
                        : Color(0xddb34555),
                    fontSize: 9.9.sp.toInt(),
                  ),
                ),
                domainAxis: DomainAxis(
                  showLine: false,
                  tickLabelFormatterT: (dateTime) {
                    return DateFormat('M.d').format(dateTime);
                  },
                  tickLength: 2,
                  labelStyle: LabelStyle(
                    color: Pantone.isDarkMode(context)
                        ? Color(0xffe38693)
                        : Color(0xddb34555),
                    fontSize: 9.9.sp.toInt(),
                  ),
                ),
                groupList: [
                  TimeGroup(
                    id: '1',
                    color: Pantone.isDarkMode(context)
                        ? Color(0xffe38693)
                        : Color(0xddb34555),
                    data: data,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    ]),
  );
}

class ReportBlock extends StatelessWidget {
  const ReportBlock(
      {super.key,
      required this.title,
      this.content,
      required this.rate,
      required this.time,
      this.last,
      this.moreInfo,
      this.moreAsset});

  final String title, time;
  final double rate;
  final bool? last;
  final String? moreInfo, content;
  final Widget? moreAsset;

  @override
  Widget build(BuildContext context) {
    return reportBlockMain(
      last: last ?? false,
      color: taskColors[(TaskColor.green, Pantone.isDarkMode(context))]!
          .bgColor
          .lighten(4),
      child: Column(children: [
        // 中间主要信息栏
        Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Pantone.green,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14.w,
                        height: 16.33.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: FlutterLogo(size: 14.r),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 9.w),
                Container(
                  width: 160.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Pantone.greenLineLabel,
                          fontSize: 14.sp,
                          fontFamily: "PingFang SC",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        time,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Pantone.greenAlt2,
                          fontSize: 11.sp,
                          fontFamily: "PingFang SC",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30.w,
                  padding: EdgeInsets.only(right: 10.w),
                  /*child: SvgPicture.asset(
                          'lib/assets/star.svg',
                          height: 20.r,
                        ),*/
                ),
              ]),
              content != null ? SizedBox(height: 8.h) : Container(),
              content != null ? reportBlockLabeled(content!) : Container(),
            ],
          ),
          // 右侧五档评分栏
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(
              height: 50.h,
              child: HistoryArcs(
                onColor: Pantone.green!,
                offColor: Color(0xffb2d6d3),
                textColor: Pantone.greenLineLabel!,
                bgColor: Pantone.greenMyBg!,
                text: rate,
                smaller: true,
                int: true,
              ),
            ),
          ]),
        ]),
        if (moreAsset != null) SizedBox(height: 16.h),
        if (moreAsset != null) moreAsset!,
        if (moreInfo != null) SizedBox(height: 12.h),
        if (moreInfo != null) reportBlockLabeled(moreInfo!, long: true),
      ]),
    );
  }
}

Widget reportBlockMain(
    {bool last = false,
    Color? color,
    EdgeInsets? padding,
    required Widget child}) {
  return IntrinsicHeight(
    child: Row(children: [
      // 左侧列表栏
      Column(children: [
        Container(
          width: 2.w,
          height: 28.h,
          color: Pantone.greenReportLeft,
        ),
        SizedBox(height: 7.h),
        SvgPicture.asset(
          'lib/assets/element_polygon.svg',
          height: 18.r,
        ),
        SizedBox(height: 7.h),
        Expanded(
          child: Container(
            width: 2.w,
            color: Pantone.greenReportLeft,
          ),
        ),
      ]),
      SizedBox(width: 16.w),
      Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 24.h),
        child: Container(
          width: 310.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: color ?? Pantone.greenMyBg,
          ),
          padding: padding ??
              EdgeInsets.only(
                left: 20.w,
                right: 10.w,
                top: 19.r,
                bottom: 18.r,
              ),
          child: child,
        ),
      ),
    ]),
  );
}

Widget reportBlockLabeled(String content, {bool long = false}) {
  return IntrinsicHeight(
    child: Row(children: [
      Column(children: [
        Expanded(
          child: Container(
            width: 2.w,
            decoration: BoxDecoration(
              color: Pantone.green,
            ),
          ),
        ),
      ]),
      SizedBox(width: 6.w),
      Container(
        width: long ? 270.w : 202.w,
        child: Text(
          content,
          style: TextStyle(
            color: Color(0xff7aa19d),
            fontSize: 8.sp,
            fontFamily: "PingFang SC",
            fontWeight: FontWeight.w600,
          ),
        ),
      )
    ]),
  );
}

Widget goMy(BuildContext context) {
  Color textColor =
      Pantone.isDarkMode(context) ? Color(0xffe5a47b) : Color(0xffa87554);
  return Bounceable(
    onTap: () => context.push('/my'),
    child: Container(
      width: 322.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color:
            Pantone.isDarkMode(context) ? Color(0xff5a4938) : Color(0xfffff4de),
        border: Border.all(
            color: Pantone.isDarkMode(context)
                ? Color(0xff7b6234)
                : Color(0x44f5bc61),
            width: 2.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SpacedRow(spaceBetween: 6.r, children: [
            SvgPicture.asset(
              'lib/assets/settings.svg',
              height: 17.r,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
            Text(
              "进入设置界面",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ]),
          SvgPicture.asset(
            'lib/assets/right_arrow.svg',
            height: 17.r,
            colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
          ),
        ],
      ),
    ),
  );
}

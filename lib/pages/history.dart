// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

/// 历史记录页面
class History extends StatefulWidget {
  const History({super.key});

  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> {
  HistoryState();

  final box = GetStorage();

  late DayAt dayAt;
  late RealmResults<TK> tasks;

  DA? theDay;
  int rateSum = 0;
  Standard standard = Standard();
  (double, double) dragPlace = (0, 0);
  List<String> dailyParams = ["-", "-", "-", "-"];
  List<TimeData> dayWorkTimeChartData = [];

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    theDay = ECApp.realm.query<DA>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]).firstOrNull;
    if (theDay == null) {
      theDay = DA(ObjectId(), ECApp.userId(), date: dayAt.day.r);
      ECApp.realm.write(() => ECApp.realm.add(theDay!));
    }
    calcDailyParams();
    calcDaysWorkTimeChart();
    rateSum = 0;
    for (var hour in theDay!.hours) {
      rateSum += hour.rate;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool ifIpad = isIPad(context);
    double dayRate = theDay == null
        ? 3
        : theDay!.hours.isEmpty
            ? 3
            : rateSum / theDay!.hours.length;
    calcDailyParams();
    calcDaysWorkTimeChart();
    return Positioned(
      bottom: 0.h,
      top: 36.h,
      left: 34.w,
      right: 34.w,
      child: GestureDetector(
        onHorizontalDragDown: (detail) {
          dragPlace = (detail.globalPosition.dx, detail.localPosition.dy);
        },
        onHorizontalDragEnd: (detail) => horizontalDragEnd(detail),
        child: SizedBox(
          height: 1.sh - 36.h,
          width: 1.sw - 68.w,
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  rateMean(dayRate, box, context, setState),
                  SizedBox(height: 24.h),
                  daily4Blocks(dailyParams, ifIpad, context),
                  SizedBox(height: 24.h),
                  daysWorkTimeChart(dayWorkTimeChartData, ifIpad, context),
                  SizedBox(height: 24.h),
                  dailyReport(ifIpad, dayRate, tasks, context),
                  SizedBox(height: 24.h),
                  SizedBox(height: 72.h),
                ],
              ),
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
        Get.replace(DayAt(
            Date.fromDateTime(dayAt.day.toDateTime().add(Duration(days: 1)))));
        goReload(context, box, holdUp: false, direction: Side.left);
      } else if (detail.velocity.pixelsPerSecond.dx > 270) {
        // 从左往右
        Get.replace(DayAt(
            Date.fromDateTime(dayAt.day.toDateTime().add(Duration(days: -1)))));
        goReload(context, box, holdUp: false);
      }
    }
  }

  void calcDailyParams() {
    tasks = ECApp.realm.query<TK>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
    // 0 = Available, 1 = Work, 2 = Rest
    // Waiting for the impl. of work-and-rest system
    List<int> leftState = List<int>.filled(1440, 0),
        rightState = List<int>.filled(1440, 0);
    for (var atk in tasks) {
      Task fr = Task.fr(atk);
      if (atk.side == Side.left.name) {
        bool isVisible = true;
        if (atk.name.contains("\$p\$")) {
          isVisible = checkTaskTodayVisible(atk.name, Date.fr(atk.date!).d);
        }
        if (isVisible) {
          for (var i = fr.startTime.comparable;
              i <= fr.endTime.comparable;
              i++) {
            if (fr.isRest) {
              leftState[i] = 2;
            } else {
              leftState[i] = 1;
            }
          }
        }
      } else {
        for (var i = fr.startTime.comparable; i <= fr.endTime.comparable; i++) {
          if (fr.isRest) {
            rightState[i] = 2;
          } else {
            rightState[i] = 1;
          }
        }
      }
    }
    dailyParams[0] = Time.fc(leftState.where((num_) => num_ == 1).length).ss;
    dailyParams[1] = Time.fc(rightState.where((num_) => num_ == 1).length).ss;
    dailyParams[2] = (leftState.where((num_) => num_ == 1).length /
            leftState.where((num_) => num_ == 2).length)
        .toStringAsPrecision(2);
    dailyParams[3] = (rightState.where((num_) => num_ == 1).length /
            rightState.where((num_) => num_ == 2).length)
        .toStringAsPrecision(2);
    if (dailyParams[2] == 'NaN') dailyParams[2] = '-';
    if (dailyParams[3] == 'NaN') dailyParams[3] = '-';
    if (dailyParams[2] == 'Infinity') dailyParams[2] = '-';
    if (dailyParams[3] == 'Infinity') dailyParams[3] = '-';
  }

  void calcDaysWorkTimeChart() {
    dayWorkTimeChartData = [];
    Date day = dayAt.day;
    for (var i = 0; i < 8; i++) {
      var dayTasks = ECApp.realm.query<TK>(
          'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
          [day.year, day.month, day.day]);
      List<int> rightState = List<int>.filled(1440, 0);
      for (var atk in dayTasks) {
        Task fr = Task.fr(atk);
        if (atk.side != Side.left.name) {
          for (var i = fr.startTime.comparable;
              i <= fr.endTime.comparable;
              i++) {
            if (fr.isRest) {
              rightState[i] = 2;
            } else {
              rightState[i] = 1;
            }
          }
        }
      }
      dayWorkTimeChartData.add(TimeData(
          domain: day.toDateTime(),
          measure: Time.fc(rightState.where((num_) => num_ == 1).length)
              .comparable));
      day = Date.fromDateTime(day.toDateTime().add(Duration(days: -1)));
    }
  }
}

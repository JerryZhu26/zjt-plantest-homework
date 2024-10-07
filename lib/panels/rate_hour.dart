// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/ui_widgets.dart';

/// 评价小时
class HourRate extends StatefulWidget {
  const HourRate({super.key});

  @override
  State<HourRate> createState() => HourRateState();
}

class HourRateState extends State<HourRate> {
  late Hour hour;
  late TextEditingController coco;
  late DayAt dayAt;

  int rate = 3, initialRate = 3;
  DA? theDay;

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    hour = Get.find();
    coco = TextEditingController();
    initialRate = hour.rate;
    coco.text = hour.comment;
    theDay = ECApp.realm.query<DA>(
        'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
        [dayAt.day.year, dayAt.day.month, dayAt.day.day]).firstOrNull;
    if (theDay == null) {
      theDay = DA(ObjectId(), ECApp.userId(), date: dayAt.day.r);
      ECApp.realm.write(() => ECApp.realm.add(theDay!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: ModalPage(
        title: '评价 ${hour.which}:00~${hour.which + 1}:00',
        child: Column(children: [
          SizedBox(
            height: 625.h - MediaQuery.of(context).viewInsets.bottom,
            child: ListView(children: [
              ModalFormBox(
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 13.r,
                    ),
                    width: 354.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 339.w,
                              height: 83.h,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "请为这一小时的效率情况打分",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Pantone.greenLineLabel,
                                      fontSize: 15.sp,
                                      fontFamily: "PingFang SC",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  RateBar(
                                    initial: initialRate,
                                    onRate: (int choice) {
                                      rate = choice;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 50.h),
                            Container(
                              width: 354.w,
                              height: 158.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 354.w,
                                    height: 123.h,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "文字评价",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Pantone.greenLineLabel,
                                            fontSize: 15.sp,
                                            fontFamily: "PingFang SC",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Container(
                                          width: 354.w,
                                          height: 87.h,
                                          padding: EdgeInsets.only(top: 4.h),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            color: Pantone.greenInputBg,
                                          ),
                                          child: Input(
                                            placeholder: "请输入对该任务的提醒文字",
                                            teco: coco,
                                            fontSize: 12.sp,
                                            minLine: 3,
                                            maxLine: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
          ),
          Container(
            alignment: Alignment.center,
            child: ModalButton(
              name: '保存',
              onTap: () {
                hour.update(rate, coco.text);
                Get.replace(hour);
                ECApp.realm.write(() {
                  bool flag = false;
                  for (var i = 0; i < theDay!.hours.length; i++) {
                    if (theDay!.hours[i].which == hour.which) {
                      theDay!.hours[i] = hour.r;
                      flag = true;
                    }
                  }
                  if (!flag) {
                    theDay!.hours.add(hour.r);
                  }
                });
                context.pop();
              },
            ),
          )
        ]),
      ),
    );
  }
}

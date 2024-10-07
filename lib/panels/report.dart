// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/parts/general.dart';

/// 历史记录 - 每日报告
class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  DailyReportState createState() => DailyReportState();
}

class DailyReportState extends State<DailyReport> {
  DailyReportState();

  final box = GetStorage();
  late DayAt dayAt;

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: ModalPage(
        title: "每日报告",
        rightSvgs: ['lib/assets/add.svg', 'lib/assets/share.svg'],
        rightSvgTaps: [() {}, () {}],
        child: ListView(children: [
          Container(
            width: 60.w,
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: isDesktop() ? 49.h : 0,
              bottom: 29.h,
            ),
            child: Column(children: [
              ReportBlock(
                title: "英语听力练习",
                time: "08:05 - 08:45",
                rate: 3,
              ),
              ReportBlock(
                title: "背诵六级单词",
                content: "完成情况较好，一个小时不到就完成了任务，继续保持！",
                time: "09:00 - 09:40",
                rate: 5,
              ),
              ReportBlock(
                title: "项目研讨会",
                content: "虽然开始稍晚了十分钟，但效率很高、很有收获的会议！",
                time: "10:35 - 11:20",
                rate: 5,
                moreAsset: ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: Container(
                    padding: EdgeInsets.only(right: 8.w),
                    // child: Image(image: AssetImage('lib/assets/eg_pic.png')),
                  ),
                ),
                moreInfo:
                    "会议要点：\n1、确认了主要的四个界面模块：历史、计划、待办、我的\n2、添加待办任务的两种方式\n3、自然语言识别、语音输入、照片输入、计时器功能\n4、任务重叠问题需要再次思考、优化",
                last: true,
              ),
            ]),
          )
        ]),
      ),
    );
  }
}

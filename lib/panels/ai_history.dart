// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/pages/ai.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

/// 智能助手历史记录
class AiHistory extends StatefulWidget {
  const AiHistory({super.key});

  @override
  State<AiHistory> createState() => AiHistoryState();
}

class AiHistoryState extends State<AiHistory> {
  AiHistoryState();

  final box = GetStorage();
  late RealmResults<AH> ahs;
  late List<Widget> histWidgets;

  @override
  void initState() {
    super.initState();
    ahs = ECApp.realm.all();
    histWidgets = [];
    for (var ah in ahs.toList().reversed) {
      histWidgets.add(
        HistoryContainer(hist: Aihist.fr(ah)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    return Container(
      decoration: BoxDecoration(
        gradient: gradientAi,
      ),
      child: SafeArea(
        child: Stack(children: [
          Positioned(
            left: 20.w,
            top: isMacOS() ? 50.h : 20.h,
            child: Bounceable(
              onTap: () {
                context.pop();
                context.replace('/--reload');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'lib/assets/back-white.svg',
                    height: 20.r,
                  ),
                  SizedBox(width: 18.w),
                  Text(
                    "历史记录",
                    style: TextStyle(fontSize: 18.sp),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 100.h,
            bottom: 0,
            width: 1.sw,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: FadingEdgeScrollView.fromScrollView(
                child: ListView(
                  controller: ScrollController(),
                  children: histWidgets,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class HistoryContainer extends StatefulWidget {
  const HistoryContainer({super.key, required this.hist});

  final Aihist hist;

  @override
  HistoryContainerState createState() => HistoryContainerState();
}

// This is the State class for HistoryContainer.
class HistoryContainerState extends State<HistoryContainer> {
  late Aihist hist;
  bool visible = true;

  @override
  void initState() {
    super.initState();
    hist = widget.hist;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.h),
        child: Bounceable(
          onTap: () {
            Get.replace(hist);
            context.pop();
          },
          child: Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 14.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: Pantone.greyAiExtremeLight!.withOpacity(0.12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadingEdgeScrollView.fromSingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: ScrollController(),
                          child: Container(
                            alignment: Alignment.topCenter,
                            child: Text(
                              hist.name,
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          dateTimeSSWY(hist.createTime),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Bounceable(
                    onTap: () => showCheckSheet("确定删除吗？不可撤销", context, () {
                      visible = false;
                      setState(() {});
                      AH? ah = ECApp.realm
                          .query<AH>('id = \$0', [hist.objectId]).firstOrNull;
                      if (ah != null) {
                        ECApp.realm.write(() => ECApp.realm.delete(ah));
                      }
                    }),
                    child: Opacity(
                      opacity: 0.7,
                      child: SvgPicture.asset(
                        'lib/assets/trash.svg',
                        height: 14.h,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

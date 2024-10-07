// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:timona_ec/libraries/adopt_calendar/adoptive_calendar.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/ui_widgets.dart';

/// 待办信息的查看与添加
class TodoDetail extends StatefulWidget {
  const TodoDetail({super.key, required this.adding});

  final bool adding;

  @override
  State<TodoDetail> createState() => TodoDetailState();
}

class TodoDetailState extends State<TodoDetail> {
  /// Naco for Name, Noco for Notification
  /// Saco for Start Time, Etco for End Time
  /// Reco for Repetition
  late TextEditingController naco, noco, saco, etco, reco;
  late Todo todo;
  late DayAt dayAt;
  TD? td;
  PJ? pj;
  String? sacoError, etcoError, presetSuffix, presetReadable, dateVisible;
  TaskColor? lastColorVal;
  bool? lastRestVal, isPreset;
  bool pickingFile = false, isOk = false;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    if (!widget.adding) {
      todo = Get.find();
      if (todo.objectId == null) {
        td = ECApp.realm.query<TD>('name = \$0 AND project = \$1', [
          todo.name,
          todo.project,
        ]).firstOrNull;
      } else {
        td = ECApp.realm.query<TD>('id = \$0', [todo.objectId]).firstOrNull;
      }
      pj = todo.project;
    } else {
      try {
        todo = Get.find();
      } catch (e) {
        try {
          pj = Get.find<PJ>();
          Get.delete<PJ>();
        } catch (_) {}
        todo = Todo(name: "", project: pj);
      }
    }
    dateVisible = todo.date?.sswy;
    isOk = todo.name.contains('\$ok\$');
    naco = TextEditingController(text: todo.name.split('\$ok\$')[0]);
    noco = TextEditingController(text: todo.comment ?? '');
    saco = TextEditingController(text: (todo.startTime ?? '').toString());
    etco = TextEditingController(text: (todo.endTime ?? '').toString());
    reco = TextEditingController(text: todo.repetition ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: ModalPage(
        title: widget.adding
            ? '新建待办'
            : todo.name != ""
                ? todo.name.split('\$ok\$')[0]
                : "待办详情",
        rightSvg: widget.adding
            ? null
            : td != null
                ? 'lib/assets/piemenu_trash.svg'
                : null,
        rightSvgTap: () {
          showCheckSheet("确定删除 ${todo.name.split('\$ok\$')[0]} 吗？不可撤销", context,
              () {
            ECApp.realm.write(() {
              ECApp.realm.delete<TD>(td!);
            });
            Get.put('delete' as String?, tag: 'status-todo');
            context.pop();
          });
        },
        child: Column(children: [
          SizedBox(
            height: 625.h - MediaQuery.of(context).viewInsets.bottom,
            child: ListView(children: [
              ModalFormBox(
                child: Column(children: [
                  Container(
                    width: 354.w,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTodoFinished(todo.name)
                                ? "任务已完成，完成时间为：${todo.finishTime != null ? dateTimeSSWY(todo.finishTime) : "未记录"}"
                                : "这一任务还未完成",
                            style: TextStyle(
                              color: Pantone.greenSemiLight,
                              fontSize: 13.sp,
                              fontFamily: "PingFang SC",
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            pj != null
                                ? "此待办将属于项目：${pj!.name}"
                                : "此待办将不属于任何项目，位于收集箱",
                            style: TextStyle(
                              color: Pantone.greenSemiLight,
                              fontSize: 13.sp,
                              fontFamily: "PingFang SC",
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "待办名称",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Pantone.greenLineLabel,
                              fontSize: 15.sp,
                              fontFamily: "PingFang SC",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 13.h),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 351.w,
                                height: isMobile() ? 34.5.h : 43.h,
                                child: Container(
                                  width: 351.w,
                                  child: Input(
                                    placeholder: "请输入待办名称",
                                    width: 278.w,
                                    teco: naco,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 38.r,
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "描述文字",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Pantone.greenLineLabel,
                                              fontSize: 15.sp,
                                              fontFamily: "PingFang SC",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 13.h),
                                          Container(
                                            height: 144.h,
                                            padding: EdgeInsets.only(top: 4.h),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                              color: Pantone.greenInputBg,
                                            ),
                                            child: Column(children: [
                                              SizedBox(
                                                width: 354.w,
                                                height: 110.h,
                                                child: Input(
                                                  placeholder: "请输入对该待办的描述文字",
                                                  teco: noco,
                                                  fontSize: 12.sp,
                                                  autoSize: false,
                                                  minLine: 5,
                                                  maxLine: 5,
                                                ),
                                              ),
                                              Container(
                                                width: 354.w,
                                                height: 30.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    bottom:
                                                        Radius.circular(6.r),
                                                  ),
                                                  color:
                                                      Pantone.greenInputBgDark,
                                                ),
                                                padding:
                                                    EdgeInsets.only(left: 20.w),
                                                child: Row(children: [
                                                  Bounceable(
                                                    onTap: () {},
                                                    child: Container(
                                                      width: 16.w,
                                                      height: 16.h,
                                                      child: SvgPicture.asset(
                                                        'lib/assets/pic.svg',
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          Pantone
                                                              .greenTextInput!,
                                                          BlendMode.srcIn,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 40.h),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Text(
                                                    "计划日期",
                                                    style: TextStyle(
                                                      color: Pantone
                                                          .greenLineLabel,
                                                      fontSize: 15.sp,
                                                      fontFamily: "PingFang SC",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  if (todo.date != null)
                                                    Bounceable(
                                                      onTap: () {
                                                        showHud(
                                                          ProgressHudType
                                                              .success,
                                                          '已清除设置的日期',
                                                        );
                                                        todo.date = null;
                                                        dateVisible = null;
                                                        setState(() {});
                                                      },
                                                      child: SvgPicture.asset(
                                                        'lib/assets/trash-bigger.svg',
                                                        height: 14.r,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          Pantone
                                                              .greenLineLabel!,
                                                          BlendMode.srcIn,
                                                        ),
                                                      ),
                                                    ),
                                                ]),
                                                SizedBox(height: 8.h),
                                                Bounceable(
                                                  onTap: () {
                                                    calendarFloatWindow(
                                                      child: AdoptiveCalendar(
                                                        useTime: false,
                                                        iconColor: Pantone
                                                            .greenButtonAlt,
                                                        selectedColor: Pantone
                                                            .greenButtonAlt,
                                                        initialDate:
                                                            (todo.date ??
                                                                    dayAt.day)
                                                                .d,
                                                        minYear: (todo.date ??
                                                                    dayAt.day)
                                                                .d
                                                                .year -
                                                            1,
                                                        maxYear: (todo.date ??
                                                                    dayAt.day)
                                                                .d
                                                                .year +
                                                            1,
                                                        onClick: (dt) {
                                                          if (dt != null) {
                                                            context.pop();
                                                            todo.date = Date
                                                                .fromDateTime(
                                                                    dt);
                                                            dateVisible =
                                                                todo.date?.sswy;
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      context: context,
                                                    );
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: 160.w,
                                                    height: 29.5.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.r),
                                                      color:
                                                          Pantone.greenInputBg,
                                                    ),
                                                    padding: EdgeInsets.only(
                                                      left: 20.w,
                                                      right: 14.w,
                                                      top: 7.h,
                                                      bottom: 7.h,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          dateVisible ?? '未设置',
                                                          style: TextStyle(
                                                            color: Pantone
                                                                .greenTextInput,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        SvgPicture.asset(
                                                          'lib/assets/calendar.svg',
                                                          height: 14.r,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                          SizedBox(width: 34.w),
                                          Container(
                                            width: 160.w,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "定期重复",
                                                  style: TextStyle(
                                                    color:
                                                        Pantone.greenLineLabel,
                                                    fontSize: 15.sp,
                                                    fontFamily: "PingFang SC",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                Container(
                                                  width: 160.w,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .forbidden,
                                                    child: Input(
                                                      placeholder: '无',
                                                      available: false,
                                                      teco: reco,
                                                      width: 100.w,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 40.h),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "开始时间",
                                                  style: TextStyle(
                                                    color:
                                                        Pantone.greenLineLabel,
                                                    fontSize: 15.sp,
                                                    fontFamily: "PingFang SC",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                Container(
                                                  width: 160.w,
                                                  child: Input(
                                                    placeholder: '9:15',
                                                    teco: saco,
                                                    width: 100.w,
                                                    fontSize: 12.sp,
                                                    right: SvgPicture.asset(
                                                      'lib/assets/clock.svg',
                                                      height: 14.r,
                                                    ),
                                                    error: sacoError,
                                                  ),
                                                ),
                                              ]),
                                          SizedBox(width: 34.w),
                                          Container(
                                            width: 160.w,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "结束时间",
                                                  style: TextStyle(
                                                    color:
                                                        Pantone.greenLineLabel,
                                                    fontSize: 15.sp,
                                                    fontFamily: "PingFang SC",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                Container(
                                                  width: 160.w,
                                                  child: Input(
                                                    placeholder: '10:00',
                                                    teco: etco,
                                                    width: 100.w,
                                                    fontSize: 12.sp,
                                                    right: SvgPicture.asset(
                                                      'lib/assets/clock.svg',
                                                      height: 14.r,
                                                    ),
                                                    error: etcoError,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 40.h),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "选择颜色",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Pantone.greenLineLabel,
                                              fontSize: 15.sp,
                                              fontFamily: "PingFang SC",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          SelectiveColorTabs(
                                            todo.taskColor,
                                            (TaskColor? tc) {
                                              todo.taskColor = tc;
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ]),
              ),
            ]),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10.h),
            child: ModalButton(
              name: widget.adding ? '新建' : '确定',
              onTap: () {
                if (!widget.adding) {
                  if (td != null) {
                    Time? sacoTime, etcoTime;
                    if (saco.text != '') {
                      sacoTime = Time.fromString(saco.text);
                    }
                    sacoError = null;
                    try {
                      if (etco.text != '') {
                        etcoTime = Time.fromString(etco.text);
                      }
                      if (sacoTime != null && etcoTime != null) {
                        if (etcoTime < sacoTime || etcoTime == sacoTime) {
                          print(sacoTime);
                          print(etcoTime < sacoTime);
                          etcoError = "输入有误，请检查！";
                          setState(() {});
                          return;
                        }
                      }
                      if (saco.text != '') {
                        ECApp.realm
                            .write(() => td!.startTime = Time.rfs(saco.text));
                      } else {
                        ECApp.realm.write(() => td!.startTime = null);
                      }
                      if (etco.text != '') {
                        ECApp.realm
                            .write(() => td!.endTime = Time.rfs(etco.text));
                      } else {
                        ECApp.realm.write(() => td!.endTime = null);
                      }
                      etcoError = null;
                      setState(() {});
                      ECApp.realm.write(() {
                        td!.comment = noco.text;
                        td!.date = todo.date?.r;
                        td!.color = todo.taskColor?.name;
                        if (isOk) {
                          td!.name = '${naco.text}\$ok\$';
                        } else {
                          td!.name = naco.text;
                        }
                        if (reco.text != '') {
                          td!.repetition = reco.text;
                        } else {
                          td!.repetition = '';
                        }
                      });
                      Get.put('edit' as String?, tag: 'status-todo');
                      Get.put(td, tag: 'edited');
                      context.pop();
                    } catch (e) {
                      sacoError = "输入有误，请检查！";
                      setState(() {});
                    }
                  } else {
                    showHud(ProgressHudType.error, '待办不存在，请检查');
                  }
                } else {
                  Time? sacoTime, etcoTime;
                  try {
                    if (saco.text != '') {
                      sacoTime = Time.fromString(saco.text);
                    }
                    sacoError = null;
                    try {
                      if (etco.text != '') {
                        etcoTime = Time.fromString(etco.text);
                      }
                      if (sacoTime != null && etcoTime != null) {
                        if (etcoTime < sacoTime || etcoTime == sacoTime) {
                          etcoError = "输入有误，请检查！";
                          setState(() {});
                          return;
                        }
                      }
                      etcoError = null;
                      setState(() {});
                      todo = Todo(
                        name: naco.text,
                        date: todo.date,
                        startTime: sacoTime,
                        endTime: etcoTime,
                        comment: noco.text,
                        project: todo.project,
                        taskColor: todo.taskColor,
                      );
                      ECApp.realm.write(() => ECApp.realm.add(todo.r));
                      Get.replace(todo.r);
                      context.pop();
                    } catch (e) {
                      etcoError = "输入有误，请检查！";
                      setState(() {});
                    }
                  } catch (e) {
                    sacoError = "输入有误，请检查！";
                    setState(() {});
                  }
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}

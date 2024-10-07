// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/ui_widgets.dart';
import 'package:tinycolor2/tinycolor2.dart';

/// 任务信息的查看与添加
class Detail extends StatefulWidget {
  const Detail({super.key, required this.adding});

  final bool adding;

  @override
  State<Detail> createState() => DetailState();
}

class DetailState extends State<Detail> {
  /// Naco for Name, Noco for Notification
  /// Saco for Start Time, Etco for End Time
  late TextEditingController naco, noco, saco, etco;
  late Task task;
  late DayAt dayAt;
  TK? tk;
  String? sacoError, etcoError, presetSuffix, presetReadable;
  TaskColor? lastColorVal;
  bool? lastRestVal, isPreset;
  bool pickingFile = false;

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    if (!widget.adding) {
      task = Get.find();
      tk = ECApp.realm.query<TK>(
          'date.year = \$0 AND date.month = \$1 AND date.day = \$2 AND name = \$3 '
          'AND startTime.hour = \$4 AND startTime.minute = \$5 AND side = \$6',
          [
            dayAt.day.year,
            dayAt.day.month,
            dayAt.day.day,
            task.name,
            task.startTime.hour,
            task.startTime.minute,
            task.side.name,
          ]).firstOrNull;
      if (task.name.contains("\$p\$")) {
        isPreset = true;
        List checked = checkPresetString(task.name, DateTime.now());
        presetSuffix = task.name.split("\$p\$")[1];
        task.name = task.name.split("\$p\$")[0];
        if (checked.isNotEmpty) {
          presetReadable =
              "${Date.fromDateTime(checked[2]).ss} ~ ${Date.fromDateTime(checked[3]).ss} (每${checked[0] != 1 ? checked[0] : ""}${checked[1]}) "
              "${Time.fromComparable(task.startTime.comparable)} ~ ${Time.fromComparable(task.endTime.comparable)}";
        } else {
          presetReadable = "预设任务";
        }
      }
    } else {
      try {
        task = Get.find();
      } catch (e) {
        task = Task(
          name: '',
          date: dayAt.day,
          startTime: Time.fromDateTime(DateTime.now()),
          endTime: Time.fromDateTime(DateTime.now().add(Duration(hours: 1))),
          side: Side.left,
        );
      }
    }
    naco = TextEditingController(text: task.name);
    noco = TextEditingController(text: task.comment ?? '');
    saco = TextEditingController(text: task.startTime.toString());
    etco = TextEditingController(text: task.endTime.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: ModalPage(
        title: widget.adding
            ? '新建任务'
            : task.name != ""
                ? task.name
                : "任务详情",
        rightSvg: widget.adding
            ? null
            : tk != null
                ? 'lib/assets/piemenu_trash.svg'
                : null,
        rightSvgTap: () {
          showCheckSheet("确定删除 ${task.name} 吗？不可撤销", context, () {
            ECApp.realm.write(() {
              ECApp.realm.delete<TK>(tk!);
            });
            Get.put('delete', tag: 'status');
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
                          if (isPreset ?? false)
                            Text(
                              "预设任务：${presetReadable!}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Pantone.greenSemiLight,
                                fontSize: 12.sp,
                                fontFamily: "PingFang SC",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (isPreset ?? false) SizedBox(height: 6.h),
                          if (task.flag == 'from-timer')
                            Text(
                              "从计时任务新建任务：请注意，此功能暂不处理暂停，如需记录暂停情况，请手动新建任务记录。",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Pantone.greenSemiLight,
                                fontSize: 12.sp,
                                fontFamily: "PingFang SC",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (task.flag == 'from-timer') SizedBox(height: 6.h),
                          Text(
                            "任务名称",
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (task.tag != null)
                                      GestureDetector(
                                        onTap: () {
                                          task.tag = null;
                                          if (lastColorVal != null) {
                                            task.taskColor = lastColorVal!;
                                          }
                                          if (lastRestVal != null) {
                                            task.isRest = lastRestVal!;
                                          }
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: 73.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                            color: taskColors[(
                                              TaskColor.values.byName(box.read(
                                                      "tagColor${task.tag}") ??
                                                  "green"),
                                              Pantone.isDarkMode(context)
                                            )]!
                                                .bgColor
                                                .tint(20),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 2.h,
                                          ),
                                          child: Text(
                                            task.tag!,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: Pantone.isDarkMode(context)
                                                  ? Pantone.black
                                                  : Pantone.greenTagDeep,
                                              fontSize: 13.5.sp,
                                              fontFamily: "PingFang SC",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (task.tag != null) SizedBox(width: 7.w),
                                    Container(
                                      width: task.tag == null ? 351.w : 271.w,
                                      child: Input(
                                        placeholder: "请输入任务名称",
                                        width: task.tag == null ? 278.w : 218.w,
                                        teco: naco,
                                        tag: task.tag,
                                        right: SvgPicture.asset(
                                          'lib/assets/add_start.svg',
                                          height: 24.r,
                                          colorFilter: ColorFilter.mode(
                                            Pantone.greenRightButton!,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14.h),
                              tags(box, context, setState, (name) {
                                task.tag = name;
                                if (box.hasData("tagColor$name")) {
                                  lastColorVal = task.taskColor;
                                  task.taskColor = TaskColor.values.byName(
                                      box.read("tagColor$name") ?? "green");
                                } else {
                                  if (lastColorVal != null) {
                                    task.taskColor = lastColorVal!;
                                  }
                                }
                                if (box.hasData("tagRest$name")) {
                                  lastRestVal = task.isRest;
                                  task.isRest =
                                      box.read("tagRest$name") ?? false;
                                } else {
                                  if (lastRestVal != null) {
                                    task.isRest = lastRestVal!;
                                  }
                                }
                                setState(() {});
                              }),
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
                                            "提醒文字",
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
                                                  placeholder: "请输入对该任务的提醒文字",
                                                  teco: noco,
                                                  tag: task.tag,
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
                                                    onTap: () => selectPic(),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "工作休息",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Pantone.greenLineLabel,
                                              fontSize: 15.sp,
                                              fontFamily: "PingFang SC",
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 20.w),
                                          workRest(task.isRest, (val) {
                                            task.isRest = val;
                                            setState(() {});
                                          }),
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
                                          ColorTabs(
                                            task.taskColor,
                                            (TaskColor tc) {
                                              task.taskColor = tc;
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
                  if (tk != null) {
                    try {
                      ECApp.realm
                          .write(() => tk!.startTime = Time.rfs(saco.text));
                      sacoError = null;
                      try {
                        if (Time.fromString(etco.text) >
                            Time.fromString(saco.text)) {
                          ECApp.realm
                              .write(() => tk!.endTime = Time.rfs(etco.text));
                          etcoError = null;
                          String newName = naco.text;
                          if (isPreset ?? false) {
                            newName = "$newName\$p\$${presetSuffix!}";
                          }
                          ECApp.realm.write(() {
                            tk!.name = newName;
                            tk!.comment = noco.text;
                            tk!.color = task.taskColor.name;
                            tk!.tag = task.tag;
                            tk!.isRest = task.isRest;
                          });
                          Get.put('edit', tag: 'status');
                          Get.put(tk, tag: 'edited');
                          context.pop();
                        } else {
                          etcoError = "输入有误，请检查！";
                          setState(() {});
                        }
                      } catch (e) {
                        etcoError = "输入有误，请检查！";
                        setState(() {});
                      }
                    } catch (e) {
                      sacoError = "输入有误，请检查！";
                      setState(() {});
                    }
                  } else {
                    showHud(ProgressHudType.error, '任务不存在，请检查');
                  }
                } else {
                  late Time sacoTime, etcoTime;
                  try {
                    sacoTime = Time.fromString(saco.text);
                    sacoError = null;
                    try {
                      etcoTime = Time.fromString(etco.text);
                      if (etcoTime > sacoTime) {
                        etcoError = null;
                        task = Task(
                          name: naco.text,
                          date: task.date,
                          startTime: sacoTime,
                          endTime: etcoTime,
                          side: task.side,
                          comment: noco.text,
                          taskColor: task.taskColor,
                          tag: task.tag,
                          isRest: task.isRest,
                        );
                        ECApp.realm.write(() => ECApp.realm.add(task.r));
                        Get.replace(task.r);
                        context.pop();
                      } else {
                        etcoError = "输入有误，请检查！";
                        setState(() {});
                      }
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

  void selectPic() {
    if (isMobile()) {
      showChooseSheet("请选择添加图片的方式", "拍摄新照片", "从相册选择图片", context,
          (int val) async {
        if (val == 2) {
          pickPic();
        } else {
          await context.push("/camera/--from-task");
        }
      });
    } else {
      pickPic();
    }
  }

  Future<void> pickPic() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    print(appDocumentsDir.path);
    FilePickerResult? result;
    if (!pickingFile) {
      pickingFile = true;
      if (isMobile()) {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 PNG 或 JPG 图片",
          type: FileType.image,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 PNG 或 JPG 图片",
          type: FileType.custom,
          allowedExtensions: ["jpg", "png", "jpeg"],
        );
      }
    } else {
      showHud(ProgressHudType.error, "请勿重复打开");
      return;
    }
    if (result != null) {
      File file = File(result.files.single.path!);
      if (file.path.contains(".png") ||
          file.path.contains(".jpg") ||
          file.path.contains(".jpeg")) {
        Directory pathDoc = await getApplicationDocumentsDirectory();
        try {
          int milliseconds = DateTime.now().millisecondsSinceEpoch;
          String newPath =
              '${pathDoc.path}/$milliseconds-${path.basenameWithoutExtension(file.path).substring(0, 6)}.${path.extension(file.path)}';
          File newFile = await file.copy(newPath);
          print(newFile);
          print(newPath);
        } catch (e) {
          print(e);
          showHud(ProgressHudType.error, "我们无法处理您选择的文件，请稍候再试");
        }
      } else {
        showHud(ProgressHudType.error, "请选择 PNG 或 JPG 图片");
      }
    } else {
      showHud(ProgressHudType.error, "未选择文件");
    }
    pickingFile = false;
  }
}

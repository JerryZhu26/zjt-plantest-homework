// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:tinycolor2/tinycolor2.dart';

part 'package:timona_ec/parts/my_preset.dart';

part 'package:timona_ec/parts/my_general.dart';

enum PageAt { main, tags, classtable, import, export, debug }

/// 个人中心页面
class My extends StatefulWidget {
  const My({super.key});

  @override
  State<My> createState() => MyState();
}

class MyState extends State<My> {
  MyState();

  final box = GetStorage();
  final MethodChannel channel = MethodChannel('scris.plnm/alarm');
  late PageAt pageAt;
  String version = "";

  @override
  void initState() {
    super.initState();
    pageAt = PageAt.main;
  }

  @override
  Widget build(BuildContext context) {
    var topLine = isDesktop()
        ? 100.h
        : isIOS()
            ? 36.h
            : 50.h;
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        if (Platform.isAndroid) {
          var verNo = version.split("-")[0];
          var buildNo = version.split("-")[1];
          var dateNo = version.split("-")[2];
          version =
              "$verNo, build ${buildNo.split(".")[1]} (${dateNo.split(".")[1]})";
        }
      });
    });
    return WillPopScope(
      onWillPop: () async {
        if (pageAt != PageAt.main) {
          pageAt = PageAt.main;
          setState(() {});
          return false;
        }
        return true;
      },
      child: ProgressHud(
        isGlobalHud: true,
        child: Container(
          color: Pantone.green,
          child: Stack(children: [
            Background(),
            Positioned(
              left: 0.w,
              right: 0.w,
              bottom: 0.h,
              child: Container(
                color: Pantone.greenMyBg,
                height: isDesktop() ? 670.h : 686.h,
              ),
            ),
            Positioned(
              top: topLine + 56.h,
              bottom: 0,
              left: 0.08.sw,
              right: 0.08.sw,
              child: ListView(
                  children: pageAt == PageAt.main
                      ? [
                          block("用户", [
                            (
                              "元素会员",
                              () {
                                showHud(ProgressHudType.error, '会员系统暂未开放');
                              }
                            ),
                            (
                              "桌面端计时伴侣：${(box.read('useCompanion') ?? false) ? '是' : '否'}",
                              () {
                                showCheckSheet(
                                  "桌面端计时伴侣可供您在 Windows 或 macOS 端查看计时情况。确认${(box.read('useCompanion') ?? false) ? '关闭' : '开启'}？",
                                  context,
                                  () async {
                                    if (box.read('useCompanion') ?? false) {
                                      box.write('useCompanion', false);
                                      showHud(
                                          ProgressHudType.success, '计时伴侣关闭成功');
                                      setState(() {});
                                    } else {
                                      box.write('useCompanion', true);
                                      setState(() {});
                                      await showChooseSheet(
                                        "您是否要访问下载桌面端计时伴侣的网址？",
                                        "从蓝奏云下载",
                                        "从GitHub下载",
                                        context,
                                        (i) {
                                          if (i == 1) {
                                            openUrl(
                                              'https://scris.lanzoul.com/b0plkgkbe',
                                            );
                                          } else {
                                            openUrl(
                                              'https://github.com/scris/plannium-release/releases/',
                                            );
                                          }
                                        },
                                        cancel: "不需要",
                                      );
                                      showHud(
                                          ProgressHudType.success, '计时伴侣开启成功');
                                    }
                                  },
                                );
                              }
                            ),
                          ]),
                          block("界面", [
                            (
                              "一天从哪里开始",
                              () async {
                                final result = await showTextInputDialog(
                                  context: context,
                                  title: "请输入一天开始的位置",
                                  message: "请输入数字，比如7。设置后，更早的时间将被隐藏",
                                  textFields: [
                                    DialogTextField(
                                      initialText: (box.read("startHour") ?? 6)
                                          .toString(),
                                    )
                                  ],
                                );
                                if (result != null) {
                                  if (int.tryParse(result[0]) != null) {
                                    box.write(
                                        "startHour", int.tryParse(result[0]));
                                    setState(() {});
                                    showHud(ProgressHudType.success, "设置成功");
                                  } else {
                                    showHud(ProgressHudType.error, "输入不正确");
                                  }
                                } else {
                                  showHud(ProgressHudType.error, "输入不正确");
                                }
                              }
                            ),
                            (
                              "标签设置",
                              () {
                                pageAt = PageAt.tags;
                                setState(() {});
                              }
                            ),
                            if (Platform.isAndroid)
                              (
                                "计时悬浮窗",
                                () {
                                  showChooseSheet(
                                      "请选择是否开启计时悬浮窗", "开启", "关闭", context,
                                      (int select) {
                                    if (select == 1) {
                                      showCheckSheet("如未开启，需开启悬浮窗权限", context,
                                          () {
                                        box.write("useTimingOverlay", true);
                                        showOverlay(DateTime.now(), false,
                                                '\$init\$', channel, box)
                                            .then((value) =>
                                                hideOverlay(channel, box));
                                        setState(() {});
                                      });
                                    } else {
                                      if (box.read("useTimingOverlay") ??
                                          false) {
                                        hideOverlay(channel, box);
                                      }
                                      box.write("useTimingOverlay", false);
                                      setState(() {});
                                    }
                                  });
                                }
                              )
                          ]),
                          block("更多", [
                            (
                              "预设任务与课表",
                              () {
                                pageAt = PageAt.classtable;
                                setState(() {});
                              }
                            ),
                            (
                              "现有数据导出",
                              () {
                                pageAt = PageAt.export;
                                setState(() {});
                              }
                            ),
                            (
                              "历史数据导入",
                              () {
                                pageAt = PageAt.import;
                                setState(() {});
                              }
                            ),
                            (
                              "查看调试信息",
                              () {
                                pageAt = PageAt.debug;
                                setState(() {});
                              }
                            ),
                          ]),
                          Container(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Text(
                              "版本号：$version\n本安装包是用于测试的，不是正式发布的版本",
                              style: TextStyle(
                                color: Pantone.greenLight,
                                fontSize: 14.5.sp,
                                fontFamily: "PingFang SC",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ]
                      : [
                          if (pageAt == PageAt.tags) TagsSettings(blockBase),
                          if (pageAt == PageAt.classtable)
                            ClassTableSettings(block, row, blockBase, rowBase,
                                rowBase2Buttons),
                          if (pageAt == PageAt.export)
                            ExportSettings(block, blockBase, rowBase),
                          if (pageAt == PageAt.import)
                            ImportSettings(block, blockBase, rowBase),
                          if (pageAt == PageAt.debug)
                            DebugInfoSettings(blockBase, rowBase),
                        ]),
            ),
            Positioned(
              top: topLine + (isIOS() ? 45.h : 0),
              left: pageAt != PageAt.main ? 0.08.sw + 4.w : 0.08.sw + 8.w,
              right: 0.08.sw,
              child: Row(children: [
                if (pageAt != PageAt.main)
                  Padding(
                    padding: EdgeInsets.only(right: 14.w, top: 3.h),
                    child: Bounceable(
                      onTap: () {
                        pageAt = PageAt.main;
                        setState(() {});
                      },
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
                  ),
                Text(
                  getPageTitle(pageAt),
                  style: TextStyle(
                    color: Pantone.greenTagDark,
                    fontSize: 31.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      BoxShadow(
                        blurRadius: 15.r,
                        offset: Offset(0, 4.h),
                        color: Pantone.greenTimerShadow!,
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget blockBase(Widget widget, {String? top, String? bottom}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 353.w,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 20.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: Pantone.greenShadow!,
              blurRadius: 8.r,
              offset: Offset(0.w, 5.h),
            ),
          ],
          color: Pantone.greenMyBlockBg,
        ),
        child: widget,
      ),
      if (bottom != null)
        Padding(
          padding: EdgeInsets.only(top: 8.h, left: 8.w),
          child: Text(
            bottom,
            style: TextStyle(
              color: Pantone.isDarkMode(context)
                  ? Pantone.greenTagDark
                  : Pantone.green!.withOpacity(0.7),
              fontSize: 11.sp,
              fontFamily: "PingFang SC",
            ),
          ),
        ),
      SizedBox(height: 26.h),
    ]);
  }

  String getPageTitle(PageAt pageAt) {
    switch (pageAt) {
      case PageAt.main:
        return "设置";
      case PageAt.tags:
        return "标签设置";
      case PageAt.classtable:
        return "预设与课表";
      case PageAt.import:
        return "导入";
      case PageAt.export:
        return "导出";
      default:
        return "设置";
    }
  }

  Widget block(String name, List<(String, Function)> names, {String? bottom}) {
    List<Widget> rows = [];
    for (var tmp in names) {
      rows.add(row(tmp.$1, tmp.$2));
      rows.add(SizedBox(height: 19.h));
    }
    rows.removeLast();
    return blockBase(
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rows,
      ),
      top: name,
      bottom: bottom,
    );
  }

  Widget rowBase(String name, Function onTap, Widget right) {
    return Bounceable(
      onTap: () => onTap(),
      duration: 55.ms,
      reverseDuration: 55.ms,
      child: Container(
        width: 302.w,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 295.w),
              child: Text(
                name,
                style: TextStyle(
                  color: Pantone.greenPresetName,
                  fontSize: 14.5.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            right,
          ],
        ),
      ),
    );
  }

  Widget rowBase2Buttons(
    String name,
    Function onTap1,
    Widget right1,
    Function onTap2,
    Widget right2,
  ) {
    return Container(
      width: 302.w,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Pantone.greenPresetName,
              fontSize: 14.5.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(children: [
            Bounceable(
              onTap: () => onTap1(),
              duration: 55.ms,
              reverseDuration: 55.ms,
              child: right1,
            ),
            Container(width: 6.w),
            Bounceable(
              onTap: () => onTap2(),
              duration: 55.ms,
              reverseDuration: 55.ms,
              child: right2,
            ),
          ])
        ],
      ),
    );
  }

  Widget row(String name, Function onTap) {
    return rowBase(name, onTap, rightArrow());
  }
}

/// 标签设置模块
class TagsSettings extends StatefulWidget {
  const TagsSettings(this.blockBase, {super.key});

  final Function blockBase;

  @override
  State<TagsSettings> createState() => TagsSettingsState();
}

class TagsSettingsState extends State<TagsSettings> {
  TagsSettingsState();

  final box = GetStorage();
  String? selectedTag;
  late List<String> tagsList;
  TaskColor? taskColor;
  bool? isRest;

  @override
  void initState() {
    super.initState();
    tagsList = (box.read("tags") ?? []).cast<String>();
    if (tagsList.isNotEmpty) {
      selectedTag = tagsList[0];
      taskColor = TaskColor.values
          .byName(box.read("tagColor${selectedTag!}") ?? "green");
      isRest = box.read("tagRest${selectedTag!}") ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.blockBase(
        tags(box, context, setState, (name) {
          selectedTag = name;
          taskColor = TaskColor.values
              .byName(box.read("tagColor${selectedTag!}") ?? "green");
          isRest = box.read("tagRest${selectedTag!}") ?? false;
          setState(() {});
        }),
        bottom: tagsList.isEmpty ? "在此处设置标签所附带的默认工作休息状态与颜色" : null,
      ),
      if (selectedTag != null)
        widget.blockBase(
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 1.sw - 162.sp,
                    height: 40.sp,
                    child: Text(
                      selectedTag!.replaceFirst("#", ""),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                        color: taskColors[(
                          taskColor,
                          Pantone.isDarkMode(context)
                        )]!
                            .commentLeftColor
                            .saturate(5)
                            .darken(10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showCheckSheet(
                        "确定撤销设置吗？所选标签将不再附带默认的工作休息状态与颜色设置",
                        context,
                        () {
                          box.remove("tagColor${selectedTag!}");
                          box.remove("tagRest${selectedTag!}");
                          taskColor = TaskColor.green;
                          isRest = false;
                          setState(() {});
                        },
                      );
                    },
                    child: Text(
                      "撤销设置",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Pantone.redAccent!.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  workRest(isRest ?? false, (val) {
                    isRest = val;
                    box.write("tagRest${selectedTag!}", isRest);
                    setState(() {});
                  }),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    taskColor ?? TaskColor.green,
                    (TaskColor tc) {
                      taskColor = tc;
                      box.write("tagColor${selectedTag!}", tc.name);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ]),
            bottom: "在此处设置标签所附带的默认工作休息状态与颜色"),
    ]);
  }
}

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/parts/ai_providers.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:tinycolor2/tinycolor2.dart';

String openaiConclusion(double dayRate, RealmResults<TK> tasks) {
  String gotStr(TK task) {
    if (task.startTime != null && task.endTime != null) {
      if (task.tag != null) {
        if (task.name != '') {
          return "${task.tag} ${task.name.split('\$p\$')[0]}: ${Time.fr(task.startTime!).ss}~${Time.fr(task.endTime!).ss}; ";
        } else {
          return "${task.tag}: ${Time.fr(task.startTime!).ss}~${Time.fr(task.endTime!).ss}; ";
        }
      } else {
        if (task.name != '') {
          return "${task.name.split('\$p\$')[0]}: ${Time.fr(task.startTime!).ss}~${Time.fr(task.endTime!).ss}; ";
        } else {
          return "未命名任务: ${Time.fr(task.startTime!).ss}~${Time.fr(task.endTime!).ss}; ";
        }
      }
    } else {
      if (task.tag != null) {
        if (task.name != '') {
          return "${task.tag} ${task.name.split('\$p\$')[0]}; ";
        } else {
          return "${task.tag}; ";
        }
      } else {
        if (task.name != '') {
          return "${task.name.split('\$p\$')[0]}; ";
        } else {
          return "未命名任务; ";
        }
      }
    }
  }

  String planInStr = '', realInStr = '';
  for (var task in tasks) {
    bool isVisiblePreset = true;
    if (task.name.contains("\$p\$") && task.date != null) {
      isVisiblePreset = checkTaskTodayVisible(task.name, Date.fr(task.date!).d);
    }
    if (task.side == Side.left.name) {
      if (isVisiblePreset) {
        planInStr += gotStr(task);
      }
    } else {
      realInStr += gotStr(task);
    }
  }
  if (planInStr == '') planInStr = '无';
  if (realInStr == '') realInStr = '无';

  return '接下来会提出“计划情况”与“实际情况”，每一块按时间顺序来，格式为“名称: 开始时间~结束时间;”。\n\n'
      '计划情况：\n$planInStr\n\n实际情况：\n$realInStr\n\n日常平均3分，今日${dayRate.toPrecision(1)}分。\n\n'
      '第一段，概括我计划做什么，100字。\n第二段，概括我实际做了什么，150字，可以详细，不要事无巨细，不要对比计划与实际。';
}

class Conclusion extends StatefulWidget {
  const Conclusion({super.key, required this.dayRate, required this.tasks});

  final double dayRate;
  final RealmResults<TK> tasks;

  @override
  ConclusionState createState() => ConclusionState();
}

class ConclusionState extends State<Conclusion> {
  ConclusionState();

  final box = GetStorage();
  late DayAt dayAt;
  late bool aiGenerated, aiGenerating;
  String aiContent = '';

  @override
  void initState() {
    super.initState();
    dayAt = Get.find();
    aiGenerated = box.read('aiConclusionGot${dayAt.day}') ?? false;
    aiContent = box.read('aiConclusion${dayAt.day}') ?? '';
    aiGenerating = false;
  }

  Future<void> generateConclusion() async {
    if (!aiGenerating) {
      aiGenerating = true;
      showHudNoDismissC(ProgressHudType.loading, "正在处理...", context);
      try {
        String prompt = openaiConclusion(widget.dayRate, widget.tasks);
        print(prompt);
        aiContent = await gpt(prompt);
        dismissHud();
        await showHudC(ProgressHudType.success, "生成成功！", context);
        aiGenerated = true;
        aiGenerating = false;
        box.write('aiConclusionGot${dayAt.day}', true);
        box.write('aiConclusion${dayAt.day}', aiContent);
        setState(() {});
      } on RequestFailedException catch (_) {
        dismissHud();
        showHudC(ProgressHudType.error, "服务器状态异常，请联系开发者", context);
      } catch (e) {
        dismissHud();
        showHudC(ProgressHudType.error, "未知错误：$e", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Pantone.isDarkMode(context)
        ? Color(0xFF69A9E1)
        : Color(0xFF275276).lighten(15).saturate(7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "智能总结",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Row(children: [
              Visibility(
                visible: aiGenerated,
                child: Bounceable(
                  onTap: () => showCheckSheet("是否确认删除？", context, () {
                    aiGenerated = false;
                    setState(() {});
                  }),
                  child: Row(children: [
                    SvgPicture.asset(
                      'lib/assets/trash-bigger.svg',
                      height: 17.r,
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                    Text(
                      " 删除 ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ]),
                ),
              ),
              Bounceable(
                onTap: () => generateConclusion(),
                child: Row(children: [
                  SvgPicture.asset(
                    aiGenerated ? 'lib/assets/redo.svg' : 'lib/assets/send.svg',
                    height: 17.r,
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  ),
                  Text(
                    " 生成",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ]),
              )
            ]),
          ],
        ),
        SizedBox(height: 6.h),
        if (!aiGenerated)
          Text(
            "使用大语言模型赋能的“智能总结”功能，快速回顾您一天的计划与实际工作情况。",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Pantone.isDarkMode(context)
                  ? textColor.lighten(5).saturate(5)
                  : textColor.lighten(20),
            ),
          )
        else
          MarkdownBody(
            data: aiContent,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Pantone.isDarkMode(context)
                    ? textColor.lighten(5).saturate(5)
                    : textColor.lighten(20),
              ),
            ),
          ),
      ],
    );
  }
}

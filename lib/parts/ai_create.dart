// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/env.g.dart';
import 'package:timona_ec/libraries/asr_plugin/asr_lib.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/libraries/siri_wave/siri_wave.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/ai_providers.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';

Future<void> nlpSubmit(String val, TextEditingController teco, GetStorage box,
    Function onTap, BuildContext context, Realm realm, DateTime now,
    {bool noTeco = false}) async {
  Navigator.of(context).pop();
  if (teco.text != "" || noTeco) {
    String input = val;
    showHudNoDismissC(ProgressHudType.loading, "正在处理...", context);
    (bool, String) output = await nlpInput(input, now);
    if (output.$1 == true) {
      onTap();
      teco.clear();
      List<String> result =
          output.$2.replaceFirst('[', '').replaceFirst(']', '').split(',');
      print(result);
      try {
        Time start = Time.fromShortString(result[0]);
        Time end = Time.fromShortString(result[1]);
        if (end.toComparable() < start.toComparable() && end.hour <= 11) {
          end.hour += 12;
        }
        print(start);
        print(end);
        Task task = Task(
          name: result[3].trim(),
          date: Date.fromNoYearShortString(result[2]),
          startTime: start,
          endTime: end,
          side: Side.left,
        );
        realm.write(() => realm.add(task.r));
        dismissHud();
        await showHudC(ProgressHudType.success, "添加成功！", context);
        context.replace('/--reload');
      } catch (e) {
        print(e);
        dismissHud();
        showHudC(ProgressHudType.error, "添加有误，请重试", context);
      }
    } else {
      if (output.$2 != "\$OFE\$") {
        dismissHud();
        showHudC(ProgressHudType.error, "服务器状态异常，请联系开发者", context);
      } else {
        dismissHud();
        showHudC(ProgressHudType.error, "您的输入不完整", context);
      }
    }
  } else {
    dismissHud();
    showHudC(ProgressHudType.error, "输入不能为空", context);
  }
  teco.clear();
}

Future<(bool, String)> nlpInput(String input, DateTime now) async {
  DateTime tomorrow = now.add(const Duration(days: 1));

  try {
    RegExp exp = RegExp(r"[\u4e00-\u9fa5]");
    bool noChinese = false;
    if (!exp.hasMatch(input)) noChinese = true;
    String content = await gpt(
        "现在是${now.month}月${now.day}日${now.hour}时${now.minute}分。按格式提取日期等信息\n"
        "回答第三部分为M.dd格式的日期${noChinese ? "，内容不含中文字符" : ""}。回答分四个非空部分，详见示例\n"
        "Input: 明天下午的0:30～1:20我打算去钓鱼\nOutput: “12:30|13:20|${tomorrow.month}.${tomorrow.day}|钓鱼”\n"
        "Input: sleep from 11 to 3\nOutput: “11:00|15:00|${now.month}.${now.day}|Sleep”\n"
        "Input: $input\nOutput: ");
    print(content);
    content.replaceAll('现在', '${now.hour}:${now.minute}');
    content.replaceAll('now', '${now.hour}:${now.minute}');
    List splitted = content.contains('“')
        ? content.split('“')[1].split('”')[0].split('|')
        : content.contains('"')
            ? content.split('"')[1].split('|')
            : content.split('|');
    RegExp timeExp = RegExp(r"[0-9]+\.[0-9]+");
    if (splitted.length == 4) {
      if (!timeExp.hasMatch(splitted[2])) {
        splitted[2] = "${now.month}.${now.day}";
      }
      return (true, splitted.toString());
    } else {
      return (false, "\$OFE\$");
    }
  } on RequestFailedException catch (e) {
    print(e.message);
    print(e.statusCode);
    return (false, e.message);
  } catch (e) {
    print(e);
    return (false, e.toString());
  }
}

class VoiceWidget extends StatefulWidget {
  const VoiceWidget({super.key, required this.fatherContext});

  final BuildContext fatherContext;

  @override
  State<VoiceWidget> createState() => VoiceWidgetState();
}

class VoiceWidgetState extends State<VoiceWidget> {
  String generated = "等待生成 ...";
  TextEditingController teco = TextEditingController();
  IOS9SiriWaveformController sico = IOS9SiriWaveformController(
    amplitude: 0.0000001,
    speed: 0.15,
  );
  bool listening = false, asrGot = false;
  String asrResult = '', asrRes = '';
  ASRController? asrc;
  Stream<ASRData>? asrStream;
  AudioPlayer player = AudioPlayer();

  late (bool, String) result;
  late DayAt dayAt;
  final box = GetStorage();

  void cacheSound(String source) async {
    await player.setAsset('lib/assets/$source');
  }

  void playSound(String source) async {
    await player.setAsset('lib/assets/$source');
    player.play();
  }

  @override
  void initState() {
    super.initState();
    buildASRController();
    cacheSound('dingdong_ding.mp3');
  }

  @override
  void dispose() {
    if (asrc != null) asrc!.release();
    super.dispose();
  }

  Future<void> buildASRController() async {
    dayAt = Get.find();
    if (Platform.isAndroid || Platform.isIOS) {
      asrc = await ASRControllerConfig(
        appID: Env.asrAppId,
        projectID: Env.asrProjId,
        secretID: Env.asrSecretId,
        secretKey: Env.asrSecretKey,
      ).build();
    }
  }

  Future<void> asrStart() async {
    if (asrc != null) {
      if (!listening) {
        playSound('dingdong_ding.mp3');
        listening = true;
        asrGot = false;
        asrStream = asrc!.recognize();
        await for (final ASRData data in asrStream!) {
          if (data.type == ASRDataType.SUCCESS) {
            asrResult = data.result ?? '';
            listening = false;
            sico.amplitude = 0.0000001;
            asrNLP(asrResult);
          } else {
            print(data);
            asrGot = true;
            asrRes = data.res ?? '';
          }
          setState(() {});
        }
      } else {
        playSound('dingdong_dong.mp3');
        asrc!.stop();
        sico.amplitude = 0.0000001;
        asrStream = null;
        listening = false;
        setState(() {});
      }
    }
  }

  void asrNLP(String val) {
    nlpSubmit(
        val, teco, box, () {}, widget.fatherContext, ECApp.realm, dayAt.day.d,
        noTeco: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(
            top: -10.h,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                sico.amplitude = 1;
                setState(() {});
                asrStart();
              },
              child: SiriWaveform.ios9(
                controller: sico,
                options: IOS9SiriWaveformOptions(
                  height: 140.h,
                  width: 1.sw - 40.w,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0.h,
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Text(
                listening
                    ? asrRes
                    : asrGot
                        ? asrResult
                        : '点击开始语音识别',
                style: TextStyle(
                  color: Pantone.grey,
                  fontSize: 12.sp,
                  fontFamily: "PingFang SC",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
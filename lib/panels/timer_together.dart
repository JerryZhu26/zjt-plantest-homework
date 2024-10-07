// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:random_string/random_string.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/pages/timer.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/ui_widgets.dart';

final supabase = sb.Supabase.instance.client;

/// 一起计时 - 入口界面
class Together extends StatefulWidget {
  const Together({super.key});

  @override
  TogetherState createState() => TogetherState();
}

class TogetherState extends State<Together> with WidgetsBindingObserver {
  TogetherState();

  final box = GetStorage();
  late TextEditingController neco, joco;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    neco = TextEditingController();
    joco = TextEditingController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget pane(List<Widget> children) {
    return Container(
      width: 308.w,
      height: 192.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Pantone.greenTimerShadowAlt1!,
            blurRadius: 15.r,
            offset: Offset(0.w, 6.h),
          ),
        ],
        color: Pantone.greenInputBg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: Container(
        color: Pantone.green,
        child: Stack(children: [
          Background(),
          Positioned(
            left: 130.w,
            right: 130.w,
            top: isIOS() ? 70.h : 50.h,
            height: 37.h,
            child: Bounceable(
              onTap: () {
                context.replace('/timer');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Pantone.greenTimerShadowAlt1!,
                      blurRadius: 15.r,
                      offset: Offset(0.w, 6.h),
                    ),
                  ],
                  color: Pantone.greenInputBg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/ip4-timer.svg',
                      height: 18.r,
                      colorFilter: ColorFilter.mode(
                        Pantone.greenTimerText!,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      "  个人计时",
                      style: TextStyle(color: Pantone.greenTimerText),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40.w,
            right: 40.w,
            top: 160.h,
            child: pane([
              Text(
                "新建计时",
                style: TextStyle(fontSize: 22.sp, color: Pantone.black87),
              ),
              Input(
                placeholder: "输入任务名完成创建",
                fontSize: 18.sp,
                teco: neco,
                width: 270.w,
                padding: EdgeInsets.only(),
              ),
              SizedBox(
                width: 270.w,
                child: ModalButton(
                  name: "新建",
                  onTap: () async {
                    box.write("duringTogether", true);
                    box.write('timer.beginTaskName', neco.text);
                    ECApp.togetherChannelName = randomNumeric(5);
                    neco.clear();
                    context.replace('/timer');
                  },
                ),
              )
            ]),
          ),
          Positioned(
            left: 40.w,
            right: 40.w,
            top: 420.h,
            child: pane([
              Text(
                "加入计时",
                style: TextStyle(fontSize: 22.sp, color: Pantone.black87),
              ),
              Input(
                placeholder: "请在此输入计时码",
                fontSize: 18.sp,
                teco: joco,
                width: 270.w,
                padding: EdgeInsets.only(),
              ),
              SizedBox(
                width: 270.w,
                child: ModalButton(
                  name: "加入",
                  onTap: () {
                    if (joco.text.length == 5) {
                      box.write("duringTogether", true);
                      ECApp.togetherChannelName = joco.text;
                      joco.clear();
                      context.replace('/timer');
                    } else {
                      showHud(ProgressHudType.error, '计时码应由五位数字组成');
                    }
                  },
                ),
              )
            ]),
          ),
          // 返回按钮
          Positioned(
            left: 0.w,
            right: 0.w,
            bottom: 50.h,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  width: 56.w,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Pantone.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4.r),
                        blurRadius: 15.r,
                        color: Pantone.greenTimerShadowAlt2!,
                      )
                    ],
                  ),
                  child: SvgPicture.asset(
                    'lib/assets/timer_arrow_down.svg',
                    height: 21.r,
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {}
  }
}

void getTogetherName() {
  ECApp.togetherChannelName ??= randomNumeric(5);
  print('Together channel name: ${ECApp.togetherChannelName}');
}

Future<void> togetherInit(
    void Function({RealtimeSubscribeStatus? status}) thenFunc) async {
  getTogetherName();
  if (ECApp.togetherChannel == null) {
    ECApp.afterTogetherChannelDel = false;
    ECApp.togetherChannel ??= supabase.channel(ECApp.togetherChannelName!);
    ECApp.togetherChannel!
        .subscribe((status, error) => thenFunc(status: status));
  } else {
    thenFunc();
  }
}

Future<void> togetherSend(
    int seconds, String? name, String? tag, bool paused, GetStorage box) async {
  if (withTogether(box)) {
    await togetherInit(({RealtimeSubscribeStatus? status}) async {
      if (!ECApp.afterTogetherChannelDel) {
        sb.ChannelResponse resp =
            await ECApp.togetherChannel!.sendBroadcastMessage(
          event: 'timer-update',
          payload: {
            'user': ECApp.userId(),
            'seconds': seconds,
            'task_name': name,
            'task_tag': tag,
            'paused': paused,
          },
        );
        print('Together send resp: $resp');
        if (resp != sb.ChannelResponse.ok) {
          showHud(ProgressHudType.error, '一起计时服务出错：${resp.name}');
        }
      }
    });
  }
}

Future<void> togetherDelete(GetStorage box) async {
  if (withTogether(box)) {
    await togetherInit(({RealtimeSubscribeStatus? status}) async {
      if (!ECApp.afterTogetherChannelDel) {
        sb.ChannelResponse resp =
            await ECApp.togetherChannel!.sendBroadcastMessage(
          event: 'timer-delete',
          payload: {
            'user': ECApp.userId(),
          },
        );
        print('Together del resp: $resp');
        box.write("duringTogether", false);
        ECApp.afterTogetherChannelDel = true;
        if (ECApp.togetherChannel != null) {
          supabase.removeChannel(ECApp.togetherChannel!);
        }
        if (resp != sb.ChannelResponse.ok) {
          showHud(ProgressHudType.error, '一起计时服务出错：${resp.name}');
        }
      }
      ECApp.togetherChannel = null;
    });
  }
}

Future<void> togetherInitStream(
  GetStorage box, {
  required Function onUpdate,
  required Function onDelete,
}) async {
  if (withTogether(box)) {
    await togetherInit(({RealtimeSubscribeStatus? status}) async {
      if (status != null) {
        if (status != sb.RealtimeSubscribeStatus.subscribed) {
          if (status != sb.RealtimeSubscribeStatus.closed) {
            showHud(ProgressHudType.error, '一起计时服务出错：${status.name}');
          }
        } else {
          showHud(ProgressHudType.success, '一起计时开启成功');
        }
      }
      ECApp.togetherChannel!.onBroadcast(
        event: 'timer-update',
        callback: (payload) {
          onUpdate(payload);
          print("Updated: $payload.");
        },
      );
      ECApp.togetherChannel!.onBroadcast(
        event: 'timer-delete',
        callback: (payload) {
          onDelete(payload);
          print("Deleted.");
        },
      );
    });
  }
}

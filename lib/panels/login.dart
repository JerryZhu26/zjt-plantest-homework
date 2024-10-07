// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/ui_widgets.dart';
import 'package:tinycolor2/tinycolor2.dart';

class LoginPanel extends StatefulWidget {
  const LoginPanel({super.key});

  @override
  LoginPanelState createState() => LoginPanelState();
}

class LoginPanelState extends State<LoginPanel> with WidgetsBindingObserver {
  late TextEditingController naco, paco;
  bool ifRegister = false;

  @override
  void initState() {
    super.initState();
    naco = TextEditingController(text: '');
    paco = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    return Scaffold(
      body: ProgressHud(
        isGlobalHud: true,
        ignorePointing: true,
        child: Container(
          height: 1.sh,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: ifRegister
                  ? [
                      Pantone.green!.darken(2).saturate(5),
                      Pantone.green!.lighten(8),
                    ]
                  : [
                      Pantone.green!.lighten(5),
                      Pantone.green!.darken(5).saturate(5)
                    ],
            ),
          ),
          child: Stack(children: [
            Positioned(
                left: 0.w,
                right: 0.w,
                top: isDesktop() ? -100.h : -50.h,
                child: Opacity(
                  opacity: 0.28,
                  child: GestureDetector(
                    onHorizontalDragEnd: (detail) {
                      if (detail.velocity.pixelsPerSecond.dx > 500) {
                        if (context.canPop()) context.pop();
                      }
                    },
                    child: SvgPicture.asset(
                      'lib/assets/my_bg.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                )),
            Positioned(
              height: 1.sh,
              width: 1.sw,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 321.w,
                    padding: EdgeInsets.only(top: 120.h),
                    child: Bounceable(
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: Container(
                          width: 22.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: Colors.white.withOpacity(0.5),
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
                  ),
                  SizedBox(height: 40.h),
                  Container(
                    width: 321.w,
                    padding: EdgeInsets.only(bottom: 40.sp),
                    child: Text(
                      ifRegister ? "注册" : "登录",
                      style: TextStyle(
                        color: Pantone.greenTagDark,
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 321.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 321.w,
                          child: Input(
                            placeholder: "邮箱",
                            teco: naco,
                            width: 278.w,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 321.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 321.w,
                          child: Input(
                            placeholder: "密码",
                            password: true,
                            teco: paco,
                            width: 278.w,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 16.sp),
                    child: Bounceable(
                      onTap: () async {
                        if (naco.text != '' && paco.text != '') {
                          if (!ifRegister) {
                            try {
                              // 需要重新实现非 realm 登录逻辑
                              context.pop();
                            } catch (e) {
                              if (e
                                  .toString()
                                  .contains('invalid username/password')) {
                                showHud(ProgressHudType.error, '用户名密码不匹配');
                              } else {
                                print(e);
                                showHud(ProgressHudType.error,
                                    '错误：${e.toString().split('link to server logs')[0]}');
                              }
                            }
                          } else {
                            if (naco.text.isEmail) {
                              if (paco.text.length > 8) {
                                try {
                                  showHud(ProgressHudType.error, '当前不支持登录或注册');
                                  ifRegister = false;
                                  setState(() {});
                                } catch (e) {
                                  if (e
                                      .toString()
                                      .contains('name already in use')) {
                                    showHud(ProgressHudType.error,
                                        '邮箱已被注册，请使用其他邮箱，或直接登录');
                                  } else {
                                    print(e);
                                    showHud(ProgressHudType.error,
                                        '错误：${e.toString().split('link to server logs')[0]}');
                                  }
                                }
                              } else {
                                showHud(ProgressHudType.error, '密码必须至少有8个字符');
                              }
                            } else {
                              showHud(ProgressHudType.error, '请输入正确的邮箱');
                            }
                          }
                        } else {
                          showHud(ProgressHudType.error, '用户名密码必须均不为空');
                        }
                      },
                      duration: 55.ms,
                      reverseDuration: 55.ms,
                      child: Container(
                        height: 54.h,
                        child: Container(
                          width: 321.w,
                          height: 37.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            color: Pantone.greenButton,
                          ),
                          child: Text(
                            ifRegister ? "注册" : "登录",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Pantone.white,
                              fontSize: 20.sp,
                              fontFamily: "PingFang SC",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Bounceable(
                    onTap: () {
                      ifRegister = !ifRegister;
                      setState(() {});
                    },
                    child: Text(
                      ifRegister ? "已有账户，点此回到登录" : "没有账户？点此进行注册",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Pantone.greenTagDark!.withOpacity(0.8),
                        fontSize: 14.5.sp,
                        fontFamily: "PingFang SC",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

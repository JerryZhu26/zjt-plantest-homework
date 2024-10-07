// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';

/// 输入框
class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.placeholder,
    this.tag,
    this.right,
    required this.teco,
    this.fontSize,
    this.minLine,
    this.maxLine,
    this.width,
    this.padding,
    this.innerPadding,
    this.error,
    this.autoFocus,
    this.backgroundColor,
    this.textColor,
    this.placeholderColor,
    this.autoSize = true,
    this.onEditingComplete,
    this.onChanged,
    this.password,
    this.available,
  });

  final String placeholder;
  final String? tag, error;
  final Widget? right;
  final TextEditingController teco;
  final double? fontSize, width;
  final int? minLine, maxLine;
  final EdgeInsets? padding, innerPadding;
  final bool? autoFocus, password, available;
  final bool autoSize;
  final Color? backgroundColor, textColor, placeholderColor;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
        width: 351.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: backgroundColor ?? Pantone.greenInputBg,
        ),
        padding: padding ??
            EdgeInsets.only(
              left: 20.w,
              right: 14.w,
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: width ?? (right != null ? 280.w : 312.w),
              padding: innerPadding,
              child: autoSize
                  ? AutoSizeTextField(
                      minLines: minLine ?? 1,
                      maxLines: maxLine ?? 1,
                      enabled: available ?? true,
                      controller: teco,
                      minFontSize: 2.sp,
                      stepGranularity: 1.sp,
                      autofocus: autoFocus ?? false,
                      onEditingComplete: onEditingComplete,
                      onChanged: onChanged,
                      obscureText: password ?? false,
                      style: TextStyle(
                        color: textColor ?? Pantone.greenTextInput,
                        fontSize: fontSize ?? 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ((isDesktop()
                                      ? 16
                                      : isIPad(context)
                                          ? 5
                                          : isIOS()
                                              ? 10.7
                                              : 7.6) *
                                  (fontSize ?? 14) /
                                  14)
                              .sp,
                        ),
                        border: InputBorder.none,
                        hintText: placeholder,
                        hintStyle: TextStyle(
                          color: placeholderColor ?? Pantone.greyPlaceholder,
                          fontSize: fontSize ?? 14.sp,
                        ),
                      ),
                    )
                  : TextField(
                      minLines: minLine ?? 1,
                      maxLines: maxLine ?? 1,
                      enabled: available ?? true,
                      controller: teco,
                      autofocus: autoFocus ?? false,
                      onEditingComplete: onEditingComplete,
                      onChanged: onChanged,
                      obscureText: password ?? false,
                      style: TextStyle(
                        color: textColor ?? Pantone.greenTextInput,
                        fontSize: fontSize ?? 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ((isDesktop()
                                      ? 16
                                      : isIPad(context)
                                          ? 5
                                          : isIOS()
                                              ? 10.7
                                              : 7.6) *
                                  (fontSize ?? 14) /
                                  14)
                              .sp,
                        ),
                        border: InputBorder.none,
                        hintText: placeholder,
                        hintStyle: TextStyle(
                          color: placeholderColor ?? Pantone.greyPlaceholder,
                          fontSize: fontSize ?? 14.sp,
                        ),
                      ),
                    ),
            ),
            Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.only(top: (2.5 * (fontSize ?? 14) / 14).r),
                child: right,
              ),
            ),
          ],
        ),
      ),
      if (error != null)
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            error!,
            style: TextStyle(
              color: Pantone.redAccent,
              fontSize: fontSize ?? 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
    ]);
  }
}

/// 五星评分框
class RateBar extends StatefulWidget {
  const RateBar({super.key, required this.onRate, this.initial = 3});

  final void Function(int rating) onRate;
  final int initial;

  @override
  RateBarState createState() => RateBarState();
}

class RateBarState extends State<RateBar> {
  late int rating;
  late double position;

  List<Widget> clickables = [];

  @override
  void initState() {
    super.initState();
    rating = widget.initial;
    position = rating * 56.w;
    for (int i = 0; i < 5; i++) {
      clickables.add(Container(
        width: 6.w,
        height: 6.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Pantone.greyRateBar!,
        ),
      ));
      clickables.add(SizedBox(width: 51.w));
    }
    clickables.add(Container(
      width: 6.w,
      height: 6.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Pantone.greyRateBar!,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 339.w,
      height: 44.h,
      alignment: Alignment.center,
      child: GestureDetector(
        onTapDown: (details) {
          rating = (details.localPosition.dx / 56.w - 0.3).round();
          position = rating * 56.w;
          widget.onRate(rating);
          setState(() {});
        },
        child: Container(
          width: 324.w,
          height: 44.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: Pantone.greenInputBg,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: position + 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      color: Pantone.greenRateBar,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                top: 19.h,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: clickables,
                ),
              ),
              Positioned(
                left: position,
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  child: Stack(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Pantone.green,
                        ),
                      ),
                      Positioned(
                        left: 16.5.w,
                        top: 10.h,
                        child: Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Pantone.isDarkMode(context)
                                ? Pantone.greenTagDark
                                : Colors.white,
                            fontSize: 18.sp,
                            fontFamily: "PingFang SC",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

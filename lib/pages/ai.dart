// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:spaces2/spaces2.dart';
import 'package:timona_ec/libraries/markdown_widget/code_wrapper.dart';
import 'package:timona_ec/libraries/markdown_widget/latex.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/ai_classified.dart';
import 'package:timona_ec/parts/ai_providers.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/ui_widgets.dart';
import 'package:window_manager/window_manager.dart';

enum PageAt { main, tags, classtable }

LinearGradient gradientAi = LinearGradient(
  begin: Alignment.lerp(Alignment.topCenter, Alignment.topLeft, 0.1)!,
  end: Alignment.lerp(Alignment.bottomCenter, Alignment.bottomRight, 0.2)!,
  colors: [
    Pantone.blueAiLight1!,
    Pantone.blueAiLight2!,
    Pantone.blueAiDark1!,
    Pantone.blueAiDark2!,
  ],
);

/// 智能助手页面
class PageAi extends StatefulWidget {
  const PageAi({super.key});

  @override
  State<PageAi> createState() => PageAiState();
}

class PageAiState extends State<PageAi> {
  PageAiState();

  final box = GetStorage();
  late TextEditingController teco;
  late bool fetchingAi;

  Aihist? hist;
  List<Widget> histWidgets = [];

  @override
  void initState() {
    super.initState();
    teco = TextEditingController();
    fetchingAi = false;
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    return Container(
      decoration: BoxDecoration(
        gradient: gradientAi,
      ),
      child: Stack(children: [
        Positioned(
          left: 0,
          right: 20.w,
          top: isIOS() ? 5.h : 20.h,
          child: DragToMoveArea(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (hist != null)
                Bounceable(
                  onTap: () {
                    showCheckSheet("确定开始新的会话吗？先前会话将留存在历史记录中", context, () {
                      hist = null;
                      setState(() {});
                    });
                  },
                  child: SvgPicture.asset(
                    'lib/assets/add_sm.svg',
                    height: 24.h,
                  ),
                ),
              SizedBox(width: 10.w),
              Bounceable(
                onTap: () async {
                  await context.push('/ai/history');
                  try {
                    hist = Get.find<Aihist>();
                    histWidgets = [];
                    for (int i = 0; i < hist!.ask.length; i++) {
                      histWidgets.add(AskContainer(text: hist!.ask[i]));
                      histWidgets.add(AnswerContainer(text: hist!.ans[i]));
                    }
                    setState(() {});
                    Get.delete<Aihist>();
                    print(hist);
                  } catch (_) {}
                },
                child: Row(children: [
                  SvgPicture.asset(
                    'lib/assets/ip4-history.svg',
                    height: 22.h,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "历史记录",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        hist == null
            ? Positioned(
          top: 100.h,
          width: 1.sw,
          child: SpacedColumn(spaceBetween: 22.h, children: [
            Text(
              "有什么我可以帮您的吗？",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                color: Pantone.greyAiExtremeLight!,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.r,
              ),
            ),
            Container(
              width: 1.sw,
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: SpacedColumn(
                spaceBetween: 20.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "您可以这样问我：",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Pantone.greyAiExtremeLight!.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ExampleContainer(
                    text: '复制消息 ${isAndroid() ? '➔' : '⭢'} 完成一天的日程规划',
                    onTap: () {
                      teco.text = '[快速规划] ';
                      setState(() {});
                    },
                  ),
                  ExampleContainer(
                    text: '请为我今天的时间规划提出建议？',
                    onTap: () {
                      teco.text = '我今天效率如何？';
                      setState(() {});
                    },
                  ),
                  ExampleContainer(
                    text: '今天的天气怎么样？',
                    onTap: () {
                      teco.text = '今天的天气怎么样？';
                      setState(() {});
                    },
                  ),
                ],
              ),
            )
          ]),
        )
            : Positioned(
          top: 45.h,
          left: 20.w,
          right: 20.w,
          bottom: 140.h,
          child: FadingEdgeScrollView.fromSingleChildScrollView(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: SpacedColumn(spaceBetween: 6.h, children: [
                SizedBox(height: 15.h),
                AskTime(time: hist!.createTime),
                SpacedColumn(spaceBetween: 16.h, children: histWidgets),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 84.h,
          left: 22.w,
          right: 22.w,
          child: Input(
            width: 1.sw - 110.w,
            placeholder: '输入',
            maxLine: 6,
            teco: teco,
            right: Container(
              width: 30.w,
              height: 42.h,
              child: Bounceable(
                onTap: () => sendMessage(),
                child: SvgPicture.asset(
                  'lib/assets/right_arrow.svg',
                  colorFilter: ColorFilter.mode(
                    Pantone.greyAiExtremeLight!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            fontSize: 15.sp,
            placeholderColor: Pantone.blueAiDark2,
            textColor: Pantone.greyAiExtremeLight,
            backgroundColor: Pantone.whiteAi!.withOpacity(0.35),
          ),
        ),
      ]),
    );
  }

  void sendMessage() {
    if (fetchingAi) {
      print('正在生成中...');
      showHud(ProgressHudType.loading, '请先等待上一轮回答完成…');
    } else {
      fetchingAi = true;
      if (hist == null) {
        // Create new talk
        hist = Aihist(
          createTime: DateTime.now(),
          name: substr(teco.text, 40),
          ask: [teco.text],
          ans: ['生成中...'],
        );
        AH ah = hist!.r;
        ECApp.realm.write(() => ECApp.realm.add(ah));
        hist!.objectId = ah.id;
        histWidgets = [
          AskContainer(text: teco.text),
          AnswerContainer(text: '生成中...')
        ];
        fetchAnswer(teco.text);
        setState(() {});
        teco.clear();
      } else {
        // Follow history talk
        AH? ah =
            ECApp.realm.query<AH>('id = \$0', [hist!.objectId]).firstOrNull;
        if (ah != null) {
          fetchAnswer(teco.text);
          ECApp.realm.write(() {
            ah.ask.add(teco.text);
            ah.ans.add('生成中...');
          });
          hist!.ask = ah.ask;
          histWidgets.add(AskContainer(text: teco.text));
          hist!.ans = ah.ans;
          histWidgets.add(AnswerContainer(text: '生成中...'));
          setState(() {});
          teco.clear();
        } else {
          showHud(ProgressHudType.error, '历史记录条目不存在，请检查');
        }
      }
    }
  }

  Future<void> fetchAnswer(String message) async {
    AH? ah = ECApp.realm.query<AH>('id = \$0', [hist!.objectId]).firstOrNull;
    String classifyResult = "";
    if (preclassifyIndicators(message)) {
      classifyResult = preclassifyClassifier(message);
    } else {
      await glm(
        message: inputClassifyPrompt(message),
        onDone: (resp) {
          classifyResult = resp.content;
        },
      );
    }

    void onDone(String content) {
      fetchingAi = false;
      if (ah != null) {
        try {
          ECApp.realm.write(() {
            hist!.ans.removeLast();
            hist!.ans.add(content);
            ah.ans.removeLast();
            ah.ans.add(content);
          });
        } catch (e) {
          print(e);
        }
      }
      if (mounted) {
        histWidgets.removeLast();
        histWidgets.add(AnswerContainer(text: content));
        setState(() {});
      }
    }

    if (classifyResult != '9') {
      String prompt = await specifiedPrompt(message, classifyResult);
      print(prompt);
      await glm(
          message: prompt,
          stream: true,
          search: classifyResult == '7' || classifyResult == '8',
          searchString: substr(message, 20),
          onStream: (resp) {
            if (mounted) {
              histWidgets.removeLast();
              histWidgets.add(AnswerContainer(text: resp.content));
              setState(() {});
            }
          },
          onDone: (resp) => onDone(resp.content));
    } else {
      await baiduQuickAddTask(
        message,
        onStream: (resp) {
          if (mounted) {
            histWidgets.removeLast();
            histWidgets.add(AnswerContainer(text: resp));
            setState(() {});
          }
        },
        onDone: (resp) => onDone(resp),
      );
    }
  }
}

class ExampleContainer extends StatelessWidget {
  const ExampleContainer({super.key, required this.text, required this.onTap});

  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => onTap(),
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 14.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: Pantone.greyAiExtremeLight!.withOpacity(0.12),
        ),
        child: Opacity(
          opacity: 0.85,
          child: Text(
            text,
            style: TextStyle(fontSize: 16.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class AnswerContainer extends StatelessWidget {
  const AnswerContainer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    codeWrapper(child, text, language) =>
        CodeWrapperWidget(child, text, language);
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(
        vertical: 12.h,
        horizontal: 14.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Pantone.greyAiExtremeLight!.withOpacity(0.12),
      ),
      child: Opacity(
        opacity: 0.85,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: Colors.white,
          ),
          child: MarkdownBlock(
            data: text.replaceAll('\\[', '\$').replaceAll('\\]', '\$'),
            selectable: true,
            generator: MarkdownGenerator(
              generators: [latexGenerator],
              inlineSyntaxList: [LatexSyntax()],
              richTextBuilder: (span) =>
                  Text.rich(span, textScaler: TextScaler.linear(1.sp)),
            ),
            config: MarkdownConfig.darkConfig.copy(configs: [
              CodeConfig(
                style: const TextStyle(backgroundColor: Colors.transparent),
              ),
              PreConfig.darkConfig.copy(
                wrapper: codeWrapper,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class AskTime extends StatelessWidget {
  const AskTime({super.key, required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 50.w),
        alignment: Alignment.centerLeft,
        child: Opacity(
          opacity: 0.7,
          child: Text(
            dateTimeSSWY(time),
            style: TextStyle(
              fontSize: 9.sp,
              color: Pantone.greyAiExtremeLight!,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.r,
            ),
          ),
        ));
  }
}

class AskContainer extends StatelessWidget {
  const AskContainer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 50.w),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: text.length < 20
              ? 19.sp
              : text.length < 50
              ? 15.sp
              : text.length < 100
              ? 11.sp
              : 7.sp,
          color: Pantone.greyAiExtremeLight!,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.r,
        ),
      ),
    );
  }
}

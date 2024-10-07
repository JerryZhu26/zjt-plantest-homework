// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Pantone {
  static BuildContext? context;

  /// 旧版兼容性颜色
  static Color? amber200lighter,
      black,
      black12,
      black26,
      black54,
      black87,
      blue,
      blue50,
      blue100,
      blue500,
      blue600,
      blueios,
      blueGrey50,
      blueGrey100,
      blueGrey600,
      blueGrey800,
      brown,
      brown100,
      brown600,
      brown800,
      cyan50,
      cyan500,
      cyan600,
      green100,
      green300,
      grey,
      greylikewhite,
      greyihour,
      grey50,
      grey100,
      grey100line,
      grey300,
      grey300alt,
      grey350,
      grey300border,
      grey300darker,
      grey300lighter,
      grey400,
      grey400lighter,
      grey600,
      grey600alt,
      grey700,
      greyline,
      lightBlue50,
      lightBlue500,
      lightBlue600,
      redAccent,
      red100,
      scris,
      scrislighter,
      scrisdarker,
      teal100,
      white,
      white54,
      white70,
      whitelayer,
      whitelayeralt,
      whitepure,
      whitetransparent;

  /// 新版的颜色系统
  static Color? bg,
      bgSemiLight,
      bgLight,
      blueAiLight1,
      blueAiLight2,
      blueAiDark1,
      blueAiDark2,
      greenWhite,
      greenWhiteDarker,
      greenExtremeLight,
      greenLight,
      greenSemiLight,
      green,
      greenAlt1,
      greenAlt2,
      greenBottomUnselected,
      greenButton,
      greenButtonAlt,
      greenColorSelect,
      greenInputBg,
      greenInputBgDark,
      greenLineLabel,
      greenMyBg,
      greenMyBlockBg,
      greenPresetName,
      greenRateBar,
      greenReportLeft,
      greenRightButton,
      greenShadow,
      greenShadowAlt1,
      greenTag,
      greenTag1,
      greenTag2,
      greenTag3,
      greenTagDeep,
      greenTagDark,
      greenText,
      greenTextInput,
      greenTimerShadow,
      greenTimerShadowAlt1,
      greenTimerShadowAlt2,
      greenTimerShadowAlt3,
      greenTimerText,
      greenTiming,
      greenMonthItem,
      greenMonthItemDay,
      greyAi,
      greyAiLight,
      greyAiExtremeLight,
      greyLight,
      greyPlaceholder,
      greyRateBar,
      redDelete,
      whiteAi;

  static bool isDarkMode(BuildContext context) {
    //return MediaQuery.of(context).platformBrightness == Brightness.dark;
    return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    //return Theme.of(context).colorScheme.brightness == Brightness.dark;
  }

  static void init(BuildContext c) {
    context = c;
    bool d = isDarkMode(context!);
    // 旧版兼容性颜色
    amber200lighter = d
        ? Color.fromARGB(140, 223, 172, 84)
        : Colors.amber[200]!.withAlpha(160);
    black = d ? Colors.white : Colors.black;
    black12 = d ? Colors.white24 : Colors.black12;
    black26 = d ? Colors.grey[700] : Colors.black26;
    black54 = d ? Colors.grey[300] : Colors.black54;
    black87 = d ? Colors.grey[200] : Colors.black87;
    blue = d ? Colors.blue : Colors.blue[400];
    blueios = d ? Color(0xFF0B84FF) : Color(0xFF007AFF);
    blue50 = d ? Color.fromARGB(180, 33, 78, 161) : Colors.blue[50];
    blue100 = d ? Color.fromARGB(180, 33, 78, 161) : Colors.blue[100];
    blue500 = d ? Colors.lightBlue[300] : Colors.blue[500];
    blue600 = d ? Colors.lightBlue[200] : Colors.blue[600];
    blueGrey50 = d ? Color(0xFF151517) : Colors.blueGrey[50];
    blueGrey100 = d ? Color.fromARGB(249, 79, 117, 135) : Colors.blueGrey[100];
    blueGrey600 = d ? Color(0xFF8DB1C2) : Colors.blueGrey[600];
    blueGrey800 = d ? Colors.blueGrey[100] : Colors.blueGrey[800];
    brown = d ? Colors.brown : Colors.brown;
    brown100 = d ? Color.fromARGB(170, 171, 86, 60) : Colors.brown[100];
    brown600 = d ? Colors.brown[200] : Colors.brown[600];
    brown800 = d ? Colors.brown[100] : Color.fromARGB(170, 171, 86, 60);
    cyan50 = d ? Colors.cyan[900] : Colors.cyan[50];
    cyan500 = d ? Colors.cyan[400] : Colors.cyan[500];
    cyan600 = d ? Colors.cyan[300] : Colors.cyan[600];
    green100 = d ? Color.fromARGB(150, 49, 157, 97) : Colors.green[100];
    green300 = d ? Color.fromARGB(220, 83, 159, 86) : Colors.green[300];
    grey = d ? Colors.grey[400] : Colors.grey;
    greyihour = d ? Color(0xFF080808) : Color(0xFFF2F2F2);
    greylikewhite = d ? Color(0xFA191919) : Color(0xFFFDFDFD);
    grey50 = d ? Color(0xFA191919) : Colors.grey[50];
    grey100 = d ? Colors.grey[900] : Colors.grey[100];
    grey100line = d ? Color(0xFF292929) : Color(0xFFF2F2F2);
    grey300 = d ? Colors.grey[800] : Colors.grey[300];
    grey300alt = d ? Colors.grey[850] : Colors.grey[300];
    grey350 = d ? Colors.grey[800] : Colors.grey[350];
    grey300border = d
        ? Color.fromARGB(200, 226, 226, 226)
        : Color.fromARGB(200, 196, 196, 197);
    grey300darker = d ? Colors.grey[900] : Colors.grey[300];
    grey300lighter = d ? Color.fromARGB(200, 226, 226, 226) : Colors.grey[300];
    grey400 = d ? Colors.grey[700] : Colors.grey[400];
    grey400lighter = d ? Color.fromARGB(200, 130, 130, 130) : Colors.grey[350];
    grey600 = d ? Colors.grey[350] : Colors.grey[600];
    grey600alt = d ? Colors.grey[400] : Colors.grey[600];
    grey700 = d ? Colors.grey[300] : Colors.grey[700];
    greyline = d ? Color(0xFA191919) : Colors.grey[300];
    lightBlue50 = d ? Color(0xFF0B4C7D) : Colors.lightBlue[50];
    lightBlue500 = d ? Colors.lightBlue[400] : Colors.lightBlue[500];
    lightBlue600 = d ? Colors.lightBlue[300] : Colors.lightBlue[600];
    redAccent = d ? Colors.redAccent[700] : Colors.redAccent;
    red100 = d ? Color.fromARGB(150, 198, 73, 73) : Colors.red[100];
    scris = Color(0xFF2D6FE8);
    scrislighter = d ? Color(0xFF124DBA) : Color(0xFF6699FE);
    scrisdarker = d ? Color(0xFF6699FE) : Color(0xFF124DBA);
    teal100 = d ? Color.fromARGB(120, 33, 168, 164) : Colors.teal[100];
    white = d ? Color(0xFF212123) : Colors.white70;
    white54 = d ? Color(0xAA212123) : Colors.white54;
    white70 = d ? Color(0xCC212123) : Colors.white70;
    whitelayer = d ? Color(0xFF151517) : Colors.white;
    whitelayeralt = d ? Colors.black : Colors.white;
    whitepure = d ? Color(0xFF151517) : Colors.white70;
    whitetransparent = d ? Color(0x00151517) : Colors.white.withAlpha(0);
    // 新版颜色系统
    bg = d ? Color(0xff2d8678) : Color(0xff1bc0a7);
    bgSemiLight = d ? Color(0xff0a483f) : Color(0xff4ac3b0);
    blueAiLight1 = d ? Color(0xFF2A61A3) : Color(0xFF2078E1);
    blueAiLight2 = d ? Color(0xFF104388) : Color(0xFF1B6CDA);
    blueAiDark1 = d ? Color(0xFF143474) : Color(0xFF0D4CC5);
    blueAiDark2 = d ? Color(0xFF0F254E) : Color(0xFF1148B5);
    bgLight = d ? Color(0xff08322c) : Color(0xffd5f8f3);
    greenWhite = d ? Color(0xff1C655B) : Color(0xffebf6f5);
    greenWhiteDarker = d ? Color(0xff0F5147) : Color(0xffe1f2f0);
    greenExtremeLight = d ? Color(0xff2F352E) : Color(0xffdbe8e7);
    greenLight = d ? Color(0x799ED9D6) : Color(0x3f0d4c47);
    greenSemiLight = Color(0xffa5c0bb);
    green = d ? Color(0xff14615c) : Color(0xff1a837b);
    greenAlt1 = Color(0xdd1a837b);
    greenAlt2 = Color(0xb20d4c48);
    greenBottomUnselected = d ? Color(0xff9CA9A2) : Color(0xff8abcba);
    greenButton = d ? Color(0xff46817C) : Color(0xff24a091);
    greenButtonAlt = Color(0xff24a091);
    greenColorSelect = Color(0xffcfebe8);
    greenInputBg = d ? Color(0xff232423) : Color(0xfff6f6f8);
    greenInputBgDark = d ? Color(0xff202120) : Color(0xfff0f0f2);
    greenLineLabel = d ? Color(0xff9EA9A9) : Color(0xff0e4c48);
    greenMyBlockBg = d ? Color(0xff132322) : Color(0xfff6f6f8);
    greenMyBg = d ? Color(0xff0E1411) : Color(0xffd3e8e6);
    greenPresetName = d ? Color(0xff86AEAC) : Color(0xff588381);
    greenRateBar = d ? Color(0xff304644) : Color(0xffc9e3e1);
    greenReportLeft = Color(0xff9eccc8);
    greenRightButton = d ? Color(0xff396E6A) : Color(0xffC9E3E1);
    greenShadow = d ? Color(0x20080C0A) : Color(0x200d4c47);
    greenShadowAlt1 = d ? Color(0x66080C0A) : Color(0x66126c65);
    greenText = d ? Color(0xff9eccc8) : Color(0xff26605c);
    greenTag = Color(0xff30726e);
    greenTag1 = d ? Color(0xff305752) : Color(0xffc9e3e1);
    greenTag2 = d ? Color(0xff345343) : Color(0xffe9f5f4);
    greenTag3 = d ? Color(0xff355F57) : Color(0xffd9f4f2);
    greenTagDeep = Color(0xff254d71);
    greenTagDark = d ? Color(0xffB4CEC9) : Colors.white;
    greenTextInput = d ? Color(0xdd82A2A0) : Color(0xdd155550);
    greenTimerShadow = d ? Color(0x660F1B1B) : Color(0xff14625c);
    greenTimerShadowAlt1 = d ? Color(0x660F1B1B) : Color(0xff13625b);
    greenTimerShadowAlt2 = d ? Color(0x660F1B1B) : Color(0xee0d4d48);
    greenTimerShadowAlt3 = d ? Color(0x660F1B1B) : Color(0xa00d4c47);
    greenTimerText = d ? Color(0xff58A39E) : Color(0xff226c67);
    greenTiming = d ? Color(0xff569791) : Color(0xff62b4ad);
    greenMonthItem = d ? Color(0xff219F8E) : Color(0xffc9e3e1);
    greenMonthItemDay = d ? Color(0xff55B8AB) : Color(0xFF94DCD6);
    greyAi = Color(0xFF7887A3);
    greyAiLight = Color(0xFF6A88C6);
    greyAiExtremeLight = d ? Color(0xFFCCDBF8) : Color(0xFFDFE4EF);
    greyLight = Color(0xfff2f2f2);
    greyPlaceholder = d ? Color(0x99C4C8C7) : Color(0x63254c71);
    greyRateBar = d ? Color(0xffABABAB) : Color(0xff818181);
    redDelete = Color(0xfff9705e);
    white = d ? Color(0xff151617) : Colors.white;
    whiteAi = d ? Color(0xFFBBCFF6) : Colors.white;
  }
}

enum TaskColor { green, purple, blue, orange, grey }

typedef TaskColorRecord = ({
  Color bgColor,
  Color iconColor,
  Color textColor,
  Color commentLeftColor,
  Color commentColor,
});

Map<(TaskColor, bool), TaskColorRecord> taskColors = {
  (TaskColor.green, false): (
    bgColor: Color(0xFFCFEBE8),
    iconColor: Color(0xFF91D0CA),
    textColor: Color(0xFF0E4D48),
    commentLeftColor: Color(0xFF64B9B1),
    commentColor: Color(0xFF387E79),
  ),
  (TaskColor.purple, false): (
    bgColor: Color(0xFFF1F1FF),
    iconColor: Color(0xFFC6C6F1),
    textColor: Color(0xFF32325A),
    commentLeftColor: Color(0xFF9292D5),
    commentColor: Color(0x9932325A),
  ),
  (TaskColor.orange, false): (
    bgColor: Color(0xFFFCDCC7),
    iconColor: Color(0xFFF6B488),
    textColor: Color(0xFF613315),
    commentLeftColor: Color(0xFFDC9668),
    commentColor: Color(0xAA5A4532),
  ),
  (TaskColor.blue, false): (
    bgColor: Color(0xFFD6F0FC),
    iconColor: Color(0xFF97D8F6),
    textColor: Color(0xFF275276),
    commentLeftColor: Color(0xFF6FBDE1),
    commentColor: Color(0xAA154169),
  ),
  (TaskColor.grey, false): (
    bgColor: Color(0xFFEAEAEB),
    iconColor: Color(0xFFD6DBDD),
    textColor: Color(0xFF5F5F62),
    commentLeftColor: Color(0xFF8F9191),
    commentColor: Color(0xAA636565),
  ),
  (TaskColor.green, true): (
    bgColor: Color(0xAA1BA891),
    iconColor: Color(0xFF83DFD6),
    textColor: Color(0xFFF1FFFD),
    commentLeftColor: Color(0xFF98E4DA),
    commentColor: Color(0xFFC8F5F1),
  ),
  (TaskColor.purple, true): (
    bgColor: Color(0xAA623ABC),
    iconColor: Color(0xFFA693F5),
    textColor: Color(0xFFF4F2FE),
    commentLeftColor: Color(0xFFD7D0FD),
    commentColor: Color(0x99D8D1FC),
  ),
  (TaskColor.orange, true): (
    bgColor: Color(0xAAD0751E),
    iconColor: Color(0xFFE9BEA0),
    textColor: Color(0xFFFAF6F4),
    commentLeftColor: Color(0xFFEFCFBA),
    commentColor: Color(0xFFF0E5DD),
  ),
  (TaskColor.blue, true): (
    bgColor: Color(0xAA309ABC),
    iconColor: Color(0xFF97D8F6),
    textColor: Color(0xFFF3FAFD),
    commentLeftColor: Color(0xFFBEE8FB),
    commentColor: Color(0xAAC0E7F9),
  ),
  (TaskColor.grey, true): (
    bgColor: Color(0xAAAAABAC),
    iconColor: Color(0xFFE8E9E9),
    textColor: Color(0xFFF3F4F4),
    commentLeftColor: Color(0xFFB8B8B8),
    commentColor: Color(0xAA828282),
  ),
};

typedef ProjectColorRecord = ({
  Color bgColor,
  Color imgColor,
  Color textColor,
});

Map<(TaskColor, bool), ProjectColorRecord> projectColors = {
  (TaskColor.green, false): (
    bgColor: Color(0xFFDEF1EF),
    imgColor: Color(0xFF75BAB4),
    textColor: Color(0xFF0E4D48),
  ),
  (TaskColor.purple, false): (
    bgColor: Color(0xfff0f0ff),
    imgColor: Color(0xffa8a8dc),
    textColor: Color(0xff4b4b87),
  ),
  (TaskColor.orange, false): (
    bgColor: Color(0xffffefd9),
    imgColor: Color(0xfff4ab7c),
    textColor: Color(0xff613316),
  ),
  (TaskColor.blue, false): (
    bgColor: Color(0xffd6f0fc),
    imgColor: Color(0xff73bee1),
    textColor: Color(0xff325c7e),
  ),
  (TaskColor.green, true): (
    bgColor: Color(0xAA41867A),
    imgColor: Color(0xFF3E9088),
    textColor: Color(0xFFF1FFFD),
  ),
  (TaskColor.purple, true): (
    bgColor: Color(0xAA5F4A92),
    imgColor: Color(0xFF6B5BB2),
    textColor: Color(0xFFF4F2FE),
  ),
  (TaskColor.orange, true): (
    bgColor: Color(0xAA95693F),
    imgColor: Color(0xFFB08262),
    textColor: Color(0xFFFAF6F4),
  ),
  (TaskColor.blue, true): (
    bgColor: Color(0xAA437A89),
    imgColor: Color(0xFF5E93AB),
    textColor: Color(0xFFF3FAFD),
  ),
};

ProjectColorRecord defaultProjColor(BuildContext context) {
  return projectColors[(TaskColor.green, Pantone.isDarkMode(context))]!;
}

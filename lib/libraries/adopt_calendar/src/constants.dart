import 'package:flutter/cupertino.dart';
import 'package:timona_ec/libraries/adopt_calendar/src/adoptive_datetime_picker.dart';

/// A class that provides constants for weekdays and month names.
class Constants {
  /// A list of abbreviated weekday names.
  static const List<String> weekDayName = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  /// A list of full month names.
  static const List<String> repeatMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}

class ConstantsCN {
  /// A list of abbreviated weekday names.
  static const List<String> weekDayName = [
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "日",
  ];

  /// A list of full month names.
  static const List<String> repeatMonthNames = [
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月',
  ];
}

extension AdoptiveBackgroundExtension on AdoptiveBackground {
  String get imageUrl {
    String url;
    switch (this) {
      case AdoptiveBackground.christmas:
        url =
            'https://www.icegif.com/wp-content/uploads/2022/12/icegif-1268.gif';
        break;
      case AdoptiveBackground.winter:
        url = 'https://cdn.wallpapersafari.com/92/98/xryMFe.jpg';
        break;
      case AdoptiveBackground.smokyLeaves:
        url =
            'https://images.pexels.com/photos/1379636/pexels-photo-1379636.jpeg?cs=srgb&dl=pexels-irina-iriser-1379636.jpg&fm=jpg';
        break;
      case AdoptiveBackground.snowFall:
        url = 'https://www.animationsoftware7.com/img/agifs/snow02.gif';
        break;
      case AdoptiveBackground.summer:
        url =
            'https://i.pinimg.com/originals/0c/9e/dc/0c9edcff20e55cc4c10101b537e6a362.jpg';
        break;
      case AdoptiveBackground.halloween:
        url = 'https://images7.alphacoders.com/133/1334604.png';
        break;
      default:
        url = '';
        break;
    }
    return url;
  }
}

Widget vSpace(double height) {
  return SizedBox(
    height: height,
  );
}

Widget hSpace(double width) {
  return SizedBox(
    width: width,
  );
}

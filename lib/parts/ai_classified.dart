import 'package:location/location.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/ai_providers.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

bool preclassifyIndicators(String input) {
  return input.contains('[快速规划]');
}

String preclassifyClassifier(String input) {
  if (input.contains('[快速规划]')) {
    return '9';
  } else {
    return '7';
  }
}

String inputClassifyPrompt(String input) {
  return """
您是一个用于效率软件的文本分类引擎，负责分析文本数据，并根据用户输入或自动确定的类别分配类别。

这是用户的输入：${substr(input, 20)}

这一输入和以下哪一条最接近？
1. 今天天气如何？
2. 今天已有哪些安排？
3. 对于今天的时间安排，你有什么建议？
4. 请为我撰写今天的工作总结。
5. 获取最近的历史记录趋势。
6. 请往列表加入这些任务：商务会见5:00-6:00、高等数学作业9:00-10:00
7. （任意效率领域问答）
8. （其他通用领域问答）

务必只回答我一个数字，比如“3”或“5”。
  """;
}

Future<String> specifiedPrompt(String input, String classified) async {
  classified = classified.trim();
  print(classified);
  if (classified == '8') {
    return input;
  } else if (classified == '1') {
    return weatherPrompt(input);
  } else if (classified == '2' || classified == '3' || classified == '4') {
    var dayContext = await dayTasksContext(input);
    var specifiedContext = "";
    if (classified == '3') specifiedContext = '\n紧紧抓住用户的问题';
    if (classified == '4') specifiedContext = '\n请不要列举，请进行简明扼要的概括';
    return "你是我的AI效率助理，今天是${dateTimeSSWY(DateTime.now())}。"
        "\n\n$dayContext \n用户的问题是：\n$input$specifiedContext";
  } else {
    return "你是我的AI效率助理，今天是${dateTimeSSWY(DateTime.now())}。\n$input";
  }
}

String weatherClassifyPrompt(String input) {
  return """
您是一个用于效率软件的文本分类引擎，负责分析文本数据并为其分配类别。

这是用户的输入：${substr(input, 20)}

这一输入和以下哪一条最接近？
1. 今天天气如何？
2. 未来几天天气如何？

务必只回答我一个数字，比如“1”或“2”。
  """;
}

Future<String> weatherPrompt(String input) async {
  String weatherClassifyResult = "1";
  await glm(
    message: weatherClassifyPrompt(input),
    onDone: (resp) {
      weatherClassifyResult = resp.content.trim();
    },
  );
  LocationData? locationData = await locationInfo();
  WeatherResponse weather = await qweather(
    x: locationData?.longitude ?? 116,
    y: locationData?.latitude ?? 40,
    tomorrow: weatherClassifyResult == '2',
  );
  return """
你是来自和风天气的天气机器人。今天用户所在地的天气情况为：$weather。

用户的问题是：$input
  """;
}

String dayFetchDatePrompt(String input) {
  return """
您是一个用于效率软件的文本引擎，负责从用户输入中提取最相关的日期。
今天是${dateTimeSSWY(DateTime.now())}。

这是用户的输入：${substr(input, 20)}

那一天的日程数据最能解决用户输入中提到的问题？务必只以YYYY-MM-DD的形式回复我。
  """;
}

Future<Date> dayFetchDate(String input) async {
  String dateResult = "1";
  await glm(
    message: dayFetchDatePrompt(input),
    onDone: (resp) {
      dateResult = resp.content.trim();
    },
  );
  print(dateResult);
  Date date = Date.now();
  try {
    date = Date(
        year: int.parse(dateResult.split('-')[0]),
        month: int.parse(dateResult.split('-')[1]),
        day: int.parse(dateResult.split('-')[2]));
  } catch (e) {
    print("$dateResult, $e");
  }
  return date;
}

Future<String> dayTasksContext(String input) async {
  var date = await dayFetchDate(input);
  var (plan, record) = await dayTasksFetch(date);
  return """
这些信息来自$date，请按需选用这些信息，来完成对用户的回答：

var 安排 = [
$plan
];
var 完成情况 = [
$record
];

注：安排是用户规划今天需要完成的安排，而完成情况中记录了用户实际完成了什么任务。
请抓住用户的问题，只针对问题进行回答，尽可能简略而生动，不额外输出无关内容。
  """;
}

Future<(String, String)> dayTasksFetch(Date date) async {
  var dayAt = DayAt(date);
  var tasks = ECApp.realm.query<TK>(
      'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
      [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
  var todos = ECApp.realm.query<TD>(
      'date.year = \$0 AND date.month = \$1 AND date.day = \$2',
      [dayAt.day.year, dayAt.day.month, dayAt.day.day]);
  String planString = "", recordString = "";
  // 任务 - 计划
  for (var task in tasks) {
    if (task.side == Side.left.name) {
      bool isVisiblePreset = true;
      if (task.name.contains("\$p\$")) {
        isVisiblePreset = checkTaskTodayVisible(
          task.name,
          Date.frn(task.date)!.d,
        );
      }
      if (isVisiblePreset) {
        planString += "{"
            "name: '${task.name.split("\$p\$")[0]}', "
            "time: '${Time.frn(task.startTime)}~${Time.frn(task.endTime)}', "
            "isRest: ${task.isRest}, "
            "${task.comment != null ? task.comment != "" ? "desc: '${substr(task.comment!, 20)}'" : "" : ""}"
            "},\n";
      }
    }
  }
  // 待办 - 计划
  for (var todo in todos) {
    var timeString = "";
    if (todo.startTime != null && todo.endTime != null) {
      timeString =
          "time: '${Time.frn(todo.startTime)}~${Time.frn(todo.endTime)}', ";
    } else if (todo.startTime != null) {
      timeString = "time: 'start at ${Time.frn(todo.startTime)}', ";
    } else if (todo.endTime != null) {
      timeString = "time: 'end at ${Time.frn(todo.startTime)}', ";
    }
    planString += "{"
        "name: '${todo.name.replaceAll('\$ok\$', '')}', "
        "$timeString"
        "isFinished: ${todo.name.contains('\$ok\$')}, "
        "${todo.comment != null ? todo.comment != '' ? "desc: '${substr(todo.comment!, 20)}'" : "" : ""}"
        "},\n";
  }
  // 任务 - 实际完成情况
  for (var task in tasks) {
    if (task.side == Side.right.name) {
      recordString += "{name: '${task.name}', "
          "time: '${Time.frn(task.startTime)}~${Time.frn(task.endTime)}', "
          "isRest: ${task.isRest}, "
          "${task.comment != null ? task.comment != "" ? "desc: '${substr(task.comment!, 20)}'" : "" : ""}"
          "},\n";
    }
  }
  return (planString, recordString);
}

String getDateTimePrompt(String input) {
  return """
用户的输入是一个任意格式的日期时间信息，你的任务是对其进行格式化。

用户输入：$input

务必只以YYYY-MM-DD-hh-mm的形式回复我。
  """;
}

Future<void> baiduQuickAddTask(String message,
    {required Function onStream, required Function onDone}) async {
  List<BaiduAiResponse> baiduResult = [];
  try {
    baiduResult = await baiduAi(
      message.replaceAll('[快速规划]', '').trim(),
    );
  } catch (e) {
    showHud(ProgressHudType.error, "快速规划出错：$e");
  }
  String resp = "";
  if (baiduResult.isEmpty) {
    resp = "提取完成，未成功提取到任何内容，因此未进行规划";
  } else {
    resp = "已提取到这些日程：";
    for (var item in baiduResult) {
      resp = "$resp\n - $item";
    }
    resp = "$resp\n\n正在添加日程到时间轴...";
    onStream(resp);
    for (int i = 0; i < baiduResult.length; i++) {
      DateTime? dateTime;
      await glm(
        message: getDateTimePrompt(baiduResult[i].time),
        onDone: (resp) {
          try {
            var elements = resp.content.trim().split('-');
            dateTime = DateTime(
              int.parse(elements[0]),
              int.parse(elements[1]),
              int.parse(elements[2]),
              int.parse(elements[3]),
              int.parse(elements[4]),
            );
          } catch (e) {
            showHud(ProgressHudType.error, '添加日程失败：$e');
          }
          baiduResult[i].dateTime = dateTime;
        },
      );
    }
    print(baiduResult);
    resp = dropAfterLast(resp, '\n');
    resp = "$resp\n日程已添加到到时间轴";
  }
  onStream(resp);
  onDone(resp);
}

String dropAfterLast(String input, String char) {
  int lastIndex = input.lastIndexOf(char);

  if (lastIndex != -1) {
    String result = input.substring(0, lastIndex);
    return result;
  } else {
    return input;
  }
}

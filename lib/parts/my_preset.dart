part of 'package:timona_ec/pages/my.dart';

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors
// ignore_for_file: curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, use_build_context_synchronously

/// 课表设置模块
class ClassTableSettings extends StatefulWidget {
  const ClassTableSettings(
      this.block, this.row, this.blockBase, this.rowBase, this.rowBase2,
      {super.key});

  final Function block, row, blockBase, rowBase, rowBase2;

  @override
  State<ClassTableSettings> createState() => ClassTableSettingsState();
}

class ClassTableSettingsState extends State<ClassTableSettings> {
  ClassTableSettingsState();

  final box = GetStorage();

  Map weekdays = {
    1: "周一",
    2: "周二",
    3: "周三",
    4: "周四",
    5: "周五",
    6: "周六",
    7: "周日",
  };
  bool pickingFile = false;
  int selected = 0;
  List<Widget> selectedPresetWidgets = [];

  @override
  void initState() {
    super.initState();
    pickingFile = false;
    selected = 0;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> weekdayManage = [];
    bool hasOne = false;
    for (int i = 1; i <= 7; i++) {
      bool has = box.read("presetUse$i") ?? false;
      if (has) hasOne = true;
      weekdayManage.add(
        has
            ? widget.rowBase2(
                weekdays[i],
                () {
                  selected = i;
                  selectedPresetWidgets = [];
                  List<Map> selectedPreset =
                      List<Map>.from(box.read("preset$i") ?? []);
                  for (var one in selectedPreset) {
                    List checked =
                        checkPresetString(one['name'], DateTime.now());
                    selectedPresetWidgets.add(Container(height: 10.h));
                    if (checked.isNotEmpty) {
                      selectedPresetWidgets.add(rowPresetItem(
                        one['name'].split("\$p\$")[0],
                        Time.fromComparable(one['start']).s,
                        Time.fromComparable(one['end']).s,
                        Date.fromDateTime(checked[2]).ss,
                        Date.fromDateTime(checked[3]).ss,
                        "每${checked[0] != 1 ? checked[0] : ""}${checked[1]}",
                      ));
                    } else {
                      selectedPresetWidgets.add(rowPresetItem(
                        one['name'].split("\$p\$")[0],
                        Time.fromComparable(one['start']).s,
                        Time.fromComparable(one['end']).s,
                        "",
                        "",
                        "",
                      ));
                    }
                  }
                  setState(() {});
                },
                rightArrow(),
                () {
                  showCheckSheet("确定要删除${weekdays[i]}的预设任务吗？不可撤销", context, () {
                    box.write("presetUse$i", false);
                    box.write("presetVersion$i",
                        (box.read("presetVersion$i") ?? 1) + 1);
                    box.remove("preset$i");
                    setState(() {});
                  });
                },
                rightArrow(iconName: 'lib/assets/trash.svg'),
              )
            : widget.rowBase(
                weekdays[i],
                () {},
                Text(
                  "-",
                  style: TextStyle(
                    color: Pantone.greenLight,
                    fontSize: 14.5.sp,
                    fontFamily: "PingFang SC",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
      );
      weekdayManage.add(SizedBox(height: 19.h));
    }
    weekdayManage.removeLast();
    return Column(
      children: selected == 0
          ? [
              widget.block(
                "新建",
                [
                  (
                    "从 ICS 课表导入",
                    () {
                      toImportICSFile();
                      setState(() {});
                    }
                  ),
                  if (hasOne)
                    (
                      "设置课表任务颜色",
                      () {
                        showSelectSheet("您想使用哪种颜色作为课表导入任务颜色？",
                            ['绿色', '紫色', '蓝色', '橙色'], context, (index) async {
                          showCheckSheet("确定要修改课表导入任务颜色吗？将影响今天及以后所有日期", context,
                              () {
                            box.write(
                                "presetColor", TaskColor.values[index].name);
                            for (int i = 1; i <= 7; i++) {
                              if ((box.read("presetUse$i") ?? false)) {
                                box.write("presetVersion$i",
                                    (box.read("presetVersion$i") ?? 1) + 1);
                                print(box.read("presetVersion$i") ?? 1);
                              }
                            }
                            setState(() {});
                          });
                        });
                      }
                    ),
                  if (hasOne)
                    (
                      "删除所有",
                      () {
                        showCheckSheet("确定要将所有预设任务全部删除吗？不可撤销", context, () {
                          for (int i = 1; i <= 7; i++) {
                            if ((box.read("presetUse$i") ?? false)) {
                              box.write("presetUse$i", false);
                              box.write("presetVersion$i",
                                  (box.read("presetVersion$i") ?? 1) + 1);
                              box.remove("preset$i");
                            }
                          }
                          setState(() {});
                        });
                      }
                    ),
                ],
                bottom:
                    "ICS 文件可以通过 WakeUp 等主流课程表工具导出。暂仅提供 ICS 导入是因为教务系统适配工作量很大，而几家主流课程表工具均已完成这一适配",
              ),
              widget.blockBase(
                Column(children: weekdayManage),
                bottom: "选择一天，查看当天的预设任务或课表",
              ),
            ]
          : [
              widget.blockBase(
                Column(children: [
                  Row(children: [
                    back(() {
                      selected = 0;
                      setState(() {});
                    }),
                    Text(
                      weekdays[selected],
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                        color: Pantone.green,
                      ),
                    ),
                  ]),
                  Column(children: selectedPresetWidgets)
                ]),
              )
            ],
    );
  }

  Future<void> toImportICSFile() async {
    FilePickerResult? result;
    if (!pickingFile) {
      pickingFile = true;
      if (isMobile()) {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 ICS 文件以导入",
          type: FileType.any,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: "选择 ICS 文件以导入",
          type: FileType.custom,
          allowedExtensions: ["ics"],
        );
      }
    } else {
      showHudC(ProgressHudType.error, "请勿重复打开", context);
      return;
    }
    if (result != null) {
      File file = File(result.files.single.path!);
      if (file.path.contains(".ics")) {
        final icsLines = await file.readAsLines();
        try {
          final iCalendar = ICalendar.fromLines(icsLines);
          List<dynamic> icsJson = iCalendar.toJson()["data"];
          await toSetICSDisplay(icsJson);
        } catch (e) {
          print(e);
          showHudC(ProgressHudType.error, "我们无法解析您选择的文件", context);
        }
      } else {
        showHudC(ProgressHudType.error, "我们无法解析您选择的文件", context);
      }
    } else {
      showHudC(ProgressHudType.error, "未选择文件", context);
    }
    pickingFile = false;
  }

  Future<void> toSetICSDisplay(List<dynamic> json) async {
    dynamic example;
    for (var event in json) {
      if (event['type'] == "VEVENT") {
        example = event;
      }
    }
    if (example != null) {
      List<String> dispList = [example['summary']];
      if (example.containsKey('location')) {
        if (example['location'].split(' ').length == 1) {
          dispList = [
            example['summary'],
            example['summary'] + " " + example['location']
          ];
        } else {
          dispList = [
            example['summary'],
            example['summary'] + " " + example['location'].split(' ')[0],
            example['summary'] + " " + example['location'].split(' ')[1],
            example['summary'] +
                " " +
                example['location'].split(' ')[0] +
                " " +
                example['location'].split(' ')[1],
          ];
        }
      }
      List<Map> events = [];
      showSelectSheet("您想使用哪种课名格式？", dispList, context, (index) async {
        bool failed = false;
        for (var event in json) {
          if (event['type'] == "VEVENT") {
            String name = event['summary'];
            if (example.containsKey('location')) {
              if (dispList.length == 2 && index == 1) {
                name = "$name ${event['location']}";
              } else if (dispList.length == 4) {
                if (index == 1) {
                  name = "$name ${event['location'].split(' ')[0]}";
                } else if (index == 2) {
                  name = "$name ${event['location'].split(' ')[1]}";
                } else if (index == 3) {
                  name =
                      "$name ${event['location'].split(' ')[0]} ${event['location'].split(' ')[1]}";
                }
              }
            }
            String nameSuffix =
                "\$p\$${event['rrule'].split(';')[2].split('=')[1]}-${event['rrule'].split(';')[0].split('=')[1].substring(0, 2)}-${event['dtstart']['dt'].split('T')[0].substring(4, 8)}-${event['rrule'].split(';')[1].split('=')[1].split('T')[0].substring(4, 8)}";
            name = name + nameSuffix;
            String startTimeString =
                event['dtstart']['dt'].split('T')[1].substring(0, 4);
            Time startTime = Time.fromComparable(
                int.parse(startTimeString.substring(0, 2)) * 60 +
                    int.parse(startTimeString.substring(2, 4)));
            String endTimeString =
                event['dtend']['dt'].split('T')[1].substring(0, 4);
            Time endTime = Time.fromComparable(
                int.parse(endTimeString.substring(0, 2)) * 60 +
                    int.parse(endTimeString.substring(2, 4)));
            DateTime startDay = DateTime(
              int.parse(event['dtstart']['dt'].toString().substring(0, 4)),
              int.parse(event['dtstart']['dt'].split('T')[0].substring(4, 6)),
              int.parse(event['dtstart']['dt'].split('T')[0].substring(6, 8)),
            );
            int startDayWD = startDay.weekday;
            String dayString = weekdays[startDayWD];
            if ((box.read("presetUse$startDayWD") ?? false) == true) {
              showHud(
                  ProgressHudType.error, "课表导入失败，因为$dayString已有预设，请先删除相关预设");
              failed = true;
              break;
            }
            events.add({
              'name': name,
              'weekday': startDayWD,
              'start': startTime.comparable,
              'end': endTime.comparable,
            });
          }
        }
        Map<int, List<Map>> presets = {
          1: [],
          2: [],
          3: [],
          4: [],
          5: [],
          6: [],
          7: []
        };
        if (!failed) {
          for (var event in events) {
            int weekday = event['weekday'];
            presets[weekday]!.add(event);
          }
          presets.forEach((key, preset) {
            if (preset.isNotEmpty) {
              box.write("presetUse$key", true);
              box.write("preset$key", preset);
              box.write("presetVersion$key",
                  (box.read("presetVersion$key") ?? 1) + 1);
            }
          });
          await showHudC(ProgressHudType.success, "解析完成", context);
          setState(() {});
        }
      }, cancel: "取消", result0SentFunc: true);
    } else {
      showHudC(ProgressHudType.error, "您选择的文件无法解析或为空", context);
    }
  }

  Widget back(Function func) {
    return Padding(
      padding: EdgeInsets.only(right: 14.w, top: 3.h),
      child: Bounceable(
        onTap: () => func(),
        duration: 55.ms,
        reverseDuration: 55.ms,
        child: Container(
          width: 20.w,
          height: 20.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Pantone.green,
          ),
          padding: EdgeInsets.only(
            top: 4.5.r,
            bottom: 4.5.r,
          ),
          child: SvgPicture.asset(
            'lib/assets/back-white.svg',
            height: 12.r,
          ),
        ),
      ),
    );
  }

  Widget rowPresetItem(String name, String startTime, String endTime,
      String startDate, String endDate, String scheduleWay) {
    return Container(
      width: 302.w,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            "$startDate ~ $endDate ($scheduleWay) $startTime ~ $endTime",
            style: TextStyle(
              color: Pantone.greenSemiLight,
              fontSize: 14.5.sp,
              fontFamily: "PingFang SC",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

part of 'package:timona_ec/parts/general.dart';

enum FilterType { none, unfinished }

Map<FilterType, String> filterMap = {
  FilterType.none: '未筛选',
  FilterType.unfinished: '仅看未完成',
};

enum SortType { none, time, create }

Map<SortType, String> sortMap = {
  SortType.none: '默认顺序',
  SortType.time: '时间顺序',
  SortType.create: '创建时间顺序',
};

Widget typeTab(String name, BuildContext context, void Function()? onTap) {
  return Bounceable(
    onTap: onTap,
    child: Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: defaultProjColor(context).textColor,
      ),
    ),
  );
}

Widget pod(String name, BuildContext context, void Function()? onTap) {
  return Bounceable(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: defaultProjColor(context).bgColor.withOpacity(
            (name == filterMap[FilterType.none]! ||
                    name == sortMap[SortType.none]!)
                ? 0.5
                : 0.8),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 15.sp,
          color: defaultProjColor(context).textColor,
        ),
      ),
    ),
  );
}

bool isTodoFinished(String name) {
  return name.contains('\$ok\$');
}

List<Widget> todoPiecesFromTodayTds(
    Timeline timeline, void Function() fetchTodos) {
  List<Widget> widgets = [];
  for (TD td in timeline.tdsToday) {
    widgets.add(TodayTodoPiece(
      name: td.name,
      id: td.id,
      showProject: true,
      place: Place.central,
      onEdited: (x) => fetchTodos(),
    ));
  }
  return widgets;
}

class TodayTodoPiece extends StatefulWidget {
  const TodayTodoPiece({
    super.key,
    required this.name,
    required this.id,
    this.showDateTime = false,
    this.showProject = false,
    this.onEdited,
    this.place = Place.todos,
  });

  final String name;
  final ObjectId id;
  final bool showDateTime, showProject;
  final void Function(Todo)? onEdited;
  final Place place;

  @override
  TodayTodoPieceState createState() => TodayTodoPieceState();

  @override
  String toString({DiagnosticLevel? minLevel}) {
    return "TodoWidget: $name";
  }
}

class TodayTodoPieceState extends State<TodayTodoPiece> {
  late bool selected, visible;
  late String name;
  late TD? td;

  String timeStr = '', dateStr = '', projStr = '';

  @override
  void initState() {
    super.initState();
    visible = true;
    selected = isTodoFinished(widget.name);
    name = widget.name;
    td = ECApp.realm.query<TD>('id = \$0', [widget.id]).firstOrNull;
    refreshDateTimeStr();
    refreshProjTimeStr();
  }

  void refreshDateTimeStr() {
    timeStr = '';
    if (td != null) {
      if (td!.startTime != null && td!.endTime != null) {
        timeStr = '${Time.fr(td!.startTime!).ss} ~ ${Time.fr(td!.endTime!).ss}';
      } else if (td!.startTime != null) {
        timeStr = Time.fr(td!.startTime!).ss;
      } else if (td!.endTime != null) {
        timeStr = Time.fr(td!.endTime!).ss;
      }
      if (td!.date != null) {
        dateStr = Date.fr(td!.date!).ss;
      }
    }
  }

  void refreshProjTimeStr() {
    projStr = '';
    if (td != null) {
      if (td!.project != null) {
        projStr = td!.project!.name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    ProjectColorRecord projColor = projectColors[(
      visible && td != null
          ? td!.color != null
              ? TaskColor.values.byName(td!.color!)
              : td!.project != null
                  ? Proj.fr(td!.project!).taskColor
                  : TaskColor.green
          : TaskColor.green,
      Pantone.isDarkMode(context)
    )]!;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails detail) {
        if (detail.localPosition.dx > 100) {
          showCheckSheet(
              name != ""
                  ? "确定删除 ${name.replaceAll('\$ok\$', '')} 吗？不可撤销"
                  : "确定删除每日提醒项目吗？不可撤销",
              context, () async {
            visible = false;
            ECApp.realm.write(() => ECApp.realm.delete<TD>(td!));
            setState(() {});
          });
        }
      },
      child: Visibility(
        visible: visible,
        child: Container(
          color: Colors.transparent,
          child: Row(children: [
            OverrideCupertinoCheckbox(
              value: selected,
              activeColor: Pantone.green,
              side: BorderSide(width: 1.r, color: Pantone.grey!),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r)),
              onChanged: (value) {
                if (td != null) {
                  setState(() {
                    selected = value ?? false;
                    if (selected) {
                      name = '$name\$ok\$';
                    } else {
                      name = name.replaceAll('\$ok\$', '');
                    }
                    ECApp.realm.write(() {
                      td!.name = name;
                      if (selected) td!.finishTime = dateTimeR(DateTime.now());
                    });
                    setState(() {});
                  });
                } else {
                  showHudC(ProgressHudType.error, "所选任务不存在，可能已被删除", context);
                }
              },
            ),
            Expanded(
              child: Bounceable(
                onTap: () async {
                  if (td != null) {
                    Get.replace<Todo>(Todo.fr(td!));
                    Date? oldDate = Date.frn(td!.date);
                    await context.push('/todos/detail');
                    try {
                      String? status = Get.find<String?>(tag: 'status-todo');
                      if (status == 'delete') {
                        visible = false;
                        setState(() {});
                      } else if (status == 'edit') {
                        td = Get.find<TD?>(tag: 'edited')!;
                        Get.delete<TD?>(tag: 'edited');
                        name = td!.name;
                        if (Date.frn(td!.date)?.toComparable() !=
                                oldDate?.toComparable() &&
                            widget.place == Place.central) {
                          visible = false;
                        }
                        refreshDateTimeStr();
                        refreshProjTimeStr();
                        if (widget.onEdited != null) {
                          widget.onEdited!(Todo.fr(td!));
                        }
                        setState(() {});
                      }
                      Get.delete<Todo>();
                      Get.delete<String?>(tag: 'status-todo');
                    } catch (err) {
                      print(err);
                    }
                  } else {
                    showHudC(ProgressHudType.error, "所选任务不存在，可能已被删除", context);
                  }
                },
                child: Text(
                  name.replaceAll('\$ok\$', ''),
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    decoration: selected ? TextDecoration.lineThrough : null,
                    decorationColor: selected ? Pantone.grey600 : Pantone.black,
                    color: selected ? Pantone.grey600 : Pantone.black,
                  ),
                ),
              ),
            ),
            if (visible && td != null)
              if (widget.showDateTime && td!.date != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                  constraints: BoxConstraints(maxWidth: 180.w),
                  decoration: BoxDecoration(
                    color: projColor.bgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    combineStrings([
                      dateStr,
                      timeStr,
                      (widget.showProject ? projStr : '')
                    ]),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: projColor.textColor,
                    ),
                  ),
                ),
            if (visible && td != null && !widget.showDateTime)
              if (widget.showProject && td!.project != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                  constraints: BoxConstraints(maxWidth: 100.w),
                  decoration: BoxDecoration(
                    color: projColor.bgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    combineStrings([projStr, timeStr]),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: projColor.textColor,
                    ),
                  ),
                ),
            if (!widget.showDateTime)
              SizedBox(width: 20.w)
            else
              SizedBox(width: 1.w),
          ]),
        ),
      ),
    );
  }
}

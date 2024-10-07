// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:spaces2/spaces2.dart';
import 'package:timona_ec/libraries/override/checkbox.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/stores/todolist.dart';

List<Widget> piecesFromHierarchy(Todolist todolist, BuildContext context,
    GetStorage box, int updateCounter, ObjectId? parent) {
  final List<Widget> pieces = [];
  for (var root in [parent, ...todolist.roots]) {
    if (root != parent) {
      pieces.add(HierarchyWidget(
        todolist: todolist,
        hierarchy: todolist.hierarchy[root],
        level: 0,
      ));
    } else {
      pieces.add(HierarchyWidget(
        todolist: todolist,
        hierarchy: null,
        level: 0,
      ));
    }
  }
  return pieces;
}

class HierarchyWidget extends StatefulWidget {
  const HierarchyWidget({
    super.key,
    required this.todolist,
    required this.level,
    this.hierarchy,
  });

  final Todolist todolist;
  final TodosHierarchyItem? hierarchy;
  final int level;

  @override
  HierarchyWidgetState createState() => HierarchyWidgetState();
}

class HierarchyWidgetState extends State<HierarchyWidget> {
  List<TD> tds = [];
  PJ? pj;
  GetStorage box = GetStorage();

  late bool showSub;
  late TodosHierarchyItem? hierarchy;
  late Todolist todolist;

  @override
  void initState() {
    super.initState();
    showSub = widget.level == 0;
    hierarchy = widget.hierarchy;
    todolist = widget.todolist;
    if (hierarchy != null) {
      pj = todolist.pjs[hierarchy!.self];
      for (var id in hierarchy!.tds) {
        tds.add(todolist.tds[id]!);
      }
    } else {
      for (var id in todolist.tdsNoPj) {
        tds.add(todolist.tds[id]!);
      }
    }
  }

  List<ObjectId> getTds() {
    List<ObjectId> tds = (hierarchy?.tds ?? todolist.tdsNoPj);
    if (todolist.sortType == SortType.time) {
      return tds.sorted((a, b) {
        if (todolist.tds[a] == null) return 1;
        if (todolist.tds[b] == null) return -1;
        TD tdA = todolist.tds[a]!;
        TD tdB = todolist.tds[b]!;
        if (tdA.date == null) return 1;
        if (tdB.date == null) return -1;
        if (tdA.date!.year != tdB.date!.year) {
          return tdA.date!.year - tdB.date!.year;
        }
        if (tdA.date!.month != tdB.date!.month) {
          return tdA.date!.month - tdB.date!.month;
        }
        if (tdA.date!.day != tdB.date!.day) {
          return tdA.date!.day - tdB.date!.day;
        }
        if (tdA.startTime == null) return 1;
        if (tdB.startTime == null) return -1;
        if (tdA.startTime!.hour != tdB.startTime!.hour) {
          return tdA.startTime!.hour - tdB.startTime!.hour;
        }
        return tdA.startTime!.minute - tdB.startTime!.minute;
      });
    } else if (todolist.sortType == SortType.none) {
      return [
        ...tds.where((a) => !isTodoFinished(todolist.tds[a]?.name ?? '')),
        ...tds.where((a) => isTodoFinished(todolist.tds[a]?.name ?? ''))
      ];
    }
    // todolist.sortType = SortType.create
    return tds.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    double textWidth = 245.w - 17.w * widget.level;
    ProjectColorRecord colorSet = projectColors[(
      hierarchy != null ? TaskColor.values.byName(pj!.color) : TaskColor.green,
      Pantone.isDarkMode(context)
    )]!;
    return Column(children: [
      if (hierarchy != null)
        Bounceable(
          onTap: () async {
            ObjectId id = pj!.id;
            Get.replace(pj!);
            Get.replace(Proj.fr(pj!));
            await context.push('/todos/project');
            try {
              String? status = Get.find<String>(tag: 'status-proj');
              if (status == 'delete') {
                todolist.removePj(id);
              } else if (status == 'edit') {
                pj = Get.find(tag: 'edited');
                if (pj != null) {
                  todolist.pjs[pj!.id] = pj!;
                }
              }
              Get.delete<String>(tag: 'status-proj');
            } catch (_) {}
          },
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: colorSet.bgColor,
              ),
              padding: EdgeInsets.only(
                left: 14.4.w,
                right: 6.w,
                top: 13.r,
                bottom: 4.r,
              ),
              child: Column(children: [
                Row(children: [
                  SvgPicture.asset(
                    'lib/assets/bookmark.svg',
                    height: 17.r,
                    colorFilter: ColorFilter.mode(
                      colorSet.imgColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: textWidth,
                    height: 21.1.h,
                    child: Text(
                      pj != null ? pj!.name : '',
                      style: TextStyle(
                        color: colorSet.textColor,
                        fontSize: 15.sp,
                        fontFamily: "PingFang SC",
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Row(children: [
                    Bounceable(
                      onTap: () async {
                        Get.delete<Todo>();
                        Get.replace<PJ>(pj!);
                        await context.push('/todos/add');
                        context.replace('/--reload');
                      },
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.r),
                          color: colorSet.imgColor,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'lib/assets/add-sw3.svg',
                          height: 9.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Bounceable(
                      onTap: () {
                        showSub = !showSub;
                        if (pj != null) {
                          box.write("projShowSub${pj!.id}", showSub);
                        }
                        setState(() {});
                      },
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          showSub
                              ? 'lib/assets/up_solid.svg'
                              : 'lib/assets/down_solid.svg',
                          height: 24.r,
                          colorFilter: ColorFilter.mode(
                            colorSet.imgColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ])
                ]),
                SizedBox(height: 6.h),
              ]),
            ),
          ]),
        ),
      SizedBox(height: 12.h),
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (pj != null) SizedBox(width: 3.4.w),
            if (pj != null)
              Container(
                width: 1.6.w,
                color: colorSet.imgColor,
              ),
            Container(
              width: textWidth + 85.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSub && hierarchy != null)
                    Container(
                      padding: hierarchy!.subs.isNotEmpty
                          ? EdgeInsets.only(left: 12.w)
                          : EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: hierarchy!.subs
                            .map(
                              (id) => HierarchyWidget(
                                todolist: todolist,
                                hierarchy: todolist.hierarchy[id],
                                level: widget.level + 1,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (showSub)
                    Container(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getTds()
                            .map(
                              (id) => TodoPiece(
                                id: id,
                                name: todolist.tds[id]!.name,
                                todolist: todolist,
                                showDateTime: true,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (showSub && hierarchy != null)
        if (hierarchy!.subs.isNotEmpty || hierarchy!.tds.isNotEmpty)
          SizedBox(height: 14.h),
      if (hierarchy == null) SizedBox(height: 14.h),
    ]);
  }
}

class TodoPiece extends StatelessWidget {
  const TodoPiece({
    super.key,
    required this.id,
    required this.name,
    required this.todolist,
    this.showDateTime = false,
    this.showProject = false,
  });

  final String name;
  final ObjectId id;
  final Todolist todolist;
  final bool showDateTime, showProject;

  @override
  Widget build(BuildContext context) {
    late bool selected, visible;
    late TD td;
    String timeStr = '', dateStr = '', projStr = '';

    Pantone.init(context);
    visible = true;
    selected = isTodoFinished(name);
    td = todolist.tds[id]!;
    if (todolist.filterType == FilterType.unfinished &&
        name.contains('\$ok\$')) {
      visible = false;
    }
    ProjectColorRecord projColor = projectColors[(
      visible
          ? td.color != null
              ? TaskColor.values.byName(td.color!)
              : td.project != null
                  ? Proj.fr(td.project!).taskColor
                  : TaskColor.green
          : TaskColor.green,
      Pantone.isDarkMode(context)
    )]!;

    timeStr = '';
    if (td.startTime != null && td.endTime != null) {
      timeStr = '${Time.fr(td.startTime!).ss} ~ ${Time.fr(td.endTime!).ss}';
    } else if (td.startTime != null) {
      timeStr = Time.fr(td.startTime!).ss;
    } else if (td.endTime != null) {
      timeStr = Time.fr(td.endTime!).ss;
    }
    if (td.date != null) {
      dateStr = Date.fr(td.date!).ss;
    }

    projStr = '';
    if (td.project != null) {
      projStr = td.project!.name;
    }
    return Visibility(
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
              String name = td.name;
              selected = value ?? false;
              if (selected) {
                name = '$name\$ok\$';
              } else {
                name = name.replaceAll('\$ok\$', '');
              }
              ECApp.realm.write(() {
                td.name = name;
                if (selected) td.finishTime = dateTimeR(DateTime.now());
              });
              todolist.tds[id] = td;
              todolist.updateCounter++;
            },
          ),
          Expanded(
            child: Bounceable(
              onTap: () async {
                PJ? pj = td.project;
                Get.replace<Todo>(Todo.fr(td));
                await context.push('/todos/detail');
                try {
                  String? status = Get.find<String?>(tag: 'status-todo');
                  if (status == 'delete') {
                    todolist.tds.remove(id);
                    if (pj == null) {
                      todolist.tdsNoPj.remove(id);
                    } else {
                      if (pj.id == todolist.parent) {
                        todolist.tdsNoPj.remove(id);
                      } else {
                        todolist.hierarchy[pj.id]!.tds.remove(id);
                      }
                    }
                    todolist.updateCounter++;
                  } else if (status == 'edit') {
                    td = Get.find<TD?>(tag: 'edited')!;
                    todolist.tds[id] = td;
                    todolist.updateCounter++;
                    Get.delete<TD?>(tag: 'edited');
                  }
                  if (status != null) {
                    Get.delete<String?>(tag: 'status-todo');
                  }
                } catch (err) {
                  print(err);
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
          if (visible && (showDateTime && td.date != null))
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              constraints: BoxConstraints(maxWidth: 180.w),
              decoration: BoxDecoration(
                color: projColor.bgColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                combineStrings(
                    [dateStr, timeStr, (showProject ? projStr : '')]),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: projColor.textColor,
                ),
              ),
            ),
          if (visible && !showDateTime && showProject && td.project != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
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
          if (!showDateTime) SizedBox(width: 20.w) else SizedBox(width: 1.w),
        ]),
      ),
    );
  }
}

class ActionsWidget extends StatefulWidget {
  const ActionsWidget(
      {super.key,
      required this.onSetFilterType,
      required this.onSetSortType,
      required this.defaultFilter,
      required this.defaultSort});

  final void Function(dynamic) onSetFilterType, onSetSortType;
  final FilterType defaultFilter;
  final SortType defaultSort;

  @override
  ActionsWidgetState createState() => ActionsWidgetState();
}

class ActionsWidgetState extends State<ActionsWidget> {
  late String filterName;
  late String sortName;
  bool filterClicking = false;
  bool sortClicking = false;

  @override
  void initState() {
    super.initState();
    filterName = filterMap[widget.defaultFilter]!;
    sortName = sortMap[widget.defaultSort]!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SpacedRow(
        spaceBetween: 12.w,
        children: [
          pod(filterName, context, () {
            if (filterClicking) {
              filterClicking = false;
            } else {
              filterClicking = true;
              sortClicking = false;
            }
            setState(() {});
          }),
          pod(sortName, context, () {
            if (sortClicking) {
              sortClicking = false;
            } else {
              sortClicking = true;
              filterClicking = false;
            }
            setState(() {});
          }),
        ],
      ),
      if (filterClicking || sortClicking)
        Padding(
          padding: EdgeInsets.only(top: 14.h),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: defaultProjColor(context).bgColor.withOpacity(0.5),
            ),
            width: 1.sw,
            child: SpacedColumn(
                spaceBetween: 12.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filterClicking
                    ? FilterType.values
                        .map(
                          (f) => typeTab(filterMap[f]!, context, () {
                            filterClicking = false;
                            widget.onSetFilterType(f);
                            filterName = filterMap[f]!;
                            setState(() {});
                          }),
                        )
                        .toList()
                    : sortClicking
                        ? SortType.values
                            .map(
                              (s) => typeTab(sortMap[s]!, context, () {
                                sortClicking = false;
                                widget.onSetSortType(s);
                                sortName = sortMap[s]!;
                                setState(() {});
                              }),
                            )
                            .toList()
                        : []),
          ),
        ),
    ]);
  }
}

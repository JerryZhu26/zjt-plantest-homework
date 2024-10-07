// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_event_bus/get_event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:spaces2/spaces2.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

/// 待办事项页面
class TodosLegacy extends StatefulWidget {
  const TodosLegacy({super.key});

  @override
  State<TodosLegacy> createState() => TodosLegacyState();
}

class TodosLegacyState extends State<TodosLegacy> {
  late List<ProjectBlock> projWidgets;
  late RealmResults<PJ> pjs;
  late RealmResults<TD> tds;

  Rx<FilterType> filterType = FilterType.none.obs;
  Rx<SortType> sortType = SortType.none.obs;
  GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();
    filterType.value =
        FilterType.values.byName(box.read("todosFilterType") ?? 'none');
    sortType.value =
        SortType.values.byName(box.read("todosSortType") ?? 'none');
    initProjects();
  }

  void initProjects() {
    pjs = ECApp.realm.query<PJ>('parent = \$0', [null]);
    projWidgets = [];
    for (var pj in pjs) {
      projWidgets.add(ProjectBlock(proj: Proj.fr(pj)));
    }
  }

  @override
  void dispose() {
    filterType.close();
    sortType.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.h,
      top: 0.h,
      left: 0.w,
      right: 0.w,
      child: ListView(children: [
        SizedBox(height: 22.h),
        Container(
          width: 60.w,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: ActionsWidget(
            defaultFilter: filterType.value,
            defaultSort: sortType.value,
            onSetFilterType: (t) {
              FilterType f = t;
              filterType.value = f;
              box.write("todosFilterType", f.name);
              Get.bus.fire(TodosFilterEvent());
              setState(() {});
            },
            onSetSortType: (t) {
              SortType s = t;
              sortType.value = s;
              box.write("todosSortType", s.name);
              Get.bus.fire(TodosSortEvent());
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: ProjectBlock(proj: null),
        ),
        if (sortType.value != SortType.time)
          Container(
            width: 60.w,
            padding: EdgeInsets.only(
              left: 25.w,
              right: 25.w,
              bottom: 110.h,
            ),
            child: Column(children: projWidgets),
          )
      ]),
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

class ProjectBlock extends StatefulWidget {
  const ProjectBlock({
    super.key,
    this.proj,
    this.textWidth,
  });

  final Proj? proj;
  final double? textWidth;

  @override
  ProjectBlockState createState() => ProjectBlockState();
}

class ProjectBlockState extends State<ProjectBlock> {
  ProjectBlockState();

  late Proj? proj;
  late double textWidth;
  late List<ProjectBlock> subWidgets;
  late RealmResults<PJ> subpjs;
  late List<TodayTodoPiece> todoWidgets, todoWidgetsFS;
  late RealmResults<TD> todos;
  late FilterType filterType;
  late SortType sortType;

  GetStorage box = GetStorage();

  bool deleted = false;
  bool showSub = false;

  @override
  void initState() {
    super.initState();
    filterType =
        FilterType.values.byName(box.read("todosFilterType") ?? 'none');
    sortType = SortType.values.byName(box.read("todosSortType") ?? 'none');
    proj = widget.proj;
    showSub = proj != null
        ? (box.read("projShowSub${proj!.project.id}") ??
            (proj!.project.parent == null))
        : true;
    textWidth = widget.textWidth ?? 245.w;
    fetchTodos();
    fetchSub();
    filterTodos();
    Get.bus.on<TodosFilterEvent>((event) {
      if (mounted) {
        filterType =
            FilterType.values.byName(box.read("todosFilterType") ?? 'none');
        fetchTodos();
        filterTodos();
        setState(() {});
      }
    });
    Get.bus.on<TodosSortEvent>((event) {
      if (mounted) {
        sortType = SortType.values.byName(box.read("todosSortType") ?? 'none');
        fetchTodos();
        filterTodos();
        setState(() {});
      }
    });
  }

  void fetchTodos() {
    if (sortType == SortType.time) {
      if (proj == null) {
        todos = ECApp.realm.query<TD>(
          'TRUEPREDICATE SORT(date.year ASC, date.month ASC, date.day ASC, startTime.hour ASC, startTime.minute ASC)',
        );
      } else {
        todos = ECApp.realm.query<TD>('project = \$0', [proj?.project]);
      }
    } else {
      todos = ECApp.realm.query<TD>('project = \$0', [proj?.project]);
    }
    todoWidgets = [];
    if (sortType == SortType.create) {
      for (var todo in todos) {
        todoWidgets.add(TodayTodoPiece(
          key: ValueKey(todo.id),
          name: todo.name,
          id: todo.id,
          showDateTime: true,
        ));
      }
    } else {
      for (var todo
          in todos.where((element) => !isTodoFinished(element.name))) {
        todoWidgets.add(TodayTodoPiece(
          key: ValueKey(todo.id),
          name: todo.name,
          id: todo.id,
          showDateTime: true,
          showProject: sortType == SortType.time,
        ));
      }
      for (var todo in todos.where((element) => isTodoFinished(element.name))) {
        todoWidgets.add(TodayTodoPiece(
          key: ValueKey(todo.id),
          name: todo.name,
          id: todo.id,
          showDateTime: true,
          showProject: sortType == SortType.time,
        ));
      }
    }
    todoWidgetsFS = todoWidgets;
  }

  void fetchSub() {
    if (showSub && proj != null) {
      subpjs = ECApp.realm.query<PJ>('parent = \$0', [proj?.project.id]);
      subWidgets = [];
      for (var pj in subpjs) {
        subWidgets.add(ProjectBlock(
          textWidth: textWidth - 17.w,
          proj: Proj.fr(pj),
        ));
      }
    } else {
      subWidgets = [];
    }
  }

  void filterTodos() {
    if (filterType == FilterType.unfinished) {
      todoWidgetsFS = todoWidgetsFS.where((element) {
        return !isTodoFinished(element.name);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    ProjectColorRecord colorSet = projectColors[(
      proj != null ? proj!.taskColor : TaskColor.green,
      Pantone.isDarkMode(context)
    )]!;
    return Visibility(
      visible: !deleted,
      child: Column(children: [
        if (proj != null)
          Bounceable(
            onTap: () async {
              Get.replace(proj!);
              await context.push('/todos/project');
              try {
                String? status = Get.find<String>(tag: 'status-proj');
                if (status == 'delete') {
                  deleted = true;
                  setState(() {});
                } else if (status == 'edit') {
                  proj = Get.find(tag: 'edited');
                  setState(() {});
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
                child: Column(
                  children: [
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
                          proj != null ? proj!.name : '',
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
                            Get.replace(proj!);
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
                            if (proj != null) {
                              box.write(
                                  "projShowSub${proj!.project.id}", showSub);
                            }
                            fetchSub();
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
                  ],
                ),
              ),
            ]),
          ),
        if (showSub && (subWidgets.isNotEmpty || todoWidgetsFS.isNotEmpty))
          SizedBox(height: 12.h),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (proj != null) SizedBox(width: 3.4.w),
              if (proj != null)
                Container(
                  width: 1.6.w,
                  color: colorSet.imgColor,
                ),
              Container(
                width: textWidth + 85.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSub)
                      Container(
                        padding: todoWidgetsFS.isNotEmpty
                            ? EdgeInsets.only(left: 6.w)
                            : EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: todoWidgetsFS,
                        ),
                      ),
                    if (showSub &&
                        (subWidgets.isNotEmpty && todoWidgetsFS.isNotEmpty))
                      SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Column(children: subWidgets),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
      ]),
    );
  }
}

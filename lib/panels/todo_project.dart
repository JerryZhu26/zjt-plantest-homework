// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:timona_ec/parts/todo_pieces.dart';
import 'package:timona_ec/stores/todolist.dart';

final todolist = Todolist();

/// 待办 - 项目
class TodoProject extends StatefulWidget {
  const TodoProject({super.key});

  @override
  State<TodoProject> createState() => TodoProjectState();
}

class TodoProjectState extends State<TodoProject> {
  final box = GetStorage();
  late Proj proj;
  late TextEditingController naco;

  TaskColor tempTaskColor = TaskColor.green;

  @override
  void initState() {
    super.initState();
    proj = Get.find();
    Get.delete<Proj>;
    naco = TextEditingController();
    todolist.fetchTodos(FilterType.none, SortType.none, proj.project.id);
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHud(
      isGlobalHud: true,
      child: ModalPage(
        title: proj.name,
        titleSvg: 'lib/assets/pencil.svg',
        titleTap: () {
          naco.text = proj.name;
          proj.name = proj.project.name;
          proj.taskColor = TaskColor.values.byName(proj.project.color);
          floatWindowSecondLine(
            naco,
            () {
              proj.name = naco.text;
              ECApp.realm.write(() {
                proj.project.name = proj.name;
                proj.project.color = proj.taskColor.name;
              });
              Get.put('edit', tag: 'status-proj');
              Get.put(proj, tag: 'edited');
              context.pop();
              setState(() {});
            },
            context,
            "编辑项目",
            "输入项目的新名称",
            Container(
              height: 37.8.h,
              padding: EdgeInsets.only(left: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColorTabs(
                    proj.taskColor,
                    (TaskColor tc) {
                      proj.taskColor = tc;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
        returnTap: proj.project.parent != null
            ? () {
                context.pop();
                todolist.fetchTodos(
                    FilterType.none, SortType.none, proj.project.parent);
              }
            : () {
                context.pop();
                context.replace('/--reload');
              },
        child: Column(children: [
          SizedBox(
            height: 625.h - MediaQuery.of(context).viewInsets.bottom,
            child: ListView(children: [
              ModalFormBox(
                borderRadius: false,
                child: Column(children: [
                  Container(
                    width: 354.w,
                    padding: EdgeInsets.only(left: 8.w, top: 8.h),
                    child: Observer(builder: (_) {
                      List<Widget> pieces = piecesFromHierarchy(
                          todolist,
                          context,
                          box,
                          todolist.updateCounter,
                          proj.project.id);
                      return Column(children: pieces);
                    }),
                  ),
                ]),
              )
            ]),
          ),
        ]),
        rightSvgs: [
          'lib/assets/add_folder.svg',
          'lib/assets/add_sm.svg',
          'lib/assets/piemenu_trash.svg'
        ],
        rightSvgTaps: [
          () {
            tempTaskColor = proj.taskColor;
            floatWindowSecondLine(
              naco,
              () async {
                Navigator.of(context).pop();
                Get.delete<Proj>();
                PJ pj = PJ(
                  ObjectId(),
                  ECApp.userId(),
                  naco.text,
                  parent: proj.project.id,
                  children: [],
                  color: tempTaskColor.name,
                );
                ECApp.realm.write(() => ECApp.realm.add(pj));
                Proj projNew = Proj.fr(pj);
                // subprojWidgets.add(ProjectBlock(proj: projNew));
                setState(() {});
                naco.clear();
                Get.put(projNew);
                context.push('/todos/project');
              },
              context,
              "新建子项目",
              "请输入子项目名称\n",
              Container(
                height: 37.8.h,
                padding: EdgeInsets.only(left: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorTabs(
                      tempTaskColor,
                      (TaskColor tc) {
                        tempTaskColor = tc;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          () async {
            Get.delete<Todo>();
            Get.replace<Proj>(proj);
            Get.replace<PJ>(proj.project);
            await context.push('/todos/add');
            context.replace('/--reload/todos/project');
          },
          () {
            showCheckSheet("确定删除 ${proj.name} 吗？不可撤销", context, () {
              ECApp.realm.write(() {
                ECApp.realm.delete<PJ>(proj.project);
              });
              Get.put('delete', tag: 'status-proj');
              context.pop();
              context.replace('/--reload');
            });
          },
        ],
      ),
    );
  }
}

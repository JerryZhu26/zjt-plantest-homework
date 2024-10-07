// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/todo_pieces.dart';
import 'package:timona_ec/stores/todolist.dart';

final todolist = Todolist();

/// 待办事项页面
class Todos extends StatefulWidget {
  const Todos({super.key});

  @override
  State<Todos> createState() => TodosState();
}

class TodosState extends State<Todos> {
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
    todolist.fetchTodos(filterType.value, sortType.value, null);
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
              todolist.filterType = f;
              setState(() {});
            },
            onSetSortType: (t) {
              SortType s = t;
              sortType.value = s;
              box.write("todosSortType", s.name);
              todolist.sortType = s;
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: 60.w,
          padding: EdgeInsets.only(
            left: 25.w,
            right: 25.w,
            bottom: 110.h,
          ),
          child: Observer(builder: (_) {
            List<Widget> pieces = piecesFromHierarchy(
                todolist, context, box, todolist.updateCounter, null);
            return Column(children: pieces);
          }),
        )
      ]),
    );
  }
}

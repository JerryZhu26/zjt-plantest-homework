// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/main.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

part 'todolist.g.dart';

class Todolist = _Todolist with _$Todolist;

class TodosHierarchyItem {
  ObjectId self;
  List<ObjectId> subs;
  List<ObjectId> tds;

  TodosHierarchyItem({
    required this.self,
    required this.subs,
    required this.tds,
  });
}

abstract class _Todolist with Store {
  @observable
  ObservableMap<ObjectId, TD> tds = ObservableMap<ObjectId, TD>();

  @observable
  ObservableMap<ObjectId, PJ> pjs = ObservableMap<ObjectId, PJ>();

  @observable
  ObservableList<ObjectId> roots = ObservableList<ObjectId>();

  @observable
  ObservableMap<ObjectId, TodosHierarchyItem> hierarchy =
      ObservableMap<ObjectId, TodosHierarchyItem>();

  @observable
  ObservableList<ObjectId> tdsNoPj = ObservableList<ObjectId>();

  @observable
  FilterType filterType = FilterType.none;

  @observable
  SortType sortType = SortType.none;

  // 更改 td 具体内容不会触发更新，因此需要手动触发
  @observable
  int updateCounter = 0;

  // 当前页面的渲染根，用于 project 界面
  @observable
  ObjectId? parent;

  @action
  void initialize() {
    tds.clear();
    pjs.clear();
    roots.clear();
    hierarchy.clear();
    tdsNoPj.clear();
    filterType = FilterType.none;
    sortType = SortType.none;
    parent = null;
  }

  @action
  void addPj(PJ pj) {
    pjs[pj.id] = pj;
    hierarchy[pj.id] =
        TodosHierarchyItem(self: pj.id, subs: pj.children.toList(), tds: []);
    if (pj.parent == null) roots.add(pj.id);
  }

  @action
  void removePj(ObjectId id) {
    pjs.remove(id);
    hierarchy.remove(id);
    if (roots.contains(id)) roots.remove(id);
  }

  @action
  void fetchTodos(
      FilterType newFilterType, SortType newSortType, ObjectId? newParent) {
    initialize();
    filterType = newFilterType;
    sortType = newSortType;
    parent = newParent;
    print(parent);
    // 产生 pjs 的结果
    RealmResults<PJ> newPjs = ECApp.realm.query<PJ>('parent = \$0', [parent]);
    for (var pj in newPjs) {
      roots.add(pj.id);
    }
    newPjs = ECApp.realm.all<PJ>();
    for (var pj in newPjs) {
      pjs[pj.id] = pj;
    }
    // 产生 hierarchy 的结果
    for (var pj in [null, ...newPjs]) {
      if (pj == null && parent != null) {
        pj = ECApp.realm.query<PJ>('id = \$0', [parent]).first;
      }
      List<ObjectId> tdList = ECApp.realm.query<TD>('project = \$0', [pj]).map(
        (td) {
          tds[td.id] = td;
          return td.id;
        },
      ).toList();
      if (pj != null) {
        if (pj.id != parent) {
          var subpjs = ECApp.realm.query<PJ>('parent = \$0', [pj.id]);
          hierarchy[pj.id] = TodosHierarchyItem(
            self: pj.id,
            subs: subpjs.map((pj) => pj.id).toList(),
            tds: tdList,
          );
        } else {
          tdsNoPj = ObservableList.of([...tdList]);
        }
      } else {
        tdsNoPj = ObservableList.of([...tdList]);
      }
    }
  }
}

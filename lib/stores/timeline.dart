// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'package:realm/realm.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';

part 'timeline.g.dart';

class Timeline = _Timeline with _$Timeline;

abstract class _Timeline with Store {
  @observable
  ObservableList<Map<int, Set<ObjectId>>> line =
      ObservableList<Map<int, Set<ObjectId>>>.of([{}, {}]);

  @observable
  ObservableMap<ObjectId, TK> tks = ObservableMap<ObjectId, TK>();

  @observable
  ObservableList<TD> tdsToday = ObservableList<TD>();

  @action
  void initialize() {
    line.clear();
    tks.clear();
    tdsToday.clear();
    line.add({});
    line.add({});
    for (int i = 0; i < 60 * 24; i++) {
      line[0][i] = {};
      line[1][i] = {};
    }
  }

  @action
  void add(ObjectId id, Time startTime, Time endTime, Side side) {
    // 如果设定 8:00 - 9:00，实际记录 8:00 - 8:59
    for (int i = startTime.comparable; i < endTime.comparable; i++) {
      line[sideIndex(side)][i]!.add(id);
    }
  }

  @action
  void remove(ObjectId id, Time startTime, Time endTime, Side side) {
    for (int i = startTime.comparable; i < endTime.comparable; i++) {
      if (line[sideIndex(side)][i] != null) {
        if (line[sideIndex(side)][i]!.contains(id)) {
          line[sideIndex(side)][i]!.remove(id);
        }
      } else {
        print('line[${sideIndex(side)}][$i] is null, which should not happen');
      }
    }
  }
}

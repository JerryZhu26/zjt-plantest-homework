// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/pages/central.dart';
import 'package:timona_ec/pages/history.dart';
import 'package:timona_ec/pages/my.dart';
import 'package:timona_ec/pages/todos.dart';
import 'package:timona_ec/parts/bars.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:window_manager/window_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.topBarHoldUp});

  final bool? topBarHoldUp;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final box = GetStorage();
  int whichScreen = 3;
  bool gotWhichScreen = false;

  @override
  void initState() {
    super.initState();
    if (box.hasData('whichScreen')) {
      whichScreen = box.read('whichScreen');
    }
    gotWhichScreen = true;
    Get.put(DayAt(Date.now()));
  }

  void bottomClick(int which) {
    whichScreen = which;
    box.write('whichScreen', which);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    topDeco = BoxDecoration(
      gradient: LinearGradient(colors: [Pantone.bg!, Pantone.bgSemiLight!]),
    );
    return ProgressHud(
      isGlobalHud: true,
      child: Container(
        decoration:
            whichScreen != 4 ? topDeco : BoxDecoration(color: Pantone.green),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(isIPad(context) ? 0.82 : 1.0),
          ),
          child: SafeArea(
            bottom: false,
            child: Scaffold(
              body: Container(
                color: Pantone.white,
                child: gotWhichScreen
                    ? Column(children: [
                        if (whichScreen != 4)
                          DragToMoveArea(
                            child: TopBar(
                              initialHoldUp: widget.topBarHoldUp ?? false,
                              whichScreen: whichScreen,
                            ),
                          ),
                        Expanded(
                          child: Stack(children: [
                            if (whichScreen == 2)
                              Central()
                            else if (whichScreen == 1)
                              History()
                            else if (whichScreen == 4)
                              My()
                            else
                              Todos(),
                            BottomBar(click: bottomClick),
                            BottomAdd(),
                          ]),
                        ),
                      ])
                    : Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:timona_ec/libraries/camerawesome/buttons_override.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';

class CameraPanel extends StatefulWidget {
  const CameraPanel({super.key, required this.from});

  final String from;

  @override
  CameraPanelState createState() => CameraPanelState();
}

class CameraPanelState extends State<CameraPanel> with WidgetsBindingObserver {
  CameraPanelState();

  @override
  void initState() {
    super.initState();
  }

  // https://github.com/Apparence-io/CamerAwesome
  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.photo(),
      onMediaTap: (mediaCapture) {},
      progressIndicator:
          CupertinoActivityIndicator(color: Pantone.white, radius: 20.w),
      topActionsBuilder: (state) => AwesomeTopActions(
        state: state,
        children: [
          AwesomeBouncingWidget(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(0.0),
              child: AwesomeCircleWidget(
                child: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          AwesomeZoomSelectorFix(state: state),
        ],
      ),
      middleContentBuilder: (state) {
        return Column(children: []);
      },
      bottomActionsBuilder: (state) => AwesomeBottomActionsCustomCaptureButton(
        state: state,
        padding: isIOS()
            ? EdgeInsets.only(top: 24, bottom: 4)
            : EdgeInsets.symmetric(vertical: 14),
        left: AwesomeFlashButton(
          state: state,
          iconBuilder: (flashMode) {
            switch (flashMode) {
              case FlashMode.none:
                return Icon(CupertinoIcons.bolt_slash, color: Colors.white);
              case FlashMode.always:
                return Icon(CupertinoIcons.lightbulb, color: Colors.white);
              case FlashMode.auto:
                return Icon(CupertinoIcons.bolt_badge_a, color: Colors.white);
              case FlashMode.on:
                return Icon(CupertinoIcons.bolt, color: Colors.white);
              default:
                return Container();
            }
          },
        ),
        captureButton: AwesomeCaptureButtonCustomWidth(state: state, width: 70),
        right: AwesomeCameraSwitchButton(
          state: state,
          scale: 1.0,
          iconBuilder: () {
            return Icon(CupertinoIcons.switch_camera, color: Colors.white);
          },
          onSwitchTap: (state) {
            state.switchCameraSensor(
              aspectRatio: state.sensorConfig.aspectRatio,
            );
          },
        ),
      ),
    );
  }
}

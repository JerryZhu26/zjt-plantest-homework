// ignore_for_file: library_private_types_in_public_api, implementation_imports

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AwesomeBottomActionsCustomCaptureButton extends StatelessWidget {
  final CameraState state;
  final Widget left;
  final Widget right;
  final Widget captureButton;
  final EdgeInsets padding;

  AwesomeBottomActionsCustomCaptureButton({
    super.key,
    required this.state,
    Widget? left,
    Widget? right,
    Widget? captureButton,
    OnMediaTap? onMediaTap,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  })  : captureButton = captureButton ??
            AwesomeCaptureButton(
              state: state,
            ),
        left = left ??
            (state is VideoRecordingCameraState
                ? AwesomePauseResumeButton(
                    state: state,
                  )
                : Builder(builder: (context) {
                    final theme = AwesomeThemeProvider.of(context).theme;
                    return AwesomeCameraSwitchButton(
                      state: state,
                      theme: theme.copyWith(
                        buttonTheme: theme.buttonTheme.copyWith(
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    );
                  })),
        right = right ??
            (state is VideoRecordingCameraState
                ? const SizedBox(width: 48)
                : StreamBuilder<MediaCapture?>(
                    stream: state.captureState$,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(width: 60, height: 60);
                      }
                      return SizedBox(
                        width: 60,
                        child: AwesomeMediaPreview(
                          mediaCapture: snapshot.requireData,
                          onMediaTap: onMediaTap,
                        ),
                      );
                    },
                  ));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Center(
              child: left,
            ),
          ),
          captureButton,
          Expanded(
            child: Center(
              child: right,
            ),
          ),
        ],
      ),
    );
  }
}

class AwesomeCaptureButtonCustomWidth extends StatefulWidget {
  final CameraState state;
  final double width;

  const AwesomeCaptureButtonCustomWidth({
    super.key,
    required this.state,
    required this.width,
  });

  @override
  _AwesomeCaptureButtonCustomWidthState createState() =>
      _AwesomeCaptureButtonCustomWidthState();
}

class _AwesomeCaptureButtonCustomWidthState
    extends State<AwesomeCaptureButtonCustomWidth>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _scale;
  final Duration _duration = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is AnalysisController) {
      return Container();
    }
    _scale = 1 - _animationController.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        key: const ValueKey('cameraButton'),
        height: widget.width,
        width: widget.width,
        child: Transform.scale(
          scale: _scale,
          child: CustomPaint(
            painter: widget.state.when(
              onPhotoMode: (_) => CameraButtonPainter(widget.width),
              onPreparingCamera: (_) => CameraButtonPainter(widget.width),
              onVideoMode: (_) => VideoButtonPainter(widget.width),
              onVideoRecordingMode: (_) =>
                  VideoButtonPainter(widget.width, isRecording: true),
            ),
          ),
        ),
      ),
    );
  }

  _onTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    _animationController.forward();
  }

  _onTapUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _animationController.reverse();
    });

    onTap.call();
  }

  _onTapCancel() {
    _animationController.reverse();
  }

  get onTap => () {
        widget.state.when(
          onPhotoMode: (photoState) => photoState.takePhoto(),
          onVideoMode: (videoState) => videoState.startRecording(),
          onVideoRecordingMode: (videoState) => videoState.stopRecording(),
        );
      };
}

class CameraButtonPainter extends CustomPainter {
  final double width;

  CameraButtonPainter(this.width);

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    bgPainter.color = Colors.white;
    canvas.drawCircle(center, radius - 8, bgPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class VideoButtonPainter extends CustomPainter {
  final bool isRecording;
  final double width;

  VideoButtonPainter(
    this.width, {
    this.isRecording = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    if (isRecording) {
      bgPainter.color = Colors.red;
      double n17 = 17 * width / 80;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                n17,
                n17,
                size.width - (n17 * 2),
                size.height - (n17 * 2),
              ),
              const Radius.circular(12.0)),
          bgPainter);
    } else {
      bgPainter.color = Colors.red;
      canvas.drawCircle(center, radius - 8, bgPainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AwesomeZoomSelectorFix extends StatefulWidget {
  final CameraState state;

  const AwesomeZoomSelectorFix({
    super.key,
    required this.state,
  });

  @override
  State<AwesomeZoomSelectorFix> createState() => _AwesomeZoomSelectorFixState();
}

class _AwesomeZoomSelectorFixState extends State<AwesomeZoomSelectorFix> {
  double? minZoom;
  double? maxZoom;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  initAsync() async {
    try {
      minZoom = await CamerawesomePlugin.getMinZoom();
      maxZoom = await CamerawesomePlugin.getMaxZoom();
    } catch (_) {
      minZoom = 1;
      maxZoom = 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorConfig>(
      stream: widget.state.sensorConfig$,
      builder: (context, sensorConfigSnapshot) {
        initAsync();
        if (sensorConfigSnapshot.data == null ||
            minZoom == null ||
            maxZoom == null) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<double>(
          stream: sensorConfigSnapshot.requireData.zoom$,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _ZoomIndicatorLayout(
                zoom: snapshot.requireData,
                min: minZoom!,
                max: maxZoom!,
                sensorConfig: widget.state.sensorConfig,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}

class _ZoomIndicatorLayout extends StatelessWidget {
  final double zoom;
  final double min;
  final double max;
  final SensorConfig sensorConfig;

  const _ZoomIndicatorLayout({
    required this.zoom,
    required this.min,
    required this.max,
    required this.sensorConfig,
  });

  @override
  Widget build(BuildContext context) {
    final displayZoom = (max - min) * zoom + min;
    if (min == 1.0) {
      // Assume there's only one lens for zooming purpose, only display current zoom
      return _ZoomIndicator(
        normalValue: 0.0,
        zoom: zoom,
        selected: true,
        min: min,
        max: max,
        sensorConfig: sensorConfig,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Show 3 dots for zooming: min, 1.0X and max zoom. The closer one shows
        // text, the other ones a dot.
        _ZoomIndicator(
          normalValue: 0.0,
          zoom: zoom,
          selected: displayZoom < 1.0,
          min: min,
          max: max,
          sensorConfig: sensorConfig,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _ZoomIndicator(
            normalValue: (1 - min) / (max - min),
            zoom: zoom,
            selected: !(displayZoom < 1.0 || displayZoom == max),
            min: min,
            max: max,
            sensorConfig: sensorConfig,
          ),
        ),
        _ZoomIndicator(
          normalValue: 1.0,
          zoom: zoom,
          selected: displayZoom == max,
          min: min,
          max: max,
          sensorConfig: sensorConfig,
        ),
      ],
    );
  }
}

class _ZoomIndicator extends StatelessWidget {
  final double zoom;
  final double min;
  final double max;
  final double normalValue;
  final SensorConfig sensorConfig;
  final bool selected;

  const _ZoomIndicator({
    required this.zoom,
    required this.min,
    required this.max,
    required this.normalValue,
    required this.sensorConfig,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = AwesomeThemeProvider.of(context).theme;
    final baseButtonTheme = baseTheme.buttonTheme;
    final displayZoom = (max - min) * zoom + min;
    Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (child, anim) {
        return ScaleTransition(scale: anim, child: child);
      },
      child: selected
          ? AwesomeBouncingWidget(
              key: ValueKey("zoomIndicator_${normalValue}_selected"),
              onTap: () {
                sensorConfig.setZoom(normalValue);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(0.0),
                child: AwesomeCircleWidget(
                  theme: baseTheme,
                  child: Text(
                    "${displayZoom.toStringAsFixed(1)}X",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            )
          : AwesomeBouncingWidget(
              key: ValueKey("zoomIndicator_${normalValue}_unselected"),
              onTap: () {
                sensorConfig.setZoom(normalValue);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16.0),
                child: AwesomeCircleWidget(
                  theme: baseTheme.copyWith(
                    buttonTheme: baseButtonTheme.copyWith(
                      backgroundColor: baseButtonTheme.foregroundColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  child: const SizedBox(width: 6, height: 6),
                ),
              ),
            ),
    );

    // Same width for each dot to keep them in their position
    return SizedBox(
      width: 56,
      child: Center(
        child: content,
      ),
    );
  }
}

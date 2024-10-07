// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:timona_ec/env.g.dart';
import 'package:timona_ec/home.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/pages/my.dart';
import 'package:timona_ec/pages/timer.dart';
import 'package:timona_ec/panels/ai_history.dart';
import 'package:timona_ec/panels/camera.dart';
import 'package:timona_ec/panels/detail.dart';
import 'package:timona_ec/panels/login.dart';
import 'package:timona_ec/panels/rate_hour.dart';
import 'package:timona_ec/panels/report.dart';
import 'package:timona_ec/panels/timer_together.dart';
import 'package:timona_ec/panels/todo_detail.dart';
import 'package:timona_ec/panels/todo_project.dart';
import 'package:timona_ec/parts/color.dart';
import 'package:timona_ec/parts/general.dart';
import 'package:timona_ec/parts/schemas.dart';
import 'package:window_manager/window_manager.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /*FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains(
        'Cannot hit test a render box that has never been laid out')) {
      print('Cannot hit test a render box that has never been laid out');
    } else if (details.exception
        .toString()
        .contains('A RenderFlex overflowed by')) {
      print(details
          .toString()
          .split('The following assertion was thrown during layout:')[1]
          .split('The relevant error-causing widget was:')[0]
          .replaceAll('\n', ''));
    } else {
      throw details.exception;
    }
  };*/

  await GetStorage.init();
  OpenAI.apiKey = Env.openAiApiKey;
  OpenAI.baseUrl = "https://api.chatanywhere.com.cn";

  final box_ = GetStorage();
  final MethodChannel channel_ = MethodChannel('scris.plnm/alarm');
  showOverlay(DateTime.now(), false, '\$init\$', channel_, box_)
      .then((value) => hideOverlay(channel_, box_));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await ScreenUtil.ensureScreenSize();

  ECApp.realm = Realm(configRealm());

  await sb.Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    realtimeClientOptions: const sb.RealtimeClientOptions(eventsPerSecond: 1),
  );

  final box = GetStorage();
  box.write("duringTogether", false);

  runApp(ECApp());

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  if (isAndroid()) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  showHud(ProgressHudType.success, title ?? body ?? '');
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
}

class ECApp extends StatelessWidget {
  ECApp({super.key});

  static late Realm realm;
  static sb.RealtimeChannel? companionChannel;
  static sb.RealtimeChannel? togetherChannel;
  static String? togetherChannelName;
  static bool afterTogetherChannelDel = false;
  static FlutterLocalNotificationsPlugin notifier =
      flutterLocalNotificationsPlugin;

  final _router = GoRouter(
    routes: [
      route('/', child: Home()),
      route(
        '/--animate-left',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: DefaultTextStyle(style: defaultTextStyle, child: Home()),
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                  Tween(begin: Offset(-1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.decelerate))),
              child: child,
            );
          },
        ),
      ),
      route(
        '/--animate-right',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: DefaultTextStyle(style: defaultTextStyle, child: Home()),
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                  Tween(begin: Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.decelerate))),
              child: child,
            );
          },
        ),
      ),
      // TBHU = Top Bar is Holding Up
      route('/--tbhu', child: Home(topBarHoldUp: true)),
      route('/--reload', child: Jump('/')),
      route('/--reload/todos/project', child: Jump('/todos/project')),
      route('/--reload-animate-left', child: Jump('/', flag: 'animate, left')),
      route('/--reload-animate-right',
          child: Jump('/', flag: 'animate, right')),
      route('/--reload-tbhu', child: Jump('/--tbhu')),
      route('/--reload-history', child: Jump('/', flag: 'history')),
      route('/--reload-history-tbhu', child: Jump('/--tbhu', flag: 'history')),
      route('/camera/--from-timer', child: CameraPanel(from: "/timer")),
      route('/camera/--from-task', child: CameraPanel(from: "/")),
      route('/history/report', child: DailyReport()),
      route('/login', child: LoginPanel()),
      route(
        '/timer',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: DefaultTextStyle(style: defaultTextStyle, child: Timer()),
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                  Tween(begin: Offset(0.0, 0.75), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut))),
              child: child,
            );
          },
        ),
      ),
      route(
        '/timer/--index',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: DefaultTextStyle(
              style: defaultTextStyle, child: Timer(from: 'index')),
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                  Tween(begin: Offset(0.0, 0.75), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut))),
              child: child,
            );
          },
        ),
      ),
      route('/timer/together/go', child: Timer(together: true)),
      route(
        '/timer/together',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: DefaultTextStyle(style: defaultTextStyle, child: Together()),
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                  Tween(begin: Offset(0.0, 0.75), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut))),
              child: child,
            );
          },
        ),
      ),
      route('/todos/detail', child: TodoDetail(adding: false)),
      route('/todos/add', child: TodoDetail(adding: true)),
      route('/todos/project', child: TodoProject()),
      route('/detail', child: Detail(adding: false)),
      route('/add', child: Detail(adding: true)),
      route('/rate/hour', child: HourRate()),
      route('/my', child: My()),
      route('/my/imported', child: ImportedPage()),
      route('/ai/history', child: AiHistory()),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Pantone.init(context);
    ScreenUtil.init(
      context,
      designSize: const Size(390, 844),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PieCanvas(
        child: MaterialApp.router(
          //showPerformanceOverlay: true,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: Pantone.isDarkMode(context)
                ? ColorScheme.dark(primary: Pantone.green!)
                : ColorScheme.light(primary: Pantone.green!),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, //多加这行代码
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('zh', 'CN'),
          ],
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  static String userId() {
    return 'local';
  }
}

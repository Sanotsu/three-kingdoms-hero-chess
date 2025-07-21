import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/main_router.dart';

import 'utils/screen_helper.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  AppCatchError().run();
}

//全局异常的捕捉
class AppCatchError {
  run() {
    ///Flutter 框架异常
    FlutterError.onError = (FlutterErrorDetails details) async {
      ///线上环境 todo
      if (kReleaseMode) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      } else {
        //开发期间 print
        FlutterError.dumpErrorToConsole(details);
      }
    };

    runZonedGuarded(() {
      //受保护的代码块
      WidgetsFlutterBinding.ensureInitialized();

      // 设置系统UI，状态栏和导航栏为透明
      // SystemChrome.setSystemUIOverlayStyle(
      //   const SystemUiOverlayStyle(
      //     statusBarColor: Colors.transparent,
      //     systemNavigationBarColor: Colors.transparent,
      //     statusBarIconBrightness: Brightness.dark,
      //     systemNavigationBarIconBrightness: Brightness.dark,
      //   ),
      // );

      // 隐藏状态栏和导航栏
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [], // 不显示任何系统UI
      );

      // 设置为横屏模式并隐藏状态栏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]).then((_) async {
        runApp(const HeroChessApp());
      });
    }, (error, stack) => catchError(error, stack));
  }

  /// 对搜集的异常、或者指定的一些异常进行处理、上报等特殊处理
  catchError(Object error, StackTrace stack) async {
    //是否是 Release版本
    debugPrint("AppCatchError>>>>>>>>>> [ kReleaseMode ] $kReleaseMode");
    debugPrint('AppCatchError>>>>>>>>>> [ Message ] $error');
    debugPrint('AppCatchError>>>>>>>>>> [ Stack ] \n$stack');
  }
}

class HeroChessApp extends StatelessWidget {
  const HeroChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        ScreenHelper.designWidth,
        ScreenHelper.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
          child: MaterialApp(
            title: '三分英雄棋',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
              useMaterial3: true,
              // 如果想使用其他字体或者默认字体，修改这里即可
              // 我是看到使用不使用apk打包大小没什么区别才保留的
              fontFamily: 'QingkeHuangyou',
            ),
            home: const MainRouter(),
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  builder: (context) => const MainRouter(),
                );
              }
              return null;
            },
            builder: (context, child) {
              // 根据平台调整字体缩放
              child = MediaQuery(
                ///设置文字大小不随系统设置改变
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    (ScreenHelper.isWeb() || ScreenHelper.isDesktop())
                        ? 1.0
                        : 1.0,
                  ),
                ),
                child: child!,
              );

              // 1 先初始化 bot_toast
              child = BotToastInit()(context, child);

              return child;
            },
            // 2. registered route observer
            navigatorObservers: [BotToastNavigatorObserver()],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 屏幕适配工具类
class ScreenHelper {
  // 设计稿尺寸
  static const double designWidth = 960;
  static const double designHeight = 540;

  static bool isWeb() => kIsWeb;

  /// 判断是否为桌面平台（Windows, macOS, Linux），包括网页
  static bool isDesktop() =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux || kIsWeb;

  /// 判断是否为移动平台（Android, iOS）
  static bool isMobile() => Platform.isAndroid || Platform.isIOS;

  // 初始化屏幕适配
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(designWidth, designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  // 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  // 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  // 根据设计稿尺寸适配宽度
  static double setWidth(double width) => width.w;

  // 根据设计稿尺寸适配高度
  static double setHeight(double height) => height.h;

  // 适配字体大小
  static double setSp(double fontSize) => fontSize.sp;

  // 适配半径
  static double setRadius(double radius) => radius.r;

  // 检查设备是否为平板
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        (size.width * size.width + size.height * size.height) / 1000;
    return diagonal > 9.0; // 对角线大于9英寸认为是平板
  }

  // 强制横屏
  static void forceOrientation() {
    // 在main.dart中调用SystemChrome.setPreferredOrientations
  }
}

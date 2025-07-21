import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 游戏按钮组件
class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color color;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.color = Colors.amber,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: ScreenHelper.setWidth(width ?? 200.sp),
        height: ScreenHelper.setHeight(height ?? 48.sp),
        decoration: BoxDecoration(
          color: isEnabled ? color : Colors.grey,
          borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.r,
                    offset: Offset(0, 5.sp),
                  ),
                ]
              : null,
          gradient: isEnabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withValues(alpha: 0.7)],
                )
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: ScreenHelper.setSp(fontSize ?? 24.sp),
                ),
                SizedBox(width: 10.sp),
              ],
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(fontSize ?? 24.sp),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

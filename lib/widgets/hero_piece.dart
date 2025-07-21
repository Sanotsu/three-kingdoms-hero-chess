import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/models/hero_model.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 英雄棋子组件
class HeroPiece extends StatelessWidget {
  final HeroModel hero;
  final Function(HeroModel) onTap;
  // 控制棋子大小(其实如果外面有容器包裹，这个宽高意义不大)
  final double? width;
  final double? height;

  const HeroPiece({
    super.key,
    required this.hero,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // 使用提供的size或默认值
    final pieceSize = width ?? 60.sp;
    final pieceHeight =
        height ?? (hero.isSelected ? pieceSize * 1.2 : pieceSize);

    // print('棋子大小: $pieceSize 棋子高度: $pieceHeight');

    return GestureDetector(
      onTap: () => onTap(hero),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: pieceSize * 0.08),
        width: pieceSize,
        height: pieceHeight,
        decoration: BoxDecoration(
          color: hero.campColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
          border: Border.all(
            color: hero.isSelected ? Colors.yellow : Colors.transparent,
            width: 2.sp,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.r,
              offset: Offset(0, 3.sp),
            ),
          ],
        ),
        transform: Matrix4.translationValues(
          0.0,
          hero.isSelected ? -pieceHeight * 0.3 : 0.0,
          0.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 阵营标识
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: pieceSize * 0.05,
                vertical: pieceHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(ScreenHelper.setRadius(5)),
              ),
              child: Text(
                hero.camp,
                style: TextStyle(
                  color: hero.campColor,
                  fontSize: pieceHeight * 0.16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: pieceHeight * 0.05),
            // 英雄名称
            Text(
              hero.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: pieceHeight * 0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: pieceHeight * 0.05),
            // 基础分数
            Text(
              '${hero.baseScore}分',
              style: TextStyle(
                color: hero.isActive ? Colors.orange : Colors.white70,
                fontSize: pieceHeight * 0.16,
                fontWeight: hero.isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

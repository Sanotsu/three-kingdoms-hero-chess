import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 锦囊卡片组件
class JinNangCard extends StatelessWidget {
  final JinNangModel jinNang;
  // 是否可选
  final bool isSelectable;
  // 是否被选中
  final bool isSelected;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  const JinNangCard({
    super.key,
    required this.jinNang,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 150.sp,
        height: height ?? 240.sp,
        margin: EdgeInsets.symmetric(horizontal: 10.sp),
        decoration: BoxDecoration(
          color: jinNang.levelColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(ScreenHelper.setRadius(12)),
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 2.sp)
              : Border.all(
                  color: jinNang.isActive ? Colors.yellow : Colors.white30,
                  width: 2.sp,
                ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.yellow.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: isSelected ? 10 : 5,
              spreadRadius: isSelected ? 2 : 1,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              jinNang.levelColor,
              jinNang.levelColor.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 锦囊等级
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                jinNang.level,
                (index) => Icon(Icons.star, color: Colors.yellow, size: 15.sp),
              ),
            ),
            SizedBox(height: 10.sp),
            // 锦囊名称
            Text(
              jinNang.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenHelper.setSp(18),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10.sp),

            // 锦囊类型
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(ScreenHelper.setRadius(5)),
              ),
              child: Text(
                jinNang.type,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(12),
                ),
              ),
            ),
            SizedBox(height: 10.sp),

            // 锦囊效果
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              height: 56.sp,
              child: Text(
                jinNang.effect,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(12),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5.sp),
            // 锦囊数值
            Text(
              _getValueText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenHelper.setSp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            // 永久生效标识
            if (jinNang.isPermanent)
              Padding(
                padding: EdgeInsets.only(top: 5.sp),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 5.sp,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(
                      ScreenHelper.setRadius(10),
                    ),
                  ),
                  child: Text(
                    '永久生效',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenHelper.setSp(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getValueText() {
    if (jinNang.type == '增益') {
      if (jinNang.name == '三思而行' || jinNang.name == '连环攻势') {
        return '+${jinNang.value}次';
      } else {
        return '+${jinNang.value}%';
      }
    } else if (jinNang.type == '基础得分') {
      return '+${jinNang.value}分';
    } else {
      return '+${jinNang.value}%';
    }
  }
}

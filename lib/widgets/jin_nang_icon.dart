import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/jin_nang_card.dart';

/// 锦囊图标组件，用于游戏界面右侧显示
class JinNangIcon extends StatelessWidget {
  final JinNangModel jinNang;
  final VoidCallback? onTap;

  const JinNangIcon({super.key, required this.jinNang, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showJinNangDetails(context);
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        width: 90.sp,
        height: 36.sp,
        margin: EdgeInsets.only(bottom: 5.sp),
        decoration: BoxDecoration(
          color: jinNang.isActive
              ? jinNang.levelColor
              : jinNang.levelColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(ScreenHelper.setRadius(8)),
          border: Border.all(
            color: jinNang.isActive ? Colors.yellow : Colors.white30,
            width: jinNang.isActive ? 2.sp : 1.sp,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 锦囊名称
            Expanded(
              child: Text(
                jinNang.name,
                style: TextStyle(
                  color: jinNang.isActive ? Colors.white : Colors.white70,
                  fontSize: ScreenHelper.setSp(12),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 锦囊等级星星
            Container(
              padding: EdgeInsets.only(right: 2.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  jinNang.level,
                  (index) => Icon(
                    Icons.star,
                    color: jinNang.isActive ? Colors.yellow : Colors.white70,
                    size: 8.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示锦囊详情
  void _showJinNangDetails(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: '锦囊详情',
      pageBuilder: (_, _, _) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: JinNangCard(jinNang: jinNang),
            ),
          ),
        );
      },
    );
  }
}

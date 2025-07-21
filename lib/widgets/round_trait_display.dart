import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/models/round_trait_model.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 轮次特性显示组件
class RoundTraitDisplay extends StatelessWidget {
  final RoundTraitModel trait;

  const RoundTraitDisplay({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
        border: Border.all(color: Colors.green, width: 1.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.green,
            size: ScreenHelper.setSp(18),
          ),
          SizedBox(width: 5.sp),
          Text(
            '本轮特性:',
            style: TextStyle(
              color: Colors.green,
              fontSize: ScreenHelper.setSp(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5.sp),
          Text(
            trait.getDescription(),
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenHelper.setSp(14),
            ),
          ),
        ],
      ),
    );
  }
}

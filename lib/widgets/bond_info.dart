import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/models/bond_model.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 羁绊信息组件
class BondInfo extends StatelessWidget {
  final BondModel? bond;
  final int? baseScore;
  final int? rateMultiplier;
  final int? totalScore;

  const BondInfo({
    super.key,
    this.bond,
    this.baseScore,
    this.rateMultiplier,
    this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black54,
        // borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.amber, width: 1.sp),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 得分详情
          Center(
            child: Text(
              "预计得分:",
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 10.sp),
          _buildScoreItem("${baseScore ?? '基础得分'}"),
          SizedBox(
            width: 24.sp,
            child: Center(
              child: Text("x", style: TextStyle(color: Colors.white)),
            ),
          ),
          _buildScoreItem(rateMultiplier != null ? '$rateMultiplier%' : '得分倍率'),

          if (totalScore != null) ...[
            SizedBox(
              width: 24.sp,
              child: Center(
                child: Text("=", style: TextStyle(color: Colors.white)),
              ),
            ),
            _buildScoreItem(totalScore.toString(), isTotal: true),
          ],

          // 羁绊名称
          if (bond != null) ...[
            SizedBox(width: 20.sp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
                border: Border.all(color: Colors.amber, width: 1.sp),
              ),
              child: Center(
                child: Text(
                  bond!.name,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: ScreenHelper.setSp(18),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreItem(String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.amber : Colors.white,
            fontSize: isTotal ? ScreenHelper.setSp(20) : ScreenHelper.setSp(18),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

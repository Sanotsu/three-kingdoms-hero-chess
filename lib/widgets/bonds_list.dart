import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tk_hero_chess/constants/game_constants.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 羁绊列表组件
class BondsList extends StatelessWidget {
  final VoidCallback onClose;

  const BondsList({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210.sp,
      height: double.infinity,
      color: Colors.black87,
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            color: Colors.amber,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '羁绊信息',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: ScreenHelper.setSp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 羁绊列表
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(10.sp),
              children: [
                _buildSectionTitle('特定羁绊'),
                _buildSpecificBonds(),
                SizedBox(height: 5.sp),
                _buildSectionTitle('同阵营羁绊'),
                _buildCampBonds(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      margin: EdgeInsets.only(bottom: 10.sp),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.amber, width: 1.sp),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber,
          fontSize: ScreenHelper.setSp(18),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpecificBonds() {
    List<Widget> bondWidgets = [];

    GameConstants.bondDefinitions.forEach((name, def) {
      if (def.containsKey('heroes')) {
        bondWidgets.add(
          _buildBondItem(
            name,
            def['heroes'].join('、'),
            def['baseScore'],
            def['rateMultiplier'],
          ),
        );
      }
    });

    return Column(children: bondWidgets);
  }

  Widget _buildCampBonds() {
    List<Widget> bondWidgets = [];

    for (int i = 1; i <= 5; i++) {
      final bondDef = GameConstants.bondDefinitions['同阵营X$i']!;
      bondWidgets.add(
        _buildBondItem(
          '同阵营X$i',
          '任意同一阵营$i个英雄',
          bondDef['baseScore'],
          bondDef['rateMultiplier'],
        ),
      );
    }

    return Column(children: bondWidgets);
  }

  Widget _buildBondItem(
    String name,
    String heroes,
    int baseScore,
    int rateMultiplier,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.sp),
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(ScreenHelper.setRadius(8)),
        border: Border.all(color: Colors.white24, width: 1.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenHelper.setSp(16),
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            heroes,
            style: TextStyle(
              color: Colors.white70,
              fontSize: ScreenHelper.setSp(14),
            ),
          ),

          Row(
            children: [
              Text(
                '基础分: $baseScore',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: ScreenHelper.setSp(14),
                ),
              ),
              SizedBox(width: 15.sp),
              Text(
                '倍率: $rateMultiplier%',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: ScreenHelper.setSp(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

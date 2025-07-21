import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/game_screen.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/jin_nang_card.dart';

/// 锦囊选择界面
class JinNangSelectScreen extends StatefulWidget {
  const JinNangSelectScreen({super.key});

  @override
  State<JinNangSelectScreen> createState() => _JinNangSelectScreenState();
}

class _JinNangSelectScreenState extends State<JinNangSelectScreen> {
  int? _selectedIndex; // 当前选中的锦囊索引

  void _selectJinNang(int index) {
    AudioManager.playSfx('select_jin_nang');
    setState(() {
      _selectedIndex = index; // 更新选中的锦囊索引
    });
  }

  void _confirmSelection() {
    if (_selectedIndex == null) return;

    AudioManager.playSfx('select_jin_nang');

    // 选择锦囊
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.selectJinNang(_selectedIndex!);

    // 跳转到游戏界面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final List<JinNangModel> jinNangOptions = gameProvider.jinNangOptions;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF1F2937)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 标题
              Text(
                '请选择一张锦囊牌',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: ScreenHelper.setSp(28),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10.sp,
                      offset: Offset(2.sp, 2.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.sp),

              // 提示文本
              Text(
                gameProvider.currentRound <= 5
                    ? '(前5轮选择的锦囊将永久生效)'
                    : gameProvider.currentRound == 6
                    ? '(难度升级，本轮开始，选择的锦囊仅在当前轮次生效)'
                    : '(本轮选择的锦囊仅在当前轮次生效)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(16),
                ),
              ),
              SizedBox(height: 10.sp),
              // 锦囊选项
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(jinNangOptions.length, (index) {
                  return GestureDetector(
                    onTap: () => _selectJinNang(index),
                    child: JinNangCard(
                      jinNang: jinNangOptions[index],
                      isSelectable: true,
                      // 传递选中状态
                      isSelected: _selectedIndex == index,
                    ),
                  );
                }),
              ),

              SizedBox(height: 15.sp),
              // 确认按钮
              ElevatedButton(
                    onPressed: _selectedIndex != null
                        ? _confirmSelection
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6091),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 5.sp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      '确认',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .animate(delay: 600.ms)
                  .fadeIn()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutQuad,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

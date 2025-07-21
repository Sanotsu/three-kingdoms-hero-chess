import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/models/round_trait_model.dart';
import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/jin_nang_select_screen.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';

/// 轮次特性界面
class RoundTraitScreen extends StatefulWidget {
  const RoundTraitScreen({super.key});

  @override
  State<RoundTraitScreen> createState() => _RoundTraitScreenState();
}

class _RoundTraitScreenState extends State<RoundTraitScreen> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AudioManager.playSfx('round_start');
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
          _navigateToJinNangSelect();
        }
      });
    });
  }

  void _navigateToJinNangSelect() {
    // 生成锦囊选项
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.generateJinNangOptions();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const JinNangSelectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final RoundTraitModel trait = gameProvider.currentRoundTrait!;

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
              // 轮次标题
              Text(
                '第 ${trait.round} 轮',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: ScreenHelper.setSp(36),
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
              SizedBox(height: 30.sp),
              // 目标分数
              Text(
                '目标分数: ${gameProvider.targetScore}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(24),
                ),
              ),
              SizedBox(height: 20.sp),
              // 当前总分
              // Text(
              //   '当前总分: ${gameProvider.totalScore}',
              //   style: TextStyle(
              //     color: Colors.green,
              //     fontSize: ScreenHelper.setSp(24),
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 5.sp),

              // 轮次特性
              Container(
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(
                    ScreenHelper.setRadius(15),
                  ),
                  border: Border.all(color: Colors.green, width: 2.sp),
                ),
                child: Column(
                  children: [
                    Text(
                      '本轮特性',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: ScreenHelper.setSp(24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.sp),
                    Text(
                      trait.getDescription(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenHelper.setSp(20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48.sp),
              TextButton(
                onPressed: () {
                  AudioManager.playSfx('button_click');
                  _timer?.cancel();
                  _navigateToJinNangSelect();
                },
                child: Text(
                  '点击关闭 ( $_countdown )',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: ScreenHelper.setSp(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

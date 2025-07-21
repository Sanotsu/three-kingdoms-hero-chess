import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/models/game_record_model.dart';
import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/welcome_screen.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/game_storage.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/game_button.dart';
import 'package:tk_hero_chess/screens/main_router.dart';

/// 游戏结束界面
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
    AudioManager.playSfx('game_over');
    _saveGameRecord();
  }

  Future<void> _saveGameRecord() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // 创建游戏记录
    final record = GameRecordModel(
      completedRounds: gameProvider.currentRound - 1, // 当前轮未完成
      totalScore: gameProvider.totalScore,
      playTime: DateTime.now(),
    );

    // 保存记录
    await GameStorage.saveGameRecord(record);

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

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
          child: _isSaving
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 挑战结束标题
                    Text(
                      '挑战结束',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: ScreenHelper.setSp(48),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 10.r,
                            offset: Offset(2.sp, 2.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    // 游戏结果
                    _buildResultItem(
                      '完成轮次',
                      '${gameProvider.currentRound - 1}轮',
                    ),
                    SizedBox(height: 10.sp),
                    _buildResultItem(
                      '总得分',
                      '${gameProvider.totalScore}分',
                      isHighlight: true,
                    ),
                    // SizedBox(height: 10.sp),
                    // _buildResultItem('目标分数', '${gameProvider.targetScore}分'),
                    SizedBox(height: 50.sp),
                    // 按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GameButton(
                          text: '再来一局',
                          fontSize: 24.sp,
                          color: Colors.green,
                          icon: Icons.refresh,
                          onPressed: () {
                            AudioManager.playSfx('button_click');
                            // 重置游戏状态并开始新游戏
                            gameProvider.resetGame();
                            gameProvider.startNewGame();

                            // 导航到主路由器，它会自动显示轮次特性页面
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const MainRouter(),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 30.sp),
                        GameButton(
                          text: '返回主页',
                          fontSize: 24.sp,
                          color: Colors.blue,
                          icon: Icons.home,
                          onPressed: () {
                            AudioManager.playSfx('button_click');
                            gameProvider.resetGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Container(
      width: 300.sp,
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(ScreenHelper.setRadius(10)),
        border: isHighlight
            ? Border.all(color: Colors.amber, width: 2.sp)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenHelper.setSp(20),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.amber : Colors.green,
              fontSize: ScreenHelper.setSp(28),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

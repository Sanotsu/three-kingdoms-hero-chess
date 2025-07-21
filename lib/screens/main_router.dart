import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/game_over_screen.dart';
import 'package:tk_hero_chess/screens/game_screen.dart';
import 'package:tk_hero_chess/screens/jin_nang_select_screen.dart';
import 'package:tk_hero_chess/screens/round_trait_screen.dart';
import 'package:tk_hero_chess/screens/welcome_screen.dart';

/// 主路由器，用于管理游戏的不同界面
class MainRouter extends StatelessWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // 根据游戏状态显示不同界面
    if (!gameProvider.isGameStarted) {
      return const WelcomeScreen();
    }

    if (gameProvider.isGameOver) {
      return const GameOverScreen();
    }

    // 游戏已开始，根据当前阶段显示不同界面
    if (gameProvider.boardHeroes.isEmpty) {
      // 棋盘为空，表示刚开始新的一轮
      if (gameProvider.jinNangOptions.isEmpty) {
        // 锦囊选项为空，表示需要显示轮次特性
        return const RoundTraitScreen();
      } else {
        // 锦囊选项不为空，表示需要选择锦囊
        return const JinNangSelectScreen();
      }
    }

    // 棋盘不为空，表示已经选择了锦囊，进入游戏主界面
    return const GameScreen();
  }
}

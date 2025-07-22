import 'package:flutter/material.dart';

import 'package:tk_hero_chess/utils/game_storage.dart';

/// 游戏常量定义
enum GameDifficulty { easy, medium, hard }

const Map<GameDifficulty, String> difficultyNames = {
  GameDifficulty.easy: '简单',
  GameDifficulty.medium: '中等',
  GameDifficulty.hard: '困难',
};

class GameConstants {
  // 阵营定义
  static const String campWei = '魏';
  static const String campShu = '蜀';
  static const String campWu = '吴';

  // 阵营颜色
  // static const Color weiColor = Color(0xFF7B68EE); // 魏营颜色
  // static const Color shuColor = Color(0xFF32CD32); // 蜀营颜色
  // static const Color wuColor = Color(0xFFFF4500); // 吴营颜色

  static const Color weiColor = Color(0xFFD4AF37); // 魏营金色
  static const Color shuColor = Color(0xFF9E2B26); // 蜀营赤红
  static const Color wuColor = Color(0xFF5D8AA8); // 吴营水蓝

  // 锦囊等级颜色
  static const Color jinNangLevel1Color = Color(0xFF3498DB); // 蓝色
  static const Color jinNangLevel2Color = Color(0xFFE91E63); // 粉色
  static const Color jinNangLevel3Color = Color(0xFFFFD700); // 金色

  // 人物列表
  static const Map<String, List<String>> campHeroes = {
    campWei: ['曹操', '典韦', '夏侯惇', '司马懿', '甄姬'],
    campShu: ['刘备', '张飞', '关羽', '诸葛亮', '赵云'],
    campWu: ['孙权', '孙策', '孙尚香', '周瑜', '小乔'],
  };

  // 羁绊定义
  static const Map<String, Map<String, dynamic>> bondDefinitions = {
    '问鼎三国': {
      'heroes': ['曹操', '刘备', '孙权'],
      'baseScore': 50,
      'rateMultiplier': 1000,
    },
    '集智三分': {
      'heroes': ['司马懿', '诸葛亮', '周瑜'],
      'baseScore': 50,
      'rateMultiplier': 1000,
    },
    '桃源结义': {
      'heroes': ['刘备', '关羽', '张飞'],
      'baseScore': 50,
      'rateMultiplier': 800,
    },
    '魏都霸业': {
      'heroes': ['曹操', '典韦', '夏侯惇'],
      'baseScore': 50,
      'rateMultiplier': 800,
    },
    '孙氏兄妹': {
      'heroes': ['孙权', '孙策', '孙尚香'],
      'baseScore': 50,
      'rateMultiplier': 800,
    },
    '同阵营X1': {'heroCount': 1, 'baseScore': 10, 'rateMultiplier': 200},
    '同阵营X2': {'heroCount': 2, 'baseScore': 20, 'rateMultiplier': 400},
    '同阵营X3': {'heroCount': 3, 'baseScore': 30, 'rateMultiplier': 600},
    '同阵营X4': {'heroCount': 4, 'baseScore': 40, 'rateMultiplier': 800},
    '同阵营X5': {'heroCount': 5, 'baseScore': 50, 'rateMultiplier': 1000},
  };

  // 锦囊定义
  static const Map<String, Map<String, dynamic>> jinNangDefinitions = {
    '三思而行': {
      'type': '增益',
      'effect': '换棋次数增加',
      'levels': [1, 2, 3], // 次数
    },
    '连环攻势': {
      'type': '增益',
      'effect': '出棋次数增加',
      'levels': [1, 2, 3], // 次数
    },
    '以逸待劳': {
      'type': '增益',
      'effect': '未触发羁绊的棋子也计算基础得分，且得分倍率增加',
      'levels': [75, 150, 300], // 倍率百分比
    },
    '三分天下': {
      'type': '基础得分',
      'effect': '本次出棋时，每存在一个阵营，基础得分增加',
      'levels': [30, 60, 90], // 分数
    },
    '当机立断': {
      'type': '基础得分',
      'effect': '本次出棋时，未执行换棋，基础得分增加',
      'levels': [30, 60, 90], // 分数
    },
    '欲擒故纵': {
      'type': '基础得分',
      'effect': '出棋时，若棋子数量小于等于3，基础得分增加',
      'levels': [40, 80, 120], // 分数
    },
    '故技重施': {
      'type': '基础得分',
      'effect': '本次出棋数量与上一次相同时，基础得分增加',
      'levels': [75, 100, 125], // 分数
    },
    '声东击西': {
      'type': '倍率',
      'effect': '本次出棋时触发的羁绊与上一次不同时，得分倍率增加',
      'levels': [150, 400, 650], // 倍率百分比
    },
    '釜底抽薪': {
      'type': '倍率',
      'effect': '执行最后1次出棋时，得分倍率增加',
      'levels': [200, 400, 800], // 倍率百分比
    },
    '深根固本': {
      'type': '倍率',
      'effect': '本次出棋时，每个剩余换棋次数使得分倍率增加',
      'levels': [50, 75, 100], // 倍率百分比
    },
    '抛砖引玉': {
      'type': '倍率',
      'effect': '每次执行换棋，使下一次出棋结算时，得分倍率增加',
      'levels': [100, 300, 500], // 倍率百分比
    },
    '短兵相接': {
      'type': '倍率',
      'effect': '出棋时，若棋子数量大于等于3，得分倍率增加',
      'levels': [100, 200, 300], // 倍率百分比
    },
  };

  // 简单的关卡目标分数设定（平方公式，前面机关比中等难，后面比中等简单）
  static int getRoundTargetScoreEasy(int round) {
    return 800 * round * round - 1250 * round + 1050;
  }

  // 中等难度关卡目标分数设定（系数更小的原版立方公式）
  static int getRoundTargetScoreMedium(int round) {
    return 35 * round * round * round + 350 * round * round - 300 * round + 900;
  }

  // 这是原版的得分设定，比较难
  static int getRoundTargetScoreHard(int round) {
    // 根据实测，得分公式为: 50*(n^3) + 400*(n^2) - 350*n + 900
    // 提取公因式: 50*(n^3 + 8n^2 - 7n + 18)
    // return (50 * (pow(round, 3) + 8 * pow(round, 2) - 7 * round + 18)).round();

    return 50 * round * round * round + 400 * round * round - 350 * round + 900;
  }

  // 难度缓存
  static GameDifficulty _cachedDifficulty = GameDifficulty.hard;

  // 初始化或切换难度时调用
  static Future<void> loadDifficulty() async {
    _cachedDifficulty = await GameStorage.getGameDifficulty();
  }

  // 根据当前难度自动获取目标分数
  static int getRoundTargetScoreAuto(int round) {
    switch (_cachedDifficulty) {
      case GameDifficulty.easy:
        return getRoundTargetScoreEasy(round);
      case GameDifficulty.medium:
        return getRoundTargetScoreMedium(round);
      case GameDifficulty.hard:
        return getRoundTargetScoreHard(round);
    }
  }

  // 默认英雄棋基础得分
  static const int defaultHeroBaseScore = 10;

  // 最大选择棋子数
  static const int maxSelectedHeroCount = 5;

  // 默认换棋次数
  static const int defaultSwapCount = 3;

  // 默认出棋次数
  static const int defaultPlayCount = 3;

  // 棋盘上的默认棋子数量
  static const int boardHeroCount = 7;
}

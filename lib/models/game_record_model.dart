import 'package:tk_hero_chess/constants/game_constants.dart';

/// 游戏记录模型
class GameRecordModel {
  final int completedRounds;
  final int totalScore;
  final DateTime playTime;
  final GameDifficulty difficulty;

  GameRecordModel({
    required this.completedRounds,
    required this.totalScore,
    required this.playTime,
    required this.difficulty,
  });

  // 从JSON创建
  factory GameRecordModel.fromJson(Map<String, dynamic> json) {
    GameDifficulty diff = GameDifficulty.hard;
    if (json.containsKey('difficulty')) {
      switch (json['difficulty']) {
        case 'easy':
          diff = GameDifficulty.easy;
          break;
        case 'medium':
          diff = GameDifficulty.medium;
          break;
        case 'hard':
        default:
          diff = GameDifficulty.hard;
      }
    }
    return GameRecordModel(
      completedRounds: json['completedRounds'] as int,
      totalScore: json['totalScore'] as int,
      playTime: DateTime.parse(json['playTime'] as String),
      difficulty: diff,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'completedRounds': completedRounds,
      'totalScore': totalScore,
      'playTime': playTime.toIso8601String(),
      'difficulty': difficulty.name,
    };
  }

  @override
  String toString() {
    return '完成轮次: $completedRounds, 总分: $totalScore, 难度: ${difficultyNames[difficulty]}, 时间: ${playTime.toString()}';
  }
}

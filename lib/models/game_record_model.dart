/// 游戏记录模型
class GameRecordModel {
  final int completedRounds;
  final int totalScore;
  final DateTime playTime;

  GameRecordModel({
    required this.completedRounds,
    required this.totalScore,
    required this.playTime,
  });

  // 从JSON创建
  factory GameRecordModel.fromJson(Map<String, dynamic> json) {
    return GameRecordModel(
      completedRounds: json['completedRounds'] as int,
      totalScore: json['totalScore'] as int,
      playTime: DateTime.parse(json['playTime'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'completedRounds': completedRounds,
      'totalScore': totalScore,
      'playTime': playTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '完成轮次: $completedRounds, 总分: $totalScore, 时间: ${playTime.toString()}';
  }
}

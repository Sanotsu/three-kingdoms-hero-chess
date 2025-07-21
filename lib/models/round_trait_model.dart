/// 轮次特性模型
class RoundTraitModel {
  final int round;
  final Map<String, int> heroScoreAdjustments; // 英雄名称 -> 分数调整

  RoundTraitModel({required this.round, required this.heroScoreAdjustments});

  // 获取特性描述
  String getDescription() {
    List<String> descriptions = [];

    heroScoreAdjustments.forEach((hero, adjustment) {
      String sign = adjustment > 0 ? '+' : '';
      descriptions.add('$hero基础得分$sign$adjustment');
    });

    return descriptions.join('，');
  }

  // 创建轮次特性的副本
  RoundTraitModel copyWith({
    int? round,
    Map<String, int>? heroScoreAdjustments,
  }) {
    return RoundTraitModel(
      round: round ?? this.round,
      heroScoreAdjustments:
          heroScoreAdjustments ?? Map.from(this.heroScoreAdjustments),
    );
  }

  @override
  String toString() {
    return '第$round轮特性: ${getDescription()}';
  }
}

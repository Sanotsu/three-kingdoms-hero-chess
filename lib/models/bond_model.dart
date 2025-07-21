/// 羁绊模型
class BondModel {
  final String name; // 羁绊名称
  final List<String> heroes; // 特定羁绊的英雄名称列表，同阵营羁绊为空
  final int? heroCount; // 同阵营羁绊需要的英雄数量
  final int baseScore; // 羁绊的基础得分
  final int rateMultiplier; // 羁绊的倍率（百分比）
  bool isActive; // 是否激活
  final bool isCampBond; // 是否为同阵营羁绊，用于特殊处理重复角色

  BondModel({
    required this.name,
    this.heroes = const [],
    this.heroCount,
    required this.baseScore,
    required this.rateMultiplier,
    this.isActive = false,
    this.isCampBond = false,
  });

  // 创建羁绊的副本
  BondModel copyWith({
    String? name,
    List<String>? heroes,
    int? heroCount,
    int? baseScore,
    int? rateMultiplier,
    bool? isActive,
    bool? isCampBond,
  }) {
    return BondModel(
      name: name ?? this.name,
      heroes: heroes ?? this.heroes,
      heroCount: heroCount ?? this.heroCount,
      baseScore: baseScore ?? this.baseScore,
      rateMultiplier: rateMultiplier ?? this.rateMultiplier,
      isActive: isActive ?? this.isActive,
      isCampBond: isCampBond ?? this.isCampBond,
    );
  }

  @override
  String toString() {
    return '$name (基础分:$baseScore, 倍率:$rateMultiplier%)';
  }
}

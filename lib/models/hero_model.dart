import 'package:flutter/material.dart';

import 'package:tk_hero_chess/constants/game_constants.dart';

/// 英雄棋模型
class HeroModel {
  final String name;
  final String camp;
  int baseScore;
  bool isSelected;
  bool isActive; // 是否在当前羁绊计算中生效

  HeroModel({
    required this.name,
    required this.camp,
    this.baseScore = GameConstants.defaultHeroBaseScore,
    this.isSelected = false,
    this.isActive = false,
  });

  // 获取阵营颜色
  Color get campColor {
    switch (camp) {
      case GameConstants.campWei:
        return GameConstants.weiColor;
      case GameConstants.campShu:
        return GameConstants.shuColor;
      case GameConstants.campWu:
        return GameConstants.wuColor;
      default:
        return Colors.grey;
    }
  }

  // 创建英雄棋的副本
  HeroModel copyWith({
    String? name,
    String? camp,
    int? baseScore,
    bool? isSelected,
    bool? isActive,
  }) {
    return HeroModel(
      name: name ?? this.name,
      camp: camp ?? this.camp,
      baseScore: baseScore ?? this.baseScore,
      isSelected: isSelected ?? this.isSelected,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return '$camp $name (基础分:$baseScore)';
  }
}

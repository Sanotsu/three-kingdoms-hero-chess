import 'package:flutter/material.dart';

import 'package:tk_hero_chess/constants/game_constants.dart';

/// 锦囊模型
class JinNangModel {
  final String name;
  final String type; // 增益、基础得分、倍率
  final String effect; // 具体效果
  final int level; // 1-3级
  final int value; // 对应级别的具体数值
  bool isActive; // 是否激活 (当前选中棋子是否触发了锦囊)
  bool isPermanent; // 是否永久生效（前5轮选择的锦囊）

  JinNangModel({
    required this.name,
    required this.type,
    required this.effect,
    required this.level,
    required this.value,
    this.isActive = false,
    this.isPermanent = false,
  });

  // 获取锦囊颜色
  Color get levelColor {
    switch (level) {
      case 1:
        return GameConstants.jinNangLevel1Color;
      case 2:
        return GameConstants.jinNangLevel2Color;
      case 3:
        return GameConstants.jinNangLevel3Color;
      default:
        return Colors.grey;
    }
  }

  // 获取锦囊描述
  String get description {
    String levelText = '$level级';
    String valueText = '';

    if (type == '增益') {
      if (name == '三思而行' || name == '连环攻势') {
        valueText = '$value次';
      } else {
        valueText = '$value%';
      }
    } else if (type == '基础得分') {
      valueText = '$value分';
    } else if (type == '倍率') {
      valueText = '$value%';
    }

    return '$levelText $name: $effect $valueText';
  }

  // 创建锦囊的副本
  JinNangModel copyWith({
    String? name,
    String? type,
    String? effect,
    int? level,
    int? value,
    bool? isActive,
    bool? isPermanent,
  }) {
    return JinNangModel(
      name: name ?? this.name,
      type: type ?? this.type,
      effect: effect ?? this.effect,
      level: level ?? this.level,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      isPermanent: isPermanent ?? this.isPermanent,
    );
  }

  @override
  String toString() {
    return '$name ($level级)';
  }
}

import 'dart:math';

import 'package:tk_hero_chess/constants/game_constants.dart';
import 'package:tk_hero_chess/models/bond_model.dart';
import 'package:tk_hero_chess/models/hero_model.dart';
import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/models/round_trait_model.dart';
import 'package:tk_hero_chess/utils/toast_utils.dart';

/// 游戏工具类
class GameUtils {
  static final Random _random = Random();

  // 生成随机英雄棋
  static List<HeroModel> generateRandomHeroes(
    int count,
    RoundTraitModel? roundTrait, {
    List<HeroModel> existingHeroes = const [],
  }) {
    List<HeroModel> heroes = [];

    // 记录每个阵营出现的次数
    Map<String, int> campCounts = {
      GameConstants.campWei: 0,
      GameConstants.campShu: 0,
      GameConstants.campWu: 0,
    };
    // 记录每个英雄出现的次数
    Map<String, int> heroCounts = {};

    // 统计已有棋子的阵营和英雄数量
    for (var hero in existingHeroes) {
      campCounts[hero.camp] = (campCounts[hero.camp] ?? 0) + 1;
      heroCounts[hero.name] = (heroCounts[hero.name] ?? 0) + 1;
    }

    for (int i = 0; i < count; i++) {
      // 确保每个阵营人物数量最多6个，每个英雄最多重复2个
      List<String> availableCamps = campCounts.entries
          .where((entry) => entry.value < 6)
          .map((entry) => entry.key)
          .toList();

      if (availableCamps.isEmpty) {
        // 如果所有阵营都已满，则重新随机
        campCounts = {
          GameConstants.campWei: 0,
          GameConstants.campShu: 0,
          GameConstants.campWu: 0,
        };
        // 重新统计已有棋子的阵营数量
        for (var hero in existingHeroes) {
          campCounts[hero.camp] = (campCounts[hero.camp] ?? 0) + 1;
        }
        availableCamps = campCounts.entries
            .where((entry) => entry.value < 6)
            .map((entry) => entry.key)
            .toList();

        if (availableCamps.isEmpty) {
          // 如果仍然没有可用阵营，则使用所有阵营
          availableCamps = campCounts.keys.toList();
        }
      }

      // 随机选择一个阵营
      String camp = availableCamps[_random.nextInt(availableCamps.length)];
      campCounts[camp] = (campCounts[camp] ?? 0) + 1;

      // 获取该阵营可用的英雄
      List<String> availableHeroes = GameConstants.campHeroes[camp]!
          .where((hero) => (heroCounts[hero] ?? 0) < 2) // 每个英雄最多出现2次
          .toList();

      if (availableHeroes.isEmpty) {
        // 如果该阵营所有英雄都已达到最大次数，则重新随机阵营
        i--;
        campCounts[camp] = (campCounts[camp] ?? 0) - 1; // 回退阵营计数
        continue;
      }

      // 随机选择一个英雄
      String heroName =
          availableHeroes[_random.nextInt(availableHeroes.length)];
      heroCounts[heroName] = (heroCounts[heroName] ?? 0) + 1;

      // 创建英雄棋
      int baseScore = GameConstants.defaultHeroBaseScore;

      // 应用轮次特性对英雄基础分的调整
      if (roundTrait != null &&
          roundTrait.heroScoreAdjustments.containsKey(heroName)) {
        baseScore += roundTrait.heroScoreAdjustments[heroName]!;
      }

      heroes.add(HeroModel(name: heroName, camp: camp, baseScore: baseScore));
    }

    // 按阵营+人物名排序
    GameUtils.sortHeroes(heroes);

    return heroes;
  }

  // 生成随机轮次特性
  static RoundTraitModel generateRoundTrait(int round) {
    Map<String, int> adjustments = {};
    List<String> allHeroes = [];

    // 收集所有英雄
    GameConstants.campHeroes.forEach((camp, heroes) {
      allHeroes.addAll(heroes);
    });

    // 随机选择两个英雄
    allHeroes.shuffle();
    String hero1 = allHeroes[0];
    String hero2 = allHeroes[1];

    if (round <= 5) {
      // 前5轮：两个英雄都增加5或10点
      int adjustment = _random.nextInt(2) == 0 ? 5 : 10;
      adjustments[hero1] = adjustment;
      adjustments[hero2] = adjustment;
    } else {
      // 第6轮及以后：一个英雄增加5-30点，一个英雄减少1-9点
      int positiveAdjustment = 5 + _random.nextInt(26); // 5-30
      int negativeAdjustment = -(_random.nextInt(9) + 1); // -1到-9

      adjustments[hero1] = positiveAdjustment;
      adjustments[hero2] = negativeAdjustment;
    }

    return RoundTraitModel(round: round, heroScoreAdjustments: adjustments);
  }

  // 生成随机锦囊选项
  static List<JinNangModel> generateRandomJinNangOptions(
    int count,
    List<JinNangModel> allPickedJinNangs,
    int round,
  ) {
    // 获取所有可用的锦囊名称
    List<String> availableJinNangNames = GameConstants.jinNangDefinitions.keys
        .toList();

    // 始终排除所有已选过的锦囊
    availableJinNangNames.removeWhere(
      (name) => allPickedJinNangs.any((jinNang) => jinNang.name == name),
    );

    // 如果可用锦囊数量不足，则返回所有可用锦囊
    if (availableJinNangNames.length <= count) {
      return availableJinNangNames.map((name) {
        final jinNangDef = GameConstants.jinNangDefinitions[name]!;
        final level = _random.nextInt(3) + 1; // 1-3级
        final value = jinNangDef['levels'][level - 1] as int;

        return JinNangModel(
          name: name,
          type: jinNangDef['type'] as String,
          effect: jinNangDef['effect'] as String,
          level: level,
          value: value,
          isPermanent: round <= 5,
        );
      }).toList();
    }

    // 随机选择不同的锦囊
    List<String> selectedNames = [];
    while (selectedNames.length < count) {
      String name =
          availableJinNangNames[_random.nextInt(availableJinNangNames.length)];
      if (!selectedNames.contains(name)) {
        selectedNames.add(name);
      }
    }

    // 创建锦囊模型
    return selectedNames.map((name) {
      final jinNangDef = GameConstants.jinNangDefinitions[name]!;
      final level = _random.nextInt(3) + 1; // 1-3级
      final value = jinNangDef['levels'][level - 1] as int;

      return JinNangModel(
        name: name,
        type: jinNangDef['type'] as String,
        effect: jinNangDef['effect'] as String,
        level: level,
        value: value,
        isPermanent: round <= 5,
      );
    }).toList();
  }

  // 获取所有可能的羁绊
  static List<BondModel> getAllPossibleBonds() {
    List<BondModel> bonds = [];

    // 添加特定羁绊
    GameConstants.bondDefinitions.forEach((name, def) {
      if (def.containsKey('heroes')) {
        bonds.add(
          BondModel(
            name: name,
            heroes: List<String>.from(def['heroes']),
            baseScore: def['baseScore'],
            rateMultiplier: def['rateMultiplier'],
          ),
        );
      }
    });

    // 添加同阵营羁绊
    // 注意：同阵营羁绊计算时应考虑所有棋子，包括重复角色
    for (int i = 1; i <= 5; i++) {
      final bondDef = GameConstants.bondDefinitions['同阵营X$i']!;
      bonds.add(
        BondModel(
          name: '同阵营X$i',
          heroCount: i,
          baseScore: bondDef['baseScore'],
          rateMultiplier: bondDef['rateMultiplier'],
          // 添加一个标记，表示这是同阵营羁绊，需要特殊处理重复角色
          isCampBond: true,
        ),
      );
    }

    return bonds;
  }

  /// 计算选中棋子的最佳羁绊和得分
  static Map<String, dynamic> calculateBestBond(
    // 当前选中的棋子
    List<HeroModel> selectedHeroes,
    // 当前激活的锦囊
    List<JinNangModel> activeJinNangs,
    // 剩余换棋次数，用于深根固本
    int remainingSwapCount,
    // 上一次出棋数量，用于故技重施
    int lastPlayCount,
    // 上一次羁绊的名称，用于声东击西
    String lastActiveBond,
    // 是否是最后一次出棋，用于釜底抽薪
    bool isLastPlay,
    // 已经换棋的次数，用于抛砖引玉、当机立断(已换棋次数=0即没有换棋)
    int swappedCount,
  ) {
    if (selectedHeroes.isEmpty) {
      return {
        'bond': null,
        'totalScore': 0,
        'baseScore': 0,
        'rateMultiplier': 0,
        'activeHeroes': <HeroModel>[],
      };
    }

    // 重置所有英雄的激活状态
    for (var hero in selectedHeroes) {
      hero.isActive = false;
    }

    // 获取所有可能的羁绊
    List<BondModel> allBonds = getAllPossibleBonds();
    List<Map<String, dynamic>> bondResults = [];

    // 计算每个羁绊的得分
    for (var bond in allBonds) {
      // 检查是否满足羁绊条件
      bool isBondActive = false;
      List<HeroModel> activeHeroes = [];

      if (bond.heroes.isNotEmpty) {
        // 特定羁绊
        Map<String, int> requiredHeroes = {};
        for (var heroName in bond.heroes) {
          requiredHeroes[heroName] = (requiredHeroes[heroName] ?? 0) + 1;
        }

        Map<String, List<HeroModel>> availableHeroes = {};
        for (var hero in selectedHeroes) {
          if (requiredHeroes.containsKey(hero.name)) {
            if (!availableHeroes.containsKey(hero.name)) {
              availableHeroes[hero.name] = [];
            }
            availableHeroes[hero.name]!.add(hero);
          }
        }

        // 检查是否满足所有需求
        bool allRequirementsMet = true;
        for (var entry in requiredHeroes.entries) {
          if (!availableHeroes.containsKey(entry.key) ||
              availableHeroes[entry.key]!.length < entry.value) {
            allRequirementsMet = false;
            break;
          }
        }

        if (allRequirementsMet) {
          isBondActive = true;
          // 选择基础分最高的英雄作为激活英雄
          for (var entry in requiredHeroes.entries) {
            List<HeroModel> heroes = availableHeroes[entry.key]!;
            heroes.sort((a, b) => b.baseScore.compareTo(a.baseScore));
            for (int i = 0; i < entry.value; i++) {
              activeHeroes.add(heroes[i]);
            }
          }
        }
      } else if (bond.heroCount != null) {
        // 同阵营羁绊
        Map<String, List<HeroModel>> campHeroes = {};
        for (var hero in selectedHeroes) {
          if (!campHeroes.containsKey(hero.camp)) {
            campHeroes[hero.camp] = [];
          }
          campHeroes[hero.camp]!.add(hero);
        }

        // 找出数量最多且基础分最高的阵营
        String? bestCamp;
        int maxCount = 0;
        int maxBaseScore = 0;

        for (var entry in campHeroes.entries) {
          // 注意：这里使用实际棋子数量，而不是不同角色的数量
          int campHeroCount = entry.value.length;

          if (campHeroCount >= bond.heroCount! &&
              (campHeroCount > maxCount ||
                  (campHeroCount == maxCount &&
                      entry.value.fold<int>(
                            0,
                            (sum, hero) => sum + hero.baseScore,
                          ) >
                          maxBaseScore))) {
            bestCamp = entry.key;
            maxCount = campHeroCount;
            maxBaseScore = entry.value.fold<int>(
              0,
              (sum, hero) => sum + hero.baseScore,
            );
          }
        }

        if (bestCamp != null &&
            campHeroes[bestCamp]!.length >= bond.heroCount!) {
          isBondActive = true;

          // 选择基础分最高的英雄作为激活英雄
          List<HeroModel> heroes = List.from(campHeroes[bestCamp]!)
            ..sort((a, b) => b.baseScore.compareTo(a.baseScore));

          // 对于同阵营羁绊，所有同阵营的棋子都应该被激活，而不是只取bond.heroCount!个
          activeHeroes = heroes;

          // 更新羁绊名称以反映实际激活的棋子数量
          // 如果实际激活的棋子数量超过5，仍然使用"同阵营X5"(最大选择棋子为5,所以这种超过5的不应该出现)
          int actualCount = heroes.length;
          if (actualCount > bond.heroCount! && actualCount <= 5) {
            // 获取正确的羁绊定义
            final correctBondDef =
                GameConstants.bondDefinitions['同阵营X$actualCount']!;
            bond = BondModel(
              name: '同阵营X$actualCount',
              heroCount: actualCount,
              baseScore: correctBondDef['baseScore'],
              rateMultiplier: correctBondDef['rateMultiplier'],
              isCampBond: true,
            );
          }
        }
      }

      if (isBondActive) {
        // 计算基础得分
        int baseScore = bond.baseScore;

        // 添加激活英雄的基础得分
        for (var hero in activeHeroes) {
          baseScore += hero.baseScore;
        }

        // 计算倍率
        int rateMultiplier = bond.rateMultiplier;

        // 应用锦囊效果
        for (var jinNang in activeJinNangs) {
          // 检查锦囊是否激活
          bool isJinNangActive = false;

          switch (jinNang.name) {
            // 换棋次数增加
            case '三思而行': // 已经在游戏状态中应用了
              break;
            //  出棋次数增加
            case '连环攻势': // 已经在游戏状态中应用了
              break;
            // 未触发羁绊的棋子也计算**基础得分**，且**得分倍率**增加
            case '以逸待劳':
              List<HeroModel> nonActivatedHeroes = selectedHeroes
                  .where((hero) => !activeHeroes.contains(hero))
                  .toList();

              isJinNangActive = nonActivatedHeroes.isNotEmpty;

              if (isJinNangActive) {
                // 未触发羁绊的棋子也计算基础得分
                for (var hero in nonActivatedHeroes) {
                  baseScore += hero.baseScore;
                }
                // 增加倍率
                rateMultiplier += jinNang.value;
              }
              break;
            // 本次出棋时，每存在一个阵营，**基础得分**增加
            case '三分天下':
              isJinNangActive = true;
              // 计算存在的阵营数量
              Set<String> camps = selectedHeroes
                  .map((hero) => hero.camp)
                  .toSet();
              baseScore += camps.length * jinNang.value;
              break;
            // 本次出棋时，未执行换棋，**基础得分**增加
            case '当机立断':
              isJinNangActive = swappedCount <= 0;
              if (isJinNangActive) {
                baseScore += jinNang.value;
              }
              break;
            //  出棋时，若棋子数量小于等于 3，**基础得分**增加
            case '欲擒故纵':
              isJinNangActive = selectedHeroes.length <= 3;
              if (isJinNangActive) {
                baseScore += jinNang.value;
              }
              break;
            // 本次出棋数量与上一次相同时，**基础得分**增加
            case '故技重施':
              isJinNangActive = selectedHeroes.length == lastPlayCount;
              if (isJinNangActive) {
                baseScore += jinNang.value;
              }
              break;
            // 本次出棋时触发的羁绊与上一次不同时，**得分倍率**增加
            case '声东击西':
              isJinNangActive =
                  lastActiveBond.isNotEmpty && bond.name != lastActiveBond;

              // 只要是同阵营羁绊都不触发，不管数量是否相同
              if (bond.name.contains("同阵营")) {
                if (lastActiveBond.contains("同阵营")) {
                  isJinNangActive = false;
                }
              }

              if (isJinNangActive) {
                rateMultiplier += jinNang.value;
              }
              break;
            // 执行最后 1 次出棋时，**得分倍率**增加
            case '釜底抽薪':
              isJinNangActive = isLastPlay;
              if (isJinNangActive) {
                rateMultiplier += jinNang.value;
              }
              break;
            // 本次出棋时，每个剩余换棋次数使**得分倍率**增加
            case '深根固本':
              isJinNangActive = remainingSwapCount > 0;
              if (isJinNangActive) {
                rateMultiplier += remainingSwapCount * jinNang.value;
              }
              break;
            // 每次执行换棋，使下一次出棋结算时，**得分倍率**增加
            case '抛砖引玉':
              isJinNangActive = swappedCount > 0;
              if (isJinNangActive) {
                rateMultiplier += jinNang.value * swappedCount;
              }
              break;
            // 出棋时，若棋子数量大于等于 3，**得分倍率**增加
            case '短兵相接':
              isJinNangActive = selectedHeroes.length >= 3;
              if (isJinNangActive) {
                rateMultiplier += jinNang.value;
              }
              break;
          }

          // 更新锦囊激活状态
          jinNang.isActive = isJinNangActive;
        }

        // 计算总得分
        int totalScore = (baseScore * rateMultiplier / 100).round();

        bondResults.add({
          'bond': bond,
          'totalScore': totalScore,
          'baseScore': baseScore,
          'rateMultiplier': rateMultiplier,
          'activeHeroes': activeHeroes,
        });
      }
    }

    // 如果没有激活的羁绊，但是有棋子
    // 这个应该不存在，因为随便选择了一个棋子，至少会触发同阵营X1羁绊
    if (bondResults.isEmpty) {
      ToastUtils.showError('没有激活的羁绊，但是有棋子，这不应该出现');

      // 计算基础得分
      int baseScore = 0;
      for (var hero in selectedHeroes) {
        baseScore += hero.baseScore;
      }

      // 计算倍率
      int rateMultiplier = 100; // 默认100%

      // 应用锦囊效果，但"以逸待劳"在没有羁绊时不激活
      for (var jinNang in activeJinNangs) {
        bool isJinNangActive = false;

        switch (jinNang.name) {
          case '三思而行':
          case '连环攻势':
            // 已经在游戏状态中应用了
            break;
          case '以逸待劳':
            // 当没有羁绊激活时，所有棋子都是"未触发羁绊的棋子"
            // 但是根据规则，如果没有羁绊被激活，则不应该激活"以逸待劳"锦囊
            // 因为"以逸待劳"锦囊需要有羁绊被激活，且有部分棋子未被该羁绊激活
            isJinNangActive = false;
            break;
          case '三分天下':
            isJinNangActive = true;
            Set<String> camps = selectedHeroes.map((hero) => hero.camp).toSet();
            baseScore += camps.length * jinNang.value;
            break;
          case '当机立断':
            isJinNangActive = swappedCount <= 0;
            if (isJinNangActive) {
              baseScore += jinNang.value;
            }
            break;
          case '欲擒故纵':
            isJinNangActive = selectedHeroes.length <= 3;
            if (isJinNangActive) {
              baseScore += jinNang.value;
            }
            break;
          case '故技重施':
            isJinNangActive = selectedHeroes.length == lastPlayCount;
            if (isJinNangActive) {
              baseScore += jinNang.value;
            }
            break;
          case '声东击西':
            // 没有羁绊，所以不会触发
            break;
          case '釜底抽薪':
            isJinNangActive = isLastPlay;
            if (isJinNangActive) {
              rateMultiplier += jinNang.value;
            }
            break;
          case '深根固本':
            isJinNangActive = remainingSwapCount > 0;
            if (isJinNangActive) {
              rateMultiplier += remainingSwapCount * jinNang.value;
            }
            break;
          case '抛砖引玉':
            // 本轮换棋次数大于0时激活，倍率根据换棋次数叠加
            isJinNangActive = swappedCount > 0;
            if (isJinNangActive) {
              rateMultiplier += jinNang.value * swappedCount;
            }
            break;
          case '短兵相接':
            isJinNangActive = selectedHeroes.length >= 3;
            if (isJinNangActive) {
              rateMultiplier += jinNang.value;
            }
            break;
        }

        // 更新锦囊激活状态
        jinNang.isActive = isJinNangActive;
      }

      // 计算总得分
      int totalScore = (baseScore * rateMultiplier / 100).round();

      return {
        'bond': null,
        'totalScore': totalScore,
        'baseScore': baseScore,
        'rateMultiplier': rateMultiplier,
        'activeHeroes': selectedHeroes,
      };
    }

    // 找出得分最高的羁绊
    bondResults.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));
    Map<String, dynamic> bestResult = bondResults.first;

    // 更新激活的英雄
    for (var hero in bestResult['activeHeroes']) {
      hero.isActive = true;
    }

    return bestResult;
  }

  // 英雄棋排序：先按阵营（魏、蜀、吴），再按人物名
  static void sortHeroes(List<HeroModel> heroes) {
    int campOrder(String camp) {
      if (camp == GameConstants.campWei) return 0;
      if (camp == GameConstants.campShu) return 1;
      if (camp == GameConstants.campWu) return 2;
      return 99;
    }

    heroes.sort((a, b) {
      int cmp = campOrder(a.camp).compareTo(campOrder(b.camp));
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });
  }
}

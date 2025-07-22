import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tk_hero_chess/constants/game_constants.dart';
import 'package:tk_hero_chess/models/game_record_model.dart';
import 'package:tk_hero_chess/utils/toast_utils.dart';

/// 游戏存储工具类
class GameStorage {
  static const String recordsKey = 'game_records';

  // 出棋时是否跳过动画
  static const String skipPlayAnimationKey = 'skip_play_animation';

  // 难度存储key
  static const String difficultyKey = 'game_difficulty';

  // 保存游戏记录
  static Future<bool> saveGameRecord(GameRecordModel record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<GameRecordModel> records = await getGameRecords();

      // 添加新记录
      records.add(record);

      // 按分数降序排序
      records.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      // 只保留前50条记录
      if (records.length > 50) {
        records = records.sublist(0, 50);
      }

      // 转换为JSON并保存
      List<String> jsonRecords = records
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      return await prefs.setStringList(recordsKey, jsonRecords);
    } catch (e) {
      ToastUtils.showError('保存游戏记录失败: $e');
      return false;
    }
  }

  // 获取所有游戏记录
  static Future<List<GameRecordModel>> getGameRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? jsonRecords = prefs.getStringList(recordsKey);

      if (jsonRecords == null || jsonRecords.isEmpty) {
        return [];
      }

      // 解析JSON记录
      return jsonRecords
          .map((json) => GameRecordModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      ToastUtils.showError('获取游戏记录失败: $e');
      return [];
    }
  }

  // 清除所有游戏记录
  static Future<bool> clearGameRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(recordsKey);
    } catch (e) {
      ToastUtils.showError('清除游戏记录失败: $e');
      return false;
    }
  }

  // 设置是否跳过动画
  static Future<void> setSkipPlayAnimation(bool skip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(skipPlayAnimationKey, skip);
    } catch (e) {
      ToastUtils.showError('设置是否跳过动画失败: $e');
    }
  }

  // 获取是否跳过动画
  static Future<bool> getSkipPlayAnimation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(skipPlayAnimationKey) ?? false;
    } catch (e) {
      ToastUtils.showError('获取是否跳过动画失败: $e');
      return false;
    }
  }

  // 保存难度
  static Future<void> setGameDifficulty(GameDifficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(difficultyKey, difficulty.name);
  }

  // 获取难度，默认困难
  static Future<GameDifficulty> getGameDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(difficultyKey);
    switch (str) {
      case 'easy':
        return GameDifficulty.easy;
      case 'medium':
        return GameDifficulty.medium;
      case 'hard':
      default:
        return GameDifficulty.hard;
    }
  }
}

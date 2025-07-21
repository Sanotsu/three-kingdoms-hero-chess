import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tk_hero_chess/utils/toast_utils.dart';

/// 音频管理工具类
class AudioManager {
  static const String bgmKey = 'bgm_enabled';
  static const String sfxKey = 'sfx_enabled';

  static bool _bgmEnabled = true;
  static bool _sfxEnabled = true;

  // 初始化音频
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bgmEnabled = prefs.getBool(bgmKey) ?? true;
      _sfxEnabled = prefs.getBool(sfxKey) ?? true;

      // 预加载音效
      await FlameAudio.audioCache.loadAll([
        'background_music.mp3',
        'button_click.mp3',
        'play_or_swap_chess.mp3',
        'game_over.mp3',
        'round_start.mp3',
        'select_jin_nang.mp3',
      ]);
    } catch (e) {
      ToastUtils.showError('初始化音频失败: $e');
    }
  }

  // 播放背景音乐
  static void playBgm() {
    try {
      if (_bgmEnabled) {
        FlameAudio.bgm.play('background_music.mp3');
      }
    } catch (e) {
      ToastUtils.showError('播放背景音乐失败: $e');
    }
  }

  // 停止背景音乐
  static void stopBgm() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      ToastUtils.showError('停止背景音乐失败: $e');
    }
  }

  // 播放音效
  static void playSfx(String name) {
    try {
      if (_sfxEnabled) {
        FlameAudio.play('$name.mp3');
      }
    } catch (e) {
      ToastUtils.showError('播放音效失败: $e');
    }
  }

  // 设置背景音乐开关
  static Future<void> setBgmEnabled(bool enabled) async {
    _bgmEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(bgmKey, enabled);

    if (enabled) {
      playBgm();
    } else {
      stopBgm();
    }
  }

  // 设置音效开关
  static Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sfxKey, enabled);
  }

  // 获取背景音乐开关状态
  static bool get bgmEnabled => _bgmEnabled;

  // 获取音效开关状态
  static bool get sfxEnabled => _sfxEnabled;
}

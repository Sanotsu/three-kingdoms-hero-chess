import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/records_screen.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/game_button.dart';
import 'package:tk_hero_chess/screens/main_router.dart';

/// 欢迎界面
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initAudio();
    _initPackageInfo();
  }

  Future<void> _initAudio() async {
    await AudioManager.init();

    // 根据浏览器政策，默认不允许直接播放音频，所以web上默认不开启背景音乐和音效
    // https://developer.chrome.com/blog/autoplay
    if (ScreenHelper.isWeb()) {
      setState(() {
        _bgmEnabled = false;
        _sfxEnabled = false;
      });
    } else {
      setState(() {
        _bgmEnabled = AudioManager.bgmEnabled;
        _sfxEnabled = AudioManager.sfxEnabled;
      });
      AudioManager.playBgm();
    }
  }

  Future<void> _initPackageInfo() async {
    WidgetsFlutterBinding.ensureInitialized();

    final info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF1F2937)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 游戏标题
              Text(
                '三分英雄棋',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: ScreenHelper.setSp(48),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10.sp,
                      offset: Offset(2.sp, 2.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.sp),
              // 开始游戏按钮
              GameButton(
                text: '开始游戏',
                fontSize: ScreenHelper.setSp(28),
                color: Colors.green,
                icon: Icons.play_arrow,
                onPressed: () {
                  AudioManager.playSfx('button_click');
                  // 确保先重置游戏状态，再开始新游戏
                  final gameProvider = context.read<GameProvider>();
                  gameProvider.resetGame();
                  gameProvider.startNewGame();

                  // 导航到主路由器，它会自动显示轮次特性页面
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainRouter()),
                  );
                },
              ),
              SizedBox(height: 20.sp),
              // 游戏记录按钮
              GameButton(
                text: '游戏记录',
                fontSize: ScreenHelper.setSp(28),
                color: Colors.blue,
                icon: Icons.history,
                onPressed: () {
                  AudioManager.playSfx('button_click');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordsScreen(),
                    ),
                  );
                },
              ),

              // TODO 2025-07-21 先留个占位，没有比较合适的音效，暂时不启用它
              if (DateTime.now().year < 2025) ...[
                SizedBox(height: 30.sp),
                // 音效设置
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAudioToggle('背景音乐', _bgmEnabled, Icons.music_note, (
                      value,
                    ) async {
                      await AudioManager.setBgmEnabled(value);
                      setState(() {
                        _bgmEnabled = value;
                      });
                    }),
                    SizedBox(width: 30.sp),
                    _buildAudioToggle('音效', _sfxEnabled, Icons.volume_up, (
                      value,
                    ) async {
                      await AudioManager.setSfxEnabled(value);
                      setState(() {
                        _sfxEnabled = value;
                      });
                      if (value) {
                        AudioManager.playSfx('button_click');
                      }
                    }),
                  ],
                ),
              ],
              SizedBox(height: 48.sp),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '版本: ${_packageInfo.version}+${_packageInfo.buildNumber}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: ScreenHelper.setSp(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioToggle(
    String label,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: ScreenHelper.setSp(20)),
        SizedBox(width: 5.sp),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenHelper.setSp(16),
          ),
        ),
        Transform.scale(
          scale: kIsWeb ? 1.0 : 0.7,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.amber,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:tk_hero_chess/constants/game_constants.dart';
import 'package:tk_hero_chess/models/bond_model.dart';
import 'package:tk_hero_chess/models/hero_model.dart';
import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/providers/game_provider.dart';
import 'package:tk_hero_chess/screens/game_over_screen.dart';
import 'package:tk_hero_chess/screens/round_trait_screen.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/game_storage.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/bond_info.dart';
import 'package:tk_hero_chess/widgets/bonds_list.dart';
import 'package:tk_hero_chess/widgets/game_button.dart';
import 'package:tk_hero_chess/widgets/hero_piece.dart';
import 'package:tk_hero_chess/widgets/round_trait_display.dart';
import 'package:tk_hero_chess/widgets/jin_nang_icon.dart';

/// 游戏主界面
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // 是否显示左侧的羁绊列表
  bool _showBondsList = false;
  // 记录上一次轮次
  int _lastRound = 0;

  // 是否正在播放出棋动画
  bool _isPlayingAnimation = false;
  // 正在出棋的棋子
  List<HeroModel> _animatingHeroes = [];

  // 动画控制器
  AnimationController? _animationController;
  // 选中的棋子聚集动画
  Animation<double>? _gatherAnimation;
  // 选中的棋子移动动画
  Animation<double>? _moveAnimation;
  // 选中的棋子淡出动画
  Animation<double>? _fadeAnimation;
  // 羁绊信息显示动画
  Animation<double>? _infoAnimation;

  // 以下几个目前暂时只在羁绊动画中显示
  // 动画中显示的羁绊
  BondModel? _animatingBond;
  // 动画中显示的的得分
  int _animatingBaseScore = 0;
  // 动画中显示的倍率
  int _animatingRateMultiplier = 0;
  // 动画中显示的总得分
  int _animatingTotalScore = 0;

  // 记录每个棋子的原始位置和索引
  final Map<HeroModel, int> _originalIndices = {};
  final Map<HeroModel, Offset> _originalPositions = {};

  // 记录棋子间距和大小
  double _heroSpacing = 0;
  double _heroSize = 60.sp;

  // 存储每个棋子的GlobalKey
  final Map<HeroModel, GlobalKey> _heroKeys = {};

  // 显示当前时间
  late Timer _timeTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    // 记录初始轮次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      _lastRound = gameProvider.currentRound;

      // 初始化棋子间距
      _calculateHeroSpacing();
    });

    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      // 动画时间
      duration: const Duration(milliseconds: 3000),
    );

    // 聚集动画：0-0.2 棋子向中间聚集
    _gatherAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0, 0.2, curve: Curves.easeInOut),
      ),
    );

    // 移动动画：0.2-0.6 棋子向上移动
    _moveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0.2, 0.6, curve: Curves.easeOutQuad),
      ),
    );

    // 信息显示动画：0.4-0.9 显示羁绊和得分信息
    _infoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    // 淡出动画：0.7-0.9 棋子淡出
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0.7, 0.9, curve: Curves.easeOut),
      ),
    );

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlayingAnimation = false;
          _animatingHeroes = [];
          _originalIndices.clear();
          _originalPositions.clear();
        });
      }
    });

    // 初始化时间
    _updateTime();
    _timeTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _heroKeys.clear();
    _timeTimer.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 检查轮次是否变化
    final gameProvider = Provider.of<GameProvider>(context);
    if (_lastRound > 0 &&
        gameProvider.currentRound > _lastRound &&
        gameProvider.boardHeroes.isEmpty) {
      // 轮次变化且棋盘为空，跳转到轮次特性页面
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoundTraitScreen()),
        );
      });
    }
    _lastRound = gameProvider.currentRound;
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  // 播放出棋动画
  void _playHeroesAnimation(GameProvider gameProvider) async {
    // 获取是否跳过动画
    final skipAnimation = await GameStorage.getSkipPlayAnimation();

    // 如果用户设置跳过出棋动画，这直接减少次数和执行出棋逻辑即可
    if (skipAnimation) {
      gameProvider.reducePlayCount();
      gameProvider.playHeroes();
      return;
    }

    // 记录选中棋子的原始位置
    _originalIndices.clear();
    _originalPositions.clear();

    // 先把选中的棋子按阵营排序，避免出棋时出现交叉
    gameProvider.selectedHeroes.sort((a, b) {
      if (a.camp == b.camp) return 0;
      if (a.camp == GameConstants.campWei) return -1;
      if (b.camp == GameConstants.campWei) return 1;
      if (a.camp == GameConstants.campShu) return -1;
      return 1;
    });

    // 查找所有选中棋子的实际位置
    for (var hero in gameProvider.selectedHeroes) {
      int index = gameProvider.boardHeroes.indexOf(hero);
      if (index != -1) {
        _originalIndices[hero] = index;

        // 找到对应棋子的RenderBox
        final heroContext = _heroKeys[hero]?.currentContext;
        if (heroContext != null && heroContext.mounted) {
          final RenderBox renderBox =
              heroContext.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);
          _originalPositions[hero] = position;
        } else {
          // 如果找不到，使用默认计算方式
          double x =
              (index * _heroSpacing) + (_heroSpacing / 2 - _heroSize / 2);
          double y = 1.sh - 150.sp;
          _originalPositions[hero] = Offset(x, y);
        }
      }
    }

    setState(() {
      _isPlayingAnimation = true;
      _animatingHeroes = List.from(gameProvider.selectedHeroes);
      _animatingBond = gameProvider.activeBond;
      _animatingBaseScore = gameProvider.currentBaseScore;
      _animatingRateMultiplier = gameProvider.currentRateMultiplier;
      _animatingTotalScore =
          (_animatingBaseScore * _animatingRateMultiplier / 100).round();
    });

    // 播放音效
    AudioManager.playSfx('play_or_swap_chess');

    // 理论上应该先减少出棋次数，然后执行动画，然后执行出棋逻辑。
    gameProvider.reducePlayCount();

    // 立即启动动画
    _animationController!.reset();
    _animationController!.forward().then((_) {
      // 动画完成后执行出棋逻辑
      gameProvider.playHeroes();
    });
  }

  // 计算棋子间距
  void _calculateHeroSpacing() {
    // 计算默认棋子高度(总高度 - 顶部轮次区域高度 - 上方羁绊信息区域高度 - 下方控制按钮区域高度)
    // /2 是默认位置和出棋动画的棋子位置各一半
    var boardHeight = (1.sh - 56.sp - 48.sp - 96.sp) / 2;

    // 计算可用宽度（中间部分的宽度,理论上是占70%宽度，左侧羁绊信息按钮0.15,右侧锦囊卡0.15）
    double availableWidth = 1.sw - (0.15.sw * 2);

    // 计算每个棋子的间距，固定7等分
    // 长宽比比较小，那高度空间足够，宽度按照7等分不受影响
    // 但如果长宽比特别大，棋子的宽带太大，导致棋子高度布局就乱了，所以要进行限制
    //   /1.5 因为棋子宽高比1.2，选中时需要往上移0.3
    //   -10 因为棋子上下边距各有5sp
    _heroSpacing = math.min((boardHeight / 1.5) - 10.sp, availableWidth / 7);
    // 调整棋子大小，保持一定的间距
    _heroSize = _heroSpacing * 0.95;

    // 很奇怪，我设计时960 * 540 ，但这个小米6显示(Z60U又不一样)
    // 1.sw = 640
    // 1.sh = 360
    // 1.h = 1.sp = 1.r = 0.67
    // 1.w = 1.30
    // print(
    //   '${1.sw}  ${1.sh} ${1.w} ${1.h} ${1.sp} ${1.r}  ${availableWidth / 7}  $availableWidth 棋子间距: $_heroSpacing 棋子大小: $_heroSize',
    // );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    // 确保棋子间距已计算
    if (_heroSpacing == 0) {
      _calculateHeroSpacing();
    }

    // 检查游戏是否结束
    if (gameProvider.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameOverScreen()),
        );
      });
    }

    return Scaffold(
      // 放在layoutBuilder中，可以在web和桌面端调整窗口大小时重新计算棋子大小
      body: LayoutBuilder(
        builder: (context, constraints) {
          _calculateHeroSpacing();

          return Container(
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
              child: Stack(
                children: [
                  // 主游戏界面 - 按照示意图布局
                  Column(
                    children: [
                      // 顶部信息栏 - 固定高度56.sp
                      _buildTopBar(gameProvider),

                      // 下方主体内容 - 左中右三部分
                      Expanded(
                        child: Row(
                          children: [
                            // 左侧 - 棋列组合区域 (15% 宽度)
                            SizedBox(
                              width: 0.15.sw,
                              child: _buildBondListButton(),
                            ),

                            // 中间 - 主要游戏区域 (70% 宽度)
                            Expanded(child: _buildMiddleArea(gameProvider)),

                            // 右侧 - 锦囊区域 (15% 宽度)
                            SizedBox(
                              width: 0.15.sw,
                              child: _buildJinNangArea(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 出棋动画层
                  if (_isPlayingAnimation) buildPlayingAnimation(),

                  // 羁绊列表侧边栏
                  if (_showBondsList)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: BondsList(
                        onClose: () {
                          setState(() {
                            _showBondsList = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 出棋动画
  Widget buildPlayingAnimation() {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Stack(
          children: [
            // 移动的棋子
            ..._buildAnimatingHeroes(),

            // 羁绊和得分显示（在动画中间显示）
            if (_animationController!.value > 0.4 &&
                _animationController!.value < 0.9)
              Positioned.fill(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _infoAnimation!.value,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(
                          ScreenHelper.setRadius(15),
                        ),
                        border: Border.all(color: Colors.amber, width: 2.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 15.r,
                            spreadRadius: 5.r,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_animatingBond != null)
                            Text(
                              '激活羁绊: ${_animatingBond!.name}',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: ScreenHelper.setSp(24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          SizedBox(height: 10.sp),
                          Text(
                            '基础得分: $_animatingBaseScore',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenHelper.setSp(18),
                            ),
                          ),
                          Text(
                            '得分倍率: $_animatingRateMultiplier%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenHelper.setSp(18),
                            ),
                          ),
                          SizedBox(height: 10.sp),
                          Text(
                            '总得分: $_animatingTotalScore',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: ScreenHelper.setSp(24),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 2.r,
                                  offset: Offset(1.sp, 1.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 构建动画中的棋子
  List<Widget> _buildAnimatingHeroes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final centerX = screenWidth * 0.5;
    final heroCount = _animatingHeroes.length;
    final totalWidth = heroCount * _heroSize;
    final startX = centerX - (totalWidth / 2);

    return _animatingHeroes.asMap().entries.map((entry) {
      final index = entry.key;
      final hero = entry.value;

      // 获取原始位置
      final originalPosition =
          _originalPositions[hero] ??
          Offset(0, ScreenHelper.screenHeight - 150.sp);

      // 计算中间聚集位置（水平居中排列）
      final centerPosition = Offset(
        startX + (index * _heroSize),
        originalPosition.dy,
      );

      // 计算目标位置（第一行，棋盘上方）
      final endY = ScreenHelper.screenHeight / 2 - _heroSize;

      // 计算当前水平位置（从原始位置到中间位置）
      final currentX = _gatherAnimation!.value < 1
          ? originalPosition.dx +
                (_gatherAnimation!.value *
                    (centerPosition.dx - originalPosition.dx))
          : centerPosition.dx;

      // 计算当前垂直位置（从底部到上方）
      double currentY = originalPosition.dy;
      if (_moveAnimation!.value > 0 && _gatherAnimation!.value >= 1) {
        currentY =
            originalPosition.dy -
            (_moveAnimation!.value * (originalPosition.dy - endY));
      }

      // 计算透明度
      double opacity = 1.0;
      if (_fadeAnimation!.value < 1 && _animationController!.value > 0.7) {
        opacity = _fadeAnimation!.value;
      }

      return Positioned(
        left: currentX,
        top: currentY,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            // 添加轻微放大效果
            scale: 1.0 + (_moveAnimation!.value * 0.1),
            child: SizedBox(
              width: _heroSize,
              height: _heroSize * 1.2,
              child: HeroPiece(hero: hero, onTap: (_) {}, width: _heroSize),
            ),
          ),
        ),
      );
    }).toList();
  }

  // 顶部信息栏
  Widget _buildTopBar(GameProvider gameProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      height: 56.sp,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1.sp,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80.sp,
            margin: EdgeInsets.only(right: 20.sp),
            decoration: BoxDecoration(
              // color: const Color.fromARGB(255, 173, 169, 156),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                // size: 20.sp,
                color: Colors.yellowAccent,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('结束游戏'),
                    content: Text('确定要结束游戏吗？', textAlign: TextAlign.center),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('取消'),
                      ),

                      TextButton(
                        onPressed: () {
                          gameProvider.setGameOver(true);
                          Navigator.pop(context);
                        },
                        child: Text('确定'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 轮次和分数
          Expanded(
            child: Row(
              children: [
                Text(
                  '第${gameProvider.currentRound}轮',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: ScreenHelper.setSp(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20.sp),
                Text(
                  '目标: ${gameProvider.targetScore}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenHelper.setSp(18),
                  ),
                ),
                SizedBox(width: 20.sp),
                Text(
                  '总分: ${gameProvider.totalScore}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: ScreenHelper.setSp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20.sp),
              ],
            ),
          ),

          // 轮次特性
          if (gameProvider.currentRoundTrait != null)
            RoundTraitDisplay(trait: gameProvider.currentRoundTrait!),

          Container(
            margin: EdgeInsets.only(left: 20.sp),
            child: Center(
              child: Text(
                _currentTime,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 羁绊信息
  Widget _buildBondInfo(GameProvider gameProvider) {
    final hasSelectedHeroes = gameProvider.selectedHeroes.isNotEmpty;
    final bond = gameProvider.activeBond;
    final baseScore = gameProvider.currentBaseScore;
    final rateMultiplier = gameProvider.currentRateMultiplier;
    final totalScore = (baseScore * rateMultiplier / 100).round();

    return hasSelectedHeroes
        ? BondInfo(
            bond: bond,
            baseScore: baseScore,
            rateMultiplier: rateMultiplier,
            totalScore: totalScore,
          )
        // 不这样做区分，羁绊信息显示会是 0 x 0 而不是预设的提示信息
        : BondInfo();
  }

  Widget _buildBondListButton() {
    var skipArea = FutureBuilder(
      future: GameStorage.getSkipPlayAnimation(),
      builder: (context, snapshot) {
        return SizedBox(
          height: 30.sp,
          child: InkWell(
            onTap: () {
              setState(() {
                GameStorage.setSkipPlayAnimation(!(snapshot.data ?? false));
              });
            },
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: snapshot.data ?? false,
                    onChanged: null, // 禁用Checkbox自带的点击事件
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? Colors.amber
                          : Colors.grey.withValues(alpha: 0.6);
                    }),
                  ),
                ),
                Text(
                  '跳过出棋动画',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: ScreenHelper.setSp(14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return Stack(
      children: [
        // 固定在左下角的跳过动画复选框
        Positioned(left: 0.sp, bottom: 33.sp, child: skipArea),
        Center(
          child: GestureDetector(
            onTap: () {
              AudioManager.playSfx('button_click');
              setState(() {
                _showBondsList = !_showBondsList;
              });
            },
            child: Container(
              width: 40.sp,
              height: 150.sp,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(ScreenHelper.setRadius(10)),
                  bottomRight: Radius.circular(ScreenHelper.setRadius(10)),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 20.sp,
                    ),
                    SizedBox(height: 15.sp),
                    RotatedBox(
                      quarterTurns: 0,
                      child: Text(
                        '棋\n列\n组\n合',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: ScreenHelper.setSp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 右侧锦囊区域
  Widget _buildJinNangArea() {
    final gameProvider = Provider.of<GameProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 10.sp),
      // decoration: BoxDecoration(
      //   border: Border(
      //     left: BorderSide(
      //       color: Colors.grey.withValues(alpha: 0.3),
      //       width: 1.sp,
      //     ),
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 永久锦囊标题
          Text(
            '永久锦囊',
            style: TextStyle(
              color: Colors.amber,
              fontSize: ScreenHelper.setSp(14),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5.sp),

          // 永久锦囊（前5轮选择的）
          Column(
            children: gameProvider.permanentJinNangs.map((jinNang) {
              // 检查锦囊是否被当前选中的棋子激活
              bool isActive = _isJinNangActive(gameProvider, jinNang);
              jinNang.isActive = isActive;

              return JinNangIcon(
                jinNang: jinNang,
                onTap: () {
                  AudioManager.playSfx('button_click');
                },
              );
            }).toList(),
          ),

          // 分隔线
          if (gameProvider.permanentJinNangs.isNotEmpty &&
              gameProvider.currentRoundJinNang != null)
            Divider(color: Colors.white30, height: 10.sp, thickness: 1.sp),

          // 本轮锦囊标题
          if (gameProvider.currentRoundJinNang != null)
            Text(
              '本轮锦囊',
              style: TextStyle(
                color: Colors.amber,
                fontSize: ScreenHelper.setSp(14),
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 5.sp),

          // 当前轮次锦囊
          if (gameProvider.currentRoundJinNang != null)
            Builder(
              builder: (context) {
                JinNangModel jinNang = gameProvider.currentRoundJinNang!;
                // 检查锦囊是否被当前选中的棋子激活
                bool isActive = _isJinNangActive(gameProvider, jinNang);
                jinNang.isActive = isActive;

                return JinNangIcon(
                  jinNang: jinNang,
                  onTap: () {
                    AudioManager.playSfx('button_click');
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // 底部控制栏
  Widget _buildBottomBar(GameProvider gameProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      margin: EdgeInsets.only(bottom: 10.sp),
      // decoration: BoxDecoration(
      //   border: Border(
      //     top: BorderSide(
      //       color: Colors.grey.withValues(alpha: 0.3),
      //       width: 1.sp,
      //     ),
      //   ),
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 换棋区域
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '剩余 ${gameProvider.remainingSwapCount} 次',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(14),
                ),
              ),
              SizedBox(height: 2.sp),
              GameButton(
                text: '换棋',
                width: 126.sp,
                height: 42.sp,
                fontSize: 24.sp,
                color: Colors.blue,
                isEnabled:
                    gameProvider.remainingSwapCount > 0 &&
                    gameProvider.selectedHeroes.isNotEmpty &&
                    !_isPlayingAnimation,
                onPressed: () {
                  AudioManager.playSfx('button_click');
                  gameProvider.swapHeroes();
                },
              ),
            ],
          ),

          // 出棋区域
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '剩余 ${gameProvider.remainingPlayCount} 次',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenHelper.setSp(14),
                ),
              ),
              SizedBox(height: 2.sp),
              GameButton(
                text: '出棋',
                width: 126.sp,
                height: 42.sp,
                fontSize: 24.sp,
                color: Colors.green,
                isEnabled:
                    gameProvider.remainingPlayCount > 0 &&
                    gameProvider.selectedHeroes.isNotEmpty &&
                    !_isPlayingAnimation,
                onPressed: () {
                  // 播放出棋动画
                  _playHeroesAnimation(gameProvider);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 默认棋子区域
  Widget _buildDefaultHeroesArea(GameProvider gameProvider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          // 固定7个位置
          if (index < gameProvider.boardHeroes.length) {
            final hero = gameProvider.boardHeroes[index];

            // 如果棋子正在动画中，显示一个透明占位符
            if (_isPlayingAnimation && _animatingHeroes.contains(hero)) {
              return SizedBox(width: _heroSpacing);
            }

            // 确保每个棋子都有一个GlobalKey
            if (!_heroKeys.containsKey(hero)) {
              _heroKeys[hero] = GlobalKey();
            }

            return Container(
              width: _heroSpacing,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: _heroSize,
                height: _heroSize * 1.2,
                child: HeroPiece(
                  key: _heroKeys[hero],
                  hero: hero,
                  onTap: (hero) {
                    AudioManager.playSfx('button_click');
                    gameProvider.toggleHeroSelection(hero);
                  },
                  width: _heroSize,
                ),
              ),
            );
          } else {
            // 空位占位符
            return SizedBox(width: _heroSpacing);
          }
        }),
      ),
    );
  }

  // 中间部分的布局
  Widget _buildMiddleArea(GameProvider gameProvider) {
    return Column(
      children: [
        // 1. 羁绊信息区域 - 固定高度
        SizedBox(
          height: 48.sp,
          // 太小了可能羁绊信息显示不全
          width: math.max(440.sp, 0.5.sw),
          child: _buildBondInfo(gameProvider),
        ),

        // 2. 出棋动画区域 - 剩余高度的一半
        Expanded(
          // 只是占位,动画在其他地方处理的
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.brown.withValues(alpha: 0.2),
            //   border: Border(
            //     bottom: BorderSide(
            //       color: Colors.brown.withValues(alpha: 0.5),
            //       width: 1.sp,
            //     ),
            //   ),
            // ),
          ),
        ),

        // 3. 默认棋子区域 - 剩余高度的一半
        Expanded(child: _buildDefaultHeroesArea(gameProvider)),

        // 4. 底部控制区域 - 固定高度
        SizedBox(height: 96.sp, child: _buildBottomBar(gameProvider)),
      ],
    );
  }

  // 检查锦囊是否被当前选中的棋子激活
  bool _isJinNangActive(GameProvider gameProvider, JinNangModel jinNang) {
    if (gameProvider.selectedHeroes.isEmpty) return false;

    // 基于锦囊类型和名称检查是否激活
    switch (jinNang.name) {
      case '三思而行':
        return true; // 总是激活，因为它增加了换棋次数
      case '连环攻势':
        return true; // 总是激活，因为它增加了出棋次数
      case '以逸待劳':
        // 检查是否有未触发羁绊的棋子
        if (gameProvider.activeBond == null) return false;

        // 获取激活羁绊的棋子和未激活羁绊的棋子
        List<HeroModel> activatedHeroes = gameProvider.selectedHeroes
            .where((h) => h.isActive)
            .toList();
        List<HeroModel> nonActivatedHeroes = gameProvider.selectedHeroes
            .where((h) => !h.isActive)
            .toList();

        // 只有当有羁绊被激活且有棋子未被该羁绊激活时，才激活"以逸待劳"锦囊
        return activatedHeroes.isNotEmpty && nonActivatedHeroes.isNotEmpty;
      case '三分天下':
        // 检查是否存在多个阵营（只有1个阵营也要激活才对）
        Set<String> camps = gameProvider.selectedHeroes
            .map((h) => h.camp)
            .toSet();
        return camps.isNotEmpty;
      case '当机立断':
        // 如果没有执行换棋，则激活
        return !gameProvider.hasSwapped;
      case '欲擒故纵':
        return gameProvider.selectedHeroes.length <= 3;
      case '故技重施':
        return gameProvider.lastPlayCount == gameProvider.selectedHeroes.length;
      case '声东击西':
        // 如果是第一次出棋肯定不会激活(没有上一次激活的羁绊则表示是第一次出棋)
        if (gameProvider.lastActiveBond.isEmpty) {
          return false;
        }
        // 理论上只要选择了棋子，都有羁绊(至少是同阵营X1)
        if (gameProvider.activeBond == null) {
          return false;
        }

        // 注意：`同阵营X1` 到 `同阵营X5` 都属于同一种羁绊
        if (gameProvider.activeBond!.name.contains('同阵营') &&
            gameProvider.lastActiveBond.contains('同阵营')) {
          return false;
        }
        // 剩下的就是非同阵营的特殊羁绊了
        return gameProvider.lastActiveBond != gameProvider.activeBond?.name;
      case '釜底抽薪':
        return gameProvider.remainingPlayCount == 1;
      case '深根固本':
        return gameProvider.remainingSwapCount > 0;
      case '抛砖引玉':
        // 如果本轮换棋次数大于0，则激活
        return gameProvider.swapCount > 0;
      case '短兵相接':
        return gameProvider.selectedHeroes.length >= 3;
      default:
        return false;
    }
  }
}

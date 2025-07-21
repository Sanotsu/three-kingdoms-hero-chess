import 'package:flutter/material.dart';
import 'package:tk_hero_chess/constants/game_constants.dart';
import 'package:tk_hero_chess/models/bond_model.dart';
import 'package:tk_hero_chess/models/hero_model.dart';
import 'package:tk_hero_chess/models/jin_nang_model.dart';
import 'package:tk_hero_chess/models/round_trait_model.dart';
import 'package:tk_hero_chess/utils/game_utils.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/utils/toast_utils.dart';

/// 游戏状态提供者
class GameProvider extends ChangeNotifier {
  /// 游戏状态
  bool _isGameStarted = false;
  bool _isGameOver = false;

  // 当前轮次
  int _currentRound = 1;
  // 总得分
  int _totalScore = 0;
  // 当前轮次得分
  int _currentRoundScore = 0;
  // 剩余出棋次数
  int _remainingPlayCount = GameConstants.defaultPlayCount;
  // 剩余换棋次数
  int _remainingSwapCount = GameConstants.defaultSwapCount;
  // 上一次出棋数量
  int _lastPlayCount = 0;
  // 上一次激活的羁绊
  String _lastActiveBond = '';
  // 已经换棋的次数(如果为0,则表示没有换过棋)
  // 当机立断需要判断是否换棋，抛砖引玉锦囊需要判断换棋次数
  int _swappedCount = 0;

  /// 游戏元素
  // 棋盘上的棋子(最下面默认的棋子)
  List<HeroModel> _boardHeroes = [];
  // 被选中的棋子(要上移一点，且在选中时实时计算配合轮次信息+锦囊+羁绊 的出棋最大得分)
  List<HeroModel> _selectedHeroes = [];
  // 永久生效的锦囊(前5轮选择的锦囊)
  List<JinNangModel> _permanentJinNangs = [];
  // 当前轮次选择的锦囊(第6轮及其之后选择的锦囊，只在当前轮生效)
  JinNangModel? _currentRoundJinNang;
  // 当前可选的锦囊(每轮开始前随机生成3个锦囊供玩家选择一个)
  List<JinNangModel> _jinNangOptions = [];
  // 当前轮次特性
  RoundTraitModel? _currentRoundTrait;
  // 当前激活的羁绊
  BondModel? _activeBond;

  /// 当前计算结果
  // 当前出棋基础得分
  int _currentBaseScore = 0;
  // 当前出棋得分倍率
  int _currentRateMultiplier = 0;

  /// Getters
  bool get isGameStarted => _isGameStarted;
  bool get isGameOver => _isGameOver;

  int get currentRound => _currentRound;
  int get totalScore => _totalScore;
  int get currentRoundScore => _currentRoundScore;
  int get remainingPlayCount => _remainingPlayCount;
  int get remainingSwapCount => _remainingSwapCount;
  int get lastPlayCount => _lastPlayCount;
  String get lastActiveBond => _lastActiveBond;
  int get swapCount => _swappedCount;

  List<HeroModel> get boardHeroes => _boardHeroes;
  List<HeroModel> get selectedHeroes => _selectedHeroes;
  List<JinNangModel> get permanentJinNangs => _permanentJinNangs;
  JinNangModel? get currentRoundJinNang => _currentRoundJinNang;
  List<JinNangModel> get jinNangOptions => _jinNangOptions;
  RoundTraitModel? get currentRoundTrait => _currentRoundTrait;
  BondModel? get activeBond => _activeBond;

  int get currentBaseScore => _currentBaseScore;
  int get currentRateMultiplier => _currentRateMultiplier;

  /// 非直接变量的getter
  // 当前轮次关卡的目标得分
  int get targetScore => GameConstants.getRoundTargetScore(_currentRound);
  // 当前轮次是否已经换过棋
  bool get hasSwapped => _swappedCount > 0;

  // 所有激活的锦囊
  List<JinNangModel> get activeJinNangs {
    List<JinNangModel> active = [];
    active.addAll(_permanentJinNangs);
    if (_currentRoundJinNang != null) {
      active.add(_currentRoundJinNang!);
    }
    return active;
  }

  // 设置当前游戏状态
  void setGameOver(bool isOver) {
    _isGameOver = isOver;
    notifyListeners();
  }

  // 开始新游戏(全部重置)
  void startNewGame() {
    _isGameStarted = true;
    _isGameOver = false;
    _currentRound = 1;
    _totalScore = 0;
    _currentRoundScore = 0;
    _lastPlayCount = 0;
    _lastActiveBond = '';
    _swappedCount = 0;
    _boardHeroes = []; // 确保棋盘为空
    _selectedHeroes = [];
    _permanentJinNangs = [];
    _currentRoundJinNang = null;

    // 生成轮次特性
    _currentRoundTrait = GameUtils.generateRoundTrait(_currentRound);

    // 清空锦囊选项，以便主路由器显示轮次特性页面
    _jinNangOptions = [];

    // 统一应用锦囊中换棋次数和出棋次数
    _applyAllJinNangCounts();

    notifyListeners();
  }

  // 选择锦囊
  void selectJinNang(int index) {
    if (index < 0 || index >= _jinNangOptions.length) return;

    JinNangModel selected = _jinNangOptions[index];

    // 前5轮的锦囊永久生效
    if (_currentRound <= 5) {
      selected.isPermanent = true;
      _permanentJinNangs.add(selected);
    } else {
      _currentRoundJinNang = selected;
    }

    // 生成初始棋盘
    _boardHeroes = GameUtils.generateRandomHeroes(
      GameConstants.boardHeroCount,
      _currentRoundTrait,
      existingHeroes: [], // 初始棋盘，没有已有棋子
    );

    // 统一应用锦囊中换棋次数和出棋次数
    _applyAllJinNangCounts();

    notifyListeners();
  }

  // 统一应用所有锦囊的换棋/出棋次数加成(其他锦囊效果在计算得分时应用)
  void _applyAllJinNangCounts() {
    // 默认次数
    _remainingSwapCount = GameConstants.defaultSwapCount;
    _remainingPlayCount = GameConstants.defaultPlayCount;

    // 叠加所有永久锦囊
    for (var jinNang in _permanentJinNangs) {
      if (jinNang.name == '三思而行') {
        _remainingSwapCount += jinNang.value;
      } else if (jinNang.name == '连环攻势') {
        _remainingPlayCount += jinNang.value;
      }
    }
    // 叠加本轮锦囊
    if (_currentRoundJinNang != null) {
      if (_currentRoundJinNang!.name == '三思而行') {
        _remainingSwapCount += _currentRoundJinNang!.value;
      } else if (_currentRoundJinNang!.name == '连环攻势') {
        _remainingPlayCount += _currentRoundJinNang!.value;
      }
    }
  }

  // 选择或取消选择棋子
  void toggleHeroSelection(HeroModel hero) {
    int index = _boardHeroes.indexWhere((h) => h == hero);
    if (index == -1) return;

    if (hero.isSelected) {
      // 取消选择
      hero.isSelected = false;
      _selectedHeroes.remove(hero);
    } else {
      // 检查是否已达到最大选择数量
      if (_selectedHeroes.length >= GameConstants.maxSelectedHeroCount) {
        ToastUtils.showInfo(
          '最多只能选择${GameConstants.maxSelectedHeroCount}个棋子哦~',
          align: (ScreenHelper.isWeb() || ScreenHelper.isDesktop())
              ? Alignment.center
              : Alignment.topCenter,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // 选择棋子
      hero.isSelected = true;
      _selectedHeroes.add(hero);
    }

    // 计算最佳羁绊和得分
    _calculateBestBond();

    notifyListeners();
  }

  // 计算最佳羁绊和得分
  void _calculateBestBond() {
    if (_selectedHeroes.isEmpty) {
      _activeBond = null;
      _currentBaseScore = 0;
      _currentRateMultiplier = 0;
      return;
    }

    // 调用GameUtils中的calculateBestBond方法计算最佳羁绊和得分
    Map<String, dynamic> result = GameUtils.calculateBestBond(
      _selectedHeroes,
      activeJinNangs,
      _remainingSwapCount,
      _lastPlayCount,
      _lastActiveBond,
      _remainingPlayCount == 1, // 是否是最后一次出棋
      _swappedCount, // 换棋次数
    );

    _activeBond = result['bond'];
    _currentBaseScore = result['baseScore'];
    _currentRateMultiplier = result['rateMultiplier'];
  }

  // 换棋
  void swapHeroes() {
    if (_remainingSwapCount <= 0 || _selectedHeroes.isEmpty) return;

    // 增加换棋次数
    _swappedCount++;

    // 移除选中的棋子
    List<int> indicesToRemove = [];
    for (var hero in _selectedHeroes) {
      int index = _boardHeroes.indexWhere((h) => h == hero);
      if (index != -1) {
        indicesToRemove.add(index);
      }
    }

    // 按索引从大到小排序，以避免删除时索引变化
    indicesToRemove.sort((a, b) => b.compareTo(a));

    // 删除选中的棋子
    for (var index in indicesToRemove) {
      _boardHeroes.removeAt(index);
    }

    // 生成新棋子，考虑已有棋子，避免可重复的棋子数量异常
    List<HeroModel> newHeroes = GameUtils.generateRandomHeroes(
      _selectedHeroes.length,
      _currentRoundTrait,
      existingHeroes: _boardHeroes, // 传递剩余的棋子
    );

    // 添加新棋子
    _boardHeroes.addAll(newHeroes);

    // 按阵营排序
    _boardHeroes.sort((a, b) {
      if (a.camp == b.camp) return 0;
      if (a.camp == GameConstants.campWei) return -1;
      if (b.camp == GameConstants.campWei) return 1;
      if (a.camp == GameConstants.campShu) return -1;
      return 1;
    });

    // 清空选中的棋子
    _selectedHeroes = [];

    // 减少换棋次数
    _remainingSwapCount--;

    notifyListeners();
  }

  // 减少出棋次数
  void reducePlayCount() {
    _remainingPlayCount--;
  }

  // 出棋
  void playHeroes() {
    // if (_remainingPlayCount <= 0 || _selectedHeroes.isEmpty) return;

    // 因为在点击时已经减少了剩余出棋次数，所以实际执行时不要检查剩余出棋次数了
    if (_selectedHeroes.isEmpty) return;

    // 计算得分
    _calculateBestBond();

    // 更新本轮得分
    int playScore = (_currentBaseScore * _currentRateMultiplier / 100).round();
    _currentRoundScore += playScore;
    _totalScore += playScore;

    // 记录本次出棋信息
    _lastPlayCount = _selectedHeroes.length;
    _lastActiveBond = _activeBond?.name ?? '';

    // 移除选中的棋子
    List<int> indicesToRemove = [];
    for (var hero in _selectedHeroes) {
      int index = _boardHeroes.indexWhere((h) => h == hero);
      if (index != -1) {
        indicesToRemove.add(index);
      }
    }

    // 按索引从大到小排序，以避免删除时索引变化
    indicesToRemove.sort((a, b) => b.compareTo(a));

    // 删除选中的棋子
    for (var index in indicesToRemove) {
      _boardHeroes.removeAt(index);
    }

    // 生成新棋子，考虑已有棋子
    List<HeroModel> newHeroes = GameUtils.generateRandomHeroes(
      _selectedHeroes.length,
      _currentRoundTrait,
      existingHeroes: _boardHeroes, // 传递剩余的棋子
    );

    // 添加新棋子
    _boardHeroes.addAll(newHeroes);

    // 按阵营排序
    _boardHeroes.sort((a, b) {
      if (a.camp == b.camp) return 0;
      if (a.camp == GameConstants.campWei) return -1;
      if (b.camp == GameConstants.campWei) return 1;
      if (a.camp == GameConstants.campShu) return -1;
      return 1;
    });

    // 清空选中的棋子
    _selectedHeroes = [];

    // // 减少出棋次数
    // _remainingPlayCount--;

    // 出棋完成之后，重置换棋次数为0,也是重置为未换棋状态
    _swappedCount = 0;

    // 检查是否需要结束轮次
    if (_remainingPlayCount == 0) {
      _checkRoundCompletion();
    }

    notifyListeners();
  }

  // 检查轮次是否完成
  void _checkRoundCompletion() {
    // 检查是否达到目标分数
    if (_totalScore >= GameConstants.getRoundTargetScore(_currentRound)) {
      // 准备进入下一轮 - 移除延迟，直接更新状态
      // 清空棋盘和锦囊选项，以便主路由器显示轮次特性页面
      _boardHeroes = [];
      _jinNangOptions = [];

      // 增加轮次
      _currentRound++;

      // 生成轮次特性(上面以及++了，这里不必轮次+1了)
      _currentRoundTrait = GameUtils.generateRoundTrait(_currentRound);

      // 重置轮次状态
      _currentRoundScore = 0;
      _lastPlayCount = 0;
      _lastActiveBond = '';
      _swappedCount = 0;
      _currentRoundJinNang = null;
      _selectedHeroes = [];

      // 统一应用锦囊中换棋次数和出棋次数
      _applyAllJinNangCounts();

      notifyListeners();
    } else {
      // 游戏结束
      _isGameOver = true;
      notifyListeners();
    }
  }

  // 生成锦囊选项
  void generateJinNangOptions() {
    _jinNangOptions = GameUtils.generateRandomJinNangOptions(
      3,
      _permanentJinNangs,
      _currentRound,
    );

    notifyListeners();
  }

  // 重置游戏
  void resetGame() {
    _isGameStarted = false;
    _isGameOver = false;
    notifyListeners();
  }
}

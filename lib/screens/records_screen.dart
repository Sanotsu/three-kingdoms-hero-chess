import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:tk_hero_chess/models/game_record_model.dart';
import 'package:tk_hero_chess/utils/audio_manager.dart';
import 'package:tk_hero_chess/utils/game_storage.dart';
import 'package:tk_hero_chess/utils/screen_helper.dart';
import 'package:tk_hero_chess/widgets/game_button.dart';

/// 游戏记录界面
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<GameRecordModel> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    final records = await GameStorage.getGameRecords();

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _clearRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有游戏记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await GameStorage.clearGameRecords();
      AudioManager.playSfx('button_click');
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '游戏记录',
          style: TextStyle(
            fontSize: ScreenHelper.setSp(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _records.isEmpty ? null : _clearRecords,
            tooltip: '清除所有记录',
          ),
        ],
      ),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : _records.isEmpty
            ? _buildEmptyState()
            : _buildRecordsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: Colors.white54,
            size: ScreenHelper.setSp(60),
          ),
          SizedBox(height: 20.sp),
          Text(
            '暂无游戏记录',
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenHelper.setSp(20),
            ),
          ),
          SizedBox(height: 40.sp),
          GameButton(
            text: '返回',
            fontSize: ScreenHelper.setSp(28),
            color: Colors.blue,
            onPressed: () {
              AudioManager.playSfx('button_click');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return Column(
      children: [
        // 表头
        Container(
          padding: EdgeInsets.all(15.sp),
          color: Colors.black26,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '排名',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: ScreenHelper.setSp(16),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '完成轮次',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: ScreenHelper.setSp(16),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '总分',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: ScreenHelper.setSp(16),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '时间',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: ScreenHelper.setSp(16),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // 记录列表
        Expanded(
          child: ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              final isTop3 = index < 3;
              final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

              return Container(
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.black12 : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: Colors.white10, width: 1.sp),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isTop3 ? Colors.amber : Colors.white,
                          fontSize: ScreenHelper.setSp(16),
                          fontWeight: isTop3
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${record.completedRounds}轮',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenHelper.setSp(16),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${record.totalScore}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: ScreenHelper.setSp(16),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        dateFormat.format(record.playTime),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ScreenHelper.setSp(14),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 返回按钮
        Padding(
          padding: EdgeInsets.all(15.sp),
          child: GameButton(
            text: '返回',
            color: Colors.blue,
            onPressed: () {
              AudioManager.playSfx('button_click');
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}

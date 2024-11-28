import 'dart:math';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'board_config_provider.g.dart';

enum OutputType { relay, dryContact, dimming }

extension OutputTypeExtension on OutputType {
  String get displayName {
    switch (this) {
      case OutputType.relay:
        return '继电器';
      case OutputType.dryContact:
        return '干接点';
      case OutputType.dimming:
        return '调光器';
    }
  }
}

// 输入电平
enum InputLevel {
  low,
  high,
  lowHigh,
  highLow,
}

extension InputLevelExtension on InputLevel {
  String get displayName {
    switch (this) {
      case InputLevel.low:
        return '低';
      case InputLevel.high:
        return '高';
      case InputLevel.lowHigh:
        return '低到高';
      case InputLevel.highLow:
        return '高到低';
    }
  }
}

// 板子上的一个输出
@JsonSerializable()
class BoardOutput {
  int hostBoardId; // 电路所在的板子的ID

  @JsonKey(fromJson: _outputTypeFromJson, toJson: _outputTypeToJson)
  OutputType type;
  int channel;
  String name;
  final int uid;

  BoardOutput({
    required this.type,
    required this.channel,
    required this.name,
    required this.hostBoardId,
    required this.uid,
  });

  // BoardOutput的正反序列化
  factory BoardOutput.fromJson(Map<String, dynamic> json) =>
      _$BoardOutputFromJson(json);
  Map<String, dynamic> toJson() => _$BoardOutputToJson(this);

  // OutputType的正反序列化
  static OutputType _outputTypeFromJson(int index) => OutputType.values[index];
  static int _outputTypeToJson(OutputType type) => type.index;
}

// 板子上的一个输入
@JsonSerializable()
class BoardInput {
  int hostBoardId;
  int channel;

  @JsonKey(fromJson: _inputLevelFromJson, toJson: _inputLevelToJson)
  InputLevel level;
  int actionGroupUid;

  BoardInput({
    required this.channel,
    required this.level,
    required this.actionGroupUid,
    required this.hostBoardId,
  });

  // BoardInput的正反序列化
  factory BoardInput.fromJson(Map<String, dynamic> json) =>
      _$BoardInputFromJson(json);
  Map<String, dynamic> toJson() => _$BoardInputToJson(this);

  // InputLevel的正反序列化
  static InputLevel _inputLevelFromJson(int index) => InputLevel.values[index];
  static int _inputLevelToJson(InputLevel level) => level.index;
}

// 一块板子
@JsonSerializable()
class BoardConfig {
  int id;

  @JsonKey(fromJson: _outputsFromJson, toJson: _outputsToJson)
  Map<int, BoardOutput> outputs = {};
  List<BoardInput> inputs = [];

  BoardConfig({
    required this.id,
  });

  void removeInputAt(int i) {
    inputs.removeAt(i);
  }

  // BoardConfig的正反序列化
  factory BoardConfig.fromJson(Map<String, dynamic> json) =>
      _$BoardConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BoardConfigToJson(this);

  // 为outputs的Map类型调整序列化方式
  static Map<int, BoardOutput> _outputsFromJson(List<dynamic> jsonList) {
    return {
      for (var item in jsonList)
        (item['uid'] as int): BoardOutput.fromJson(item as Map<String, dynamic>)
    };
  }

  static List<Map<String, dynamic>> _outputsToJson(
      Map<int, BoardOutput> outputs) {
    return outputs.values.map((output) => output.toJson()).toList();
  }
}

// 整个板子配置的管理类
class BoardConfigNotifier extends ChangeNotifier {
  // 所有板子
  List<BoardConfig> _allBoard = [];

  List<BoardConfig> get allBoard => _allBoard;

  // 所有板子里的输出/输入
  Map<int, BoardOutput> get allOutputs =>
      Map.fromEntries(_allBoard.expand((board) => board.outputs.entries));

  List<BoardInput> get allInputs =>
      _allBoard.expand((board) => board.inputs).toList();

  void addBoard() {
    _allBoard.add(BoardConfig(id: _allBoard.length));
    notifyListeners();
  }

  void removeAt(int index) {
    _allBoard.removeAt(index);
    notifyListeners();
  }

  void addOutputToBoard(int boardId) {
    final board = _allBoard.firstWhere((board) => board.id == boardId);

    final newOutput = BoardOutput(
        type: OutputType.relay,
        channel: 127,
        name: '',
        hostBoardId: boardId,
        uid: UidManager().generateOutputUid());
    board.outputs[newOutput.uid] = newOutput;
    notifyListeners();
  }

  void addInputToBoard(BuildContext context, int boardId) {
    final allActionGroups =
        Provider.of<ActionConfigNotifier>(context, listen: false)
            .allActionGroup;
    if (allActionGroups.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置动作组')));
      return;
    }
    final board = _allBoard.firstWhere((board) => board.id == boardId);
    board.inputs.add(BoardInput(
        channel: 127,
        level: InputLevel.low,
        actionGroupUid: allActionGroups.values.first.uid,
        hostBoardId: boardId));
    notifyListeners();
  }

  // 更新整个 Map
  void deserializationUpdate(List<BoardConfig> newBoards) {
    _allBoard.clear();
    // 找到所有 BoardOutput 中的最大 UID
    int newOutputUidMax = newBoards.fold(0, (prev, board) {
      return max(
        prev,
        board.outputs.values
            .fold(0, (boardPrev, output) => max(boardPrev, output.uid)),
      );
    });

    UidManager().setOutputUid(newOutputUidMax + 1);

    _allBoard.addAll(newBoards);
    notifyListeners();
  }
}

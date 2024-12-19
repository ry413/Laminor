import 'dart:math';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';

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
}

extension InputLevelExtension on InputLevel {
  String get displayName {
    switch (this) {
      case InputLevel.low:
        return '低';
      case InputLevel.high:
        return '高';
    }
  }
}

// 板子上的一个输出
@JsonSerializable()
class BoardOutput with UsageCountMixin {
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

// 板子输入的动作组类
class InputActionGroup extends ActionGroupBase {
  InputActionGroup({
    required super.uid,
    required super.atomicActions,
  });

  factory InputActionGroup.fromJson(Map<String, dynamic> json) {
    final actionGroup = InputActionGroup(
      uid: json['uid'] as int,
      atomicActions: (json['atomicActions'] as List<dynamic>)
          .map((e) => AtomicAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    ActionGroupManager().addActionGroup(actionGroup);
    UidManager().updateActionGroupUid(actionGroup.uid);
    return actionGroup;
  }
}

// 板子上的一个输入
@JsonSerializable()
class BoardInput extends InputBase {
  int hostBoardId;
  int channel;

  @JsonKey(fromJson: _inputLevelFromJson, toJson: _inputLevelToJson)
  InputLevel level;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int currentActionGroupIndex; // 当前动作组索引

  BoardInput(
      {required this.channel,
      required this.level,
      required this.hostBoardId,
      required super.actionGroups,
      this.currentActionGroupIndex = 0});

  // BoardInput的正反序列化
  factory BoardInput.fromJson(Map<String, dynamic> json) {
    final input = BoardInput(
      channel: (json['channel'] as num).toInt(),
      level: BoardInput._inputLevelFromJson((json['level'] as num).toInt()),
      hostBoardId: (json['hostBoardId'] as num).toInt(),
      actionGroups: (json['actionGroups'] as List<dynamic>)
          .map((e) => InputActionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    input.modeName = json['modeName'] as String?;

    // 将本按钮设置为此动作组的宿主
    for (var actionGroup in input.actionGroups) {
      actionGroup.parent = input;
    }
    return input;
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hostBoardId': hostBoardId,
      'channel': channel,
      'level': BoardInput._inputLevelToJson(level),
      'actionGroups': actionGroups,
      if (modeName != null && modeName != '') 'modeName': modeName
    };
  }

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

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<BoardInput> inputs = [];

  BoardConfig({
    required this.id,
  });

  void removeInputAt(int i) {
    for (var input in inputs) {
      for (var actionGroup in input.actionGroups) {
        actionGroup.remove();
      }
    }
    inputs.removeAt(i);
  }

  // BoardConfig的正反序列化
  factory BoardConfig.fromJson(Map<String, dynamic> json) =>
      _$BoardConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BoardConfigToJson(this);

  void loadInputsFromJson(List<dynamic> inputsJson) {
    inputs = inputsJson
        .map((e) => BoardInput.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
  final BoardManager _boardManager = BoardManager();

  // 所有板子
  List<BoardConfig> get allBoard => _boardManager.allBoards;

  void addBoard() {
    _boardManager.addBoard(BoardConfig(id: _boardManager.allBoards.length));
    notifyListeners();
  }

  void removeAt(int index) {
    _boardManager.removeBoardAt(index);
    notifyListeners();
  }

  // 所有板子里的输出/输入
  Map<int, BoardOutput> get allOutputs => _boardManager.allOutputs;
  List<BoardInput> get allInputs => _boardManager.allInputs;

  void addOutputToBoard(int boardId) {
    _boardManager.addOutputToBoard(boardId);
    notifyListeners();
  }

  void addInputToBoard(int boardId) {
    _boardManager.addInputToBoard(boardId);
    notifyListeners();
  }

  // 更新整个 Map
  void deserializationUpdate(List<BoardConfig> newBoards) {
    _boardManager.clear();

    // 找到所有 BoardConfig的所有BoardOutput 中的最大 UID
    int newOutputUidMax = newBoards.fold(0, (prev, board) {
      return max(
        prev,
        board.outputs.values
            .fold(0, (boardPrev, output) => max(boardPrev, output.uid)),
      );
    });
    UidManager().setOutputUid(newOutputUidMax + 1);

    for (var board in newBoards) {
      _boardManager.addBoard(board);
    }
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }
}

import 'dart:math';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';

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

// 输入类型
enum InputType { lowLevel, highLevel, infrared }

extension InputTypeExtension on InputType {
  String get displayName {
    switch (this) {
      case InputType.lowLevel:
        return '低电平';
      case InputType.highLevel:
        return '高电平';
      case InputType.infrared:
        return '红外';
    }
  }
}

// 板子上的一个输出
class BoardOutput with UsageCountMixin {
  int hostBoardId; // 电路所在的板子的ID

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
  factory BoardOutput.fromJson(Map<String, dynamic> json) => BoardOutput(
        type: BoardOutput._outputTypeFromJson((json['tp'] as num).toInt()),
        channel: (json['ch'] as num).toInt(),
        name: json['nm'] as String,
        hostBoardId: (json['hBId'] as num).toInt(),
        uid: (json['uid'] as num).toInt(),
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hBId': hostBoardId,
      'tp': BoardOutput._outputTypeToJson(type),
      'ch': channel,
      'nm': name,
      'uid': uid,
    };
  }

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
      atomicActions: (json['atoActs'] as List<dynamic>)
          .map((e) => AtomicAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    ActionGroupManager().addActionGroup(actionGroup);
    UidManager().updateActionGroupUid(actionGroup.uid);
    return actionGroup;
  }
}

// 板子上的一个输入
class BoardInput extends InputBase {
  int hostBoardId;
  int channel;
  InputType inputType;

  int? infraredDuration; // 反正, 是红外检测时, 多久没检测到人就关闭设备的'多久'

  @JsonKey(includeToJson: false, includeFromJson: false)
  int currentActionGroupIndex; // 当前动作组索引

  BoardInput(
      {required this.channel,
      required this.inputType,
      required this.hostBoardId,
      required super.actionGroups,
      this.currentActionGroupIndex = 0});

  // BoardInput的正反序列化
  factory BoardInput.fromJson(Map<String, dynamic> json) {
    final input = BoardInput(
      channel: (json['ch'] as num).toInt(),
      inputType: BoardInput._inputTypeFromJson((json['iTp'] as num).toInt()),
      hostBoardId: (json['hBId'] as num).toInt(),
      actionGroups: (json['actGps'] as List<dynamic>)
          .map((e) => InputActionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    input.infraredDuration = (json['infDu'] as num?)?.toInt();
    input.modeName = json['modeName'] as String?;

    return input;
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hBId': hostBoardId,
      'ch': channel,
      'iTp': BoardInput._inputTypeToJson(inputType),
      'actGps': actionGroups,
      if (modeName != null && modeName != '') 'modeName': modeName,
      if (infraredDuration != null) 'infDu': infraredDuration,
    };
  }

  // InputType的正反序列化
  static InputType _inputTypeFromJson(int index) => InputType.values[index];
  static int _inputTypeToJson(InputType type) => type.index;
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
  factory BoardConfig.fromJson(Map<String, dynamic> json) => BoardConfig(
        id: (json['id'] as num).toInt(),
      )..outputs = BoardConfig._outputsFromJson(json['os'] as List);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'os': BoardConfig._outputsToJson(outputs),
      'is': inputs,
    };
  }

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

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_web_1/uid_manager.dart';

// 动作类型
enum ActionType {
  lamp, // 操作灯
  airCon, // 操作空调
  curtain, // 操作窗帘
  rs485, // 操作485
  output,    // 直接操作继电器

  actionGroup, // 调用动作组
  delay, // 延时
}

extension ActionTypeExtension on ActionType {
  String get displayName {
    switch (this) {
      case ActionType.lamp:
        return '灯';
      case ActionType.airCon:
        return '空调';
      case ActionType.curtain:
        return '窗帘';
      case ActionType.rs485:
        return '485';
      case ActionType.output:
        return '输出通道';
      // 特殊
      case ActionType.actionGroup:
        return '动作组';
      case ActionType.delay:
        return '延时';
    }
  }
}

// 一个动作, 这个类突然成核心了
class Action {
  ActionType type;
  int? targetUID; // 目标的uid, 根据type来查对应的表, 只有type是delay时才会不存在
  String _operation;
  dynamic parameter; // operation的参数

  Action({required this.type})
    : _operation = '';

  set operation (String newValue) {
    _operation = newValue;
    if (_operation == '调光' || _operation == '延时') {
      parameter = 0;
    }
  }
  String get operation => _operation;

  factory Action.fromJson(Map<String, dynamic> json) {
    final type = ActionType.values[json['type'] as int];
    final operation = json['operation'] as String;
    final action = Action(type: type);
    action.operation = operation;

    // 除了delay都有targetUID
    if (type != ActionType.delay) {
      action.targetUID = json['targetUID'] as int;
    }

    switch (type) {
      case ActionType.lamp:
        if (action.operation == '调光') {
          action.parameter = json['parameter'] as int; // 调光亮度等级, 1~10
        }
        break;
      case ActionType.airCon:
        break;
      case ActionType.curtain:
        break;
      case ActionType.rs485:
        break;
      case ActionType.output:
        break;
      case ActionType.actionGroup:
        break;
      case ActionType.delay:
        action.parameter = json['parameter'] as int; // 延时秒数
    }

    return action;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'type': type.index,
    };
    // 除了delay都有targetUID
    if (type != ActionType.delay) {
      jsonMap['targetUID'] = targetUID;
    }
    // 所有类型都有operation, 至于为什么写在这行是因为我想把这个放在targetUID下面
    jsonMap['operation'] = operation;

    // 根据类型解析parameter
    switch (type) {
      case ActionType.lamp:
        if (operation == '调光') {
          jsonMap['parameter'] = parameter as int; // 调光亮度等级, 1~10
        }
        break;
      case ActionType.airCon:
        break;
      case ActionType.curtain:
        break;
      case ActionType.rs485:
        break;
      case ActionType.output:
        break;
      case ActionType.actionGroup:
        break;
      case ActionType.delay:
        jsonMap['parameter'] = parameter as int; // 延时秒数
        break;
    }
    return jsonMap;
  }
}

// 动作组
class ActionGroup {
  final int uid;
  String name;
  List<Action> actions;

  ActionGroup({required this.uid, required this.name, required this.actions});

  static List<String> get operations {
    return ['调用', '销毁'];
  }

  // 动作组的正反序列化, 手写
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'actionList': actions.map((action) => action.toJson()).toList(),
    };
  }

  factory ActionGroup.fromJson(Map<String, dynamic> json) {
    return ActionGroup(
      uid: json['uid'] as int,
      name: json['name'] as String,
      actions: (json['actionList'] as List<dynamic>)
          .map((actionJson) =>
              Action.fromJson(actionJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActionConfigNotifier extends ChangeNotifier {
  Map<int, ActionGroup> _actionGroups = {};

  Map<int, ActionGroup> get allActionGroup => _actionGroups;

  // 更新整个 Map
  void updateActionGroupsMap(Map<int, ActionGroup> newActionGroups) {
    _actionGroups = newActionGroups;
    notifyListeners();
  }

  // 删除指定键
  void removeActionGroup(int key) {
    _actionGroups.remove(key);
    notifyListeners();
  }

  // 添加或修改 ActionGroup
  void addOrUpdateActionGroup(Action initialItem) {
    final actionGroup = ActionGroup(
      uid: UidManager().generateActionGroupUid(),
      name: '未命名 动作组',
      actions: [initialItem],
    );
    _actionGroups[actionGroup.uid] = actionGroup;
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void deserializationUpdate(List<ActionGroup> newActionGroups) {
    _actionGroups.clear();

    int newActionGroupUidMax = newActionGroups.fold(
        0, (prev, actionGroup) => max(prev, actionGroup.uid));

    UidManager().setActionGroupUid(newActionGroupUidMax + 1);

    for (var actionGroup in newActionGroups) {
      _actionGroups[actionGroup.uid] = actionGroup;
    }

    notifyListeners();
  }
}

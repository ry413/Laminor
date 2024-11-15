import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

// 动作类型
enum ActionType {
  lamp,       // 操作灯
  airCon,     // 操作空调
  curtain,    // 操作窗帘
  // rs485,      // 操作485

  actionGroup,// 调用动作组
  delay,      // 延时
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
      // case ActionType.rs485:
      //   return '485';

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
  ActionType _type;

  Lamp? _lampConfig; // 1
  AirCon? _airConConfig; // 2
  // 窗帘类 3
  int? _actionGroupUid; // 4    // 这个比较特殊, 只储存目标动作组的uid, 因为反序列化的时候会死锁之类的
  int? _delayTime; // 5         // 至于别的设备类型为什么不存uid

  String operation;

  Action({required ActionType type})
      : _type = type,
        operation = '';

  // 修改type时清空无关的数据
  ActionType get type => _type;
  set type(ActionType newType) {
    _type = newType;

    // 应该清除非newType的所有实例指针
    switch (newType) {
      case ActionType.lamp:
        _airConConfig = null; // 2
        // ...3
        _actionGroupUid = null; // 4
        _delayTime = null; // 5
        break;
      case ActionType.airCon:
        _lampConfig = null; // 1
        // ...3
        _actionGroupUid = null; // 4
        _delayTime = null; // 5
        break;
      case ActionType.curtain:
        _lampConfig = null; // 1
        _airConConfig = null; // 2
        _actionGroupUid = null; // 4
        _delayTime = null; // 5
        break;
      case ActionType.actionGroup:
        _lampConfig = null; // 1
        _airConConfig = null;
        // ...3
        _delayTime = null; // 5
      case ActionType.delay:
        _lampConfig = null; // 1
        _airConConfig = null;
        // ...3
        _actionGroupUid = null; // 4
    }
  }

  // 灯
  Lamp? get lamp => _lampConfig;
  set lamp(Lamp? newLampConfig) {
    if (_type == ActionType.lamp) {
      _lampConfig = newLampConfig;
      operation = newLampConfig!.operations.first;
    }
  }

  // 空调
  AirCon? get airCon => _airConConfig;
  set airCon(AirCon? newACConfig) {
    if (_type == ActionType.airCon) {
      _airConConfig = newACConfig;
      operation = newACConfig!.operations.first;
    }
  }

  // 调用动作组
  int? get actionGroupUid => _actionGroupUid;
  set actionGroupUid(int? newActionGroupUid) {
    if (_type == ActionType.actionGroup) {
      _actionGroupUid = newActionGroupUid;
      operation = '';
    }
  }

  // 延时
  int? get delayTime => _delayTime;
  set delayTime(int? newDelayTime) {
    if (_type == ActionType.delay) {
      _delayTime = newDelayTime;
      operation = '';
    }
  }

  factory Action.fromJson(Map<String, dynamic> json, BuildContext context) {
    final lampNotifier = Provider.of<LampNotifier>(context, listen: false);
    final airConNotifier = Provider.of<AirConNotifier>(context, listen: false);

    final type = ActionType.values[json['类型'] as int];
    final action = Action(type: type);

    switch (type) {
      case ActionType.lamp:
        final lampUid = json['灯UID'] as int;
        action._lampConfig = lampNotifier.allLamp.firstWhere(
          (lamp) => lamp.uid == lampUid,
          orElse: () => throw Exception('没有找到UID为$lampUid的灯'),
        );
        action.operation = json['操作'] as String;
        break;
      case ActionType.airCon:
        final airConId = json['空调ID'] as int;
        action._airConConfig = airConNotifier.allAirCons.firstWhere(
          (airCon) => airCon.id == airConId,
          orElse: () => throw Exception('没有找到ID为$airConId的空调'),
        );
        action.operation = json['操作'] as String;
        break;
      case ActionType.curtain:
        break;
      case ActionType.actionGroup:
        action.actionGroupUid = json['动作组UID'] as int;
      case ActionType.delay:
        action._delayTime = json['延时'] as int;
    }

    return action;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      '类型': _type.index,
    };

    switch (_type) {
      case ActionType.lamp:
        jsonMap['灯UID'] = _lampConfig!.uid;
        jsonMap['操作'] = operation;
        break;
      case ActionType.airCon:
        jsonMap['空调ID'] = _airConConfig!.id;
        jsonMap['操作'] = operation;
        break;
      case ActionType.curtain:
        //
        break;

      // 这两个没有操作
      case ActionType.actionGroup:
        jsonMap['动作组UID'] = _actionGroupUid;
        break;
      case ActionType.delay:
        jsonMap['延时'] = _delayTime;
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

  // 动作组的正反序列化, 手写
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'actionList': actions.map((action) => action.toJson()).toList(),
    };
  }

  factory ActionGroup.fromJson(
      Map<String, dynamic> json, BuildContext context) {
    return ActionGroup(
      uid: json['uid'] as int,
      name: json['name'] as String,
      actions: (json['actionList'] as List<dynamic>)
          .map((actionJson) =>
              Action.fromJson(actionJson as Map<String, dynamic>, context))
          .toList(),
    );
  }
}

class ActionConfigNotifier extends ChangeNotifier {
  Map<int, ActionGroup> _actionGroups = {};

  Map<int, ActionGroup> get allActionGroup => _actionGroups;

  // 更新整个 Map
  void updateActionGroups(Map<int, ActionGroup> newActionGroups) {
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

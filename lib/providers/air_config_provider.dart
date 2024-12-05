import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'air_config_provider.g.dart';

// 空调模式
enum ACMode {
  cooling,
  heating,
  fan,
}

extension ACModeExtension on ACMode {
  String get displayName {
    switch (this) {
      case ACMode.cooling:
        return '制冷';
      case ACMode.heating:
        return '制热';
      case ACMode.fan:
        return '通风';
    }
  }
}

// 空调风速
enum ACFanSpeed {
  low,
  mid,
  high,
  auto,
}

extension ACFanSpeedExtension on ACFanSpeed {
  String get displayName {
    switch (this) {
      case ACFanSpeed.low:
        return '低';
      case ACFanSpeed.mid:
        return '中';
      case ACFanSpeed.high:
        return '高';
      case ACFanSpeed.auto:
        return '自动';
    }
  }
}

// 空调停止动作
enum ACStopAction {
  closeAll,
  closeValve,
  closeFan,
  closeNone,
}

extension ACStopActionExtension on ACStopAction {
  String get displayName {
    switch (this) {
      case ACStopAction.closeAll:
        return '关闭风机与水阀';
      case ACStopAction.closeValve:
        return '仅关闭水阀';
      case ACStopAction.closeFan:
        return '仅关闭风机';
      case ACStopAction.closeNone:
        return '都不关';
    }
  }
}

// 模式: 通风. 风速: 自动时的风速
enum ACAutoVentSpeed { low, mid, high }

// 空调类型, 盘管和红外
enum ACType {
  single,
  infrared,
  double,
}

extension ACAutoVentSpeedExtension on ACAutoVentSpeed {
  String get displayName {
    switch (this) {
      case ACAutoVentSpeed.low:
        return '低风';
      case ACAutoVentSpeed.mid:
        return '中风';
      case ACAutoVentSpeed.high:
        return '高风';
    }
  }
}

// 单台盘管空调配置数据结构
@JsonSerializable()
class AirCon {
  int id;
  int uid; // 显然, 易证
  String name;

  @JsonKey(fromJson: _acTypeFromJson, toJson: _acTypeToJson)
  ACType type;
  int channelPowerUid;
  int channelLowUid;
  int channelMidUid;
  int channelHighUid;
  int channelWater1Uid;
  int channelWater2Uid;

  AirCon({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.channelPowerUid,
    required this.channelLowUid,
    required this.channelMidUid,
    required this.channelHighUid,
    required this.channelWater1Uid,
    required this.channelWater2Uid,
  });

  static List<String> get operations {
    return ["开", "关"];
  }

  // AirCon的正反序列化
  factory AirCon.fromJson(Map<String, dynamic> json) => _$AirConFromJson(json);
  Map<String, dynamic> toJson() => _$AirConToJson(this);

  // ACType的正反序列化
  static ACType _acTypeFromJson(int index) => ACType.values[index];
  static int _acTypeToJson(ACType type) => type.index;
}

// 空调总配置管理类
class AirConNotifier extends ChangeNotifier {
  // 默认模式
  ACMode _defaultMode = ACMode.cooling;
  ACMode get defaultMode => _defaultMode;
  set defaultMode(ACMode value) {
    _defaultMode = value;
    notifyListeners();
  }

  // 默认温度
  int _defaultTargetTemp = 26;
  int get defaultTargetTemp => _defaultTargetTemp;
  set defaultTargetTemp(int value) {
    _defaultTargetTemp = value;
    notifyListeners();
  }

  // 默认风速
  ACFanSpeed _defaultFanSpeed = ACFanSpeed.low;
  ACFanSpeed get defaultFanSpeed => _defaultFanSpeed;
  set defaultFanSpeed(ACFanSpeed value) {
    _defaultFanSpeed = value;
    notifyListeners();
  }

  // 停止工作的阈值
  int _stopThreshold = 1;
  int get stopThreshold => _stopThreshold;
  set stopThreshold(int value) {
    _stopThreshold = value;
    notifyListeners();
  }

  // 重新开始工作的阈值
  int _reworkThreshold = 1;
  int get reworkThreshold => _reworkThreshold;
  set reworkThreshold(int value) {
    _reworkThreshold = value;
    notifyListeners();
  }

  // 停止工作时的动作
  ACStopAction _stopAction = ACStopAction.closeAll;
  ACStopAction get stopAction => _stopAction;
  set stopAction(ACStopAction value) {
    _stopAction = value;
    notifyListeners();
  }

  // 自动风, 进入低风所需低于等于的温差
  int _lowFanTempDiff = 2;
  int get lowFanTempDiff => _lowFanTempDiff;
  set lowFanTempDiff(int value) {
    _lowFanTempDiff = value;
    notifyListeners();
  }

  // 自动风, 进入高风所需高于等于的温差
  int _highFanTempDiff = 4;
  int get highFanTempDiff => _highFanTempDiff;
  set highFanTempDiff(int value) {
    _highFanTempDiff = value;
    notifyListeners();
  }

  // 模式: 通风. 风速: 自动时的风速
  ACAutoVentSpeed _autoVentSpeed = ACAutoVentSpeed.mid;
  ACAutoVentSpeed get autoVentSpeed => _autoVentSpeed;
  set autoVentSpeed(ACAutoVentSpeed value) {
    _autoVentSpeed = value;
    notifyListeners();
  }

  Map<int, AirCon> _allAirCons = {};

  Map<int, AirCon> get allAirCons => _allAirCons;

  // 添加一个新空调
  void addAirCon(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
      return;
    }

    final airCon = AirCon(
      id: allAirCons.length,
      uid: UidManager().generateAirConUid(),
      name: '未命名 空调',
      type: ACType.single,
      channelPowerUid: allOutputs.keys.first,
      channelLowUid: allOutputs.keys.first,
      channelMidUid: allOutputs.keys.first,
      channelHighUid: allOutputs.keys.first,
      channelWater1Uid: allOutputs.keys.first,
      channelWater2Uid: allOutputs.keys.first,
    );

    _allAirCons[airCon.uid] = airCon;
    notifyListeners();
  }

  void removeAirCon(int key) {
    _allAirCons.remove(key);
    notifyListeners();
  }

  // 手动实现正反序列化
  Map<String, dynamic> toJson() {
    return {
      'defaultTemp': defaultTargetTemp,
      'defaultMode': defaultMode.index,
      'defaultFanSpeed': defaultFanSpeed.index,
      'stopThreshold': stopThreshold,
      'reworkThreshold': reworkThreshold,
      'stopAction': stopAction.index,
      'lowFanTempDiff': lowFanTempDiff,
      'highFanTempDiff': highFanTempDiff,
      'autoVentSpeed': autoVentSpeed.index,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _defaultTargetTemp = json['defaultTemp'] as int;
    _defaultMode = ACMode.values[json['defaultMode'] as int];
    _defaultFanSpeed = ACFanSpeed.values[json['defaultFanSpeed'] as int];
    _stopThreshold = json['stopThreshold'] as int;
    _reworkThreshold = json['reworkThreshold'] as int;
    _stopAction = ACStopAction.values[json['stopAction'] as int];
    _lowFanTempDiff = json['lowFanTempDiff'] as int;
    _highFanTempDiff = json['highFanTempDiff'] as int;
    _autoVentSpeed = ACAutoVentSpeed.values[json['autoVentSpeed'] as int];

    notifyListeners();
  }

  void deserializationUpdate(List<AirCon> newAirCons) {
    _allAirCons.clear();
    int newAirConUidMax =
        newAirCons.fold(0, (prev, airCon) => max(prev, airCon.uid));

    UidManager().setAirConUid(newAirConUidMax + 1);

    for (var airCon in newAirCons) {
      _allAirCons[airCon.uid] = airCon;
    }
    notifyListeners();
  }
}

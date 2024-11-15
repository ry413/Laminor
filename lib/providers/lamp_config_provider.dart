import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'lamp_config_provider.g.dart';

enum LampType { switchLight, dimmableLight }

extension LampTypeExtension on LampType {
  String get displayName {
    switch (this) {
      case LampType.switchLight:
        return '普通灯';
      case LampType.dimmableLight:
        return '调光灯';
    }
  }
}

@JsonSerializable()
class Lamp {
  final int uid;
  String name;

  @JsonKey(fromJson: _lampTypeFromJson, toJson: _lampTypeToJson)
  LampType type;
  int channelPowerUid;

  Lamp({
    required this.uid,
    required this.name,
    required this.type,
    required this.channelPowerUid,
  });

  List<String> get operations {
    return ['开', '关'];
  }

  // Lamp的正反序列化
  factory Lamp.fromJson(Map<String, dynamic> json) => _$LampFromJson(json);
  Map<String, dynamic> toJson() => _$LampToJson(this);

  // LampType的正反序列化
  static LampType _lampTypeFromJson(int index) => LampType.values[index];
  static int _lampTypeToJson(LampType type) => type.index;
}

class LampNotifier extends ChangeNotifier {
  List<Lamp> _allLamps = [];
  List<Lamp> get allLamp => _allLamps;

  void addLamp(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;

    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置输出')));
      return;
    }

    _allLamps.add(Lamp(
      uid: UidManager().generateLampUid(),
      name: '未命名 灯',
      type: LampType.switchLight,
      channelPowerUid: allOutputs.keys.first,
    ));
    notifyListeners();
  }

  void removeAt(int index) {
    _allLamps.removeAt(index);
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void deserializationUpdate(List<Lamp> newLamps) {
    _allLamps.clear();
    int newLampUidMax = newLamps.fold(0, (prev, lamp) => max(prev, lamp.uid));

    UidManager().setLampUid(newLampUidMax + 1);

    _allLamps.addAll(newLamps);
    notifyListeners();
  }
}

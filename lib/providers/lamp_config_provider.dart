import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

enum LampType { normalLight, dimmableLight }

extension LampTypeExtension on LampType {
  String get displayName {
    switch (this) {
      case LampType.normalLight:
        return '普通灯';
      case LampType.dimmableLight:
        return '调光灯';
    }
  }

  List<String> get operations {
    switch (this) {
      case LampType.normalLight:
        return ['打开', '关闭', '反转'];
      case LampType.dimmableLight:
        return ['调光']; // 调光灯就使用一个操作
    }
  }
}

class Lamp extends IDeviceBase {
  LampType type;
  BoardOutput output;

  Lamp({
    required super.name,
    required super.uid,
    required this.type,
    required this.output,
  });

  @override
  List<String> get operations {
    if (type == LampType.normalLight) {
      return ['打开', '关闭', '反转'];
    } else {
      return ['调光'];
    }
  }

  // Lamp的正反序列化
  factory Lamp.fromJson(Map<String, dynamic> json) {
    return Lamp(
      name: json['name'] as String,
      uid: (json['uid'] as num).toInt(),
      type: LampType.values[json['type'] as int],
      output: BoardManager().getOutputByUid(json['outputUid'] as int),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': type.index,
      'outputUid': output.uid,
    };
  }
}

class LampNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<Lamp> get allLamps => DeviceManager().getDevices<Lamp>().toList();

  void addLamp(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
      return;
    }

    final lamp = Lamp(
      uid: UidManager().generateDeviceUid(),
      name: '未命名 灯',
      type: LampType.normalLight,
      output: allOutputs.values.first,
    );

    DeviceManager().addDevice(lamp);
    notifyListeners();
  }
}

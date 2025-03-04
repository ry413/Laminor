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
}

class Lamp extends IDeviceBase {
  LampType type;
  BoardOutput _output;

  Lamp(
      {required this.type,
      required BoardOutput output,
      required super.name,
      required super.uid,
      super.causeState,
      super.linkDeviceUids,
      super.repelDeviceUids})
      : _output = output {
    _output.addUsage();
  }

  BoardOutput get output => _output;
  set output(BoardOutput newOutput) {
    _output.removeUsage();
    _output = newOutput;
    _output.addUsage();
  }

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
      name: json['nm'] as String,
      uid: (json['uid'] as num).toInt(),
      type: LampType.values[json['tp'] as int],
      output: BoardManager().getOutputByUid(json['oUid'] as int),
      causeState: json['cauSt'] as String? ?? '',
      linkDeviceUids: (json['linkDUids'] as List<dynamic>?)
              ?.map((item) => (item as num).toInt())
              .toList() ??
          [],
      repelDeviceUids: (json['repelDUids'] as List<dynamic>?)
              ?.map((item) => (item as num).toInt())
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tp': type.index,
      'oUid': _output.uid,
    };
  }
}

class LampNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<Lamp> get allLamps => DeviceManager().getDevices<Lamp>().toList();

  void addLamp(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
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

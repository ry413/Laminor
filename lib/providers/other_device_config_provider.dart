import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';

enum OtherDeviceType { outputControl, heartbeatState }

extension OtherDeviceTypeExtension on OtherDeviceType {
  String get displayName {
    switch (this) {
      case OtherDeviceType.outputControl:
        return '输出通道控制';
      case OtherDeviceType.heartbeatState:
        return '心跳状态';
    }
  }
}

class OtherDevice extends IDeviceBase {
  OtherDeviceType type;
  BoardOutput? output;

  OtherDevice({
    required super.name,
    required super.uid,
    required this.type,
  });

  @override
  List<String> get operations {
    if (type == OtherDeviceType.outputControl) {
      return ['打开', '关闭', '反转'];
    } else {
      return ['睡眠'];
    }
  }

  factory OtherDevice.fromJson(Map<String, dynamic> json) {
    final device = OtherDevice(
      name: json['name'] as String,
      uid: (json['uid'] as num).toInt(),
      type: OtherDeviceType.values[json['type'] as int],
    );

    if (json.containsKey('outputUid') && json['outputUid'] != null) {
      device.output = BoardManager().getOutputByUid(json['outputUid'] as int);
    }

    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'type': type.index,
      if (output != null) 'outputUid': output!.uid
    };
  }
}

class OtherDeviceNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<OtherDevice> get allOtherDevices =>
      DeviceManager().getDevices<OtherDevice>().toList();

  void addOtherDevice(BuildContext context) {
    // final allOutputs =
    //     Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    // if (allOutputs.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
    //   return;
    // }

    final otherDevice = OtherDevice(
        name: '其他(抽象)设备',
        uid: UidManager().generateDeviceUid(),
        type: OtherDeviceType.heartbeatState);

    DeviceManager().addDevice(otherDevice);
    notifyListeners();
  }
}

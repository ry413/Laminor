import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

// OtherDevice可以是延时者, 动作组管理者, 什么的, 动作组操作也附属给它

enum OtherDeviceType {
  outputControl,
  heartbeatState,
  delayer,
  actionGroup,
  stateSetter
}

extension OtherDeviceTypeExtension on OtherDeviceType {
  String get displayName {
    switch (this) {
      case OtherDeviceType.outputControl:
        return '输出通道控制';
      case OtherDeviceType.heartbeatState:
        return '心跳状态';
      case OtherDeviceType.delayer:
        return '延时器';
      case OtherDeviceType.actionGroup:
        return '动作组管理';
      case OtherDeviceType.stateSetter:
        return '状态更改';
    }
  }
}

class OtherDevice extends IDeviceBase {
  OtherDeviceType type;
  BoardOutput? _output;

  OtherDevice(
      {required this.type,
      BoardOutput? output,
      required super.name,
      required super.uid,
      super.causeState,
      // super.linkDeviceUids,
      super.repelDeviceUids})
      : _output = output {
    if (_output != null) {
      _output!.addUsage();
    }
  }

  BoardOutput get output {
    if (_output == null) {
      _output = BoardManager().allOutputs.values.first;
      return _output!;
    } else {
      return _output!;
    }
  }

  set output(BoardOutput newOutput) {
    if (_output != null) {
      _output!.removeUsage();
    }
    _output = newOutput;
    _output!.addUsage();
  }

  void clearOutput() {
    _output = null;
  }

  @override
  List<String> get operations {
    if (type == OtherDeviceType.outputControl) {
      return ['打开', '关闭', '反转'];
    } else if (type == OtherDeviceType.heartbeatState) {
      return ['存活', '睡眠', '死亡'];
    } else if (type == OtherDeviceType.delayer) {
      return ['延时'];
    } else if (type == OtherDeviceType.actionGroup) {
      return ['销毁'];
    } else if (type == OtherDeviceType.stateSetter) {
      return ['添加状态', '清除状态', '反转状态'];
    } else {
      return [];
    }
  }

  factory OtherDevice.fromJson(Map<String, dynamic> json) {
    final device = OtherDevice(
      name: json['nm'] as String,
      uid: (json['uid'] as num).toInt(),
      type: OtherDeviceType.values[json['tp'] as int],
      causeState: json['cauSt'] as String? ?? '',
      // linkDeviceUids: (json['linkDUids'] as List<dynamic>?)
      //         ?.map((item) => (item as num).toInt())
      //         .toList() ??
      //     [],
      repelDeviceUids: (json['repelDUids'] as List<dynamic>?)
              ?.map((item) => (item as num).toInt())
              .toList() ??
          [],
    );

    if (json.containsKey('oUid') && json['oUid'] != null) {
      device.output = BoardManager().getOutputByUid(json['oUid'] as int);
    }

    return device;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'tp': type.index,
      if (_output != null) 'oUid': _output!.uid
    };
  }
}

class OtherDeviceNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<OtherDevice> get allOtherDevices =>
      DeviceManager().getDevices<OtherDevice>().toList();

  void addOtherDevice(BuildContext context) {
    var type = OtherDeviceType.outputControl;
    if (Provider.of<BoardConfigNotifier>(context, listen: false)
        .allOutputs
        .isEmpty) {
      type = OtherDeviceType.heartbeatState;
    }

    final otherDevice = OtherDevice(
        name: '其他(抽象)设备', uid: UidManager().generateDeviceUid(), type: type);

    DeviceManager().addDevice(otherDevice);
    notifyListeners();
  }
}

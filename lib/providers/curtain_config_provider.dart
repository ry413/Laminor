import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

class Curtain extends IDeviceBase {
  BoardOutput _outputOpen;
  BoardOutput _outputClose;
  int runDuration;

  Curtain({
    required super.name,
    required super.uid,
    required BoardOutput outputOpen,
    required BoardOutput outputClose,
    required this.runDuration,
  })  : _outputOpen = outputOpen,
        _outputClose = outputClose {
    _outputOpen.addUsage();
    _outputClose.addUsage();
  }

  BoardOutput get outputOpen => _outputOpen;
  set outputOpen(BoardOutput newOutput) {
    _outputOpen.removeUsage();
    _outputOpen = newOutput;
    _outputOpen.addUsage();
  }
  BoardOutput get outputClose => _outputClose;
  set outputClose(BoardOutput newOutput) {
    _outputClose.removeUsage();
    _outputClose = newOutput;
    _outputClose.addUsage();
  }

  @override
  List<String> get operations => ["打开", "关闭", "反转"];

  factory Curtain.fromJson(Map<String, dynamic> json) {
    return Curtain(
      name: json['nm'] as String,
      uid: (json['uid'] as num).toInt(),
      outputOpen: BoardManager().getOutputByUid(json['oOUid'] as int),
      outputClose: BoardManager().getOutputByUid(json['oCUid'] as int),
      runDuration: json['runDur'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'oOUid': outputOpen.uid,
      'oCUid': outputClose.uid,
      'runDur': runDuration,
    };
  }
}

class CurtainNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<Curtain> get allCurtains =>
      DeviceManager().getDevices<Curtain>().toList();

  void addCurtain(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
      return;
    }

    final curtain = Curtain(
      uid: UidManager().generateDeviceUid(),
      name: '未命名 窗帘',
      outputOpen: allOutputs.values.first,
      outputClose: allOutputs.values.first,
      runDuration: 20,
    );

    DeviceManager().addDevice(curtain);
    notifyListeners();
  }
}

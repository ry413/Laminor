import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

class Curtain extends IDeviceBase {
  BoardOutput outputOpen;
  BoardOutput outputClose;
  int runDuration;

  Curtain({
    required super.name,
    required super.uid,
    required this.outputOpen,
    required this.outputClose,
    required this.runDuration,
  });

  @override
  List<String> get operations => ["打开", "关闭", "反转"];

  factory Curtain.fromJson(Map<String, dynamic> json) {
    return Curtain(
      name: json['name'] as String,
      uid: (json['uid'] as num).toInt(),
      outputOpen: BoardManager().getOutputByUid(json['outputOpenUid'] as int),
      outputClose: BoardManager().getOutputByUid(json['outputCloseUid'] as int),
      runDuration: json['runDuration'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'outputOpenUid': outputOpen.uid,
      'outputCloseUid': outputClose.uid,
      'runDuration': runDuration,
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
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

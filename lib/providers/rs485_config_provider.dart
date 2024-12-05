import 'package:flutter/foundation.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';

class RS485Command extends IDeviceBase {
  String code;

  RS485Command({required super.uid, required super.name, required this.code});

  @override
  List<String> get operations => ['发送'];

  factory RS485Command.fromJson(Map<String, dynamic> json) {
    return RS485Command(
      uid: (json['uid'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'code': code,
    };
  }
}

class RS485ConfigNotifier extends ChangeNotifier with DeviceNotifierMixin {
  List<RS485Command> get allCommands =>
      DeviceManager().getDevices<RS485Command>().toList();

  void addCommand() {
    final command = RS485Command(
        uid: UidManager().generateDeviceUid(), name: '未命名 指令码', code: '');

    DeviceManager().addDevice(command);
    notifyListeners();
  }

}

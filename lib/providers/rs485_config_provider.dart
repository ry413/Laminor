import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rs485_config_provider.g.dart';

@JsonSerializable()
class RS485Command {
  int uid;
  String name;
  String code;

  RS485Command({required this.uid, required this.name, required this.code});

  // RS485Command的正反序列化
  factory RS485Command.fromJson(Map<String, dynamic> json) =>
  _$RS485CommandFromJson(json);
  Map<String, dynamic> toJson() => _$RS485CommandToJson(this);
}

class RS485ConfigNotifier extends ChangeNotifier {
  Map<int, RS485Command> _allCommands = {};
  Map<int, RS485Command> get allCommands => _allCommands;

  void updateWidget() {
    notifyListeners();
  }

  void removeRS485Command(int key) {
    _allCommands.remove(key);
    notifyListeners();
  }

  void addCommand() {
    final command = RS485Command(
        uid: UidManager().generateRS485CommandUid(), name: '未命名 指令码', code: '');
    _allCommands[command.uid] = command;
    notifyListeners();
  }

  void updateRS485Map(Map<int, RS485Command> map) {
    _allCommands = map;
    notifyListeners();
  }

  void deserializationUpdate(List<RS485Command> newCommands) {
    _allCommands.clear();
    int newCommandUidMax = newCommands.fold(0, (prev, lamp) => max(prev, lamp.uid));

    UidManager().setRS485CommandUid(newCommandUidMax + 1);

    for (var command in newCommands) {
      _allCommands[command.uid] = command;
    }
    notifyListeners();
  }
}

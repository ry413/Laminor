import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';

class VoiceActionGroup extends ActionGroupBase {
  VoiceActionGroup({
    required super.uid,
    required super.atomicActions,
  });

  factory VoiceActionGroup.fromJson(Map<String, dynamic> json) {
    final actionGroup = VoiceActionGroup(
      uid: json['uid'] as int,
      atomicActions: (json['atomicActions'] as List<dynamic>)
          .map((e) => AtomicAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    UidManager().updateActionGroupUid(actionGroup.uid);

    return actionGroup;
  }
}

class VoiceCommand extends InputBase {
  String name;
  String code;

  int currentActionGroupIndex;

  VoiceCommand(
      {required this.name,
      required this.code,
      required super.actionGroups,
      this.currentActionGroupIndex = 0});

  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      name: json['nm'] as String,
      code: json['code'] as String,
      actionGroups: (json['actGps'] as List<dynamic>)
          .map((e) => VoiceActionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nm': name,
      'code': code,
      'actGps': actionGroups,
    };
  }
}

class VoiceConfigNotifier extends ChangeNotifier {
  List<VoiceCommand> _allVoiceCommands = [];
  List<VoiceCommand> get allVoiceCommands => _allVoiceCommands;

  void addCommand() {
    final command = VoiceCommand(name: '未命名 语音码', code: '', actionGroups: [
      VoiceActionGroup(
          uid: UidManager().generateActionGroupUid(), atomicActions: [])
    ]);

    _allVoiceCommands.add(command);
    notifyListeners();
  }

  void deserializationUpdate(List<VoiceCommand> newCommands) {
    _allVoiceCommands.clear();
    _allVoiceCommands.addAll(newCommands);
    notifyListeners();
  }
}

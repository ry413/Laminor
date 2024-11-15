import 'package:flutter/foundation.dart';
import 'package:flutter_web_1/uid_manager.dart';

class RS485Command {
  int uid;
  String name;
  String code;

  RS485Command({required this.uid, required this.name, required this.code});
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
}

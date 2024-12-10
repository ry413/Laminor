import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';

class BoardManager {
  static final BoardManager _instance = BoardManager._internal();
  factory BoardManager() => _instance;

  BoardManager._internal();

  final List<BoardConfig> _allBoards = [];
  List<BoardConfig> get allBoards => _allBoards;

  void addBoard(BoardConfig board) {
    _allBoards.add(board);
  }

  void removeBoardAt(int index) {
    _allBoards.removeAt(index);
  }

  void clear() {
    _allBoards.clear();
  }

  BoardOutput getOutputByUid(int uid) {
    return allOutputs[uid]!;
  }

  Map<int, BoardOutput> get allOutputs =>
      Map.fromEntries(_allBoards.expand((board) => board.outputs.entries));

  void addOutputToBoard(int boardId) {
    final board = _allBoards.firstWhere((board) => board.id == boardId);

    final newOutput = BoardOutput(
        type: OutputType.relay,
        channel: 127,
        name: '',
        hostBoardId: boardId,
        uid: UidManager().generateOutputUid());
    board.outputs[newOutput.uid] = newOutput;
  }

  void addInputToBoard(int boardId) {
    final board = _allBoards.firstWhere((board) => board.id == boardId);

    final newInput = BoardInput(
      channel: 127,
      level: InputLevel.low,
      hostBoardId: boardId,
      actionGroups: [
        InputActionGroup(
            uid: UidManager().generateActionGroupUid(), atomicActions: [])
      ],
    );
    for (var actionGroup in newInput.actionGroups) {
      actionGroup.parent = newInput;
      ActionGroupManager().addActionGroup(actionGroup);
    }
    board.inputs.add(newInput);
  }

  List<BoardInput> get allInputs =>
      _allBoards.expand((board) => board.inputs).toList();
}

// 管理所有Device
class DeviceManager {
  static final DeviceManager _instance = DeviceManager._internal();
  factory DeviceManager() => _instance;

  DeviceManager._internal();

  final Map<int, IDeviceBase> _allDevices = {};

  // 储存所有Device
  Map<int, IDeviceBase> get allDevices => _allDevices;

  void addDevice(IDeviceBase device) {
    _allDevices[device.uid] = device;
  }

  void addDevices(List<IDeviceBase> devices) {
    for (var device in devices) {
      _allDevices[device.uid] = device;
    }
  }

  void removeDevice(int uid) {
    _allDevices.remove(uid);
  }

  void clear() {
    _allDevices.clear();
  }

  Iterable<T> getDevices<T extends IDeviceBase>() =>
      _allDevices.values.whereType<T>();
}

// 管理所有动作组
class ActionGroupManager {
  static final ActionGroupManager _instance = ActionGroupManager._internal();
  factory ActionGroupManager() => _instance;

  ActionGroupManager._internal();

  final Map<int, ActionGroupBase> _allActionGroups = {};

  Map<int, ActionGroupBase> get allActionGroups => _allActionGroups;

  void addActionGroup(ActionGroupBase actionGroup) {
    _allActionGroups[actionGroup.uid] = actionGroup;
  }

  void removeActionGroup(int uid) {
    _allActionGroups.remove(uid);
  }
}

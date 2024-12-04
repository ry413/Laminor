import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
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
    // final allActionGroups =
    //     Provider.of<ActionConfigNotifier>(context, listen: false)
    //         .allActionGroup;
    // if (allActionGroups.isEmpty) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text('请先配置动作组')));
    //   return;
    // }
    // final board = _allBoard.firstWhere((board) => board.id == boardId);
    // board.inputs.add(BoardInput(
    //     channel: 127,
    //     level: InputLevel.low,
    //     actionGroupUid: allActionGroups.values.first.uid,
    //     hostBoardId: boardId));
    // notifyListeners();
  }

  List<BoardInput> get allInputs =>
      _allBoards.expand((board) => board.inputs).toList();
}

// class LampManager {
//   static final LampManager _instance = LampManager._internal();
//   factory LampManager() => _instance;

//   LampManager._internal();

//   final Map<int, Lamp> _allLamps = {};
//   Map<int, Lamp> get allLamps => _allLamps;

//   void addLamp(Lamp lamp) {
//     _allLamps[lamp.uid] = lamp;
//   }

//   void removeLamp(int uid) {
//     _allLamps.remove(uid);
//   }

//   void clear() {
//     _allLamps.clear();
//   }

//   void updateLampMap(Map<int, Lamp> newLamps) {
//     _allLamps.clear();
//     _allLamps.addAll(newLamps);
//   }
// }

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

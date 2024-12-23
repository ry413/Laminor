import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

// 空调模式
enum ACMode {
  cooling,
  heating,
  fan,
}

extension ACModeExtension on ACMode {
  String get displayName {
    switch (this) {
      case ACMode.cooling:
        return '制冷';
      case ACMode.heating:
        return '制热';
      case ACMode.fan:
        return '通风';
    }
  }
}

// 空调风速
enum ACFanSpeed {
  low,
  mid,
  high,
  auto,
}

extension ACFanSpeedExtension on ACFanSpeed {
  String get displayName {
    switch (this) {
      case ACFanSpeed.low:
        return '低';
      case ACFanSpeed.mid:
        return '中';
      case ACFanSpeed.high:
        return '高';
      case ACFanSpeed.auto:
        return '自动';
    }
  }
}

// 空调停止动作
enum ACStopAction {
  closeAll,
  closeValve,
  closeFan,
  closeNone,
}

extension ACStopActionExtension on ACStopAction {
  String get displayName {
    switch (this) {
      case ACStopAction.closeAll:
        return '关闭风机与水阀';
      case ACStopAction.closeValve:
        return '仅关闭水阀';
      case ACStopAction.closeFan:
        return '仅关闭风机';
      case ACStopAction.closeNone:
        return '都不关';
    }
  }
}

// 模式: 通风. 风速: 自动时的风速
enum ACAutoVentSpeed { low, mid, high }

// 空调类型, 盘管和红外
enum ACType {
  single,
  infrared,
  double,
}

extension ACAutoVentSpeedExtension on ACAutoVentSpeed {
  String get displayName {
    switch (this) {
      case ACAutoVentSpeed.low:
        return '低风';
      case ACAutoVentSpeed.mid:
        return '中风';
      case ACAutoVentSpeed.high:
        return '高风';
    }
  }
}

// 红外码库
enum CodeBases { gree }

extension CodebasesExtension on CodeBases {
  String get displayName {
    switch (this) {
      case CodeBases.gree:
        return '格力';
    }
  }
}

// 单台盘管空调配置数据结构, 根据type来决定哪些属性有效
class AirCon extends IDeviceBase {
  int id;
  ACType _type;

  BoardOutput? _lowOutput;
  BoardOutput? _midOutput;
  BoardOutput? _highOutput;
  BoardOutput? _water1Output;

  CodeBases? codeBases;

  AirCon({
    required this.id,
    required ACType type,
    required super.name,
    required super.uid,
  }) : _type = type;

  ACType get type => _type;
  set type(ACType newType) {
    if (newType == _type) return;
    if (newType == ACType.single) {
      
    } else if (newType == ACType.infrared) {
      codeBases = CodeBases.values.first;
    }

    _type = newType;
  }

  BoardOutput? get lowOutput => _lowOutput;
  BoardOutput? get midOutput => _midOutput;
  BoardOutput? get highOutput => _highOutput;
  BoardOutput? get water1Output => _water1Output;

  set lowOutput(BoardOutput? newOutput) {
    _lowOutput?.removeUsage();
    _lowOutput = newOutput;
    _lowOutput!.addUsage();
  }

  set midOutput(BoardOutput? newOutput) {
    _midOutput?.removeUsage();
    _midOutput = newOutput;
    _midOutput!.addUsage();
  }

  set highOutput(BoardOutput? newOutput) {
    _highOutput?.removeUsage();
    _highOutput = newOutput;
    _highOutput!.addUsage();
  }

  set water1Output(BoardOutput? newOutput) {
    _water1Output?.removeUsage();
    _water1Output = newOutput;
    _water1Output!.addUsage();
  }

  @override
  List<String> get operations {
    return [
      '打开',
      '关闭',
      '制冷',
      '制热',
      '低风',
      '中风',
      '高风',
      '风量加大',
      '风量减小',
      '温度升高',
      '温度降低',
      '调节温度'
    ];
  }

  // AirCon的正反序列化
  factory AirCon.fromJson(Map<String, dynamic> json) {
    final airCon = AirCon(
        id: (json['id'] as num).toInt(),
        type: ACType.values[json['type'] as int],
        name: json['name'] as String,
        uid: (json['uid'] as num).toInt());

    if (airCon.type == ACType.single) {
      airCon.lowOutput = BoardManager().getOutputByUid(json['lowUid'] as int);
      airCon.midOutput = BoardManager().getOutputByUid(json['midUid'] as int);
      airCon.highOutput = BoardManager().getOutputByUid(json['highUid'] as int);
      airCon.water1Output =
          BoardManager().getOutputByUid(json['water1Uid'] as int);
    } else if (airCon.type == ACType.infrared) {
      airCon.codeBases = CodeBases.values[json['codeBases'] as int];
    }

    return airCon;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = {
      ...super.toJson(),
      'id': id,
      'type': type.index,
    };

    if (type == ACType.single) {
      json.addAll({
        'lowUid': _lowOutput!.uid,
        'midUid': _midOutput!.uid,
        'highUid': _highOutput!.uid,
        'water1Uid': _water1Output!.uid,
      });
    } else if (type == ACType.infrared) {
      json.addAll({
        'codeBase': codeBases!.name,
      });
    }

    return json;
  }
}

// 空调总配置管理类
class AirConNotifier extends ChangeNotifier with DeviceNotifierMixin {
  // 默认模式
  ACMode _defaultMode = ACMode.cooling;
  ACMode get defaultMode => _defaultMode;
  set defaultMode(ACMode value) {
    _defaultMode = value;
    notifyListeners();
  }

  // 默认温度
  int _defaultTargetTemp = 26;
  int get defaultTargetTemp => _defaultTargetTemp;
  set defaultTargetTemp(int value) {
    _defaultTargetTemp = value;
    notifyListeners();
  }

  // 默认风速
  ACFanSpeed _defaultFanSpeed = ACFanSpeed.low;
  ACFanSpeed get defaultFanSpeed => _defaultFanSpeed;
  set defaultFanSpeed(ACFanSpeed value) {
    _defaultFanSpeed = value;
    notifyListeners();
  }

  // 停止工作的阈值
  int _stopThreshold = 1;
  int get stopThreshold => _stopThreshold;
  set stopThreshold(int value) {
    _stopThreshold = value;
    notifyListeners();
  }

  // 重新开始工作的阈值
  int _reworkThreshold = 1;
  int get reworkThreshold => _reworkThreshold;
  set reworkThreshold(int value) {
    _reworkThreshold = value;
    notifyListeners();
  }

  // 停止工作时的动作
  ACStopAction _stopAction = ACStopAction.closeAll;
  ACStopAction get stopAction => _stopAction;
  set stopAction(ACStopAction value) {
    _stopAction = value;
    notifyListeners();
  }

  // 自动风, 进入低风所需低于等于的温差
  int _lowFanTempDiff = 2;
  int get lowFanTempDiff => _lowFanTempDiff;
  set lowFanTempDiff(int value) {
    _lowFanTempDiff = value;
    notifyListeners();
  }

  // 自动风, 进入高风所需高于等于的温差
  int _highFanTempDiff = 4;
  int get highFanTempDiff => _highFanTempDiff;
  set highFanTempDiff(int value) {
    _highFanTempDiff = value;
    notifyListeners();
  }

  // 模式: 通风. 风速: 自动时的风速
  ACAutoVentSpeed _autoVentSpeed = ACAutoVentSpeed.mid;
  ACAutoVentSpeed get autoVentSpeed => _autoVentSpeed;
  set autoVentSpeed(ACAutoVentSpeed value) {
    _autoVentSpeed = value;
    notifyListeners();
  }

  List<AirCon> get allAirCons => DeviceManager().getDevices<AirCon>().toList();

  // 添加一个新空调
  void addAirCon(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先配置输出'), duration: Duration(seconds: 1)));
      return;
    }

    final airCon = AirCon(
      id: DeviceManager().getDevices<AirCon>().length,
      uid: UidManager().generateDeviceUid(),
      name: '未命名 空调',
      type: ACType.single,
    );
    airCon.lowOutput = allOutputs.values.first;
    airCon.midOutput = allOutputs.values.first;
    airCon.highOutput = allOutputs.values.first;
    airCon.water1Output = allOutputs.values.first;

    DeviceManager().addDevice(airCon);
    notifyListeners();
  }

  // 手动实现正反序列化
  Map<String, dynamic> toJson() {
    return {
      'defaultTemp': defaultTargetTemp,
      'defaultMode': defaultMode.index,
      'defaultFanSpeed': defaultFanSpeed.index,
      'stopThreshold': stopThreshold,
      'reworkThreshold': reworkThreshold,
      'stopAction': stopAction.index,
      'lowFanTempDiff': lowFanTempDiff,
      'highFanTempDiff': highFanTempDiff,
      'autoVentSpeed': autoVentSpeed.index,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _defaultTargetTemp = json['defaultTemp'] as int;
    _defaultMode = ACMode.values[json['defaultMode'] as int];
    _defaultFanSpeed = ACFanSpeed.values[json['defaultFanSpeed'] as int];
    _stopThreshold = json['stopThreshold'] as int;
    _reworkThreshold = json['reworkThreshold'] as int;
    _stopAction = ACStopAction.values[json['stopAction'] as int];
    _lowFanTempDiff = json['lowFanTempDiff'] as int;
    _highFanTempDiff = json['highFanTempDiff'] as int;
    _autoVentSpeed = ACAutoVentSpeed.values[json['autoVentSpeed'] as int];

    notifyListeners();
  }
}

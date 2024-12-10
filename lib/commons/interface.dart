import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';

part 'interface.g.dart';

// 最原子级的操作, 天了
// 把它叫作Action, 就是说一个Action里含有的, 是target和operation

@JsonSerializable()
class AtomicAction {
  int deviceUid; // 此操作的目标设备的uid
  String operation; // 操作, 所属于目标设备的operations之中
  int parameter;

  // 普通构造函数，使用外部参数
  AtomicAction({
    required this.deviceUid,
    required this.operation,
    required this.parameter,
  }) {
    DeviceManager().allDevices[deviceUid]!.addUsage();
  }

  // 默认构造函数，使用默认值
  AtomicAction.defaultAction()
      : deviceUid = DeviceManager().allDevices.values.first.uid,
        operation = DeviceManager().allDevices.values.first.operations.first,
        parameter = 0 {
    // 既然默认用第一个设备, 也要增加它的引用计数
    DeviceManager().allDevices.values.first.addUsage();
  }

  factory AtomicAction.fromJson(Map<String, dynamic> json) =>
      _$AtomicActionFromJson(json);
  Map<String, dynamic> toJson() => _$AtomicActionToJson(this);
}

// 继承于IDeviceAction的类, 如灯, 窗帘什么的, 会被面板控制的设备
// 表示这些设备关联于哪个面板的哪个按钮
class AssociatedButton {
  int panelId;
  int buttonId;

  AssociatedButton({required this.panelId, required this.buttonId});
}

// 有操作的设备的基类
abstract class IDeviceBase with UsageCountMixin {
  String name;
  final int uid;
  List<AssociatedButton>
      _associatedButtons; // 这个属性在常时是不应该被使用的, 仅仅在最终的toJson时才能用它

  IDeviceBase({
    required this.uid,
    required this.name,
  }) : _associatedButtons = [];

  List<String> get operations => [];

  // 只应该在最终生成json那一步被[Panel.toJson]调用
  // 也就是说必须调用这个之后, 才调用所有IDeviceBase的派生类.toJson
  // 不参与fromJson
  void clearAssociatedButtons() {
    _associatedButtons.clear();
  }

  void addAssociatedButton(AssociatedButton button) {
    _associatedButtons.add(button);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uid': uid,
      'associatedButtons': _associatedButtons
          .map((e) => {'panelId': e.panelId, 'buttonId': e.buttonId})
          .toList(),
    };
  }
}

// 独特的心跳状态
class HeartbeatState extends IDeviceBase {
  HeartbeatState({required super.name, required super.uid});

  @override
  List<String> get operations => ['睡眠'];
}

abstract class ActionGroupBase {
  final int uid;
  List<AtomicAction> atomicActions;

  InputBase? parent; // 此动作组的宿主输入

  ActionGroupBase(
      {required this.uid, required this.atomicActions, this.parent});

  void remove() {
    ActionGroupManager().removeActionGroup(uid);
  }

  // 序列化方法
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'atomicActions': atomicActions.map((e) => e.toJson()).toList(),
    };
  }

  // 反序列化方法，子类需要实现具体的逻辑
  factory ActionGroupBase.fromJson(Map<String, dynamic> json,
      ActionGroupBase Function(Map<String, dynamic>) create) {
    return create(json);
  }
}

abstract class InputBase {
  List<ActionGroupBase> actionGroups;

  InputBase({required this.actionGroups});
}

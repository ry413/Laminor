import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'panel_config_provider.g.dart';

// 按下按钮后的指示灯动作
enum ButtonPolitAction { lightOn, lightShort, lightOff, ignore }

extension ButtonPolitActionExtension on ButtonPolitAction {
  String get displayName {
    switch (this) {
      case ButtonPolitAction.lightOn:
        return '常亮';
      case ButtonPolitAction.lightShort:
        return '短亮'; // 1秒后熄灭
      case ButtonPolitAction.lightOff:
        return '熄灭';
      case ButtonPolitAction.ignore:
        return '忽略';
    }
  }
}

// 不管, 就再写一个枚举得了, 希望只会对别的按钮做这两个操作
enum ButtonOtherPolitAction { lightOff, ignore }

extension ButtonOtherPolitActionExtension on ButtonOtherPolitAction {
  String get displayName {
    switch (this) {
      case ButtonOtherPolitAction.lightOff:
        return '熄灭';
      case ButtonOtherPolitAction.ignore:
        return '忽略';
    }
  }
}

// 一个按钮的动作组类
class PanelButtonActionGroup {
  List<AtomicAction> atomicActions;
  ButtonPolitAction pressedPolitAction; // 触发此Action后, 对按钮的指示灯的行为
  ButtonOtherPolitAction pressedOtherPolitAction; // 触发此Action后, 对别的按钮指示灯的行为

  // 默认构造函数
  PanelButtonActionGroup(
      {required this.atomicActions,
      required this.pressedPolitAction,
      required this.pressedOtherPolitAction});

  PanelButtonActionGroup.defaultActionGroup()
      : atomicActions = [AtomicAction.defaultAction()],
        pressedPolitAction = ButtonPolitAction.ignore,
        pressedOtherPolitAction = ButtonOtherPolitAction.ignore;

  // 反序列化
  factory PanelButtonActionGroup.fromJson(Map<String, dynamic> json) {
    return PanelButtonActionGroup(
      atomicActions: (json['atomicActions'] as List<dynamic>)
          .map((e) => AtomicAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      pressedPolitAction:
          ButtonPolitAction.values[(json['pressedPolitAction'] as num).toInt()],
      pressedOtherPolitAction: ButtonOtherPolitAction
          .values[(json['pressedOtherPolitAction'] as num).toInt()],
    );
  }

  // 序列化
  Map<String, dynamic> toJson() {
    return {
      'atomicActions': atomicActions.map((e) => e.toJson()).toList(),
      'pressedPolitAction': pressedPolitAction.index,
      'pressedOtherPolitAction': pressedOtherPolitAction.index,
    };
  }
}

// 一个按钮可以有多个[操作], 循环行动
class PanelButton {
  int id; // 按钮的ID就允许用户随便写, 把这责任给他们
  List<PanelButtonActionGroup> panelActionGroups;

  int currentActionGroupIndex;

  int explicitAssociatedDeviceUid; // 本面板显式关联的设备UID, 会使这个按钮无论如何都会成为此设备的关联按钮

  PanelButton(
      {required this.id,
      required this.panelActionGroups,
      this.currentActionGroupIndex = 0,
      this.explicitAssociatedDeviceUid = -1});

  // PanelButton的正反序列化
  factory PanelButton.fromJson(Map<String, dynamic> json) {
    return PanelButton(
        id: (json['id'] as num).toInt(),
        panelActionGroups: (json['actionGroups'] as List<dynamic>)
            .map((e) =>
                PanelButtonActionGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
        explicitAssociatedDeviceUid:
            (json['explicitAssociatedDeviceUid'] as num?)?.toInt() ?? -1);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionGroups': panelActionGroups.map((e) => e.toJson()).toList(),
      if (explicitAssociatedDeviceUid != -1)
        'explicitAssociatedDeviceUid': explicitAssociatedDeviceUid
    };
  }
}

enum PanelType {
  fourButton,
  sixButton,
  eightButton,
}

@JsonSerializable()
class Panel {
  int id;

  @JsonKey(fromJson: _panelTypeFromJson, toJson: _panelTypeToJson)
  PanelType type;
  String name;
  List<PanelButton> buttons;

  Panel({
    required this.id,
    required this.type,
    required this.name,
    required this.buttons,
  });

  // Panel的正反序列化
  factory Panel.fromJson(Map<String, dynamic> json) => _$PanelFromJson(json);
  Map<String, dynamic> toJson() {
    // 遍历本面板的每个按钮
    for (var button in buttons) {
      if (button.panelActionGroups.isEmpty) continue;
      if (button.panelActionGroups.first.atomicActions.isEmpty) continue;

      // 固定把此按钮添加给它可能存在的显式关联的设备
      if (button.explicitAssociatedDeviceUid != -1) {
        DeviceManager()
            .allDevices[button.explicitAssociatedDeviceUid]!
            .addAssociatedButton(
                AssociatedButton(panelId: id, buttonId: button.id));
      }

      // 判断每个按钮它自己所有的Action的deviceUid是否相同(表示是否指向同一个设备)
      final firstDeviceUid =
          button.panelActionGroups.first.atomicActions.first.deviceUid;
      bool allSameDeviceUid = true;

      // 遍历每个actionGroup
      for (var actionGroup in button.panelActionGroups) {
        // 遍历每个PanelAction的AtomicAction
        for (var atomicAction in actionGroup.atomicActions) {
          // 如果这个AtomicAction是延时, 就不用担心, 跳过它. 这个按钮仍然有可能是关联按钮
          if (atomicAction.operation == '延时') {
            continue;
          }
          if (firstDeviceUid != atomicAction.deviceUid) {
            allSameDeviceUid = false;
            break;
          }
        }
        if (!allSameDeviceUid) break;
      }

      // 如果这个按钮的所有操作都控制同一个设备的话, 就说明这个按钮是那个设备的关联按钮, 添加它
      if (allSameDeviceUid) {
        DeviceManager()
            .allDevices[
                button.panelActionGroups.first.atomicActions.first.deviceUid]!
            .addAssociatedButton(
                AssociatedButton(panelId: id, buttonId: button.id));

        // 如果按钮上有
      }
    }
    // 上面只是把数据准备好, 不在这里操作, 而是等各个设备自己的toJson
    return _$PanelToJson(this);
  }

  // PanelType的正反序列化
  static PanelType _panelTypeFromJson(int index) => PanelType.values[index];
  static int _panelTypeToJson(PanelType type) => type.index;
}

class PanelConfigNotifier extends ChangeNotifier {
  List<Panel> _allPanels = [];
  List<Panel> get allPanel => _allPanels;

  void addPanel(BuildContext context, PanelType type) {
    if (DeviceManager().allDevices.values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请先添加设备'), duration: Duration(seconds: 1)));
      return;
    }
    int buttonCount = 0;
    switch (type) {
      case PanelType.fourButton:
        buttonCount = 4;
        break;
      case PanelType.sixButton:
        buttonCount = 6;
        break;
      case PanelType.eightButton:
        buttonCount = 8;
        break;
    }
    _allPanels
        .add(Panel(id: _allPanels.length, type: type, name: '未命名 面板', buttons: [
      for (int i = 0; i < buttonCount; i++) ...[
        PanelButton(
            id: i,
            panelActionGroups: [PanelButtonActionGroup.defaultActionGroup()]),
      ]
    ]));
    notifyListeners();
  }

  void removeAt(int index) {
    _allPanels.removeAt(index);
    notifyListeners();
  }

  void deserializationUpdate(List<Panel> newPanels) {
    _allPanels.clear();
    _allPanels.addAll(newPanels);
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }
}

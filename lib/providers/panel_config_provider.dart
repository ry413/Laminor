import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'panel_config_provider.g.dart';

// 按下按钮后的指示灯动作
enum ButtonPolitAction { lightOn, lightShort, lightOff, ingore }

extension ButtonPolitActionExtension on ButtonPolitAction {
  String get displayName {
    switch (this) {
      case ButtonPolitAction.lightOn:
        return '常亮';
      case ButtonPolitAction.lightShort:
        return '短亮';    // 1秒后熄灭
      case ButtonPolitAction.lightOff:
        return '熄灭';
      case ButtonPolitAction.ingore:
        return '忽略';
    }
  }
}

// 不管, 就再写一个枚举得了, 希望只会对别的按钮做这两个操作
enum ButtonOtherPolitAction { lightOff, ingore }

extension ButtonOtherPolitActionExtension on ButtonOtherPolitAction {
  String get displayName {
    switch (this) {
      case ButtonOtherPolitAction.lightOff:
        return '熄灭';
      case ButtonOtherPolitAction.ingore:
        return '忽略';
    }
  }
}

@JsonSerializable()
class PanelButton {
  int id; // 按钮的ID就允许用户随便写, 把这责任给他们
  List<int> actionGroupUids;
  
  @JsonKey(fromJson: _buttonPolitActionListFromIndex, toJson: _buttonPolitActionListToIndex)
  List<ButtonPolitAction> pressedPolitActions;      // 按下本按钮后对本按钮的指示灯的操作

  @JsonKey(fromJson: _buttonOtherPolitActionListFromIndex, toJson: _buttonOtherPolitActionListToIndex)
  List<ButtonOtherPolitAction> pressedOtherPolitActions; // 同时对所有其他按钮的指示灯的操作

  PanelButton(
      {required this.id,
      required this.actionGroupUids,
      required this.pressedPolitActions,
      required this.pressedOtherPolitActions});

  // PanelButton的正反序列化
  factory PanelButton.fromJson(Map<String, dynamic> json) =>
      _$PanelButtonFromJson(json);
  Map<String, dynamic> toJson() => _$PanelButtonToJson(this);


  static List<ButtonPolitAction> _buttonPolitActionListFromIndex(List<dynamic> indexs) {
    return indexs.map((index) => ButtonPolitAction.values[index as int]).toList();
  }
  static List<int> _buttonPolitActionListToIndex(List<ButtonPolitAction> actions) {
    return actions.map((action) => action.index).toList();
  }

  static List<ButtonOtherPolitAction> _buttonOtherPolitActionListFromIndex(List<dynamic> indexs) {
    return indexs.map((index) => ButtonOtherPolitAction.values[index as int]).toList();
  }
  static List<int> _buttonOtherPolitActionListToIndex(List<ButtonOtherPolitAction> actions) {
    return actions.map((action) => action.index).toList();
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
  Map<String, dynamic> toJson() => _$PanelToJson(this);

  // PanelType的正反序列化
  static PanelType _panelTypeFromJson(int index) => PanelType.values[index];
  static int _panelTypeToJson(PanelType type) => type.index;
}

class PanelConfigNotifier extends ChangeNotifier {
  List<Panel> _allPanels = [];
  List<Panel> get allPanel => _allPanels;

  void addPanel(BuildContext context, PanelType type) {
    final allActionGroup =
        Provider.of<ActionConfigNotifier>(context, listen: false)
            .allActionGroup;
    if (allActionGroup.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置动作组')));
      return;
    }

    switch (type) {
      case PanelType.fourButton:
        _allPanels.add(Panel(
            id: _allPanels.length,
            type: type,
            name: '未命名 四键面板',
            buttons: [
              for (int i = 0; i < 4; i++) ...[
                PanelButton(
                    id: i,
                    actionGroupUids: [allActionGroup.keys.first],
                    pressedPolitActions: [ButtonPolitAction.lightOn],
                    pressedOtherPolitActions: [ButtonOtherPolitAction.ingore]),
              ]
            ]));
        break;
      case PanelType.sixButton:
        _allPanels.add(Panel(
            id: _allPanels.length,
            type: type,
            name: '未命名 六键面板',
            buttons: [
              for (int i = 0; i < 6; i++) ...[
                PanelButton(
                    id: i,
                    actionGroupUids: [allActionGroup.keys.first],
                    pressedPolitActions: [ButtonPolitAction.lightOn],
                    pressedOtherPolitActions: [ButtonOtherPolitAction.ingore]),
              ]
            ]));
        break;
      case PanelType.eightButton:
        _allPanels.add(Panel(
            id: _allPanels.length,
            type: type,
            name: '未命名 八键面板',
            buttons: [
              for (int i = 0; i < 8; i++) ...[
                PanelButton(
                    id: i,
                    actionGroupUids: [allActionGroup.keys.first],
                    pressedPolitActions: [ButtonPolitAction.lightOn],
                    pressedOtherPolitActions: [ButtonOtherPolitAction.ingore]),
              ]
            ]));
        break;
    }
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
}

import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'panel_config_provider.g.dart';

@JsonSerializable()
class PanelButton {
  int id; // 按钮的ID就允许用户随便写, 把这责任给他们
  int actionGroupUid;

  PanelButton({
    required this.id,
    required this.actionGroupUid,
  });

  // PanelButton的正反序列化
  factory PanelButton.fromJson(Map<String, dynamic> json) =>
      _$PanelButtonFromJson(json);
  Map<String, dynamic> toJson() => _$PanelButtonToJson(this);
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
  factory Panel.fromJson(Map<String, dynamic> json) =>
    _$PanelFromJson(json);
  Map<String, dynamic> toJson() => _$PanelToJson(this);
  
  // PanelType的正反序列化
  static PanelType _panelTypeFromJson(int index) => PanelType.values[index];
  static int _panelTypeToJson(PanelType type) => type.index;
}

class PanelConfigNotifier extends ChangeNotifier {
  List<Panel> _allPanels = [];
  List<Panel> get allPanel => _allPanels;

  void addPanel(BuildContext context, PanelType type) {
    final allActionGroup = Provider.of<ActionConfigNotifier>(context, listen: false).allActionGroup;
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
            PanelButton(id: 0, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 1, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 2, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 3, actionGroupUid: allActionGroup.keys.first),
          ]
        ));
        break;
      case PanelType.sixButton:
        _allPanels.add(Panel(
          id: _allPanels.length,
          type: type,
          name: '未命名 六键面板',
          buttons: [
            PanelButton(id: 0, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 1, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 2, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 3, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 4, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 5, actionGroupUid: allActionGroup.keys.first),
          ]
        ));
        break;
      case PanelType.eightButton:
        _allPanels.add(Panel(
          id: _allPanels.length,
          type: type,
          name: '未命名 八键面板',
          buttons: [
            PanelButton(id: 0, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 1, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 2, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 3, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 4, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 5, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 6, actionGroupUid: allActionGroup.keys.first),
            PanelButton(id: 7, actionGroupUid: allActionGroup.keys.first),
          ]
        ));
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
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanelButton _$PanelButtonFromJson(Map<String, dynamic> json) => PanelButton(
      id: (json['id'] as num).toInt(),
      actionGroupUids: (json['actionGroupUids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      pressedPolitActions: PanelButton._buttonPolitActionListFromIndex(
          json['pressedPolitActions'] as List),
      pressedOtherPolitActions:
          PanelButton._buttonOtherPolitActionListFromIndex(
              json['pressedOtherPolitActions'] as List),
    );

Map<String, dynamic> _$PanelButtonToJson(PanelButton instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionGroupUids': instance.actionGroupUids,
      'pressedPolitActions': PanelButton._buttonPolitActionListToIndex(
          instance.pressedPolitActions),
      'pressedOtherPolitActions':
          PanelButton._buttonOtherPolitActionListToIndex(
              instance.pressedOtherPolitActions),
    };

Panel _$PanelFromJson(Map<String, dynamic> json) => Panel(
      id: (json['id'] as num).toInt(),
      type: Panel._panelTypeFromJson((json['type'] as num).toInt()),
      name: json['name'] as String,
      buttons: (json['buttons'] as List<dynamic>)
          .map((e) => PanelButton.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PanelToJson(Panel instance) => <String, dynamic>{
      'id': instance.id,
      'type': Panel._panelTypeToJson(instance.type),
      'name': instance.name,
      'buttons': instance.buttons,
    };

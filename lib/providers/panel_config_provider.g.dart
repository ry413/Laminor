// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanelButton _$PanelButtonFromJson(Map<String, dynamic> json) => PanelButton(
      id: (json['id'] as num).toInt(),
      actionGroupUid: (json['actionGroupUid'] as num).toInt(),
    );

Map<String, dynamic> _$PanelButtonToJson(PanelButton instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionGroupUid': instance.actionGroupUid,
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

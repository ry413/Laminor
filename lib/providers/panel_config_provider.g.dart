// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtomicAction _$AtomicActionFromJson(Map<String, dynamic> json) => AtomicAction(
      deviceUid: (json['deviceUid'] as num).toInt(),
      operation: json['operation'] as String,
      parameter: json['parameter'],
    );

Map<String, dynamic> _$AtomicActionToJson(AtomicAction instance) =>
    <String, dynamic>{
      'deviceUid': instance.deviceUid,
      'operation': instance.operation,
      'parameter': instance.parameter,
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

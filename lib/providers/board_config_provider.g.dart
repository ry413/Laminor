// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardOutput _$BoardOutputFromJson(Map<String, dynamic> json) => BoardOutput(
      type: BoardOutput._outputTypeFromJson((json['type'] as num).toInt()),
      channel: (json['channel'] as num).toInt(),
      name: json['name'] as String,
      hostBoardId: (json['hostBoardId'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
    );

Map<String, dynamic> _$BoardOutputToJson(BoardOutput instance) =>
    <String, dynamic>{
      'hostBoardId': instance.hostBoardId,
      'type': BoardOutput._outputTypeToJson(instance.type),
      'channel': instance.channel,
      'name': instance.name,
      'uid': instance.uid,
    };

BoardInput _$BoardInputFromJson(Map<String, dynamic> json) => BoardInput(
      channel: (json['channel'] as num).toInt(),
      level: BoardInput._inputLevelFromJson((json['level'] as num).toInt()),
      hostBoardId: (json['hostBoardId'] as num).toInt(),
      actionGroups: (json['actionGroups'] as List<dynamic>)
          .map((e) => InputActionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BoardInputToJson(BoardInput instance) =>
    <String, dynamic>{
      'hostBoardId': instance.hostBoardId,
      'channel': instance.channel,
      'level': BoardInput._inputLevelToJson(instance.level),
      'actionGroups': instance.actionGroups,
    };

BoardConfig _$BoardConfigFromJson(Map<String, dynamic> json) => BoardConfig(
      id: (json['id'] as num).toInt(),
    )..outputs = BoardConfig._outputsFromJson(json['outputs'] as List);

Map<String, dynamic> _$BoardConfigToJson(BoardConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'outputs': BoardConfig._outputsToJson(instance.outputs),
      'inputs': instance.inputs,
    };

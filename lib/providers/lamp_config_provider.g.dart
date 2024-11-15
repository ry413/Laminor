// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lamp_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lamp _$LampFromJson(Map<String, dynamic> json) => Lamp(
      uid: (json['uid'] as num).toInt(),
      name: json['name'] as String,
      type: Lamp._lampTypeFromJson((json['type'] as num).toInt()),
      channelPowerUid: (json['channelPowerUid'] as num).toInt(),
    );

Map<String, dynamic> _$LampToJson(Lamp instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'type': Lamp._lampTypeToJson(instance.type),
      'channelPowerUid': instance.channelPowerUid,
    };

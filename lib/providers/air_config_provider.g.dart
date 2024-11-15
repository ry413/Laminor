// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirCon _$AirConFromJson(Map<String, dynamic> json) => AirCon(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: AirCon._acTypeFromJson((json['type'] as num).toInt()),
      channelPowerUid: (json['channelPowerUid'] as num).toInt(),
      channelLowUid: (json['channelLowUid'] as num).toInt(),
      channelMidUid: (json['channelMidUid'] as num).toInt(),
      channelHighUid: (json['channelHighUid'] as num).toInt(),
      channelWater1Uid: (json['channelWater1Uid'] as num).toInt(),
      channelWater2Uid: (json['channelWater2Uid'] as num).toInt(),
      temperatureID: (json['temperatureID'] as num).toInt(),
    );

Map<String, dynamic> _$AirConToJson(AirCon instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': AirCon._acTypeToJson(instance.type),
      'channelPowerUid': instance.channelPowerUid,
      'channelLowUid': instance.channelLowUid,
      'channelMidUid': instance.channelMidUid,
      'channelHighUid': instance.channelHighUid,
      'channelWater1Uid': instance.channelWater1Uid,
      'channelWater2Uid': instance.channelWater2Uid,
      'temperatureID': instance.temperatureID,
    };

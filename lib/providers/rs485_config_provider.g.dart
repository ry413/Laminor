// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rs485_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RS485Command _$RS485CommandFromJson(Map<String, dynamic> json) => RS485Command(
      uid: (json['uid'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$RS485CommandToJson(RS485Command instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'code': instance.code,
    };

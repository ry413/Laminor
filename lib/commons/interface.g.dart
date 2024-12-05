// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtomicAction _$AtomicActionFromJson(Map<String, dynamic> json) => AtomicAction(
      deviceUid: json['deviceUid'],
      operation: json['operation'],
      parameter: json['parameter'],
    );

Map<String, dynamic> _$AtomicActionToJson(AtomicAction instance) =>
    <String, dynamic>{
      'deviceUid': instance.deviceUid,
      'operation': instance.operation,
      'parameter': instance.parameter,
    };

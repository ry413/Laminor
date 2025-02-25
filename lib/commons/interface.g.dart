// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtomicAction _$AtomicActionFromJson(Map<String, dynamic> json) => AtomicAction(
      deviceUid: (json['deviceUid'] as num).toInt(),
      operation: json['operation'] as String,
      parameter: json['parameter'] as String,
    );

Map<String, dynamic> _$AtomicActionToJson(AtomicAction instance) =>

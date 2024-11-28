// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curtain_config_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Curtain _$CurtainFromJson(Map<String, dynamic> json) => Curtain(
      uid: (json['uid'] as num).toInt(),
      name: json['name'] as String,
      channelOpenUid: (json['channelOpenUid'] as num).toInt(),
      channelCloseUid: (json['channelCloseUid'] as num).toInt(),
      runDuration: (json['runDuration'] as num).toInt(),
    );

Map<String, dynamic> _$CurtainToJson(Curtain instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'channelOpenUid': instance.channelOpenUid,
      'channelCloseUid': instance.channelCloseUid,
      'runDuration': instance.runDuration,
    };

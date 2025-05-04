// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: (json['port'] as num).toInt(),
      isHost: json['isHost'] as bool? ?? false,
      scores: (json['scores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ipAddress': instance.ipAddress,
      'port': instance.port,
      'isHost': instance.isHost,
      'scores': instance.scores,
      'isReady': instance.isReady,
      'isConnected': instance.isConnected,
    };

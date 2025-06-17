// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      payload: json['payload'] as Map<String, dynamic>,
      senderId: json['senderId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'type': _$MessageTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'senderId': instance.senderId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.joinGame: 'joinGame',
  MessageType.leaveGame: 'leaveGame',
  MessageType.gameStarted: 'gameStarted',
  MessageType.roundStarted: 'roundStarted',
  MessageType.letterSelected: 'letterSelected',
  MessageType.submitAnswers: 'submitAnswers',
  MessageType.playerSubmitted: 'playerSubmitted',
  MessageType.roundEnded: 'roundEnded',
  MessageType.scoringResults: 'scoringResults',
  MessageType.scoreUpdate: 'scoreUpdate',
  MessageType.gameEnded: 'gameEnded',
  MessageType.finalScoreboard: 'finalScoreboard',
  MessageType.playerReady: 'playerReady',
  MessageType.gameLobbyData: 'gameLobbyData',
  MessageType.error: 'error',
  MessageType.ping: 'ping',
  MessageType.pong: 'pong',
  MessageType.hostSessionTerminated: 'hostSessionTerminated',
};

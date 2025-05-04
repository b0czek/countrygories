// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
      id: json['id'] as String,
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((e) => GameRound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      state: $enumDecodeNullable(_$GameStateEnumMap, json['state']) ??
          GameState.lobby,
      host: Player.fromJson(json['host'] as Map<String, dynamic>),
      currentLetter: json['currentLetter'] as String?,
      currentRound: (json['currentRound'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'players': instance.players,
      'categories': instance.categories,
      'settings': instance.settings,
      'rounds': instance.rounds,
      'state': _$GameStateEnumMap[instance.state]!,
      'host': instance.host,
      'currentLetter': instance.currentLetter,
      'currentRound': instance.currentRound,
    };

const _$GameStateEnumMap = {
  GameState.lobby: 'lobby',
  GameState.playing: 'playing',
  GameState.scoring: 'scoring',
  GameState.finished: 'finished',
};

_$GameRoundImpl _$$GameRoundImplFromJson(Map<String, dynamic> json) =>
    _$GameRoundImpl(
      id: json['id'] as String,
      letter: json['letter'] as String,
      roundNumber: (json['roundNumber'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      answers: (json['answers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
          ) ??
          const {},
      scores: (json['scores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Map<String, int>.from(e as Map)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$GameRoundImplToJson(_$GameRoundImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'letter': instance.letter,
      'roundNumber': instance.roundNumber,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'answers': instance.answers,
      'scores': instance.scores,
    };

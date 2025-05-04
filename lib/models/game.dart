import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/models/game_settings.dart';

part 'game.freezed.dart';
part 'game.g.dart';

enum GameState { lobby, playing, scoring, finished }

@freezed
class Game with _$Game {
  const factory Game({
    required String id,
    required List<Player> players,
    required List<String> categories,
    required GameSettings settings,
    @Default([]) List<GameRound> rounds,
    @Default(GameState.lobby) GameState state,
    required Player host,
    String? currentLetter,
    int? currentRound,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@freezed
class GameRound with _$GameRound {
  const factory GameRound({
    required String id,
    required String letter,
    required int roundNumber,
    required DateTime startTime,
    DateTime? endTime,
    @Default({})
    Map<String, Map<String, String>> answers, // playerId -> category -> answer
    @Default({})
    Map<String, Map<String, int>> scores, // playerId -> category -> points
  }) = _GameRound;

  factory GameRound.fromJson(Map<String, dynamic> json) =>
      _$GameRoundFromJson(json);
}

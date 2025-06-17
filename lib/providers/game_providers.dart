import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game.dart';
import 'package:countrygories/models/game_settings.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/services/game/letter_generator.dart';
import 'package:uuid/uuid.dart';

final gameProvider = StateNotifierProvider<GameNotifier, Game?>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<Game?> {
  GameNotifier() : super(null);

  void createGame(GameSettings settings, Player host) {
    final gameId = const Uuid().v4();

    state = Game(
      id: gameId,
      players: [host],
      categories: settings.selectedCategories,
      settings: settings,
      host: host,
    );
  }

  void joinGame(Player player) {
    if (state == null) return;

    state = state!.copyWith(players: [...state!.players, player]);
  }

  void removePlayer(String playerId) {
    if (state == null) return;

    state = state!.copyWith(
      players: state!.players.where((p) => p.id != playerId).toList(),
    );
  }

  void updatePlayerStatus(String playerId, {bool? isReady, bool? isConnected}) {
    if (state == null) return;

    state = state!.copyWith(
      players: [
        for (final player in state!.players)
          if (player.id == playerId)
            player.copyWith(
              isReady: isReady ?? player.isReady,
              isConnected: isConnected ?? player.isConnected,
            )
          else
            player,
      ],
    );
  }

  void startGame() {
    if (state == null) return;

    state = state!.copyWith(state: GameState.playing, currentRound: 1);

    startRound();
  }

  void startRound() {
    if (state == null || state!.currentRound == null) return;

    final letterGenerator = LetterGenerator(
      excludedLetters: state!.settings.excludedLetters,
    );

    final letter = letterGenerator.generateRandomLetter();
    final roundId = const Uuid().v4();

    final round = GameRound(
      id: roundId,
      letter: letter,
      roundNumber: state!.currentRound!,
      startTime: DateTime.now(),
    );

    state = state!.copyWith(
      rounds: [...state!.rounds, round],
      currentLetter: letter,
    );
  }

  void submitAnswers(String playerId, Map<String, String> answers) {
    if (state == null || state!.rounds.isEmpty) return;

    final currentRound = state!.rounds.last;
    final updatedAnswers = Map<String, Map<String, String>>.from(
      currentRound.answers,
    );

    updatedAnswers[playerId] = answers;

    state = state!.copyWith(
      rounds: [
        ...state!.rounds.sublist(0, state!.rounds.length - 1),
        currentRound.copyWith(answers: updatedAnswers),
      ],
    );
  }

  void endRound() {
    if (state == null || state!.rounds.isEmpty) return;

    final currentRound = state!.rounds.last;

    state = state!.copyWith(
      rounds: [
        ...state!.rounds.sublist(0, state!.rounds.length - 1),
        currentRound.copyWith(endTime: DateTime.now()),
      ],
      state: GameState.scoring,
    );
  }

  void setRoundScores(Map<String, Map<String, int>> scores) {
    if (state == null || state!.rounds.isEmpty) return;

    final currentRound = state!.rounds.last;

    state = state!.copyWith(
      rounds: [
        ...state!.rounds.sublist(0, state!.rounds.length - 1),
        currentRound.copyWith(scores: scores),
      ],
    );

    final updatedPlayers = <Player>[];

    for (final player in state!.players) {
      final playerScores = Map<String, int>.from(player.scores);
      final roundScore = scores[player.id];

      int totalRoundScore = 0;
      if (roundScore != null) {
        for (final score in roundScore.values) {
          totalRoundScore += score; // Include all scores (positive, negative, or zero)
        }
      }
      
      // Always record the round score, even if it's 0
      playerScores[currentRound.id] = totalRoundScore;

      updatedPlayers.add(player.copyWith(scores: playerScores));
    }

    state = state!.copyWith(players: updatedPlayers);
  }

  void nextRound() {
    if (state == null || state!.currentRound == null) return;

    final nextRound = state!.currentRound! + 1;

    if (nextRound > state!.settings.numberOfRounds) {
      // Game ended
      state = state!.copyWith(
        state: GameState.finished,
        currentRound: null,
        currentLetter: null,
      );
      return;
    }

    state = state!.copyWith(
      state: GameState.playing,
      currentRound: nextRound,
      currentLetter: null,
    );

    startRound();
  }

  void endGame() {
    state = state?.copyWith(
      state: GameState.finished,
      currentRound: null,
      currentLetter: null,
    );
  }

  void resetGame() {
    state = null;
  }

  // Add a method to update the game state with data from the server
  void updateGameState(Game game) {
    state = game;
  }

  void syncLetterFromServer(String letter) {
    if (state == null) return;
    state = state!.copyWith(currentLetter: letter);
  }

  void syncRoundFromServer(int roundNumber) {
    if (state == null) return;
    state = state!.copyWith(currentRound: roundNumber);
  }

  void syncCompleteRoundFromServer(Map<String, dynamic> roundData) {
    if (state == null) return;

    final round = GameRound.fromJson(roundData);

    // Check if this round already exists
    final existingRoundIndex = state!.rounds.indexWhere(
      (r) => r.id == round.id,
    );

    if (existingRoundIndex != -1) {
      // Update existing round
      final updatedRounds = List<GameRound>.from(state!.rounds);
      updatedRounds[existingRoundIndex] = round;
      state = state!.copyWith(rounds: updatedRounds);
    } else {
      // Add new round
      state = state!.copyWith(
        rounds: [...state!.rounds, round],
        currentLetter: round.letter,
        currentRound: round.roundNumber,
      );
    }
  }

  void syncPlayersFromServer(List<Player> updatedPlayers) {
    if (state == null) return;

    state = state!.copyWith(players: updatedPlayers);
  }
}

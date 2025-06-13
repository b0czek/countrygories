import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game_settings.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/providers/database_providers.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/game_play_screen.dart';
import 'package:countrygories/screens/results_screen.dart';
import 'package:countrygories/services/game/scoring_service.dart';
import 'package:countrygories/widgets/common/custom_button.dart';
import 'package:countrygories/widgets/scoring/responsive_scoring_table.dart';

class ScoringScreen extends ConsumerStatefulWidget {
  const ScoringScreen({super.key});

  @override
  ConsumerState<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends ConsumerState<ScoringScreen> {
  bool _isLoading = false;
  Map<String, Map<String, int>> _scores = {};
  bool _scoresCalculated = false;

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
    _calculateScores();
  }

  void _setupNetworkListeners() {
    final isHost = ref.read(isHostProvider);

    if (isHost) {
    } else {
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final clientService = ref.read(clientProvider);
        if (clientService != null) {
          clientService.onMessage.listen((message) {
            if (message.type == MessageType.scoringResults) {
              final scores = Map<String, Map<String, int>>.from(
                message.payload['scores'].map(
                  (k, v) => MapEntry(k, Map<String, int>.from(v)),
                ),
              );

              setState(() {
                _scores = scores;
                _scoresCalculated = true;
              });
            } else if (message.type == MessageType.gameEnded) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ResultsScreen()),
              );
            } else if (message.type == MessageType.roundStarted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const GamePlayScreen()),
              );
            }
          });
        }
      }
    }
  }

  Future<void> _calculateScores() async {
    if (_scoresCalculated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final game = ref.read(gameProvider);
      if (game == null || game.rounds.isEmpty) {
        throw Exception('No game or rounds available');
      }

      final currentRound = game.rounds.last;
      final databaseService = ref.read(databaseServiceProvider);

      final scoringService = ScoringService(
        databaseService: databaseService,
        mode: game.settings.scoringMode,
      );

      final scores = await scoringService.calculateRoundScores(
        allAnswers: currentRound.answers,
        letter: currentRound.letter,
      );

      setState(() {
        _scores = scores;
        _scoresCalculated = true;
      });

      final isHost = ref.read(isHostProvider);
      if (isHost && game.settings.scoringMode == ScoringMode.automatic) {
        ref.read(gameProvider.notifier).setRoundScores(scores);

        final serverService = ref.read(serverProvider);
        if (serverService != null) {
          final message = Message(
            type: MessageType.scoringResults,
            payload: {'scores': scores},
            senderId: game.host.id,
            timestamp: DateTime.now(),
          );

          await serverService.broadcastMessage(message);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating scores: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveManualScores() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    ref.read(gameProvider.notifier).setRoundScores(_scores);

    final isHost = ref.read(isHostProvider);
    if (isHost) {
      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        final message = Message(
          type: MessageType.scoringResults,
          payload: {'scores': _scores},
          senderId: game.host.id,
          timestamp: DateTime.now(),
        );

        serverService.broadcastMessage(message);
      }
    }
  }

  void _nextRound() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    if (game.settings.scoringMode == ScoringMode.manual) _saveManualScores();

    if (game.currentRound! >= game.settings.numberOfRounds) {
      ref.read(gameProvider.notifier).endGame();

      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        final message = Message(
          type: MessageType.gameEnded,
          payload: {},
          senderId: game.host.id,
          timestamp: DateTime.now(),
        );

        serverService.broadcastMessage(message);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    } else {
      ref.read(gameProvider.notifier).nextRound();

      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        final message = Message(
          type: MessageType.roundStarted,
          payload: {},
          senderId: game.host.id,
          timestamp: DateTime.now(),
        );

        serverService.broadcastMessage(message);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePlayScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isHost = ref.watch(isHostProvider);

    if (game == null || game.rounds.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentRound = game.rounds.last;

    return Scaffold(
      appBar: AppBar(
        title: Text('Punktacja - Runda ${game.currentRound}'),
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Litera: ${currentRound.letter}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ResponsiveScoringTable(
                          game: game,
                          round: currentRound,
                          scores: _scores,
                          isManualScoring:
                              game.settings.scoringMode == ScoringMode.manual,
                          isHost: isHost,
                          onScoreChanged: (playerId, category, score) {
                            setState(() {
                              _scores.putIfAbsent(playerId, () => {});
                              _scores[playerId]![category] = score;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isHost &&
                                game.settings.scoringMode == ScoringMode.manual)
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: CustomButton(
                                  text: 'Zapisz punkty',
                                  onPressed: _saveManualScores,
                                  width: 150,
                                ),
                              ),
                            if (isHost)
                              CustomButton(
                                text:
                                    game.currentRound! >=
                                            game.settings.numberOfRounds
                                        ? 'Zakończ grę'
                                        : 'Następna runda',
                                onPressed: _nextRound,
                                width: 150,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

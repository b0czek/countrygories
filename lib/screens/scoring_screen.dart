import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game.dart';
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
  StreamSubscription? _clientMessageSubscription;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
    _calculateScores();
  }

  @override
  void dispose() {
    _clientMessageSubscription?.cancel();
    super.dispose();
  }

  void _setupNetworkListeners() {
    final isHost = ref.read(isHostProvider);

    if (isHost) {
    } else {
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final clientService = ref.read(clientProvider);
        if (clientService != null) {
          _clientMessageSubscription = clientService.onMessage.listen((
            message,
          ) {
            if (!mounted) return; // Check if widget is still mounted

            if (message.type == MessageType.scoringResults) {
              final scores = Map<String, Map<String, int>>.from(
                message.payload['scores'].map(
                  (k, v) => MapEntry(k, Map<String, int>.from(v)),
                ),
              );

              // Also sync the round data if provided
              if (message.payload.containsKey('roundData')) {
                final roundData =
                    message.payload['roundData'] as Map<String, dynamic>;
                ref
                    .read(gameProvider.notifier)
                    .syncCompleteRoundFromServer(roundData);
              }

              setState(() {
                _scores = scores;
                _scoresCalculated = true;
                _isLoading = false; // Ensure loading spinner is hidden
              });
            } else if (message.type == MessageType.scoreUpdate) {
              // Handle live score updates
              final playerId = message.payload['playerId'] as String;
              final category = message.payload['category'] as String;
              final score = message.payload['score'] as int;

              setState(() {
                _scores.putIfAbsent(playerId, () => {});
                _scores[playerId]![category] = score;
                _scoresCalculated =
                    true; // Mark as calculated when receiving updates
                _isLoading = false; // Ensure not in loading state
              });
            } else if (message.type == MessageType.gameEnded) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ResultsScreen()),
              );
            } else if (message.type == MessageType.roundStarted) {
              final round = (message.payload['round'] as int) + 1;
              // Host updates the current round after the LetterSelected
              ref.read(gameProvider.notifier).syncRoundFromServer(round);

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

    final isHost = ref.read(isHostProvider);

    // Only hosts calculate scores, clients receive them via network
    if (!isHost) {
      setState(() {
        _isLoading =
            false; // Clients don't need to calculate, just wait for results
      });
      return;
    }

    if (!mounted) return; // Check if widget is still mounted

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

      if (!mounted) return;

      setState(() {
        _scores = scores;
        _scoresCalculated = true;
      });

      final isHost = ref.read(isHostProvider);
      if (isHost) {
        ref.read(gameProvider.notifier).setRoundScores(scores);

        final serverService = ref.read(serverProvider);
        if (serverService != null) {
          // Include the complete round data for clients to sync
          final currentRound = game.rounds.isNotEmpty ? game.rounds.last : null;
          final payload = <String, dynamic>{'scores': scores};

          if (currentRound != null) {
            payload['roundData'] = currentRound.toJson();
          }

          final message = Message(
            type: MessageType.scoringResults,
            payload: payload,
            senderId: game.host.id,
            timestamp: DateTime.now(),
          );

          // Delay to ensure clients are ready to receive the message in proper order - roundEnded -> scoringResults
          await Future.delayed(const Duration(milliseconds: 300));
          await serverService.broadcastMessage(message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error calculating scores: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveScoresToGameState() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    ref.read(gameProvider.notifier).setRoundScores(_scores);
  }

  void _broadcastScoreUpdate(String playerId, String category, int score) {
    final game = ref.read(gameProvider);
    final isHost = ref.read(isHostProvider);

    if (game == null || !isHost) return;

    final serverService = ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.scoreUpdate,
        payload: {'playerId': playerId, 'category': category, 'score': score},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }
  }

  void _nextRound() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

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
          payload: {'round': game.currentRound},
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

    if (game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // For clients, if they don't have rounds data yet but have received scores,
    // we can still show the scoring interface
    final currentRound = game.rounds.isNotEmpty ? game.rounds.last : null;

    // Show error message if there's one, after the widget is built
    if (_errorMessage != null && _scoresCalculated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _errorMessage = null; // Clear the error message
          });
        }
      });
    }

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
                        'Litera: ${currentRound?.letter ?? "?"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isHost)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  color: Colors.blue.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Oglądasz na żywo punktację prowadzoną przez hosta',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!isHost && !_scoresCalculated) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              if (_errorMessage == null) ...[
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                const Text(
                                  'Czekam na wyniki punktacji...',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Błąd podczas obliczania punktów',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        // Always show the scoring table if we have scores, even without complete round data
                        if (_scoresCalculated && _scores.isNotEmpty) ...[
                          Expanded(
                            child: ResponsiveScoringTable(
                              game: game,
                              round:
                                  currentRound ??
                                  GameRound(
                                    id: 'temp-round',
                                    letter: game.currentLetter ?? '?',
                                    roundNumber: game.currentRound ?? 1,
                                    startTime: DateTime.now(),
                                    answers: {},
                                    scores: _scores,
                                  ),
                              scores: _scores,
                              isManualScoring:
                                  game.settings.scoringMode ==
                                  ScoringMode.manual,
                              isHost: isHost,
                              onScoreChanged: (playerId, category, score) {
                                setState(() {
                                  _scores.putIfAbsent(playerId, () => {});
                                  _scores[playerId]![category] = score;
                                });

                                // Automatically save scores to game state
                                _saveScoresToGameState();

                                // Broadcast the score update to clients
                                _broadcastScoreUpdate(
                                  playerId,
                                  category,
                                  score,
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          // Fallback UI when round data is not available and no scores
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.table_chart,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Przygotowywanie tabeli punktacji...',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Otrzymano wyniki: ${_scores.isNotEmpty ? "Tak" : "Nie"}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                    ],
                  ),
                ),
              ),
    );
  }
}

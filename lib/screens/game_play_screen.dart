import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/scoring_screen.dart';
import 'package:countrygories/widgets/game/category_input.dart';
import 'package:countrygories/widgets/game/letter_wheel.dart';
import 'package:countrygories/widgets/game/timer_widget.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  const GamePlayScreen({super.key});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  final Map<String, TextEditingController> _controllers = {};
  Timer? _timer;
  int _remainingTime = 0;
  bool _isSelectingLetter = true;
  bool _isSubmitting = false;
  bool _isWaitingForOthers = false;
  Set<String> _submittedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
    _initializeControllers();

    // Reset state when entering the screen
    setState(() {
      _isSubmitting = false;
      _isWaitingForOthers = false;
      _submittedPlayerIds.clear();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupNetworkListeners() {
    final isHost = ref.read(isHostProvider);

    if (isHost) {
      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        serverService.onMessage.listen((message) {
          if (message.type == MessageType.submitAnswers) {
            final playerId = message.senderId;
            final answers = Map<String, String>.from(
              message.payload['answers'],
            );

            ref.read(gameProvider.notifier).submitAnswers(playerId, answers);

            // Track which player submitted
            setState(() {
              _submittedPlayerIds.add(playerId);
            });

            // Broadcast to all clients that this player submitted
            _broadcastPlayerSubmitted(playerId);

            // Check if all players have submitted
            _checkAllPlayersSubmitted();
          }
        });
      }
    } else {
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final clientService = ref.read(clientProvider);
        if (clientService != null) {
          clientService.onMessage.listen((message) {
            if (message.type == MessageType.letterSelected) {
              setState(() {
                _isSelectingLetter = false;
                _isSubmitting = false;
                _isWaitingForOthers = false;
                _submittedPlayerIds.clear();
              });

              final letter = message.payload['letter'] as String;
              ref.read(gameProvider.notifier).syncLetterFromServer(letter);

              _startRoundTimer();
            } else if (message.type == MessageType.playerSubmitted) {
              // Update submission status from host
              final submittedPlayerIds = List<String>.from(
                message.payload['submittedPlayerIds'],
              );
              print('Client received playerSubmitted message!');
              print('Received submittedPlayerIds: $submittedPlayerIds');
              print(
                'Current _submittedPlayerIds before update: $_submittedPlayerIds',
              );
              print('Current _isWaitingForOthers: $_isWaitingForOthers');

              setState(() {
                // Merge received submissions with current state
                final receivedSubmissions = submittedPlayerIds.toSet();
                _submittedPlayerIds.addAll(receivedSubmissions);

                // Ensure current player is in the list if they're waiting
                final currentPlayer = ref.read(currentPlayerProvider);
                if (_isWaitingForOthers && currentPlayer != null) {
                  _submittedPlayerIds.add(currentPlayer.id);
                  print(
                    'Added current player ${currentPlayer.id} to submitted list',
                  );
                }
                print(
                  'Final client submitted list after update: $_submittedPlayerIds',
                );
              });
            } else if (message.type == MessageType.roundEnded) {
              _timer?.cancel();

              // Reset waiting state before going to scoring
              setState(() {
                _isWaitingForOthers = false;
                _isSubmitting = false;
              });

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ScoringScreen()),
              );
            }
          });
        }
      }
    }
  }

  void _initializeControllers() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    for (final category in game.categories) {
      _controllers[category] = TextEditingController();
    }
  }

  void _startRoundTimer() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    _remainingTime = game.settings.timePerRound;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();

          // Time is up - force submit if not already submitted
          if (!_isSubmitting && !_isWaitingForOthers) {
            _submitAnswers();
          }

          final isHost = ref.read(isHostProvider);
          if (isHost) {
            // Host: end round regardless of who submitted
            _endRound();
          }
        }
      });
    });
  }

  void _selectLetter() {
    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    setState(() {
      _isSelectingLetter = false;
      _isSubmitting = false;
      _isWaitingForOthers = false;
      _submittedPlayerIds.clear();
    });

    ref.read(gameProvider.notifier).startRound();

    final game = ref.read(gameProvider);
    if (game == null || game.currentLetter == null) return;

    final serverService = ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.letterSelected,
        payload: {'letter': game.currentLetter!},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }

    _startRoundTimer();
  }

  void _submitAnswers() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final game = ref.read(gameProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (game == null || currentPlayer == null) return;

    final answers = <String, String>{};
    for (final category in game.categories) {
      answers[category] = _controllers[category]?.text.trim() ?? '';
    }

    ref.read(gameProvider.notifier).submitAnswers(currentPlayer.id, answers);

    final isHost = ref.read(isHostProvider);
    if (isHost) {
      // Host submitted, now wait for others or end if all submitted
      setState(() {
        _isWaitingForOthers = true;
        _submittedPlayerIds.add(currentPlayer.id); // Add host to submitted list
      });

      // Broadcast that host has submitted
      _broadcastPlayerSubmitted(currentPlayer.id);

      _checkAllPlayersSubmitted();
    } else {
      // Send to server
      final clientService = ref.read(clientProvider);
      if (clientService != null) {
        final message = Message(
          type: MessageType.submitAnswers,
          payload: {'answers': answers},
          senderId: currentPlayer.id,
          timestamp: DateTime.now(),
        );

        clientService.sendMessage(message);
      }

      // Client enters waiting state and adds themselves to submitted list
      setState(() {
        _isWaitingForOthers = true;
        _submittedPlayerIds.add(currentPlayer.id); // Add themselves immediately
      });

      print(
        'Client ${currentPlayer.id} submitted, waiting state: $_isWaitingForOthers',
      );
      print('Client submitted players: $_submittedPlayerIds');
    }
  }

  void _broadcastPlayerSubmitted(String playerId) {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    print('Host broadcasting player submitted: $playerId');
    print('Host submitted players: $_submittedPlayerIds');

    final serverService = ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.playerSubmitted,
        payload: {
          'playerId': playerId,
          'submittedPlayerIds': _submittedPlayerIds.toList(),
        },
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }
  }

  void _checkAllPlayersSubmitted() {
    final game = ref.read(gameProvider);
    if (game == null) return;

    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    // Get all connected players (excluding disconnected ones)
    final connectedPlayers = game.players.where((p) => p.isConnected).toList();
    final allPlayerIds = connectedPlayers.map((p) => p.id).toSet();

    print(
      'Submitted players: ${_submittedPlayerIds.length}/${allPlayerIds.length}',
    );
    print('All players: $allPlayerIds');
    print('Submitted: $_submittedPlayerIds');

    if (_submittedPlayerIds.containsAll(allPlayerIds)) {
      // All players have submitted, end the round
      print('All players submitted, ending round');
      _timer?.cancel();
      _endRound();
    }
  }

  void _endRound() {
    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    ref.read(gameProvider.notifier).endRound();

    // Broadcast end round message
    final game = ref.read(gameProvider);
    if (game == null) return;

    final serverService = ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.roundEnded,
        payload: {},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }

    // Go to scoring screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ScoringScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isHost = ref.watch(isHostProvider);

    if (game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Runda ${game.currentRound ?? 0}'),
        automaticallyImplyLeading: false,
        actions: [
          if (!_isSelectingLetter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TimerWidget(remainingTime: _remainingTime),
            ),
        ],
      ),
      body: Container(
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
            children: [
              if (_isSelectingLetter) ...[
                const SizedBox(height: 40),
                Text(
                  isHost
                      ? 'Kliknij, aby wylosować literę'
                      : 'Czekaj na wylosowanie litery...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Center(
                  child: LetterWheel(onStop: isHost ? _selectLetter : null),
                ),
              ] else if (_isWaitingForOthers) ...[
                const SizedBox(height: 40),
                const Icon(
                  Icons.hourglass_empty,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Czekam na pozostałych graczy...',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Czas pozostały: ${_remainingTime}s',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  'Gracze którzy oddali odpowiedzi: ${_submittedPlayerIds.length}/${game.players.where((p) => p.isConnected).length}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Show list of players and their status
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.where((p) => p.isConnected).length,
                    itemBuilder: (context, index) {
                      final player =
                          game.players
                              .where((p) => p.isConnected)
                              .toList()[index];
                      final hasSubmitted = _submittedPlayerIds.contains(
                        player.id,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          leading: Icon(
                            hasSubmitted
                                ? Icons.check_circle
                                : Icons.hourglass_empty,
                            color: hasSubmitted ? Colors.green : Colors.orange,
                          ),
                          title: Text(player.name),
                          subtitle: Text(
                            hasSubmitted ? 'Oddał odpowiedzi' : 'Czeka...',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (isHost)
                  ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      _endRound();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Wymuś zakończenie rundy',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  'Litera: ${game.currentLetter ?? "?"}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.categories.length,
                    itemBuilder: (context, index) {
                      final category = game.categories[index];
                      return CategoryInput(
                        category: category,
                        controller: _controllers[category]!,
                        letter: game.currentLetter ?? '',
                        enabled: !_isSubmitting,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Wysłano!' : 'Zakończ rundę',
                    style: const TextStyle(fontSize: 18),
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

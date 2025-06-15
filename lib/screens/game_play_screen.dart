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

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
    _initializeControllers();
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
              });

              final letter = message.payload['letter'] as String;
              ref.read(gameProvider.notifier).syncLetterFromServer(letter);

              _startRoundTimer();
            } else if (message.type == MessageType.roundEnded) {
              _timer?.cancel();
              _submitAnswers();

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
          _submitAnswers();

          final isHost = ref.read(isHostProvider);
          if (isHost) {
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
      // Host already got it in game state
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
                  onPressed:
                      _isSubmitting
                          ? null
                          : () {
                            _submitAnswers();
                            if (isHost) {
                              _timer?.cancel();
                              _endRound();
                            }
                          },
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

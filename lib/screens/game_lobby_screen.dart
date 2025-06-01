import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/game_play_screen.dart';
import 'package:countrygories/screens/home_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';
import 'package:countrygories/widgets/game/player_list.dart';

class GameLobbyScreen extends ConsumerStatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
  }

  void _setupNetworkListeners() {
    final isHost = ref.read(isHostProvider);

    if (isHost) {
      // Setup network listeners
      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        serverService.onPlayerConnected.listen((player) {
          ref.read(connectedPlayersProvider.notifier).addPlayer(player);
          ref.read(gameProvider.notifier).joinGame(player);

          // Send current game state to the newly connected player
          final game = ref.read(gameProvider);
          if (game != null) {
            final clientId =
                serverService.players.entries
                    .firstWhere(
                      (e) => e.value.id == player.id,
                      orElse: () => MapEntry('', player),
                    )
                    .key;

            if (clientId.isNotEmpty) {
              serverService.sendGameDataToClient(clientId, game);
            }
          }
        });

        serverService.onPlayerDisconnected.listen((playerId) {
          ref.read(connectedPlayersProvider.notifier).removePlayer(playerId);
          ref
              .read(gameProvider.notifier)
              .updatePlayerStatus(playerId, isConnected: false);
        });

        serverService.onMessage.listen((message) {
          if (message.type == MessageType.playerReady) {
            ref
                .read(gameProvider.notifier)
                .updatePlayerStatus(message.senderId, isReady: true);
          } else if (message.type == MessageType.ping) {
            final playerId = message.senderId;
            ref
                .read(gameProvider.notifier)
                .updatePlayerStatus(playerId, isConnected: true);
          }
        });
      }
    } else {
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final clientService = ref.read(
          clientProvider({
            'ip': currentPlayer.ipAddress,
            'port': currentPlayer.port,
          }),
        );

        clientService.onMessage.listen((message) {
          if (message.type == MessageType.gameStarted) {
            // Go to game screen when game starts
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const GamePlayScreen()),
              );
            }
          } else if (message.type == MessageType.gameLobbyData) {
            // Update client's game lobbstate with data from server
            if (message.payload.containsKey('game')) {
              final gameData = message.payload['game'];
              final game = Game.fromJson(gameData);
              ref.read(gameProvider.notifier).updateGameState(game);
            }
          } else if (message.type == MessageType.hostSessionTerminated) {
            // Host has terminated the session
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Host has left the game. The session has been terminated.',
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );

              // Return to home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        });

        clientService.connectionStatus.listen((isConnected) {
          if (!isConnected && mounted) {
            // If disconnected, show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Connection to server lost! Trying to reconnect...',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 8),
              ),
            );

            final updatedPlayer = currentPlayer.copyWith(isConnected: false);
            ref.read(currentPlayerProvider.notifier).state = updatedPlayer;

            // Attempt to reconnect
            _attemptReconnection(clientService);
          } else if (isConnected) {
            // If reconnected after a disconnection
            final updatedPlayer = currentPlayer.copyWith(isConnected: true);
            ref.read(currentPlayerProvider.notifier).state = updatedPlayer;
          }
        });
      }
    }
  }

  Future<void> _attemptReconnection(clientService) async {
    if (!mounted) return;

    // Try to reconnect up to 3 times
    for (int i = 0; i < 3; i++) {
      try {
        if (!clientService.isConnected) {
          await clientService.connectToServer();
          if (clientService.isConnected) {
            // Re-join the game with the current player
            final currentPlayer = ref.read(currentPlayerProvider);
            if (currentPlayer != null) {
              await clientService.joinGame(currentPlayer);
            }
            return;
          }
        } else {
          return;
        }
      } catch (e) {
        print('Reconnection attempt $i failed: $e');
      }

      // Wait before next attempt
      await Future.delayed(const Duration(seconds: 2));
    }

    // If all reconnection attempts fail
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to reconnect to the server. Please try rejoining the game.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 10),
        ),
      );
    }
  }

  Future<void> _leave() async {
    final isHost = ref.read(isHostProvider);
    if (isHost) {
      // Host is leaving - terminate the session and notify all players
      final serverService = ref.read(serverProvider);
      if (serverService != null) {
        try {
          await serverService.terminateHostSession();
        } catch (e) {
          print('Error terminating host session: $e');
        }
      }

      // Reset host state
      ref.read(isHostProvider.notifier).state = false;
      ref.read(serverActiveProvider.notifier).state = false;
    } else {
      // Regular player leaving
      final currentPlayer = ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final clientService = ref.read(
          clientProvider({
            'ip': currentPlayer.ipAddress,
            'port': currentPlayer.port,
          }),
        );
        try {
          await clientService.leaveGame(currentPlayer.id);
          await clientService.disconnectFromServer();
        } catch (e) {
          print('Error leaving game: $e');
        }
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _toggleReady() {
    final currentPlayer = ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    final isHost = ref.read(isHostProvider);
    if (isHost) {
      // Host is always ready
      return;
    }

    final updatedPlayer = currentPlayer.copyWith(
      isReady: !currentPlayer.isReady,
    );
    ref.read(currentPlayerProvider.notifier).state = updatedPlayer;

    final clientService = ref.read(
      clientProvider({
        'ip': currentPlayer.ipAddress,
        'port': currentPlayer.port,
      }),
    );

    final message = Message(
      type: MessageType.playerReady,
      payload: {'isReady': updatedPlayer.isReady},
      senderId: currentPlayer.id,
      timestamp: DateTime.now(),
    );

    clientService.sendMessage(message);
  }

  void _startGame() {
    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    final game = ref.read(gameProvider);
    if (game == null) return;

    final allReady = game.players.every((p) => p.isHost || p.isReady);
    if (!allReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie wszyscy gracze są gotowi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final allConnected = game.players.every((p) => p.isConnected);
    if (!allConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Niektórzy gracze stracili połączenie!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(gameProvider.notifier).startGame();

    final serverService = ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.gameStarted,
        payload: {'game': game.toJson()},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GamePlayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final isHost = ref.watch(isHostProvider);

    if (game == null || currentPlayer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby gry'),
        automaticallyImplyLeading: false,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kod gry: ${game.id.substring(0, 6).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // if (isHost)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8.0),
              //     child: Text(
              //       'Adres IP: ${ref.read(serverProvider)?.serverAddress ?? "N/A"}',
              //       style: const TextStyle(fontSize: 16),
              //     ),
              //   ),
              if (isHost)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final localIpAsync = ref.watch(localIpProvider);

                      return localIpAsync.when(
                        data:
                            (ip) => Text(
                              'Adres IP: $ip',
                              style: const TextStyle(fontSize: 16),
                            ),
                        loading: () => const Text('Pobieranie adresu IP...'),
                        error: (err, _) => Text('Błąd IP: $err'),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),
              const Text(
                'Gracze:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PlayerList(
                  players: game.players,
                  currentPlayerId: currentPlayer.id,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kategorie:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    game.categories.map((category) {
                      return Chip(label: Text(category));
                    }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: "Opuść pokój",
                    onPressed: _leave,
                    width: 150,
                  ),
                  const SizedBox(width: 8),
                  if (!isHost)
                    CustomButton(
                      text: currentPlayer.isReady ? 'Nie gotowy' : 'Gotowy',
                      onPressed: _toggleReady,
                      color: currentPlayer.isReady ? Colors.green : null,
                      width: 150,
                    ),
                  if (isHost) ...[
                    CustomButton(
                      text: 'Rozpocznij grę',
                      onPressed: _startGame,
                      width: 150,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

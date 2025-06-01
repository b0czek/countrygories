import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/services/network/client_service.dart';

class LobbyService {
  final WidgetRef _ref;
  final BuildContext _context;
  final List<StreamSubscription> _subscriptions = [];

  LobbyService(this._ref, this._context);

  void setupNetworkListeners() {
    final isHost = _ref.read(isHostProvider);

    if (isHost) {
      _setupHostListeners();
    } else {
      _setupClientListeners();
    }
  }

  void _setupHostListeners() {
    final serverService = _ref.read(serverProvider);
    if (serverService == null) return;

    // Player connected
    _subscriptions.add(
      serverService.onPlayerConnected.listen((player) {
        _ref.read(connectedPlayersProvider.notifier).addPlayer(player);
        _ref.read(gameProvider.notifier).joinGame(player);

        // Send current game state to the newly connected player
        final game = _ref.read(gameProvider);
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
      }),
    );

    // Player disconnected
    _subscriptions.add(
      serverService.onPlayerDisconnected.listen((playerId) {
        _ref.read(connectedPlayersProvider.notifier).removePlayer(playerId);
        _ref
            .read(gameProvider.notifier)
            .updatePlayerStatus(playerId, isConnected: false);
      }),
    );

    // Handle messages
    _subscriptions.add(
      serverService.onMessage.listen((message) {
        if (message.type == MessageType.playerReady) {
          final playerId = message.senderId;
          final isReady = message.payload['isReady'] as bool? ?? false;
          _ref
              .read(gameProvider.notifier)
              .updatePlayerStatus(playerId, isReady: isReady);
        }
        // Note: Ping messages are handled by ServerService internally for connection monitoring
        // No need to process them here as they don't represent actual player status changes
      }),
    );
  }

  void _setupClientListeners() {
    final currentPlayer = _ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    final clientService = _ref.read(clientProvider);
    if (clientService == null) return;

    // Handle messages
    _subscriptions.add(
      clientService.onMessage.listen((message) {
        if (message.type == MessageType.gameStarted) {
          // Delegate navigation to callback
          _onGameStarted();
        } else if (message.type == MessageType.gameLobbyData) {
          _handleGameLobbyData(message);
        } else if (message.type == MessageType.playerReady) {
          _handlePlayerReady(message);
        } else if (message.type == MessageType.hostSessionTerminated) {
          _onHostSessionTerminated();
        }
      }),
    );

    // Handle connection status
    _subscriptions.add(
      clientService.connectionStatus.listen((isConnected) {
        if (!isConnected) {
          _onConnectionLost(clientService);
        } else {
          _onConnectionRestored(currentPlayer);
        }
      }),
    );
  }

  void _handleGameLobbyData(Message message) {
    print('_handleGameLobbyData called with message type: ${message.type}');

    if (message.payload.containsKey('game')) {
      final gameData = message.payload['game'];
      final game = Game.fromJson(gameData);
      print('Updating full game state from server');

      // Check current player's ready status before and after
      final currentPlayer = _ref.read(currentPlayerProvider);
      if (currentPlayer != null) {
        final serverPlayer = game.players.firstWhere(
          (p) => p.id == currentPlayer.id,
          orElse: () => currentPlayer,
        );
        print(
          'Current player ready status: ${currentPlayer.isReady} -> Server has: ${serverPlayer.isReady}',
        );
      }

      _ref.read(gameProvider.notifier).updateGameState(game);

      // After updating game state, ensure current player state is consistent
      if (currentPlayer != null) {
        final updatedGamePlayer = game.players.firstWhere(
          (p) => p.id == currentPlayer.id,
          orElse: () => currentPlayer,
        );
        if (updatedGamePlayer.isReady != currentPlayer.isReady) {
          print(
            'Syncing current player state with game state: ${currentPlayer.isReady} -> ${updatedGamePlayer.isReady}',
          );
          _ref.read(currentPlayerProvider.notifier).state = updatedGamePlayer;
        }
      }
    } else if (message.payload.containsKey('playerJoined')) {
      final playerJoinedData = message.payload['playerJoined'];
      final playerData = playerJoinedData['player'];
      final newPlayer = Player.fromJson(playerData);
      _ref.read(gameProvider.notifier).joinGame(newPlayer);
      print('New player joined: ${newPlayer.name}');
    } else if (message.payload.containsKey('playerLeft')) {
      final playerLeftData = message.payload['playerLeft'];
      final leftPlayer = Player.fromJson(playerLeftData['player']);
      _ref
          .read(gameProvider.notifier)
          .updatePlayerStatus(leftPlayer.id, isConnected: false);
      print('Player left: ${leftPlayer.name}');
    }
  }

  void _handlePlayerReady(Message message) {
    final playerId = message.payload['playerId'] as String?;
    final isReady = message.payload['isReady'] as bool? ?? false;

    print(
      '_handlePlayerReady called for playerId: $playerId, isReady: $isReady',
    );

    if (playerId != null) {
      _ref
          .read(gameProvider.notifier)
          .updatePlayerStatus(playerId, isReady: isReady);

      // If this is the current player's ready status, also update the current player provider
      final currentPlayer = _ref.read(currentPlayerProvider);
      if (currentPlayer != null && currentPlayer.id == playerId) {
        print('Updating current player ready status to: $isReady');
        final updatedPlayer = currentPlayer.copyWith(isReady: isReady);
        _ref.read(currentPlayerProvider.notifier).state = updatedPlayer;
        print(
          'Current player updated, new ready status: ${updatedPlayer.isReady}',
        );
      } else {
        print(
          'Not updating current player - IDs do not match or current player is null',
        );
        print(
          'Current player ID: ${currentPlayer?.id}, Message player ID: $playerId',
        );
      }
    }
  }

  void _onGameStarted() {
    // This will be handled by the screen through a callback
    _gameStartedCallback?.call();
  }

  void _onHostSessionTerminated() {
    if (!_isMounted()) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      const SnackBar(
        content: Text(
          'Host has left the game. The session has been terminated.',
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );

    _hostSessionTerminatedCallback?.call();
  }

  void _onConnectionLost(ClientService clientService) {
    if (!_isMounted()) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      const SnackBar(
        content: Text('Connection to server lost!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );

    final currentPlayer = _ref.read(currentPlayerProvider);
    if (currentPlayer != null) {
      final updatedPlayer = currentPlayer.copyWith(isConnected: false);
      _ref.read(currentPlayerProvider.notifier).state = updatedPlayer;
    }

    // Attempt to reconnect
    _attemptReconnection(clientService);
  }

  void _onConnectionRestored(Player currentPlayer) {
    final updatedPlayer = currentPlayer.copyWith(isConnected: true);
    _ref.read(currentPlayerProvider.notifier).state = updatedPlayer;
  }

  Future<void> _attemptReconnection(ClientService clientService) async {
    if (!_isMounted()) return;

    // Try to reconnect up to 3 times
    for (int i = 0; i < 3; i++) {
      if (!_isMounted()) return;

      try {
        if (!clientService.isConnected) {
          await clientService.connectToServer();
          if (clientService.isConnected) {
            final currentPlayer = _ref.read(currentPlayerProvider);
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

      await Future.delayed(const Duration(seconds: 2));
    }

    // If all reconnection attempts fail - check mounted status again
    final isMounted = _isMounted();
    if (isMounted) {
      ScaffoldMessenger.of(_context).showSnackBar(
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

  Future<void> leaveGame() async {
    final isHost = _ref.read(isHostProvider);
    if (isHost) {
      await _leaveAsHost();
    } else {
      await _leaveAsClient();
    }
  }

  Future<void> _leaveAsHost() async {
    final serverService = _ref.read(serverProvider);
    if (serverService != null) {
      try {
        await serverService.terminateHostSession();
      } catch (e) {
        print('Error terminating host session: $e');
      }
    }

    _ref.read(isHostProvider.notifier).state = false;
    _ref.read(serverActiveProvider.notifier).state = false;
  }

  Future<void> _leaveAsClient() async {
    final currentPlayer = _ref.read(currentPlayerProvider);
    if (currentPlayer != null) {
      final clientService = _ref.read(clientProvider);
      if (clientService != null) {
        try {
          await clientService.leaveGame(currentPlayer.id);
          await clientService.disconnectFromServer();
        } catch (e) {
          print('Error leaving game: $e');
        }
      }
    }
  }

  void togglePlayerReady() {
    final currentPlayer = _ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    final isHost = _ref.read(isHostProvider);
    if (isHost) return; // Host is always ready

    final clientService = _ref.read(clientProvider);
    if (clientService == null) return;

    // Send message to server with the new ready status
    // Don't update local state immediately - wait for server confirmation
    final newReadyStatus = !currentPlayer.isReady;
    final message = Message(
      type: MessageType.playerReady,
      payload: {'isReady': newReadyStatus},
      senderId: currentPlayer.id,
      timestamp: DateTime.now(),
    );

    clientService.sendMessage(message);
  }

  String? validateGameStart() {
    final isHost = _ref.read(isHostProvider);
    if (!isHost) return 'Only host can start the game';

    final game = _ref.read(gameProvider);
    if (game == null) return 'No game found';

    final allReady = game.players.every((p) => p.isHost || p.isReady);
    if (!allReady) return 'Nie wszyscy gracze są gotowi!';

    final allConnected = game.players.every((p) => p.isConnected);
    if (!allConnected) return 'Niektórzy gracze stracili połączenie!';

    return null; // Valid to start
  }

  void startGame() {
    final game = _ref.read(gameProvider);
    if (game == null) return;

    _ref.read(gameProvider.notifier).startGame();

    final serverService = _ref.read(serverProvider);
    if (serverService != null) {
      final message = Message(
        type: MessageType.gameStarted,
        payload: {'game': game.toJson()},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      serverService.broadcastMessage(message);
    }
  }

  bool _isMounted() {
    // Check if the widget is still mounted
    try {
      return _context.mounted;
    } catch (e) {
      return false;
    }
  }

  // Callbacks that can be set by the screen
  VoidCallback? _gameStartedCallback;
  VoidCallback? _hostSessionTerminatedCallback;

  void setGameStartedCallback(VoidCallback callback) {
    _gameStartedCallback = callback;
  }

  void setHostSessionTerminatedCallback(VoidCallback callback) {
    _hostSessionTerminatedCallback = callback;
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

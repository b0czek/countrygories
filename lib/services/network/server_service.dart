import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:countrygories/models/message.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/models/game.dart';
import 'package:countrygories/services/network/server_discovery_service.dart';
import 'package:uuid/uuid.dart';

class ServerService {
  final int port;
  ServerSocket? _server;
  final Map<String, Socket> _connectedClients = {};
  final Map<String, Player> _players = {};
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<Player> _playerConnectedController =
      StreamController<Player>.broadcast();
  final StreamController<String> _playerDisconnectedController =
      StreamController<String>.broadcast();
  // Add locks to prevent concurrent socket operations
  final Map<String, bool> _socketInUse = {};

  // Keep track of the last ping from each client
  final Map<String, DateTime> _lastClientPing = {};
  Timer? _connectionMonitorTimer;
  final Duration _connectionMonitorInterval = const Duration(seconds: 10);

  // Server discovery service
  final ServerDiscoveryService _discoveryService = ServerDiscoveryService();
  String _serverName = 'Countrygories Game';
  String _hostName = 'Host';

  Stream<Message> get onMessage => _messageController.stream;
  Stream<Player> get onPlayerConnected => _playerConnectedController.stream;
  Stream<String> get onPlayerDisconnected =>
      _playerDisconnectedController.stream;

  ServerService({required this.port});

  Future<void> startServer({String? serverName, String? hostName}) async {
    if (_server != null) return;

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print('Server started on ${_server!.address.address}:${_server!.port}');

      if (serverName != null) _serverName = serverName;
      if (hostName != null) _hostName = hostName;

      _server!.listen(_handleClient);
      _startConnectionMonitoring();

      // Start server discovery advertisement
      await _discoveryService.startAdvertising(
        serverName: _serverName,
        ipAddress: _server!.address.address,
        port: _server!.port,
        hostName: _hostName,
        playerCount: _players.length,
        maxPlayers: 8,
      );
    } catch (e) {
      print('Error starting server: $e');
      rethrow;
    }
  }

  Future<void> stopServer() async {
    if (_server == null) return;

    _stopConnectionMonitoring();

    // Stop server discovery advertisement
    await _discoveryService.stopAdvertising();

    for (final client in _connectedClients.values) {
      client.close();
    }

    await _server!.close();
    _server = null;
    _connectedClients.clear();
    _players.clear();
    print('Server stopped');
  }

  Future<void> terminateHostSession() async {
    if (_server == null) return;

    // First, notify all clients that the host session is terminated
    final terminationMessage = Message(
      type: MessageType.hostSessionTerminated,
      payload: {'reason': 'Host has left the game'},
      senderId: 'server',
      timestamp: DateTime.now(),
    );

    await broadcastMessage(terminationMessage);

    // Give clients time to receive the message before closing connections
    await Future.delayed(const Duration(milliseconds: 500));

    // Then stop the server
    await stopServer();
  }

  void _handleClient(Socket client) {
    final clientId = const Uuid().v4();
    final clientAddress = client.remoteAddress.address;
    final clientPort = client.remotePort;

    print('Client connected: $clientAddress:$clientPort (ID: $clientId)');

    _connectedClients[clientId] = client;
    _lastClientPing[clientId] = DateTime.now(); // Initialize last ping time

    client.listen(
      (data) {
        _handleMessage(clientId, data);
      },
      onError: (error) {
        print('Error from client $clientId: $error');
        _disconnectClient(clientId);
      },
      onDone: () {
        print('Client $clientId disconnected');
        _disconnectClient(clientId);
      },
    );
  }

  void _handleMessage(String clientId, List<int> data) async {
    try {
      final messageJson = utf8.decode(data);
      final message = Message.fromJson(json.decode(messageJson));

      print('Message from $clientId: ${message.type}');

      _lastClientPing[clientId] = DateTime.now();

      if (message.type == MessageType.joinGame) {
        final player = Player.fromJson(message.payload['player']);
        _players[clientId] = player;
        _playerConnectedController.add(player);

        // Send acceptance message back to the client
        final confirmationMessage = Message(
          type: MessageType.joinGame,
          payload: {'status': 'accepted', 'playerId': clientId},
          senderId: 'server',
          timestamp: DateTime.now(),
        );

        await sendToClient(clientId, confirmationMessage);

        // Broadcast player joined event to all other clients
        await _broadcastPlayerJoined(clientId, player);

        // Update server discovery info
        await _updateDiscoveryInfo();
      } else if (message.type == MessageType.leaveGame) {
        await _disconnectClient(clientId);
      } else if (message.type == MessageType.playerReady) {
        // Handle player ready status and broadcast to all clients
        await _handlePlayerReady(clientId, message);
      } else if (message.type == MessageType.ping) {
        // Respond to ping with a pong
        _respondToPing(clientId);
      } else if (message.type == MessageType.playerSubmitted) {
        // Broadcast player submission status to all clients
        await broadcastMessage(message);
      }

      _messageController.add(message);
    } catch (e) {
      print('Error parsing message from $clientId: $e');
    }
  }

  Future<void> _respondToPing(String clientId) async {
    try {
      final pongMessage = Message(
        type: MessageType.pong,
        payload: {'timestamp': DateTime.now().toIso8601String()},
        senderId: 'server',
        timestamp: DateTime.now(),
      );

      await sendToClient(clientId, pongMessage);
    } catch (e) {
      print('Error sending pong to client $clientId: $e');
    }
  }

  Future<void> _disconnectClient(String clientId) async {
    final client = _connectedClients.remove(clientId);
    final player = _players.remove(clientId);
    _lastClientPing.remove(clientId);
    _socketInUse.remove(clientId);

    if (client != null) {
      client.close();
    }

    if (player != null) {
      _playerDisconnectedController.add(player.id);

      // Broadcast player left notification to all remaining clients
      _broadcastPlayerLeft(clientId, player);

      // Update server discovery info
      await _updateDiscoveryInfo();
    }
  }

  void _startConnectionMonitoring() {
    _stopConnectionMonitoring();

    _connectionMonitorTimer = Timer.periodic(
      _connectionMonitorInterval,
      (_) async => await _checkClientConnections(),
    );
  }

  void _stopConnectionMonitoring() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = null;
  }

  Future<void> _checkClientConnections() async {
    final now = DateTime.now();
    final clientsToRemove = <String>[];

    for (final entry in _lastClientPing.entries) {
      final clientId = entry.key;
      final lastPing = entry.value;

      if (now.difference(lastPing) > const Duration(seconds: 20)) {
        print(
          'Client $clientId timed out (no ping received in ${now.difference(lastPing).inSeconds} seconds)',
        );
        clientsToRemove.add(clientId);
      }
    }

    for (final clientId in clientsToRemove) {
      await _disconnectClient(clientId);
    }
  }

  Future<void> broadcastMessage(Message message) async {
    for (final clientId in _connectedClients.keys) {
      try {
        await sendToClient(clientId, message);
      } catch (e) {
        print('Error sending message to client $clientId: $e');
      }
    }
  }

  Future<void> sendToClient(String clientId, Message message) async {
    final client = _connectedClients[clientId];

    if (client == null) {
      print('Client $clientId not found');
      return;
    }

    // Check if socket is currently in use
    if (_socketInUse[clientId] == true) {
      print('Socket for client $clientId is currently in use, waiting...');
      // Wait a short time and try again
      await Future.delayed(Duration(milliseconds: 100));
      return sendToClient(clientId, message);
    }

    try {
      // Mark socket as in use
      _socketInUse[clientId] = true;

      final messageJson = json.encode(message.toJson());
      final data = utf8.encode(messageJson);

      print('Sending message to client $clientId: ${message.type}');

      try {
        client.add(data);
        await client.flush().catchError((error) async {
          print('Error flushing data to client $clientId: $error');
          await _disconnectClient(clientId);
          throw error;
        });

        print('Message sent to client $clientId');
      } catch (e) {
        print('Error sending message to client $clientId: $e');
        await _disconnectClient(clientId);
        rethrow;
      } finally {
        // Release the socket
        _socketInUse[clientId] = false;
      }
    } catch (e) {
      print('Error preparing message for client $clientId: $e');
      // Release the socket in case of error
      _socketInUse[clientId] = false;
      rethrow;
    }
  }

  Future<void> sendGameDataToClient(String clientId, Game game) async {
    try {
      final gameMessage = Message(
        type: MessageType.gameLobbyData,
        payload: {'game': game.toJson()},
        senderId: 'server',
        timestamp: DateTime.now(),
      );

      await sendToClient(clientId, gameMessage);
      print('Game data sent to client $clientId');
    } catch (e) {
      print('Error sending game data to client $clientId: $e');
    }
  }

  Future<void> _handlePlayerReady(String clientId, Message message) async {
    try {
      final playerId = message.senderId;
      final isReady = message.payload['isReady'] as bool? ?? false;

      // Find the client ID that corresponds to this player ID
      String? targetClientId;
      Player? targetPlayer;

      for (final entry in _players.entries) {
        if (entry.value.id == playerId) {
          targetClientId = entry.key;
          targetPlayer = entry.value;
          break;
        }
      }

      if (targetClientId != null && targetPlayer != null) {
        // Update the player's ready status locally
        final updatedPlayer = targetPlayer.copyWith(isReady: isReady);
        _players[targetClientId] = updatedPlayer;

        print(
          'Player $targetClientId (${targetPlayer.name}) ready status changed to: $isReady',
        );

        // Broadcast the playerReady message to all connected clients
        final broadcastMsg = Message(
          type: MessageType.playerReady,
          payload: {
            'playerId': playerId, // Use the actual player ID, not client ID
            'playerName': targetPlayer.name,
            'isReady': isReady,
          },
          senderId: 'server',
          timestamp: DateTime.now(),
        );

        await broadcastMessage(broadcastMsg);
        print('Player ready status broadcasted to all clients');
      } else {
        print('Player with ID $playerId not found for ready status update');
      }
    } catch (e) {
      print('Error handling player ready status for client $clientId: $e');
    }
  }

  Future<void> _broadcastPlayerJoined(
    String newClientId,
    Player newPlayer,
  ) async {
    try {
      // Create a message to notify all clients about the new player
      final playerJoinedMessage = Message(
        type: MessageType.gameLobbyData,
        payload: {
          'playerJoined': {
            'playerId': newClientId,
            'player': newPlayer.toJson(),
          },
        },
        senderId: 'server',
        timestamp: DateTime.now(),
      );

      // Send to all clients except the newly joined one
      for (final clientId in _connectedClients.keys) {
        if (clientId != newClientId) {
          try {
            await sendToClient(clientId, playerJoinedMessage);
          } catch (e) {
            print(
              'Error sending player joined message to client $clientId: $e',
            );
          }
        }
      }

      print(
        'Player joined message broadcasted to ${_connectedClients.length - 1} existing clients',
      );
    } catch (e) {
      print('Error broadcasting player joined message: $e');
    }
  }

  Future<void> _broadcastPlayerLeft(
    String leftClientId,
    Player leftPlayer,
  ) async {
    try {
      // Create a message to notify all clients about the player leaving
      final playerLeftMessage = Message(
        type: MessageType.gameLobbyData,
        payload: {
          'playerLeft': {
            'playerId': leftClientId,
            'player': leftPlayer.toJson(),
          },
        },
        senderId: 'server',
        timestamp: DateTime.now(),
      );

      // Send to all remaining clients
      for (final clientId in _connectedClients.keys) {
        try {
          await sendToClient(clientId, playerLeftMessage);
        } catch (e) {
          print('Error sending player left message to client $clientId: $e');
        }
      }

      print(
        'Player left message broadcasted to ${_connectedClients.length} remaining clients',
      );
    } catch (e) {
      print('Error broadcasting player left message: $e');
    }
  }

  Map<String, Player> get players => Map.unmodifiable(_players);

  bool get hasClients => _connectedClients.isNotEmpty;

  String get serverAddress => _server?.address.address ?? 'Not started';

  int get serverPort => _server?.port ?? 0;

  Future<void> _updateDiscoveryInfo() async {
    if (_server != null) {
      try {
        // Stop current advertising
        await _discoveryService.stopAdvertising();

        // Start advertising again with updated info
        await _discoveryService.startAdvertising(
          serverName: _serverName,
          ipAddress: _server!.address.address,
          port: _server!.port,
          hostName: _hostName,
          playerCount: _players.length,
          maxPlayers: 8,
        );

        print(
          'Server discovery info restarted: $_serverName on ${_server!.address.address}:${_server!.port} with ${_players.length} players',
        );
      } catch (e) {
        print('Error updating discovery info: $e');
      }
    } else {
      print('Server stopped, not able to update discovery info');
    }
  }
}

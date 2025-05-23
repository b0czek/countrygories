import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:countrygories/models/message.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/models/game.dart';
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

  Stream<Message> get onMessage => _messageController.stream;
  Stream<Player> get onPlayerConnected => _playerConnectedController.stream;
  Stream<String> get onPlayerDisconnected =>
      _playerDisconnectedController.stream;

  ServerService({required this.port});

  Future<void> startServer() async {
    if (_server != null) return;

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print('Server started on ${_server!.address.address}:${_server!.port}');

      _server!.listen(_handleClient);
      _startConnectionMonitoring();
    } catch (e) {
      print('Error starting server: $e');
      rethrow;
    }
  }

  Future<void> stopServer() async {
    if (_server == null) return;

    _stopConnectionMonitoring();

    for (final client in _connectedClients.values) {
      client.close();
    }

    await _server!.close();
    _server = null;
    _connectedClients.clear();
    _players.clear();
    print('Server stopped');
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

  void _handleMessage(String clientId, List<int> data) {
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

        sendToClient(clientId, confirmationMessage);
      } else if (message.type == MessageType.leaveGame) {
        _disconnectClient(clientId);
      } else if (message.type == MessageType.ping) {
        // Respond to ping with a pong
        _respondToPing(clientId);
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

  void _disconnectClient(String clientId) {
    final client = _connectedClients.remove(clientId);
    final player = _players.remove(clientId);
    _lastClientPing.remove(clientId);
    _socketInUse.remove(clientId);

    if (client != null) {
      client.close();
    }

    if (player != null) {
      _playerDisconnectedController.add(player.id);
    }
  }

  void _startConnectionMonitoring() {
    _stopConnectionMonitoring();

    _connectionMonitorTimer = Timer.periodic(
      _connectionMonitorInterval,
      (_) => _checkClientConnections(),
    );
  }

  void _stopConnectionMonitoring() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = null;
  }

  void _checkClientConnections() {
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
      _disconnectClient(clientId);
    }
  }

  Future<void> broadcastMessage(Message message) async {
    final messageJson = json.encode(message.toJson());
    final data = utf8.encode(messageJson);

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
        await client.flush().catchError((error) {
          print('Error flushing data to client $clientId: $error');
          _disconnectClient(clientId);
          throw error;
        });

        print('Message sent to client $clientId');
      } catch (e) {
        print('Error sending message to client $clientId: $e');
        _disconnectClient(clientId);
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

  Map<String, Player> get players => Map.unmodifiable(_players);

  bool get hasClients => _connectedClients.isNotEmpty;

  String get serverAddress => _server?.address.address ?? 'Not started';

  int get serverPort => _server?.port ?? 0;
}

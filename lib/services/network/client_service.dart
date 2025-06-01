import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:countrygories/models/message.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/models/game.dart';

class ClientService {
  final String serverIp;
  final int serverPort;
  Socket? _socket;
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<void> _connectedController =
      StreamController<void>.broadcast();
  final StreamController<void> _disconnectedController =
      StreamController<void>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _joinAcceptedController =
      StreamController<bool>.broadcast();
  final StreamController<Game> _gameLobbyDataController =
      StreamController<Game>.broadcast(); // New controller for game data

  Stream<Message> get onMessage => _messageController.stream;
  Stream<void> get onConnected => _connectedController.stream;
  Stream<void> get onDisconnected => _disconnectedController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<bool> get onJoinAccepted => _joinAcceptedController.stream;
  Stream<Game> get onGameLobbyData =>
      _gameLobbyDataController.stream; // New stream

  // Keepalive related properties
  Timer? _keepAliveTimer;
  final Duration _keepAlivePeriod = const Duration(seconds: 5);
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  DateTime? _lastPongReceived;

  ClientService({required this.serverIp, required this.serverPort});

  bool _joinAccepted = false;

  Future<void> connectToServer() async {
    if (_socket != null) return;

    try {
      _socket = await Socket.connect(serverIp, serverPort);
      print('Connected to server: $serverIp:$serverPort');

      _socket!.listen(
        _handleMessage,
        onError: (error) {
          print('Error from server: $error');
          _connectionStatusController.add(false);
          _errorController.add(error.toString());
          disconnectFromServer();
        },
        onDone: () {
          print('Disconnected from server');
          _connectionStatusController.add(false);
          _disconnectedController.add(null);
          _socket = null;
        },
      );

      _connectedController.add(null);
      _connectionStatusController.add(true);
      _startKeepAlive();
    } catch (e) {
      print('Error connecting to server: $e');
      _connectionStatusController.add(false);
      _errorController.add(e.toString());
      rethrow;
    }
  }

  Future<void> disconnectFromServer() async {
    if (_socket == null) return;

    _stopKeepAlive();
    await _socket!.close();
    _socket = null;
  }

  void _handleMessage(List<int> data) {
    try {
      final messageJson = utf8.decode(data);
      print('Raw message from server: $messageJson');

      final message = Message.fromJson(json.decode(messageJson));

      print('Message from server: ${message.type}');

      if (message.type == MessageType.joinGame &&
          message.payload.containsKey('status') &&
          message.payload['status'] == 'accepted') {
        print('Join game accepted by server!');
        _joinAccepted = true;
        _joinAcceptedController.add(true);
      } else if (message.type == MessageType.gameLobbyData &&
          message.payload.containsKey('game')) {
        print('Game lobby data received from server!');
        try {
          final gameData = Game.fromJson(message.payload['game']);
          _gameLobbyDataController.add(gameData);
        } catch (e) {
          print('Error parsing game data: $e');
        }
      } else if (message.type == MessageType.pong) {
        _lastPongReceived = DateTime.now();
        print('Received pong from server');
      } else if (message.type == MessageType.hostSessionTerminated) {
        print('Host session terminated by server');
        // Server is shutting down, we'll be disconnected
        _connectionStatusController.add(false);
      }

      _messageController.add(message);
    } catch (e) {
      print('Error parsing message from server: $e');
    }
  }

  // Start sending keepalive signals to the server
  void _startKeepAlive() {
    _stopKeepAlive();
    _lastPongReceived = DateTime.now();

    _keepAliveTimer = Timer.periodic(_keepAlivePeriod, (_) {
      if (_socket != null) {
        _sendPingToServer();
        _checkServerConnection();
      } else {
        _stopKeepAlive();
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  Future<void> _sendPingToServer() async {
    try {
      final pingMessage = Message(
        type: MessageType.ping,
        payload: {'timestamp': DateTime.now().toIso8601String()},
        senderId: 'client',
        timestamp: DateTime.now(),
      );

      await sendMessage(pingMessage);
    } catch (e) {
      print('Error sending ping to server: $e');
    }
  }

  void _checkServerConnection() {
    if (_lastPongReceived == null) return;

    final timeSinceLastPong = DateTime.now().difference(_lastPongReceived!);
    // If we haven't received a pong in 15 seconds, consider the connection dead
    if (timeSinceLastPong > const Duration(seconds: 15)) {
      print(
        'Server connection timed out - no pong received in ${timeSinceLastPong.inSeconds} seconds',
      );
      _connectionStatusController.add(false);
    } else {
      _connectionStatusController.add(true);
    }
  }

  Future<void> sendMessage(Message message) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final messageJson = json.encode(message.toJson());
    final data = utf8.encode(messageJson);

    _socket!.add(data);
    await _socket!.flush();
  }

  Future<void> joinGame(Player player) async {
    final message = Message(
      type: MessageType.joinGame,
      payload: {'player': player.toJson()},
      senderId: player.id,
      timestamp: DateTime.now(),
    );

    await sendMessage(message);
    print('Join game message sent to server');
  }

  Future<void> leaveGame(String playerId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final message = Message(
      type: MessageType.leaveGame,
      payload: {},
      senderId: playerId,
      timestamp: DateTime.now(),
    );

    await sendMessage(message);
    print('Leave game message sent to server');
  }

  Future<bool> waitForJoinAccepted({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_joinAccepted) {
      print('Join already accepted, returning immediately');
      return true;
    }

    final completer = Completer<bool>();

    final subscription = onJoinAccepted.listen((accepted) {
      print('Join accepted event received: $accepted');
      if (!completer.isCompleted) {
        print('Completing completer with: $accepted');
        completer.complete(accepted);
      }
    });

    // Set timeout
    final timer = Timer(timeout, () {
      print('Timeout waiting for join acceptance');
      if (!completer.isCompleted) {
        print('Completing completer with: false (timeout)');
        completer.complete(false);
      }
    });

    // Cancel subscription and timer
    completer.future.then((result) {
      print('Completer resolved with: $result');
      subscription.cancel();
      timer.cancel();
      return result;
    });

    return completer.future;
  }

  bool get isConnected => _socket != null;
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveredServer {
  final String name;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;
  final String hostName;
  final int playerCount;
  final int maxPlayers;

  DiscoveredServer({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
    required this.hostName,
    required this.playerCount,
    required this.maxPlayers,
  });

  factory DiscoveredServer.fromJson(Map<String, dynamic> json) {
    return DiscoveredServer(
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      lastSeen: DateTime.now(),
      hostName: json['hostName'] as String? ?? 'Unknown Host',
      playerCount: json['playerCount'] as int? ?? 0,
      maxPlayers: json['maxPlayers'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'hostName': hostName,
      'playerCount': playerCount,
      'maxPlayers': maxPlayers,
    };
  }

  DiscoveredServer copyWith({DateTime? lastSeen}) {
    return DiscoveredServer(
      name: name,
      ipAddress: ipAddress,
      port: port,
      lastSeen: lastSeen ?? this.lastSeen,
      hostName: hostName,
      playerCount: playerCount,
      maxPlayers: maxPlayers,
    );
  }

  String get uniqueId => '$ipAddress:$port';
}

class ServerDiscoveryService {
  static const int _discoveryPort = 8081;
  static const Duration _advertisementInterval = Duration(milliseconds: 500);
  static const Duration _serverLifetime = Duration(seconds: 5);

  RawDatagramSocket? _advertisementSocket;
  RawDatagramSocket? _discoverySocket;
  Timer? _advertisementTimer;
  Timer? _cleanupTimer;

  final Map<String, DiscoveredServer> _discoveredServers = {};
  final StreamController<List<DiscoveredServer>> _serversController =
      StreamController<List<DiscoveredServer>>.broadcast();

  Stream<List<DiscoveredServer>> get discoveredServers =>
      _serversController.stream;
  List<DiscoveredServer> get currentServers =>
      _discoveredServers.values.toList();

  // Server Advertisement (for hosts)
  Future<void> startAdvertising({
    required String serverName,
    required String ipAddress,
    required int port,
    required String hostName,
    int playerCount = 0,
    int maxPlayers = 8,
  }) async {
    if (_advertisementSocket != null) return;

    try {
      _advertisementSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0, // Use any available port for sending
      );

      _advertisementSocket!.broadcastEnabled = true;

      final serverInfo = {
        'name': serverName,
        'ipAddress': ipAddress,
        'port': port,
        'hostName': hostName,
        'playerCount': playerCount,
        'maxPlayers': maxPlayers,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      _advertisementTimer = Timer.periodic(_advertisementInterval, (_) {
        _sendAdvertisement(serverInfo);
      });

      print('Started advertising server: $serverName on $ipAddress:$port');
    } catch (e) {
      print('Error starting server advertisement: $e');
      rethrow;
    }
  }

  void _sendAdvertisement(Map<String, dynamic> serverInfo) {
    try {
      // Update timestamp for each advertisement
      serverInfo['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      final data = utf8.encode(json.encode(serverInfo));
      final broadcastAddress = InternetAddress('255.255.255.255');

      _advertisementSocket?.send(data, broadcastAddress, _discoveryPort);
    } catch (e) {
      print('Error sending advertisement: $e');
    }
  }

  Future<void> stopAdvertising() async {
    _advertisementTimer?.cancel();
    _advertisementTimer = null;

    _advertisementSocket?.close();
    _advertisementSocket = null;

    print('Stopped advertising server');
  }

  // Server Discovery (for clients)
  Future<void> startDiscovery() async {
    if (_discoverySocket != null) return;

    try {
      _discoverySocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _discoveryPort,
      );

      _discoverySocket!.listen(_handleDiscoveryMessage);

      // Start cleanup timer to remove old servers
      _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _cleanupOldServers();
      });

      print('Started server discovery on port $_discoveryPort');
    } catch (e) {
      print('Error starting server discovery: $e');
      rethrow;
    }
  }

  void _handleDiscoveryMessage(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _discoverySocket!.receive();
      if (datagram != null) {
        try {
          final message = utf8.decode(datagram.data);
          final serverInfo = json.decode(message) as Map<String, dynamic>;

          final server = DiscoveredServer.fromJson(serverInfo);
          final uniqueId = server.uniqueId;

          // Update or add server
          _discoveredServers[uniqueId] = server;

          // Notify listeners
          _serversController.add(_discoveredServers.values.toList());

          print(
            'Discovered server: ${server.name} at ${server.ipAddress}:${server.port}',
          );
        } catch (e) {
          print('Error parsing discovery message: $e');
        }
      }
    }
  }

  void _cleanupOldServers() {
    final now = DateTime.now();
    final serversToRemove = <String>[];

    for (final entry in _discoveredServers.entries) {
      final server = entry.value;
      if (now.difference(server.lastSeen) > _serverLifetime) {
        serversToRemove.add(entry.key);
      }
    }

    if (serversToRemove.isNotEmpty) {
      for (final serverId in serversToRemove) {
        _discoveredServers.remove(serverId);
        print('Removed expired server: $serverId');
      }

      // Notify listeners of updated server list
      _serversController.add(_discoveredServers.values.toList());
    }
  }

  Future<void> stopDiscovery() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;

    _discoverySocket?.close();
    _discoverySocket = null;

    _discoveredServers.clear();
    _serversController.add([]);

    print('Stopped server discovery');
  }

  void dispose() {
    stopAdvertising();
    stopDiscovery();
    _serversController.close();
  }
}

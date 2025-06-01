import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/player.dart';
import 'package:countrygories/services/network/client_service.dart';
import 'package:countrygories/services/network/server_service.dart';
import 'package:countrygories/services/network/server_discovery_service.dart';
import 'package:uuid/uuid.dart';
import 'package:network_info_plus/network_info_plus.dart';

final localIpProvider = FutureProvider<String>((ref) async {
  final info = NetworkInfo();
  final wifiIP = await info.getWifiIP();
  return wifiIP ?? "N/A";
});

final isHostProvider = StateProvider<bool>((ref) => false);

final serverProvider = Provider<ServerService?>((ref) {
  final isHost = ref.watch(isHostProvider);
  if (!isHost) return null;

  return ServerService(port: 8080);
});

final serverActiveProvider = StateProvider<bool>((ref) => false);

final clientServerIpProvider = StateProvider<String>((ref) => '');
final clientServerPortProvider = StateProvider<int>((ref) => 8080);

// Server discovery provider
final serverDiscoveryProvider = Provider<ServerDiscoveryService>((ref) {
  return ServerDiscoveryService();
});

// Discovered servers provider
final discoveredServersProvider = StreamProvider<List<DiscoveredServer>>((ref) {
  final discoveryService = ref.watch(serverDiscoveryProvider);
  return discoveryService.discoveredServers;
});

final clientProvider = Provider<ClientService?>((ref) {
  final isHost = ref.watch(isHostProvider);
  if (isHost) return null;

  final serverIp = ref.watch(clientServerIpProvider);
  final serverPort = ref.watch(clientServerPortProvider);

  if (serverIp.isEmpty) return null;

  return ClientService(serverIp: serverIp, serverPort: serverPort);
});

final currentPlayerProvider = StateProvider<Player?>((ref) => null);

final connectedPlayersProvider =
    StateNotifierProvider<ConnectedPlayersNotifier, List<Player>>((ref) {
      return ConnectedPlayersNotifier();
    });

class ConnectedPlayersNotifier extends StateNotifier<List<Player>> {
  ConnectedPlayersNotifier() : super([]);

  void setPlayers(List<Player> players) {
    state = players;
  }

  void addPlayer(Player player) {
    state = [...state, player];
  }

  void removePlayer(String playerId) {
    state = state.where((p) => p.id != playerId).toList();
  }

  void updatePlayer(Player player) {
    state = [
      for (final p in state)
        if (p.id == player.id) player else p,
    ];
  }

  void clear() {
    state = [];
  }
}

final localPlayerProvider = Provider<Player>((ref) {
  final playerId = const Uuid().v4();
  return Player(
    id: playerId,
    name: 'Player_$playerId',
    ipAddress: '127.0.0.1',
    port: 0,
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/providers/network_providers.dart';

class ServerDiscoveryWidget extends ConsumerStatefulWidget {
  final Function(String ip, int port) onServerSelected;
  final bool autoStart;

  const ServerDiscoveryWidget({
    super.key,
    required this.onServerSelected,
    this.autoStart = true,
  });

  @override
  ConsumerState<ServerDiscoveryWidget> createState() =>
      _ServerDiscoveryWidgetState();
}

class _ServerDiscoveryWidgetState extends ConsumerState<ServerDiscoveryWidget> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _startDiscovery();
    }
  }

  @override
  void dispose() {
    _stopDiscovery();
    super.dispose();
  }

  // Expose methods for parent control
  void startDiscovery() => _startDiscovery();
  void stopDiscovery() => _stopDiscovery();

  Future<void> _startDiscovery() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final discoveryService = ref.read(serverDiscoveryProvider);
      await discoveryService.startDiscovery();
    } catch (e) {
      print('Error starting discovery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting server discovery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopDiscovery() async {
    if (!_isScanning) return;

    try {
      final discoveryService = ref.read(serverDiscoveryProvider);
      await discoveryService.stopDiscovery();
    } catch (e) {
      print('Error stopping discovery: $e');
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _refreshServers() async {
    await _stopDiscovery();
    await Future.delayed(const Duration(milliseconds: 500));
    await _startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final discoveredServersAsync = ref.watch(discoveredServersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dostępne serwery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (_isScanning)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _refreshServers,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Odśwież listę serwerów',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: discoveredServersAsync.when(
                data: (servers) {
                  if (servers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Nie znaleziono serwerów',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sprawdź czy jesteś w tej samej sieci',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final timeSinceLastSeen =
                          DateTime.now().difference(server.lastSeen).inSeconds;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                timeSinceLastSeen < 3
                                    ? Colors.green
                                    : Colors.orange,
                            child: Text(
                              server.hostName.isNotEmpty
                                  ? server.hostName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            server.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Host: ${server.hostName}'),
                              Text('${server.ipAddress}:${server.port}'),
                              Text(
                                'Gracze: ${server.playerCount}/${server.maxPlayers}',
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                timeSinceLastSeen < 3
                                    ? Icons.signal_cellular_4_bar
                                    : Icons.signal_cellular_alt,
                                color:
                                    timeSinceLastSeen < 3
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                              Text(
                                '${timeSinceLastSeen}s',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.onServerSelected(
                              server.ipAddress,
                              server.port,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading:
                    () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Wyszukiwanie serwerów...'),
                        ],
                      ),
                    ),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Błąd wyszukiwania serwerów',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            error.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/game_lobby_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';
import 'package:countrygories/widgets/network/server_discovery_widget.dart';

class JoinGameScreen extends ConsumerStatefulWidget {
  const JoinGameScreen({super.key});

  @override
  ConsumerState<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends ConsumerState<JoinGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  final _serverIpController = TextEditingController();
  final _serverPortController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    _playerNameController.text = 'Gracz';
    _serverIpController.text = '192.168.1.';
    _serverPortController.text = '8080';
  }

  void _onServerSelected(String ip, int port) {
    setState(() {
      _serverIpController.text = ip;
      _serverPortController.text = port.toString();
      _showManualInput =
          true; // Show manual input so user can see the selected values
    });
  }

  Future<void> _stopServerDiscovery() async {
    try {
      final discoveryService = ref.read(serverDiscoveryProvider);
      await discoveryService.stopDiscovery();
      print('Server discovery stopped');
    } catch (e) {
      print('Error stopping server discovery: $e');
    }
  }

  @override
  void dispose() {
    _stopServerDiscovery();
    _playerNameController.dispose();
    _serverIpController.dispose();
    _serverPortController.dispose();
    super.dispose();
  }

  Future<void> _joinGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Set the client connection details in state providers
      ref.read(clientServerIpProvider.notifier).state =
          _serverIpController.text;
      ref.read(clientServerPortProvider.notifier).state = int.parse(
        _serverPortController.text,
      );

      final clientService = ref.read(clientProvider);
      if (clientService == null) {
        throw Exception('Failed to create client service');
      }

      clientService.onMessage.listen((message) {
        if (message.type == MessageType.joinGame &&
            message.payload.containsKey('status') &&
            message.payload['status'] == 'accepted') {
          print('Join acceptance received in message listener');
        }
      });

      clientService.onGameLobbyData.listen((game) {
        print('Game lobby data received: ${game.id}');
        ref.read(gameProvider.notifier).updateGameState(game);
        ref.read(isHostProvider.notifier).state = false;

        // Stop server discovery when successfully joining a game
        _stopServerDiscovery();

        // Navigate to the lobby screen once we have the game data
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GameLobbyScreen()),
          );
        }
      });

      await clientService.connectToServer();

      final player = ref
          .read(localPlayerProvider)
          .copyWith(
            name: _playerNameController.text,
            ipAddress: _serverIpController.text,
            port: int.parse(_serverPortController.text),
            isConnected: true,
          );
      ref.read(currentPlayerProvider.notifier).state = player;

      await clientService.joinGame(player);

      print('Waiting for join acceptance...');
      final joinAccepted = await clientService.waitForJoinAccepted();
      print('Join acceptance result: $joinAccepted');

      if (!joinAccepted) {
        _stopServerDiscovery();
        setState(() {
          _errorMessage =
              'Nie otrzymano potwierdzenia dołączenia do gry. Spróbuj ponownie.';
          _isLoading = false;
        });
      }
    } catch (e) {
      _stopServerDiscovery();
      setState(() {
        _errorMessage = 'Error joining game: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dołącz do gry')),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dane gracza',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Twoja nazwa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę podać nazwę';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Dane serwera',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Server discovery section
                if (!_showManualInput) ...[
                  ServerDiscoveryWidget(onServerSelected: _onServerSelected),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        _stopServerDiscovery(); // Stop discovery when switching to manual
                        setState(() {
                          _showManualInput = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Wprowadź ręcznie IP i port'),
                    ),
                  ),
                ] else ...[
                  // Manual input section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ręczne wprowadzanie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showManualInput = false;
                          });
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Wyszukaj serwery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _serverIpController,
                    decoration: const InputDecoration(
                      labelText: 'Adres IP serwera',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać adres IP';
                      }
                      final ipRegex = RegExp(
                        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
                      );
                      if (!ipRegex.hasMatch(value)) {
                        return 'Nieprawidłowy format adresu IP';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serverPortController,
                    decoration: const InputDecoration(
                      labelText: 'Port serwera',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Proszę podać port';
                      }
                      final port = int.tryParse(value);
                      if (port == null || port <= 0 || port > 65535) {
                        return 'Port musi być liczbą z zakresu 1-65535';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Center(
                  child:
                      _isLoading
                          ? Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'Łączenie z serwerem...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      try {
                                        final clientService = ref.read(
                                          clientProvider,
                                        );

                                        if (clientService != null &&
                                            clientService.isConnected) {
                                          clientService.disconnectFromServer();
                                        }

                                        // Stop discovery when canceling connection
                                        _stopServerDiscovery();
                                      } catch (e) {
                                        print('Error disconnecting: $e');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Anuluj'),
                                  ),
                                ],
                              ),
                            ],
                          )
                          : CustomButton(
                            text: 'Dołącz do gry',
                            onPressed: _joinGame,
                            width: 250,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

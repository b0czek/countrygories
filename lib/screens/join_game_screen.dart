import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/game_lobby_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';

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

  @override
  void initState() {
    super.initState();
    _playerNameController.text = 'Gracz';
    _serverIpController.text = '192.168.1.';
    _serverPortController.text = '8080';
  }

  @override
  void dispose() {
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
      final clientService = ref.read(
        clientProvider({
          'ip': _serverIpController.text,
          'port': int.parse(_serverPortController.text),
        }),
      );

      clientService.onMessage.listen((message) {
        print('Message received in listener: ${message.type}');

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
        setState(() {
          _errorMessage =
              'Nie otrzymano potwierdzenia dołączenia do gry. Spróbuj ponownie.';
          _isLoading = false;
        });
      }
    } catch (e) {
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
                                        clientProvider({
                                          'ip': _serverIpController.text,
                                          'port': int.parse(
                                            _serverPortController.text,
                                          ),
                                        }),
                                      );

                                      if (clientService.isConnected) {
                                        clientService.disconnectFromServer();
                                      }
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

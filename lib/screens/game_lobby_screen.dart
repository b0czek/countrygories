import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/game_play_screen.dart';
import 'package:countrygories/screens/home_screen.dart';
import 'package:countrygories/services/game/lobby_service.dart';
import 'package:countrygories/widgets/common/custom_button.dart';
import 'package:countrygories/widgets/game/player_list.dart';

class GameLobbyScreen extends ConsumerStatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  ConsumerState<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends ConsumerState<GameLobbyScreen> {
  LobbyService? _lobbyService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupLobbyService();
    });
  }

  void _setupLobbyService() {
    _lobbyService = LobbyService(ref, context);

    // Set up callbacks
    _lobbyService!.setGameStartedCallback(() {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GamePlayScreen()),
        );
      }
    });

    _lobbyService!.setHostSessionTerminatedCallback(() {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });

    // Setup network listeners
    _lobbyService!.setupNetworkListeners();
  }

  @override
  void dispose() {
    _lobbyService?.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    await _lobbyService?.leaveGame();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _toggleReady() {
    _lobbyService?.togglePlayerReady();
  }

  void _startGame() {
    if (_lobbyService == null) return;

    final validationError = _lobbyService!.validateGameStart();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor:
              validationError.contains('gotowi') ? Colors.orange : Colors.red,
        ),
      );
      return;
    }

    _lobbyService!.startGame();

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

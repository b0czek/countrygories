import 'dart:async';
import 'package:countrygories/models/message.dart';
import 'package:countrygories/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/screens/home_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  StreamSubscription? _clientMessageSubscription;

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
    _sendFinalScoreboard();
  }

  @override
  void dispose() {
    _clientMessageSubscription?.cancel();
    super.dispose();
  }

  void _setupNetworkListeners() {
    final isHost = ref.read(isHostProvider);

    if (!mounted) return;

    if (isHost) {
    } else {
      final clientService = ref.read(clientProvider);
      if (clientService != null) {
        _clientMessageSubscription = clientService.onMessage.listen((message) {
          if (message.type == MessageType.finalScoreboard) {
            final playersData = message.payload['players'];
            final players =
                playersData.map<Player>((p) => Player.fromJson(p)).toList();
            ref.read(gameProvider.notifier).syncPlayersFromServer(players);
          }
        });
      }
    }
  }

  void _sendFinalScoreboard() async {
    if (!mounted) return;

    final game = ref.read(gameProvider);
    if (game == null) return;
    final isHost = ref.read(isHostProvider);
    if (!isHost) return;

    // Delay to ensure all players have setup their listeners
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final serverService = ref.read(serverProvider);

    if (serverService != null) {
      final message = Message(
        type: MessageType.finalScoreboard,
        payload: {'players': game.players.map((p) => p.toJson()).toList()},
        senderId: game.host.id,
        timestamp: DateTime.now(),
      );

      await serverService.broadcastMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isHost = ref.watch(isHostProvider);

    if (game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final playerTotalScores = <String, int>{};
    for (final player in game.players) {
      int totalScore = 0;
      for (final score in player.scores.values) {
        totalScore += score;
      }
      playerTotalScores[player.id] = totalScore;
    }

    final sortedPlayers = List<Player>.from(game.players);
    sortedPlayers.sort(
      (a, b) => playerTotalScores[b.id]!.compareTo(playerTotalScores[a.id]!),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyniki końcowe'),
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
            children: [
              const Text(
                'Gratulacje!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Zwycięzca: ${sortedPlayers.first.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildResultsTable(
                  sortedPlayers,
                  playerTotalScores,
                  game.rounds.length,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Powrót do menu',
                onPressed: () {
                  if (isHost) {
                    final serverService = ref.read(serverProvider);
                    if (serverService != null) {
                      serverService.stopServer();
                    }
                    ref.read(serverActiveProvider.notifier).state = false;
                  } else {
                    final currentPlayer = ref.read(currentPlayerProvider);
                    if (currentPlayer != null) {
                      final clientService = ref.read(clientProvider);

                      if (clientService != null && clientService.isConnected) {
                        clientService.disconnectFromServer();
                      }
                    }
                  }

                  ref.read(isHostProvider.notifier).state = false;
                  ref.read(currentPlayerProvider.notifier).state = null;
                  ref.read(connectedPlayersProvider.notifier).clear();
                  ref.read(gameProvider.notifier).resetGame();

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable(
    List<Player> sortedPlayers,
    Map<String, int> playerTotalScores,
    int roundsCount,
  ) {
    return ListView.builder(
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        final player = sortedPlayers[index];
        final totalScore = playerTotalScores[player.id]!;
        final roundKeys = player.scores.keys.toList();

        return Card(
          elevation: index == 0 ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          color: index == 0 ? Colors.amber.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  index == 0
                      ? Colors.amber
                      : (index == 1 ? Colors.grey : Colors.brown),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              player.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                const Text(
                  'Rundy:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...roundKeys.map((roundId) {
                  final roundScore = player.scores[roundId] ?? 0;
                  return Text(
                    '$roundScore',
                    style: TextStyle(
                      color: roundScore > 0 ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ],
            ),

            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$totalScore pkt',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

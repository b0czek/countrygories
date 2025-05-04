import 'package:flutter/material.dart';
import 'package:countrygories/models/player.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;
  final String currentPlayerId;

  const PlayerList({
    super.key,
    required this.players,
    required this.currentPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isCurrentPlayer = player.id == currentPlayerId;

        return Card(
          elevation: isCurrentPlayer ? 4 : 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isCurrentPlayer ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              child: Text(player.name.substring(0, 1).toUpperCase()),
            ),
            title: Row(
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    fontWeight:
                        isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isCurrentPlayer)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      '(Ty)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              player.isHost
                  ? 'Host'
                  : (player.isReady ? 'Gotowy' : 'Nie gotowy'),
            ),
            trailing: Icon(
              player.isHost
                  ? Icons.star
                  : (player.isReady
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked),
              color:
                  player.isHost
                      ? Colors.amber
                      : (player.isReady ? Colors.green : Colors.grey),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:countrygories/models/game.dart';
import 'package:countrygories/models/player.dart';

class ResponsiveScoringTable extends StatelessWidget {
  final Game game;
  final GameRound round;
  final Map<String, Map<String, int>> scores;
  final bool isManualScoring;
  final bool isHost;
  final Function(String playerId, String category, int score)? onScoreChanged;

  const ResponsiveScoringTable({
    super.key,
    required this.game,
    required this.round,
    required this.scores,
    required this.isManualScoring,
    required this.isHost,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is wide enough, show optimized wide layout
        if (constraints.maxWidth > 800) {
          return _buildWideScreenLayout();
        }
        // For medium screens, show compact cards in grid
        else if (constraints.maxWidth > 600) {
          return _buildMediumScreenLayout();
        }
        // For narrow screens, show single column cards
        return _buildCardLayout();
      },
    );
  }

  Widget _buildWideScreenLayout() {
    // For wide screens, show a more compact horizontal layout
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row with categories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    'Gracz',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...game.categories.map(
                  (category) => Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Suma',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Player rows
          ...game.players.map((player) {
            final playerAnswers = round.answers[player.id] ?? {};
            final playerScores = scores[player.id] ?? {};
            final totalScore = playerScores.values
                .where((s) => s > 0)
                .fold(0, (sum, score) => sum + score);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...game.categories.map((category) {
                    final answer =
                        (playerAnswers[category] == null ||
                                playerAnswers[category]!.trim().isEmpty)
                            ? '-'
                            : playerAnswers[category]!;
                    final score = playerScores[category] ?? 0;

                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            answer,
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          if (isManualScoring && isHost)
                            SizedBox(
                              width: 80,
                              child: DropdownButton<int>(
                                value: score < 0 ? 0 : score,
                                isDense: true,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('0 pkt'),
                                  ),
                                  DropdownMenuItem(
                                    value: 5,
                                    child: Text('5 pkt'),
                                  ),
                                  DropdownMenuItem(
                                    value: 10,
                                    child: Text('10 pkt'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null && onScoreChanged != null) {
                                    onScoreChanged!(player.id, category, value);
                                  }
                                },
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    score == 10
                                        ? Colors.green.shade100
                                        : (score == 5
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${score < 0 ? "?" : score}',
                                style: TextStyle(
                                  color:
                                      score == 10
                                          ? Colors.green.shade700
                                          : (score == 5
                                              ? Colors.orange.shade700
                                              : Colors.red.shade700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(
                    width: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$totalScore',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMediumScreenLayout() {
    // For medium screens, show cards in a 2-column grid
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: game.players.length,
      itemBuilder: (context, index) {
        final player = game.players[index];
        return _buildPlayerCard(player, compact: true);
      },
    );
  }

  Widget _buildCardLayout() {
    return ListView.builder(
      itemCount: game.players.length,
      itemBuilder: (context, index) {
        final player = game.players[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPlayerCard(player),
        );
      },
    );
  }

  Widget _buildPlayerCard(Player player, {bool compact = false}) {
    final playerAnswers = round.answers[player.id] ?? {};
    final playerScores = scores[player.id] ?? {};
    final totalScore = playerScores.values
        .where((s) => s > 0)
        .fold(0, (sum, score) => sum + score);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    style: TextStyle(
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Suma: $totalScore pkt',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 12 : 16),
            ...game.categories.map((category) {
              final answer =
                  (playerAnswers[category] == null ||
                          playerAnswers[category]!.trim().isEmpty)
                      ? '-'
                      : playerAnswers[category]!;
              final score = playerScores[category] ?? 0;

              return Padding(
                padding: EdgeInsets.only(bottom: compact ? 8 : 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: compact ? 12 : 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        answer,
                        style: TextStyle(fontSize: compact ? 13 : 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child:
                          isManualScoring && isHost
                              ? DropdownButton<int>(
                                value: score < 0 ? 0 : score,
                                isDense: true,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('0 pkt'),
                                  ),
                                  DropdownMenuItem(
                                    value: 5,
                                    child: Text('5 pkt'),
                                  ),
                                  DropdownMenuItem(
                                    value: 10,
                                    child: Text('10 pkt'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null && onScoreChanged != null) {
                                    onScoreChanged!(player.id, category, value);
                                  }
                                },
                              )
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      score == 10
                                          ? Colors.green.shade100
                                          : (score == 5
                                              ? Colors.orange.shade100
                                              : Colors.red.shade100),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${score < 0 ? "?" : score} pkt',
                                  style: TextStyle(
                                    color:
                                        score == 10
                                            ? Colors.green.shade700
                                            : (score == 5
                                                ? Colors.orange.shade700
                                                : Colors.red.shade700),
                                    fontWeight: FontWeight.bold,
                                    fontSize: compact ? 10 : 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

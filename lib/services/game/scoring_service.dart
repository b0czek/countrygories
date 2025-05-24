import 'package:countrygories/models/game_settings.dart';
import 'package:countrygories/services/database/isar_database.dart';

class ScoringService {
  final IsarDatabaseService databaseService;
  final ScoringMode mode;

  ScoringService({required this.databaseService, required this.mode});

  Future<Map<String, Map<String, int>>> calculateRoundScores({
    required Map<String, Map<String, String>> allAnswers,
    required String letter,
  }) async {
    final result = <String, Map<String, int>>{};

    // Prepare a list of all answers for each category
    final categoryAnswers = <String, Map<String, List<String>>>{};

    for (final playerId in allAnswers.keys) {
      final playerAnswers = allAnswers[playerId]!;

      for (final category in playerAnswers.keys) {
        final answer = playerAnswers[category]!;

        categoryAnswers.putIfAbsent(category, () => {});
        categoryAnswers[category]!.putIfAbsent(answer, () => []);
        categoryAnswers[category]![answer]!.add(playerId);
      }
    }

    // Calculate points for each player
    for (final playerId in allAnswers.keys) {
      result[playerId] = {};
      final playerAnswers = allAnswers[playerId]!;

      for (final category in playerAnswers.keys) {
        final answer = playerAnswers[category]!;

        if (answer.isEmpty) {
          result[playerId]![category] = 0;
          continue;
        }

        // Check if the answer starts with the correct letter
        if (!answer.toUpperCase().startsWith(letter.toUpperCase())) {
          result[playerId]![category] = 0;
          continue;
        }

        //if (mode == ScoringMode.automatic) {
          // Check if the answer exists in the database
          final isValid = await databaseService.verifyAnswer(
            category,
            letter,
            answer,
          );

          if (!isValid) {
            result[playerId]![category] = 0;
            continue;
          }

          // Check if the answer is unique
          final isUnique = categoryAnswers[category]![answer]!.length == 1;

          result[playerId]![category] = isUnique ? 10 : 5;
        //} else {
          // In manual mode, points will be assigned later
        //  result[playerId]![category] = -1;
       // }
      }
    }

    return result;
  }
}

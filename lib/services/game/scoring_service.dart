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
      result[playerId] = {};
      final playerAnswers = allAnswers[playerId]!;

      for (final category in playerAnswers.keys) {
        final answer = playerAnswers[category]!;

        if (answer.isEmpty) {
          result[playerId]![category] = 0;
          continue;
        }

        if (!answer.toUpperCase().startsWith(letter.toUpperCase())) {
          result[playerId]![category] = 0;
          continue;
        }

        final answerResult = await databaseService.verifyAnswer(
          category,
          letter,
          answer,
        );


        final isValid = answerResult.item1;
        final resultAnswer = answerResult.item2;

        if (!isValid) {
          print("LOOL NOT VALID!");
          result[playerId]![category] = 0;
          continue;
        }

        categoryAnswers.putIfAbsent(category, () => {});
        categoryAnswers[category]!.putIfAbsent(resultAnswer, () => []);
        categoryAnswers[category]![resultAnswer]!.add(playerId);
      }
    }

    for (var cat in categoryAnswers.entries) {
      final category = cat.key;
      final answerMap = cat.value;
      for (var ans in answerMap.entries) {
        final answer = ans.key;
        final playerList = ans.value;
        final isUnique = playerList.length == 1;
        for (var playerId in playerList) {
          result[playerId]![category] = isUnique ? 10 : 5;
        }
      }
    }

    return result;
  }
}

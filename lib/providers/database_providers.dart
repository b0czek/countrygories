import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/services/database/isar_database.dart';
import 'package:countrygories/models/category.dart';
import 'package:countrygories/models/answer_entry.dart';

final databaseServiceProvider = Provider<IsarDatabaseService>((ref) {
  return IsarDatabaseService();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  await databaseService.initializeDefaultData();
  return databaseService.getAllCategories();
});

final answerVerificationProvider =
    Provider.family<Future<bool>, Map<String, String>>((ref, params) {
      final databaseService = ref.watch(databaseServiceProvider);
      return databaseService.verifyAnswer(
        params['category']!,
        params['letter']!,
        params['answer']!,
      );
    });

final customAnswersProvider = FutureProvider<List<AnswerEntry>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.getUserAddedAnswers();
});

final deleteAnswerProvider = Provider.family<Future<void>, int>((
  ref,
  id,
) async {
  final databaseService = ref.watch(databaseServiceProvider);
  await databaseService.deleteAnswer(id);
  // Refresh the custom answers list
  ref.invalidate(customAnswersProvider);
});

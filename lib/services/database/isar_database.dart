import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:countrygories/models/category.dart';
import 'package:countrygories/models/answer_entry.dart';
import 'package:countrygories/config/app_config.dart';

class IsarDatabaseService {
  late Future<Isar> db;

  IsarDatabaseService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([
      CategorySchema,
      AnswerEntrySchema,
    ], directory: dir.path);
  }

  Future<void> initializeDefaultData() async {
    final isar = await db;

    final categoriesCount = await isar.categorys.count();
    if (categoriesCount == 0) {
      final categories =
          AppConfig.defaultCategories.map((name) {
            final category =
                Category()
                  ..name = name
                  ..isCustom = false;
            return category;
          }).toList();

      await isar.writeTxn(() async {
        await isar.categorys.putAll(categories);
      });

      await addSampleAnswers(isar);
    }
  }

  Future<void> addSampleAnswers(Isar isar) async {
    final sampleData = {
      'Państwo': {
        'A': ['Argentyna', 'Australia', 'Austria'],
        'B': ['Belgia', 'Brazylia', 'Bułgaria'],
        'P': ['Polska', 'Portugalia', 'Peru'],
      },
      'Miasto': {
        'A': ['Ateny', 'Amsterdam', 'Atlanta'],
        'B': ['Berlin', 'Barcelona', 'Budapeszt'],
        'W': ['Warszawa', 'Wiedeń', 'Wrocław'],
      },
      // TODO: Properly add data for built in dictionary
    };

    final entries = <AnswerEntry>[];

    sampleData.forEach((category, letterMap) {
      letterMap.forEach((letter, answers) {
        for (final answer in answers) {
          final entry =
              AnswerEntry()
                ..categoryName = category
                ..letter = letter
                ..answer = answer
                ..builtIn = true;

          entries.add(entry);
        }
      });
    });

    await isar.writeTxn(() async {
      await isar.answerEntrys.putAll(entries);
    });
  }

  Future<List<Category>> getAllCategories() async {
    final isar = await db;
    return await isar.categorys.where().findAll();
  }

  Future<void> addCategory(
    String name, {
    bool isCustom = true,
    String? createdBy,
  }) async {
    final isar = await db;
    final category =
        Category()
          ..name = name
          ..isCustom = isCustom
          ..createdBy = createdBy;

    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  Future<void> addAnswer(
    String categoryName,
    String letter,
    String answer,
    bool builtIn,
  ) async {
    final isar = await db;
    final entry =
        AnswerEntry()
          ..categoryName = categoryName
          ..letter = letter.toUpperCase()
          ..answer = answer
          ..addedAt = DateTime.now()
          ..builtIn = builtIn;

    await isar.writeTxn(() async {
      await isar.answerEntrys.put(entry);
    });
  }

  Future<List<String>> getAnswersForCategoryAndLetter(
    String categoryName,
    String letter,
  ) async {
    final isar = await db;
    final entries =
        await isar.answerEntrys
            .filter()
            .categoryNameEqualTo(categoryName)
            .letterEqualTo(letter.toUpperCase())
            .findAll();

    return entries.map((e) => e.answer).toList();
  }

  Future<bool> verifyAnswer(
    String categoryName,
    String letter,
    String answer,
  ) async {
    final isar = await db;
    final count =
        await isar.answerEntrys
            .filter()
            .categoryNameEqualTo(categoryName)
            .letterEqualTo(letter.toUpperCase())
            .answerEqualTo(answer)
            .count();

    return count > 0;
  }
}

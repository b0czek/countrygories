import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:countrygories/models/category.dart';
import 'package:countrygories/models/answer_entry.dart';
import 'package:countrygories/config/app_config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:tuple/tuple.dart';


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

      //await addSampleAnswers(isar);
    }
    await updateDefaultAnswersFromJsonIfNeeded();
  }

  Future<String> calculateFileHash(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  Future<void> updateDefaultAnswersFromJsonIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final isar = await db;

    final assetFiles = {
      'countries.json': 'Państwo',
      'cities.json': 'Miasto',
      'animals.json': 'Zwierzę',
      'plants.json': 'Roślina',
      'names.json': 'Imię',
      'jobs.json': 'Zawód',
    };

    final Set<String> shouldUpdate = {};
    final updatedEntries = <AnswerEntry>[];

    for (final entry in assetFiles.entries) {
      final assetPath = 'assets/default_categories/${entry.key}';
      final categoryName = entry.value;

      final jsonString = await rootBundle.loadString(assetPath);
      final hash = sha256.convert(utf8.encode(jsonString)).toString();

      if (prefs.getString('hash_${entry.key}') != hash) {
        shouldUpdate.add(categoryName);
        prefs.setString('hash_${entry.key}', hash);

        final Map<String, dynamic> content = jsonDecode(jsonString);

        content.forEach((letter, answersList) {
          for (final answer in (answersList as List)) {
            updatedEntries.add(AnswerEntry()
              ..categoryName = categoryName
              ..letter = letter.toUpperCase()
              ..answer = answer
              ..builtIn = true);
          }
        });
      }
    }

    if (shouldUpdate.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final category in shouldUpdate) {
          await isar.answerEntrys.filter().categoryNameEqualTo(category).builtInEqualTo(true).deleteAll();
        }
        await isar.answerEntrys.putAll(updatedEntries);
      });
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

  Future<Tuple2<bool, String>> verifyAnswer(
    String categoryName,
    String letter,
    String answer,
  ) async {
    if (answer.isEmpty || answer[0] != letter) {
      return Tuple2(false, answer.toLowerCase());
    }
    final isar = await db;
    final possibleAnswersList = 
        await isar.answerEntrys
            .filter()
            .categoryNameEqualTo(categoryName)
            .letterEqualTo(letter)
            .findAll()
            .then((entries) => entries.map((entry) => entry.answer).toList());
    if (possibleAnswersList.contains(answer.toLowerCase())) {
      return Tuple2(true, answer.toLowerCase());
    }
    final matched = normalizePolishLetters(answer)
                      .toLowerCase()
                      .bestMatch(possibleAnswersList.map((answer) => normalizePolishLetters(answer)).toList())
                      .ratings
                      .reduce((a, b) => (a.rating ?? 0.0) > (b.rating ?? 0.0) ? a : b);
    print("Best match: ${matched.target} with rating: ${matched.rating}");
    bool isFoundAnswer = (matched.rating ?? 0.0) >= AppConfig.minAnswerLevensteinMatchValue;
    String foundAnswer = answer;
    if (isFoundAnswer) {
      foundAnswer = matched.target!;
    }
    return Tuple2(isFoundAnswer, foundAnswer.toLowerCase());
  }

  String normalizePolishLetters(String word) {
    const Map<String, String> polishToAscii = {
      'ą': 'a',
      'ć': 'c',
      'ę': 'e',
      'ł': 'l',
      'ń': 'n',
      'ó': 'o',
      'ś': 's',
      'ź': 'z',
      'ż': 'z',
      'Ą': 'A',
      'Ć': 'C',
      'Ę': 'E',
      'Ł': 'L',
      'Ń': 'N',
      'Ó': 'O',
      'Ś': 'S',
      'Ź': 'Z',
      'Ż': 'Z',
    };

    return word.split('').map((char) {
      return polishToAscii[char] ?? char;
    }).join();
  }

  Future<List<AnswerEntry>> getUserAddedAnswers() async {
    final isar = await db;
    return isar.answerEntrys
        .filter()
        .builtInEqualTo(false)
        .sortByCategoryName()
        .thenByLetter()
        .findAll();
  }

  Future<void> deleteAnswer(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.answerEntrys.delete(id);
    });
  }

  Future<void> deleteCategory(String categoryName) async {
  final isar = await db;

  await isar.writeTxn(() async {
    await isar.answerEntrys
        .filter()
        .categoryNameEqualTo(categoryName)
        .deleteAll();

   
    final category = await isar.categorys
        .filter()
        .nameEqualTo(categoryName)
        .findFirst();

    if (category != null) {
      await isar.categorys.delete(category.id);
    }
  });
}

}

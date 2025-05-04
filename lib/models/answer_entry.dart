import 'package:isar/isar.dart';

part 'answer_entry.g.dart';

@collection
class AnswerEntry {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('letter')])
  late String categoryName;

  @Index(composite: [CompositeIndex('categoryName')])
  late String letter;

  late String answer;

  DateTime? addedAt;

  // whether the answer comes from the built-in dictionary
  late bool builtIn;

  @override
  String toString() => '$categoryName:$letter:$answer';
}

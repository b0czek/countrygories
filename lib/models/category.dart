import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  bool isCustom = false;
  String? createdBy;

  @override
  String toString() => name;
}

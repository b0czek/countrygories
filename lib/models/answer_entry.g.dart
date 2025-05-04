// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnswerEntryCollection on Isar {
  IsarCollection<AnswerEntry> get answerEntrys => this.collection();
}

const AnswerEntrySchema = CollectionSchema(
  name: r'AnswerEntry',
  id: -8198128471807833350,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'answer': PropertySchema(
      id: 1,
      name: r'answer',
      type: IsarType.string,
    ),
    r'builtIn': PropertySchema(
      id: 2,
      name: r'builtIn',
      type: IsarType.bool,
    ),
    r'categoryName': PropertySchema(
      id: 3,
      name: r'categoryName',
      type: IsarType.string,
    ),
    r'letter': PropertySchema(
      id: 4,
      name: r'letter',
      type: IsarType.string,
    )
  },
  estimateSize: _answerEntryEstimateSize,
  serialize: _answerEntrySerialize,
  deserialize: _answerEntryDeserialize,
  deserializeProp: _answerEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'categoryName_letter': IndexSchema(
      id: 8688836331913545244,
      name: r'categoryName_letter',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'letter',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'letter_categoryName': IndexSchema(
      id: 2316090926512073295,
      name: r'letter_categoryName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'letter',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'categoryName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _answerEntryGetId,
  getLinks: _answerEntryGetLinks,
  attach: _answerEntryAttach,
  version: '3.1.8',
);

int _answerEntryEstimateSize(
  AnswerEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.answer.length * 3;
  bytesCount += 3 + object.categoryName.length * 3;
  bytesCount += 3 + object.letter.length * 3;
  return bytesCount;
}

void _answerEntrySerialize(
  AnswerEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeString(offsets[1], object.answer);
  writer.writeBool(offsets[2], object.builtIn);
  writer.writeString(offsets[3], object.categoryName);
  writer.writeString(offsets[4], object.letter);
}

AnswerEntry _answerEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnswerEntry();
  object.addedAt = reader.readDateTimeOrNull(offsets[0]);
  object.answer = reader.readString(offsets[1]);
  object.builtIn = reader.readBool(offsets[2]);
  object.categoryName = reader.readString(offsets[3]);
  object.id = id;
  object.letter = reader.readString(offsets[4]);
  return object;
}

P _answerEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _answerEntryGetId(AnswerEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _answerEntryGetLinks(AnswerEntry object) {
  return [];
}

void _answerEntryAttach(
    IsarCollection<dynamic> col, Id id, AnswerEntry object) {
  object.id = id;
}

extension AnswerEntryQueryWhereSort
    on QueryBuilder<AnswerEntry, AnswerEntry, QWhere> {
  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnswerEntryQueryWhere
    on QueryBuilder<AnswerEntry, AnswerEntry, QWhereClause> {
  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      categoryNameEqualToAnyLetter(String categoryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryName_letter',
        value: [categoryName],
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      categoryNameNotEqualToAnyLetter(String categoryName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [],
              upper: [categoryName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [],
              upper: [categoryName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      categoryNameLetterEqualTo(String categoryName, String letter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryName_letter',
        value: [categoryName, letter],
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      categoryNameEqualToLetterNotEqualTo(String categoryName, String letter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName],
              upper: [categoryName, letter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName, letter],
              includeLower: false,
              upper: [categoryName],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName, letter],
              includeLower: false,
              upper: [categoryName],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName_letter',
              lower: [categoryName],
              upper: [categoryName, letter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      letterEqualToAnyCategoryName(String letter) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'letter_categoryName',
        value: [letter],
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      letterNotEqualToAnyCategoryName(String letter) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [],
              upper: [letter],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [],
              upper: [letter],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      letterCategoryNameEqualTo(String letter, String categoryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'letter_categoryName',
        value: [letter, categoryName],
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterWhereClause>
      letterEqualToCategoryNameNotEqualTo(String letter, String categoryName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter],
              upper: [letter, categoryName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter, categoryName],
              includeLower: false,
              upper: [letter],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter, categoryName],
              includeLower: false,
              upper: [letter],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'letter_categoryName',
              lower: [letter],
              upper: [letter, categoryName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AnswerEntryQueryFilter
    on QueryBuilder<AnswerEntry, AnswerEntry, QFilterCondition> {
  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      addedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addedAt',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      addedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addedAt',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> addedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      addedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> addedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> addedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      answerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      answerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> answerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      answerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      answerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answer',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> builtInEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'builtIn',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      categoryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      letterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'letter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      letterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'letter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition> letterMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'letter',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      letterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'letter',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterFilterCondition>
      letterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'letter',
        value: '',
      ));
    });
  }
}

extension AnswerEntryQueryObject
    on QueryBuilder<AnswerEntry, AnswerEntry, QFilterCondition> {}

extension AnswerEntryQueryLinks
    on QueryBuilder<AnswerEntry, AnswerEntry, QFilterCondition> {}

extension AnswerEntryQuerySortBy
    on QueryBuilder<AnswerEntry, AnswerEntry, QSortBy> {
  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'builtIn', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByBuiltInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'builtIn', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy>
      sortByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByLetter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'letter', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> sortByLetterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'letter', Sort.desc);
    });
  }
}

extension AnswerEntryQuerySortThenBy
    on QueryBuilder<AnswerEntry, AnswerEntry, QSortThenBy> {
  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answer', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'builtIn', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByBuiltInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'builtIn', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy>
      thenByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByLetter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'letter', Sort.asc);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QAfterSortBy> thenByLetterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'letter', Sort.desc);
    });
  }
}

extension AnswerEntryQueryWhereDistinct
    on QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> {
  QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> distinctByAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> distinctByBuiltIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'builtIn');
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> distinctByCategoryName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnswerEntry, AnswerEntry, QDistinct> distinctByLetter(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'letter', caseSensitive: caseSensitive);
    });
  }
}

extension AnswerEntryQueryProperty
    on QueryBuilder<AnswerEntry, AnswerEntry, QQueryProperty> {
  QueryBuilder<AnswerEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnswerEntry, DateTime?, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<AnswerEntry, String, QQueryOperations> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answer');
    });
  }

  QueryBuilder<AnswerEntry, bool, QQueryOperations> builtInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'builtIn');
    });
  }

  QueryBuilder<AnswerEntry, String, QQueryOperations> categoryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryName');
    });
  }

  QueryBuilder<AnswerEntry, String, QQueryOperations> letterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'letter');
    });
  }
}

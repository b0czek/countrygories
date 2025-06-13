// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSettingsImpl _$$GameSettingsImplFromJson(Map<String, dynamic> json) =>
    _$GameSettingsImpl(
      numberOfRounds: (json['numberOfRounds'] as num?)?.toInt() ?? 5,
      timePerRound: (json['timePerRound'] as num?)?.toInt() ?? 60,
      scoringMode:
          $enumDecodeNullable(_$ScoringModeEnumMap, json['scoringMode']) ??
              ScoringMode.manual,
      allowCustomCategories: json['allowCustomCategories'] as bool? ?? true,
      excludedLetters: (json['excludedLetters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ["Q", "V", "X", "Y"],
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GameSettingsImplToJson(_$GameSettingsImpl instance) =>
    <String, dynamic>{
      'numberOfRounds': instance.numberOfRounds,
      'timePerRound': instance.timePerRound,
      'scoringMode': _$ScoringModeEnumMap[instance.scoringMode]!,
      'allowCustomCategories': instance.allowCustomCategories,
      'excludedLetters': instance.excludedLetters,
      'selectedCategories': instance.selectedCategories,
    };

const _$ScoringModeEnumMap = {
  ScoringMode.automatic: 'automatic',
  ScoringMode.manual: 'manual',
};

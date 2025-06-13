import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings.freezed.dart';
part 'game_settings.g.dart';

enum ScoringMode { automatic, manual }

@freezed
class GameSettings with _$GameSettings {
  const factory GameSettings({
    @Default(5) int numberOfRounds,
    @Default(60) int timePerRound,
    @Default(ScoringMode.manual) ScoringMode scoringMode,
    @Default(true) bool allowCustomCategories,
    @Default(["Q", "V", "X", "Y"]) List<String> excludedLetters,
    @Default([]) List<String> selectedCategories,
  }) = _GameSettings;

  factory GameSettings.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsFromJson(json);
}

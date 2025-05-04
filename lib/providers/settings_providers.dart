import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game_settings.dart';
import 'package:countrygories/config/app_config.dart';

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
      return GameSettingsNotifier();
    });

class GameSettingsNotifier extends StateNotifier<GameSettings> {
  GameSettingsNotifier()
    : super(GameSettings(selectedCategories: AppConfig.defaultCategories));

  void updateNumberOfRounds(int rounds) {
    state = state.copyWith(numberOfRounds: rounds);
  }

  void updateTimePerRound(int seconds) {
    state = state.copyWith(timePerRound: seconds);
  }

  void updateScoringMode(ScoringMode mode) {
    state = state.copyWith(scoringMode: mode);
  }

  void toggleCustomCategories(bool allow) {
    state = state.copyWith(allowCustomCategories: allow);
  }

  void updateExcludedLetters(List<String> letters) {
    state = state.copyWith(excludedLetters: letters);
  }

  void updateSelectedCategories(List<String> categories) {
    state = state.copyWith(selectedCategories: categories);
  }
}

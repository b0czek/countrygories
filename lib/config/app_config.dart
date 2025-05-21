class AppConfig {
  static const String appName = "Countrygories";
  static const int defaultServerPort = 8080;
  static const int defaultTimePerRound = 60;
  static const int defaultNumberOfRounds = 5;

  static const List<String> defaultCategories = [
    "Państwo",
    "Miasto",
    "Zwierzę",
    "Roślina",
    "Imię",
    "Zawód",
  ];

  static const List<String> defaultExcludedLetters = ["Q", "V", "X", "Y"];

  static const double minAnswerLevensteinMatchValue = 0.7;
}

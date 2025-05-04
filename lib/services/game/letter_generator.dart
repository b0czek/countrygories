import 'dart:math';

class LetterGenerator {
  final List<String> excludedLetters;
  final List<String> usedLetters = [];
  final List<String> alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'R',
    'S',
    'T',
    'U',
    'W',
    'Z',
  ];
  final Random _random = Random();

  LetterGenerator({this.excludedLetters = const []}) {
    for (final letter in excludedLetters) {
      alphabet.remove(letter.toUpperCase());
    }
  }

  String generateRandomLetter() {
    final availableLetters =
        alphabet.where((l) => !usedLetters.contains(l)).toList();

    if (availableLetters.isEmpty) {
      usedLetters.clear();
      return alphabet[_random.nextInt(alphabet.length)];
    }

    final letter = availableLetters[_random.nextInt(availableLetters.length)];
    usedLetters.add(letter);
    return letter;
  }

  void resetUsedLetters() {
    usedLetters.clear();
  }
}

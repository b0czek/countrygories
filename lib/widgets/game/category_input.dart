import 'package:flutter/material.dart';

class CategoryInput extends StatelessWidget {
  final String category;
  final TextEditingController controller;
  final String letter;
  final bool enabled;

  const CategoryInput({
    super.key,
    required this.category,
    required this.controller,
    required this.letter,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: category,
          hintText:
              letter.isNotEmpty
                  ? 'Wpisz $category na literę $letter'
                  : 'Czekaj na literę...',
          border: const OutlineInputBorder(),
        ),
        enabled: enabled && letter.isNotEmpty,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        onChanged: (value) {
          if (value.isNotEmpty &&
              value[0].toLowerCase() == letter.toLowerCase()) {
            final correctedValue = letter.toUpperCase() + value.substring(1);
            if (correctedValue != value) {
              controller.value = TextEditingValue(
                text: correctedValue,
                selection: TextSelection.collapsed(
                  offset: correctedValue.length,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

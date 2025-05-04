import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/providers/database_providers.dart';
import 'package:countrygories/widgets/common/custom_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _answerController = TextEditingController();
  final _letterController = TextEditingController();
  String? _selectedCategory;
  bool _isAddingCategory = false;
  bool _isAddingAnswer = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    _answerController.dispose();
    _letterController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _categoryNameController.text.trim();

    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.addCategory(categoryName, isCustom: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategoria dodana pomyślnie'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isAddingCategory = false;
        _categoryNameController.clear();
      });

      ref.invalidate(categoriesProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd dodawania kategorii: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addAnswer() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _selectedCategory;
    final letter = _letterController.text.trim().toUpperCase();
    final answer = _answerController.text.trim();

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wybierz kategorię'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.addAnswer(category, letter, answer, false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odpowiedź dodana pomyślnie'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isAddingAnswer = false;
        _answerController.clear();
        _letterController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd dodawania odpowiedzi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zarządzanie kategoriami',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCategoriesList(),
              const SizedBox(height: 16),
              if (_isAddingCategory)
                _buildAddCategoryForm()
              else
                CustomButton(
                  text: 'Dodaj nową kategorię',
                  onPressed: () {
                    setState(() {
                      _isAddingCategory = true;
                    });
                  },
                ),
              const SizedBox(height: 32),
              const Text(
                'Zarządzanie odpowiedziami',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isAddingAnswer)
                _buildAddAnswerForm()
              else
                CustomButton(
                  text: 'Dodaj nową odpowiedź',
                  onPressed: () {
                    setState(() {
                      _isAddingAnswer = true;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);

        return categoriesAsync.when(
          data: (categories) {
            return SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text(
                      category.isCustom ? 'Niestandardowa' : 'Domyślna',
                    ),
                    trailing:
                        category.isCustom
                            ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                // TODO: Implement delete category functionality
                              },
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.name;
                      });
                    },
                    selected: _selectedCategory == category.name,
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildAddCategoryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categoryNameController,
          decoration: const InputDecoration(
            labelText: 'Nazwa kategorii',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Proszę podać nazwę kategorii';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isAddingCategory = false;
                  _categoryNameController.clear();
                });
              },
              child: const Text('Anuluj'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Dodaj kategorię'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddAnswerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);

            return categoriesAsync.when(
              data: (categories) {
                final categoryNames = categories.map((c) => c.name).toList();

                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategoria',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      categoryNames.map((name) {
                        return DropdownMenuItem(value: name, child: Text(name));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wybrać kategorię';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _letterController,
          decoration: const InputDecoration(
            labelText: 'Litera',
            border: OutlineInputBorder(),
          ),
          maxLength: 1,
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Proszę podać literę';
            }
            if (value.length != 1) {
              return 'Proszę podać dokładnie jedną literę';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _answerController,
          decoration: const InputDecoration(
            labelText: 'Odpowiedź',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Proszę podać odpowiedź';
            }
            if (_letterController.text.isNotEmpty &&
                !value.toUpperCase().startsWith(
                  _letterController.text.toUpperCase(),
                )) {
              return 'Odpowiedź musi zaczynać się na literę ${_letterController.text.toUpperCase()}';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isAddingAnswer = false;
                  _answerController.clear();
                  _letterController.clear();
                });
              },
              child: const Text('Anuluj'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _addAnswer,
              child: const Text('Dodaj odpowiedź'),
            ),
          ],
        ),
      ],
    );
  }
}

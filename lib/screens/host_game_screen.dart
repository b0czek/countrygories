import 'package:countrygories/providers/database_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/models/game_settings.dart';
import 'package:countrygories/providers/game_providers.dart';
import 'package:countrygories/providers/network_providers.dart';
import 'package:countrygories/providers/settings_providers.dart';
import 'package:countrygories/screens/game_lobby_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';

class HostGameScreen extends ConsumerStatefulWidget {
  const HostGameScreen({super.key});

  @override
  ConsumerState<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends ConsumerState<HostGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _playerNameController.text = 'Host';
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  Future<void> _startServer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ref.read(isHostProvider.notifier).state = true;

      final serverService = ref.read(serverProvider);
      if (serverService == null) {
        throw Exception('Server service not available');
      }

      await serverService.startServer(
        serverName: '${_playerNameController.text}\'s Game',
        hostName: _playerNameController.text,
      );
      ref.read(serverActiveProvider.notifier).state = true;

      // Create local player (host)
      final player = ref
          .read(localPlayerProvider)
          .copyWith(
            name: _playerNameController.text,
            isHost: true,
            isConnected: true,
          );
      ref.read(currentPlayerProvider.notifier).state = player;
      ref.read(connectedPlayersProvider.notifier).addPlayer(player);

      // Create game
      final settings = ref.read(gameSettingsProvider);
      ref.read(gameProvider.notifier).createGame(settings, player);

      // Go to game lobby
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameLobbyScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting server: ${e.toString()}';
      });
      // Reset host state
      ref.read(isHostProvider.notifier).state = false;
      ref.read(serverActiveProvider.notifier).state = false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hostuj grę')),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ustawienia gry',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Twoja nazwa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę podać nazwę';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildGameSettingsSection(settings),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Center(
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                            text: 'Rozpocznij hosting',
                            onPressed: _startServer,
                            width: 250,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameSettingsSection(GameSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liczba rund:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: settings.numberOfRounds.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: settings.numberOfRounds.toString(),
          onChanged: (value) {
            ref
                .read(gameSettingsProvider.notifier)
                .updateNumberOfRounds(value.toInt());
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Czas na rundę (sekundy):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: settings.timePerRound.toDouble(),
          min: 30,
          max: 120,
          divisions: 9,
          label: settings.timePerRound.toString(),
          onChanged: (value) {
            ref
                .read(gameSettingsProvider.notifier)
                .updateTimePerRound(value.toInt());
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tryb punktacji:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<ScoringMode>(
          value: settings.scoringMode,
          isExpanded: true,
          onChanged: (ScoringMode? newValue) {
            if (newValue != null) {
              ref
                  .read(gameSettingsProvider.notifier)
                  .updateScoringMode(newValue);
            }
          },
          items: const [
            DropdownMenuItem(
              value: ScoringMode.automatic,
              child: Text('Automatyczny'),
            ),
            DropdownMenuItem(
              value: ScoringMode.manual,
              child: Text('Ręczny (host przyznaje punkty)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Zezwalaj na niestandardowe kategorie'),
          value: settings.allowCustomCategories,
          onChanged: (bool value) {
            ref
                .read(gameSettingsProvider.notifier)
                .toggleCustomCategories(value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Wybrane kategorie:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCategoriesSelection(settings),
      ],
    );
  }

  Widget _buildCategoriesSelection(GameSettings settings) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);

        return categoriesAsync.when(
          data: (categories) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  categories.map((category) {
                    final isSelected = settings.selectedCategories.contains(
                      category.name,
                    );
                    return FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        final updatedCategories = List<String>.from(
                          settings.selectedCategories,
                        );
                        if (selected) {
                          updatedCategories.add(category.name);
                        } else {
                          updatedCategories.remove(category.name);
                        }
                        ref
                            .read(gameSettingsProvider.notifier)
                            .updateSelectedCategories(updatedCategories);
                      },
                    );
                  }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }
}

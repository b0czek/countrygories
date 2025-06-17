import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/providers/database_providers.dart';
import 'package:countrygories/screens/host_game_screen.dart';
import 'package:countrygories/screens/join_game_screen.dart';
import 'package:countrygories/screens/settings_screen.dart';
import 'package:countrygories/widgets/common/custom_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the database if not already done
    ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 240),
              const SizedBox(height: 32),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Hostuj grę',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HostGameScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Dołącz do gry',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JoinGameScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

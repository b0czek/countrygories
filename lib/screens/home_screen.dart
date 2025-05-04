import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/config/app_config.dart';
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
      appBar: AppBar(title: Text(AppConfig.appName), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Witaj w grze Państwa-Miasta!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
            const SizedBox(height: 16),
            CustomButton(
              text: 'Ustawienia',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

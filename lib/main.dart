import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:countrygories/config/app_config.dart';
import 'package:countrygories/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9C4), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue, 
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 157, 202, 240),
          onSecondary: Colors.black, 
          surface: Color(0xFFFFF9C4), 
          surfaceContainerLowest: Color(0xFFFFF59D), 
          surfaceContainerHighest: Color(0xFFFFF9C4) 
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, 
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), 
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFFF9C4), 
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ValasztoApp());
}

class ValasztoApp extends StatelessWidget {
  const ValasztoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Választás 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

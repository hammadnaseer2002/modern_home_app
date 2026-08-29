import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart'; // Just import your home screen!

class HouseDesignApp extends StatelessWidget {
  const HouseDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Design',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(), // Launches immediately when the engine is ready
    );
  }
}
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const ArtisanHubApp());
}

class ArtisanHubApp extends StatelessWidget {
  const ArtisanHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CraftBridge',
      debugShowCheckedModeBanner: false,
      theme: CraftTheme.themeData,
      home: const OnboardingScreen(),
    );
  }
}

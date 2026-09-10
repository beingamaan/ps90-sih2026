import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'providers/product_draft_provider.dart';

void main() {
  runApp(
    ProductDraftScope(
      provider: ProductDraftProvider(),
      child: const ArtisanHubApp(),
    ),
  );
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

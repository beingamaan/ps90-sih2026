import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "icon": Icons.local_florist_rounded,
      "title": "Welcome to CraftBridge",
      "subtitle": "Your AI Virtual Business Manager designed for Indian artisans and craftspeople.",
      "color": CraftTheme.terracottaPrimary,
      "lightColor": CraftTheme.terracottaLight,
    },
    {
      "icon": Icons.mic_rounded,
      "title": "Voice & Camera Cataloging",
      "subtitle": "Speak in your own language or snap a photo. AI generates product listings in seconds.",
      "color": CraftTheme.violetTint,
      "lightColor": CraftTheme.violetLight,
    },
    {
      "icon": Icons.account_balance_wallet_rounded,
      "title": "Fair Pricing & Global Markets",
      "subtitle": "Guaranteed fair wage calculation and instant 1-click publishing to ONDC & GeM networks.",
      "color": CraftTheme.tealTint,
      "lightColor": CraftTheme.tealLight,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Layered Circle Illustrated Motif
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide["lightColor"],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: slide["color"],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (slide["color"] as Color).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                slide["icon"] as IconData,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide["title"] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CraftTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide["subtitle"] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            height: 1.5,
                            color: CraftTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Progress Indicator
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? CraftTheme.terracottaPrimary
                              : CraftTheme.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CraftTheme.terracottaPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _slides.length - 1 ? "Get Started" : "Next",
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

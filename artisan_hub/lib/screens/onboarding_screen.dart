import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/responsive_container.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'voice_overlay.dart';

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
      "step": "STEP 1 OF 5: CAPTURE",
      "icon": Icons.camera_alt_rounded,
      "title": "Take a clean photo of your craft",
      "subtitle": "CraftBridge preserves your original craft photos. Studio enhancement is optionally applied.",
      "color": CraftTheme.terracottaPrimary,
      "lightColor": CraftTheme.terracottaLight,
    },
    {
      "step": "STEP 2 OF 5: DESCRIBE",
      "icon": Icons.mic_rounded,
      "title": "Speak naturally about your craft",
      "subtitle": "Describe materials, techniques, and origin in your native language via voice recording.",
      "color": CraftTheme.violetTint,
      "lightColor": CraftTheme.violetLight,
    },
    {
      "step": "STEP 3 OF 5: REVIEW",
      "icon": Icons.verified_user_rounded,
      "title": "Review AI-suggested product facts",
      "subtitle": "AI suggestions remain under seller review. Confirm, edit, or exclude claims.",
      "color": CraftTheme.tealTint,
      "lightColor": CraftTheme.tealLight,
    },
    {
      "step": "STEP 4 OF 5: PREPARE",
      "icon": Icons.inventory_2_rounded,
      "title": "Set fair price & declare order readiness",
      "subtitle": "Ensure your price covers material costs and labor time while declaring operational readiness.",
      "color": CraftTheme.amberTint,
      "lightColor": CraftTheme.amberLight,
    },
    {
      "step": "STEP 5 OF 5: SHOWCASE",
      "icon": Icons.share_rounded,
      "title": "Approve & generate export catalogue",
      "subtitle": "Format your listing into seller-approved catalogue schemas ready for buyer sharing.",
      "color": CraftTheme.blueTint,
      "lightColor": CraftTheme.blueLight,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      body: SafeArea(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Header brand title
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: CraftTheme.terracottaLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: CraftTheme.terracottaPrimary, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "CraftBridge",
                          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Text("Skip to Workspace →", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary)),
                    ),
                  ],
                ),
              ),

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
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: slide["lightColor"],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: slide["color"],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (slide["color"] as Color).withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  slide["icon"] as IconData,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: slide["lightColor"] as Color,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              slide["step"] as String,
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: slide["color"] as Color,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide["title"] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CraftTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide["subtitle"] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              height: 1.4,
                              color: CraftTheme.mutedText,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Trust Badge Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: CraftTheme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: CraftTheme.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_outlined, size: 16, color: CraftTheme.tealTint),
                                const SizedBox(width: 8),
                                Text(
                                  "AI suggests. You decide.",
                                  style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.tealTint),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Example snippet card
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CraftTheme.cardSurface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: CraftTheme.borderLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CraftTheme.terracottaLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text("EXAMPLE", style: GoogleFonts.notoSans(fontSize: 9, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "\"Handwoven cotton basket, made in 3 days...\"",
                                    style: GoogleFonts.notoSans(fontSize: 11, fontStyle: FontStyle.italic, color: CraftTheme.darkText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Prominent Entry Actions & Page Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CameraScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                            label: Text("ADD PHOTO", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CraftTheme.terracottaPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const VoiceOverlay(),
                              );
                            },
                            icon: const Icon(Icons.mic_rounded, size: 16, color: CraftTheme.violetTint),
                            label: Text("DESCRIBE BY VOICE", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              side: const BorderSide(color: CraftTheme.violetTint, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 6),
                              height: 6,
                              width: _currentPage == index ? 20 : 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? CraftTheme.terracottaPrimary
                                    : CraftTheme.borderLight,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
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
                          child: Row(
                            children: [
                              Text(
                                _currentPage == _slides.length - 1 ? "Start Catalogue →" : "Next →",
                                style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

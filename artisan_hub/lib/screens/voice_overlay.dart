import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'voice_screen.dart';

class VoiceOverlay extends StatefulWidget {
  const VoiceOverlay({super.key});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onSelectPrompt(String prompt) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceScreen(initialTranscript: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: CraftTheme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CraftTheme.violetLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.graphic_eq_rounded, color: CraftTheme.violetTint, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Voice Assistant",
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CraftTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: CraftTheme.mutedText),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Animated Mic Pulse Button
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(16 * _animController.value),
                    decoration: BoxDecoration(
                      color: CraftTheme.terracottaPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: CraftTheme.terracottaPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, size: 40, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                "Listening…",
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),

              // Animated Waveform Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  7,
                  (index) => AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final h = 12 + 20 * (index % 2 == 0 ? _animController.value : 1.0 - _animController.value);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: h,
                        decoration: BoxDecoration(
                          color: CraftTheme.terracottaPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                "Or tap a quick example command:",
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CraftTheme.mutedText,
                ),
              ),
              const SizedBox(height: 12),

              // Sample Command Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.color_lens_rounded, size: 16, color: CraftTheme.terracottaPrimary),
                    label: Text("Red Chanderi Silk Saree", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    backgroundColor: CraftTheme.terracottaLight,
                    onPressed: () => _onSelectPrompt("Red Chanderi Silk Saree with zari border"),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.local_florist_rounded, size: 16, color: CraftTheme.tealTint),
                    label: Text("Blue Terracotta Water Jug", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    backgroundColor: CraftTheme.tealLight,
                    onPressed: () => _onSelectPrompt("Blue painted clay terracotta water pot"),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.diamond_rounded, size: 16, color: CraftTheme.violetTint),
                    label: Text("Silver Tribal Necklace", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    backgroundColor: CraftTheme.violetLight,
                    onPressed: () => _onSelectPrompt("Handcrafted brass silver beaded tribal necklace"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

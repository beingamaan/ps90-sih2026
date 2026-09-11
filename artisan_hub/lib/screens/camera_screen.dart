import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../api_service.dart';
import '../services/image_matting_service.dart';
import '../widgets/responsive_container.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/craft_buttons.dart';
import '../providers/product_draft_provider.dart';
import 'voice_screen.dart';
import 'home_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _originalBytes;
  String? _enhancedB64;
  bool _isLoading = false;
  double _sliderPos = 0.0;
  int _selectedBgIndex = 0;
  String _selectedCraftName = "Handcrafted Artisan Item";

  final List<Map<String, dynamic>> _bgPresets = [
    {"name": "Clean White", "color": Colors.white},
    {"name": "Studio Beige", "color": const Color(0xFFF7F3ED)},
    {"name": "Neutral Grey", "color": const Color(0xFFE8E8E8)},
    {"name": "Clay Terracotta", "color": const Color(0xFFF6E4DC)},
  ];

  String _enhancementStatus = "AI Background Removal";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'craft_photo.jpg';
      _processBytes(bytes, filename, "Uploaded Craft Photo");
    } catch (e) {
      if (kDebugMode) {
        print('Pick Image error: $e');
      }
      _loadSampleCraft("Textile Saree");
    }
  }

  Future<void> _processBytes(Uint8List bytes, String filename, String craftName, {String? transparentFallbackB64}) async {
    setState(() {
      _originalBytes = bytes;
      _enhancedB64 = null;
      _isLoading = true;
      _selectedCraftName = craftName;
      _enhancementStatus = "Removing Background...";
    });

    // 1. Try backend enhance-image endpoint (uses remove.bg API key / rembg AI)
    String? resultB64 = await ApiService.enhanceImage(bytes, filename);
    String status = "AI Studio Enhanced (remove.bg)";

    // 2. If backend is offline or returned null, use sample cutout or client-side matting engine
    if (resultB64 == null || resultB64.isEmpty) {
      if (transparentFallbackB64 != null && transparentFallbackB64.isNotEmpty) {
        resultB64 = transparentFallbackB64;
        status = "Studio Cutout Applied";
      } else {
        resultB64 = await ImageMattingService.removeBackground(bytes);
        status = "Client Studio Matting";
      }
    }
    
    if (mounted) {
      setState(() {
        if (resultB64 != null && resultB64.isNotEmpty) {
          _enhancedB64 = resultB64;
          _enhancementStatus = status;
        } else {
          final b64 = base64Encode(bytes);
          _enhancedB64 = "data:image/png;base64,$b64";
          _enhancementStatus = "Original Preserved";
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSampleCraft(String type) async {
    // 1. Generate realistic simulated photo WITH wood table background
    final bgRecorder = ui.PictureRecorder();
    final bgCanvas = Canvas(bgRecorder, const Rect.fromLTWH(0, 0, 400, 400));
    final bgPaint = Paint();

    // Wood table texture
    bgPaint.color = const Color(0xFF5D4037);
    bgCanvas.drawRect(const Rect.fromLTWH(0, 0, 400, 400), bgPaint);

    bgPaint.color = const Color(0xFF3E2723);
    for (double i = 0; i < 400; i += 40) {
      bgCanvas.drawRect(Rect.fromLTWH(0, i, 400, 4), bgPaint);
    }
    bgPaint.color = const Color(0xFF8D6E63).withValues(alpha: 0.5);
    for (int i = 0; i < 20; i++) {
      bgCanvas.drawCircle(Offset((i * 23) % 400, (i * 37) % 400), 8, bgPaint);
    }

    _drawCraftObject(bgCanvas, type);

    final bgPicture = bgRecorder.endRecording();
    final bgImg = await bgPicture.toImage(400, 400);
    final bgPngBytes = await bgImg.toByteData(format: ui.ImageByteFormat.png);

    // 2. Generate clean transparent foreground cutout (offline backup)
    final fgRecorder = ui.PictureRecorder();
    final fgCanvas = Canvas(fgRecorder, const Rect.fromLTWH(0, 0, 400, 400));
    _drawCraftObject(fgCanvas, type);
    final fgPicture = fgRecorder.endRecording();
    final fgImg = await fgPicture.toImage(400, 400);
    final fgPngBytes = await fgImg.toByteData(format: ui.ImageByteFormat.png);

    String? transparentB64;
    if (fgPngBytes != null) {
      final b64Str = base64Encode(fgPngBytes.buffer.asUint8List());
      transparentB64 = "data:image/png;base64,$b64Str";
    }

    if (bgPngBytes != null) {
      _processBytes(
        bgPngBytes.buffer.asUint8List(),
        "$type.png",
        type,
        transparentFallbackB64: transparentB64,
      );
    }
  }

  void _drawCraftObject(Canvas canvas, String type) {
    final paint = Paint();
    if (type == "Textile Saree") {
      paint.color = const Color(0xFFD81B60);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(100, 80, 200, 240), const Radius.circular(20)), paint);
      paint.color = const Color(0xFFFFD700);
      canvas.drawRect(const Rect.fromLTWH(100, 280, 200, 40), paint);
    } else if (type == "Terracotta Pot") {
      paint.color = const Color(0xFFE64A19);
      canvas.drawOval(const Rect.fromLTWH(110, 100, 180, 200), paint);
      paint.color = const Color(0xFFBF360C);
      canvas.drawRect(const Rect.fromLTWH(150, 70, 100, 40), paint);
    } else {
      paint.color = const Color(0xFFFBC02D);
      canvas.drawCircle(const Offset(200, 200), 90, paint);
      paint.color = const Color(0xFF5D4037);
      canvas.drawCircle(const Offset(200, 200), 60, paint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // 2. STEP PROGRESS BAR (Step 1 Active)
                  const StepProgressBar(currentStep: 1),
                  const SizedBox(height: 24),

                  // 3. MAIN EDITORIAL CONTENT
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildHeroPhotoStudioPanel()),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: _buildRightContentColumn()),
                      ],
                    )
                  else ...[
                    _buildHeroPhotoStudioPanel(),
                    const SizedBox(height: 24),
                    _buildRightContentColumn(),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 1. TOP HEADER ────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CraftTheme.terracottaLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: CraftTheme.terracottaPrimary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CraftBridge",
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "CREATE PRODUCT",
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.terracottaPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: CraftTheme.terracottaPrimary),
          label: Text(
            "Skip to Workspace →",
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CraftTheme.terracottaPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── 2. HERO PHOTO STUDIO PANEL ───────────────────────
  Widget _buildHeroPhotoStudioPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CraftTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Studio Framing Visual Box
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CraftTheme.terracottaLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.terracottaPrimary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Stack(
              children: [
                // Corner Framing Indicators
                Positioned(top: 12, left: 12, child: _buildFrameCorner(top: true, left: true)),
                Positioned(top: 12, right: 12, child: _buildFrameCorner(top: true, left: false)),
                Positioned(bottom: 12, left: 12, child: _buildFrameCorner(top: false, left: true)),
                Positioned(bottom: 12, right: 12, child: _buildFrameCorner(top: false, left: false)),

                // Center Icon + Silhouette Frame
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CraftTheme.terracottaPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CraftTheme.terracottaPrimary.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Put your craft in the frame",
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CraftTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Position product centered with clear light",
                        style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
                      ),
                    ],
                  ),
                ),

                // Floating Guidance Labels
                Positioned(
                  top: 16,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 600 ? 300 : 360,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFloatingTag("GOOD LIGHT"),
                        const SizedBox(width: 8),
                        _buildFloatingTag("CLEAR FOCUS"),
                        const SizedBox(width: 8),
                        _buildFloatingTag("SHOW DETAILS"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contextual Hero Caption
          Text(
            "CRAFT PHOTO STUDIO",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.terracottaPrimary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Original photos are preserved. Enhancement is optional assistance.",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameCorner({required bool top, required bool left}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: CraftTheme.terracottaPrimary, width: 2.5) : BorderSide.none,
          bottom: !top ? const BorderSide(color: CraftTheme.terracottaPrimary, width: 2.5) : BorderSide.none,
          left: left ? const BorderSide(color: CraftTheme.terracottaPrimary, width: 2.5) : BorderSide.none,
          right: !left ? const BorderSide(color: CraftTheme.terracottaPrimary, width: 2.5) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFloatingTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CraftTheme.borderLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: CraftTheme.darkText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── 3. RIGHT CONTENT COLUMN ──────────────────────────
  Widget _buildRightContentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STEP LABEL & HEADINGS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: CraftTheme.terracottaLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "STEP 1 OF 5 • CAPTURE",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.terracottaPrimary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "Take a clean photo of your craft",
          style: GoogleFonts.notoSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "CraftBridge keeps your original photo. Studio enhancement is optional assistance for catalog presentation.",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            height: 1.5,
            color: CraftTheme.mutedText,
          ),
        ),
        const SizedBox(height: 24),

        // IF IMAGE PICKED: STUDIO COMPARISON VIEW
        if (_originalBytes != null) ...[
          _buildStudioComparison(),
          const SizedBox(height: 20),
          _buildBackgroundPresetChips(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],

        // IF NO IMAGE PICKED: GUIDANCE & CHECKLIST CARDS
        if (_originalBytes == null) ...[
          _buildPhotoGuidanceSection(),
          const SizedBox(height: 20),
          _buildPhotoChecklistSection(),
          const SizedBox(height: 20),
          _buildPhotoTipCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildSampleCraftSection(),
        ],
      ],
    );
  }

  // ─── PHOTO GUIDANCE CARD ──────────────────────────────
  Widget _buildPhotoGuidanceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 18, color: CraftTheme.terracottaPrimary),
              const SizedBox(width: 8),
              Text(
                "MAKE YOUR PHOTO WORK",
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.terracottaPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final items = [
                _buildGuidanceItem("01", "GOOD LIGHTING", "Use natural or even light.", Icons.light_mode_outlined),
                _buildGuidanceItem("02", "CLEAR FOCUS", "Keep the product centered.", Icons.center_focus_strong_rounded),
                _buildGuidanceItem("03", "SHOW THE CRAFT", "Keep details visible.", Icons.texture_rounded),
              ];

              if (isNarrow) {
                return Column(children: items);
              }
              return Row(
                children: items.map((item) => Expanded(child: item)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(String num, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CraftTheme.creamBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                num,
                style: GoogleFonts.notoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.terracottaPrimary,
                ),
              ),
              Icon(icon, size: 16, color: CraftTheme.terracottaPrimary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CraftTheme.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
          ),
        ],
      ),
    );
  }

  // ─── PHOTO CHECKLIST SECTION ─────────────────────────
  Widget _buildPhotoChecklistSection() {
    final hasPhoto = _originalBytes != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PHOTO CHECK",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.mutedText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildCheckItem("Product clearly visible", hasPhoto)),
              Expanded(child: _buildCheckItem("Main details visible", hasPhoto)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildCheckItem("Original photo preserved", true)),
              Expanded(child: _buildCheckItem("Enhancement optional", true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isDone ? CraftTheme.tealTint : CraftTheme.captionText,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: isDone ? CraftTheme.darkText : CraftTheme.mutedText,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // ─── PHOTO TIP CARD ───────────────────────────────────
  Widget _buildPhotoTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CraftTheme.terracottaLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CraftTheme.terracottaPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: CraftTheme.terracottaPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PHOTO TIP",
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.terracottaPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Use a clean background and soft natural light when possible. Good light helps show craft details.",
                  style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.darkText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ACTIONS AREA ─────────────────────────────────────
  Widget _buildActionButtons() {
    if (_originalBytes != null) {
      return Row(
        children: [
          Expanded(
            child: CraftSecondaryButton(
              label: "Change Photo",
              icon: Icons.refresh_rounded,
              onPressed: () => setState(() {
                _originalBytes = null;
                _enhancedB64 = null;
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CraftPrimaryButton(
              label: "CONTINUE TO DESCRIPTION →",
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                try {
                  final provider = ProductDraftProvider.of(context, listen: false);
                  provider.updateImage(
                    originalBytes: _originalBytes,
                    enhancedB64: _enhancedB64,
                  );
                } catch (_) {}
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoiceScreen(initialTranscript: _selectedCraftName),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final primaryBtn = CraftPrimaryButton(
          label: "ADD PHOTO",
          icon: Icons.camera_alt_rounded,
          onPressed: () => _pickImage(ImageSource.camera),
        );

        final galleryBtn = CraftSecondaryButton(
          label: "CHOOSE FROM GALLERY",
          icon: Icons.photo_library_rounded,
          onPressed: () => _pickImage(ImageSource.gallery),
        );

        final voiceBtn = OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceScreen()),
            );
          },
          icon: const Icon(Icons.mic_rounded, size: 18, color: CraftTheme.violetTint),
          label: Text(
            "DESCRIBE BY VOICE INSTEAD",
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CraftTheme.violetTint,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: CraftTheme.violetTint, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );

        if (isMobile) {
          return Column(
            children: [
              primaryBtn,
              const SizedBox(height: 10),
              galleryBtn,
              const SizedBox(height: 10),
              voiceBtn,
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: primaryBtn),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: galleryBtn),
              ],
            ),
            const SizedBox(height: 12),
            voiceBtn,
          ],
        );
      },
    );
  }

  // ─── SAMPLE CRAFT SELECTION ───────────────────────────
  Widget _buildSampleCraftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Or test with sample craft photos:",
          style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ActionChip(
              avatar: const Icon(Icons.checkroom_rounded, color: CraftTheme.terracottaPrimary, size: 16),
              label: Text("Chanderi Silk Saree", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600)),
              backgroundColor: CraftTheme.terracottaLight,
              onPressed: () => _loadSampleCraft("Textile Saree"),
            ),
            ActionChip(
              avatar: const Icon(Icons.local_florist_rounded, color: CraftTheme.tealTint, size: 16),
              label: Text("Terracotta Water Pot", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600)),
              backgroundColor: CraftTheme.tealLight,
              onPressed: () => _loadSampleCraft("Terracotta Pot"),
            ),
            ActionChip(
              avatar: const Icon(Icons.diamond_rounded, color: CraftTheme.violetTint, size: 16),
              label: Text("Brass Jewelry Ornament", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.w600)),
              backgroundColor: CraftTheme.violetLight,
              onPressed: () => _loadSampleCraft("Brass Jewelry"),
            ),
          ],
        ),
      ],
    );
  }

  // ─── STUDIO COMPARISON SLIDER ────────────────────────
  Widget _buildStudioComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Original vs Studio Enhanced",
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.darkText,
                  ),
                ),
                Text(
                  _selectedCraftName,
                  style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
                ),
              ],
            ),
            if (_isLoading)
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: CraftTheme.tealTint),
                  ),
                  const SizedBox(width: 8),
                  Text("Processing…", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.tealTint)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Truthful Photo Status Chips & View Mode
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: CraftTheme.greenLight, borderRadius: BorderRadius.circular(6)),
                  child: Text("Photo Added", style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.greenTint)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: CraftTheme.tealLight, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: CraftTheme.tealTint, size: 12),
                      const SizedBox(width: 4),
                      Text(_enhancementStatus, style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.tealTint)),
                    ],
                  ),
                ),
              ],
            ),
            // Quick View Mode Toggle
            Row(
              children: [
                _buildViewModeChip("Studio", _sliderPos < 0.05, () => setState(() => _sliderPos = 0.0)),
                const SizedBox(width: 4),
                _buildViewModeChip("Split", _sliderPos >= 0.05 && _sliderPos <= 0.95, () => setState(() => _sliderPos = 0.5)),
                const SizedBox(width: 4),
                _buildViewModeChip("Original", _sliderPos > 0.95, () => setState(() => _sliderPos = 1.0)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;
            final double handleLeft = (containerWidth * _sliderPos - 18).clamp(0.0, containerWidth - 36);
            final isSplit = _sliderPos > 0.02 && _sliderPos < 0.98;

            return Container(
              height: 340,
              decoration: BoxDecoration(
                color: _bgPresets[_selectedBgIndex]["color"] as Color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CraftTheme.borderLight, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sliderPos = (_sliderPos + details.delta.dx / containerWidth).clamp(0.0, 1.0);
                    });
                  },
                  child: Stack(
                    children: [
                      // Layer 1 (Bottom): Transparent Background-Removed Studio Cutout
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: _enhancedB64 != null
                              ? Image.memory(
                                  base64Decode(_enhancedB64!.split(',').last),
                                  fit: BoxFit.contain,
                                )
                              : (_originalBytes != null
                                  ? Image.memory(_originalBytes!, fit: BoxFit.contain)
                                  : const SizedBox.shrink()),
                        ),
                      ),
                      // Layer 2 (Top): Original Photo with Background (Clipped by slider)
                      if (_sliderPos > 0.001)
                        Positioned.fill(
                          child: ClipRect(
                            clipper: _BeforeClipper(_sliderPos),
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16),
                              child: _originalBytes != null
                                  ? Image.memory(_originalBytes!, fit: BoxFit.contain)
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Slider Divider Line
                      if (isSplit)
                        Positioned(
                          left: containerWidth * _sliderPos - 1.5,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3,
                            color: CraftTheme.terracottaPrimary,
                          ),
                        ),

                      // Drag Handle
                      if (isSplit)
                        Positioned(
                          left: handleLeft,
                          top: 150,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: CraftTheme.terracottaPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.unfold_more_rounded, color: Colors.white, size: 22),
                          ),
                        ),

                      // Corner Badges
                      if (_sliderPos >= 0.5)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                            child: Text("Original Photo", style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (_sliderPos <= 0.5)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: CraftTheme.terracottaPrimary, borderRadius: BorderRadius.circular(999)),
                            child: Text("Studio Enhanced", style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackgroundPresetChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Studio Background Presets",
          style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_bgPresets.length, (index) {
            final isSelected = _selectedBgIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedBgIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? CraftTheme.terracottaPrimary : CraftTheme.cardSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? CraftTheme.terracottaPrimary : CraftTheme.borderLight,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _bgPresets[index]["name"] as String,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : CraftTheme.darkText,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildViewModeChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? CraftTheme.terracottaPrimary : CraftTheme.cardSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? CraftTheme.terracottaPrimary : CraftTheme.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : CraftTheme.darkText,
          ),
        ),
      ),
    );
  }
}

class _BeforeClipper extends CustomClipper<Rect> {
  final double fraction;
  _BeforeClipper(this.fraction);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_BeforeClipper oldClipper) => oldClipper.fraction != fraction;
}


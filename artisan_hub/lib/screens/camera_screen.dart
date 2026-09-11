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
import '../providers/product_draft_provider.dart';
import 'voice_screen.dart';

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
    {"name": "Studio Beige", "color": const Color(0xFFF7F3EE)},
    {"name": "Neutral Grey", "color": const Color(0xFFE8E8E8)},
    {"name": "Craft Terracotta", "color": const Color(0xFFFBEBE8)},
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
    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      appBar: AppBar(
        backgroundColor: CraftTheme.creamBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CraftTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: CraftTheme.tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: CraftTheme.tealTint, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "Photo Studio Assistant",
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CraftTheme.darkText,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_originalBytes == null) _buildPhotoPickerCards(),

                if (_originalBytes != null) ...[
                  _buildStudioComparison(),
                  const SizedBox(height: 20),
                  _buildBackgroundPresetChips(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPickerCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Step 1: Capture or Upload Craft Photo",
          style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        const SizedBox(height: 4),
        Text(
          "Take a clean photo of your craft. The original photo is always preserved.",
          style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.mutedText),
        ),
        const SizedBox(height: 14),

        // Photo Guidance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CraftTheme.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CraftTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BETTER PRODUCT PHOTOS",
                style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text("✓ Good lighting", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText))),
                  Expanded(child: Text("✓ Product clearly visible", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText))),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text("✓ Simple background", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText))),
                  Expanded(child: Text("✓ Show full product", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: CraftTheme.tealLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CraftTheme.tealTint.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              children: [
                CraftTheme.iconBadge(
                  icon: Icons.camera_alt_rounded,
                  color: CraftTheme.tealTint,
                  lightColor: Colors.white,
                  outerSize: 60,
                  innerSize: 42,
                  iconSize: 22,
                ),
                const SizedBox(height: 14),
                Text(
                  "TAKE CRAFT PHOTO",
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.tealTint,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Snap a photo with your device camera",
                  style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.mutedText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.borderLight, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library_rounded, color: CraftTheme.darkText, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Choose from Device Gallery",
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

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
                    fontSize: 16,
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
        const SizedBox(height: 8),

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
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;
            final double handleLeft = (containerWidth * _sliderPos - 18).clamp(0.0, containerWidth - 36);
            final isSplit = _sliderPos > 0.02 && _sliderPos < 0.98;

            return Container(
              height: 320,
              decoration: BoxDecoration(
                color: _bgPresets[_selectedBgIndex]["color"] as Color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CraftTheme.borderLight, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
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
                            color: CraftTheme.tealTint,
                          ),
                        ),

                      // Drag Handle
                      if (isSplit)
                        Positioned(
                          left: handleLeft,
                          top: 140,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: CraftTheme.tealTint,
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
                            decoration: BoxDecoration(color: CraftTheme.tealTint, borderRadius: BorderRadius.circular(999)),
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
                  color: isSelected ? CraftTheme.tealTint : CraftTheme.cardSurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? CraftTheme.tealTint : CraftTheme.borderLight,
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
          color: isActive ? CraftTheme.tealTint : CraftTheme.cardSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? CraftTheme.tealTint : CraftTheme.borderLight,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() {
              _originalBytes = null;
              _enhancedB64 = null;
            }),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              side: const BorderSide(color: CraftTheme.borderLight, width: 1.5),
            ),
            child: Text("Change Photo", style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: CraftTheme.terracottaPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 2,
            ),
            child: Text(
              "CONTINUE TO DESCRIPTION →",
              style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
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

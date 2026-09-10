import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../api_service.dart';
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
  double _sliderPos = 0.5; // Drag position (0.0 to 1.0)
  int _selectedBgIndex = 0;
  String _selectedCraftName = "Handcrafted Artisan Item";

  final List<Map<String, dynamic>> _bgPresets = [
    {"name": "Clean White", "color": Colors.white},
    {"name": "Studio Beige", "color": const Color(0xFFF7F3EE)},
    {"name": "Neutral Grey", "color": const Color(0xFFE8E8E8)},
    {"name": "Craft Terracotta", "color": const Color(0xFFFBEBE8)},
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'craft_photo.jpg';
      _processBytes(bytes, filename, "Uploaded Craft Photo");
    } catch (e) {
      print('Pick Image error: $e');
      // Fallback to sample photo if device camera/picker fails on web
      _loadSampleCraft("Textile Saree");
    }
  }

  Future<void> _processBytes(Uint8List bytes, String filename, String craftName) async {
    setState(() {
      _originalBytes = bytes;
      _enhancedB64 = null;
      _isLoading = true;
      _selectedCraftName = craftName;
    });

    // Send to real remove.bg backend API
    final resultB64 = await ApiService.enhanceImage(bytes, filename);
    
    if (mounted) {
      setState(() {
        if (resultB64 != null && resultB64.isNotEmpty) {
          _enhancedB64 = resultB64;
        } else {
          // Fallback: encode original if API is offline
          final b64 = base64Encode(bytes);
          _enhancedB64 = "data:image/png;base64,$b64";
        }
        _isLoading = false;
      });
    }
  }

  /// Generates real colored sample craft image bytes with background texture
  Future<void> _loadSampleCraft(String type) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 400));
    final paint = Paint();

    // 1. Draw Busy/Wood-texture background (Original Photo)
    paint.color = const Color(0xFF5D4037); // Dark wood floor background
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 400), paint);

    // Wood floor planks texture
    paint.color = const Color(0xFF3E2723);
    for (double i = 0; i < 400; i += 40) {
      canvas.drawRect(Rect.fromLTWH(0, i, 400, 4), paint);
    }
    // Background noise dots
    paint.color = const Color(0xFF8D6E63).withOpacity(0.5);
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(Offset((i * 23) % 400, (i * 37) % 400), 8, paint);
    }

    // 2. Draw Center Craft Object (Craft Item to isolate)
    if (type == "Textile Saree") {
      paint.color = const Color(0xFFD81B60); // Crimson Saree
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(100, 80, 200, 240), const Radius.circular(20)), paint);
      // Gold Zari Border
      paint.color = const Color(0xFFFFD700);
      canvas.drawRect(const Rect.fromLTWH(100, 280, 200, 40), paint);
    } else if (type == "Terracotta Pot") {
      paint.color = const Color(0xFFE64A19); // Terracotta Clay
      canvas.drawOval(const Rect.fromLTWH(110, 100, 180, 200), paint);
      paint.color = const Color(0xFFBF360C);
      canvas.drawRect(const Rect.fromLTWH(150, 70, 100, 40), paint);
    } else {
      paint.color = const Color(0xFFFBC02D); // Gold/Brass Necklace
      canvas.drawCircle(const Offset(200, 200), 90, paint);
      paint.color = const Color(0xFF5D4037);
      canvas.drawCircle(const Offset(200, 200), 60, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 400);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      _processBytes(pngBytes.buffer.asUint8List(), "$type.png", type);
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
              "Image Studio AI",
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Picker Buttons if no image yet
              if (_originalBytes == null) _buildPhotoPickerCards(),

              // Image Studio Interactive View
              if (_originalBytes != null) ...[
                _buildStudioComparison(),
                const SizedBox(height: 24),
                _buildBackgroundPresetChips(),
                const SizedBox(height: 28),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPickerCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 1. Take Photo Card
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: CraftTheme.tealLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CraftTheme.tealTint.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              children: [
                CraftTheme.iconBadge(
                  icon: Icons.camera_alt_rounded,
                  color: CraftTheme.tealTint,
                  lightColor: Colors.white,
                  outerSize: 64,
                  innerSize: 44,
                  iconSize: 24,
                ),
                const SizedBox(height: 16),
                Text(
                  "TAKE CRAFT PHOTO",
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.tealTint,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Snap a photo with your device camera",
                  style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.mutedText),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Choose from Gallery Button
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.borderLight, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library_rounded, color: CraftTheme.darkText, size: 22),
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
        const SizedBox(height: 28),

        // 3. One-Click Sample Craft Photos
        Text(
          "Or test instantly with 1-click sample craft photos:",
          style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ActionChip(
              avatar: const Icon(Icons.checkroom_rounded, color: CraftTheme.terracottaPrimary, size: 18),
              label: Text("Chanderi Silk Saree", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
              backgroundColor: CraftTheme.terracottaLight,
              onPressed: () => _loadSampleCraft("Textile Saree"),
            ),
            ActionChip(
              avatar: const Icon(Icons.local_florist_rounded, color: CraftTheme.tealTint, size: 18),
              label: Text("Terracotta Water Pot", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
              backgroundColor: CraftTheme.tealLight,
              onPressed: () => _loadSampleCraft("Terracotta Pot"),
            ),
            ActionChip(
              avatar: const Icon(Icons.diamond_rounded, color: CraftTheme.violetTint, size: 18),
              label: Text("Brass Jewelry Ornament", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600)),
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
                  "Before / After Comparison",
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
                  Text("Enhancing…", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.tealTint)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Interactive Drag Comparison Container with LayoutBuilder
        LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;
            final double handleLeft = (containerWidth * _sliderPos - 18).clamp(0.0, containerWidth - 36);

            return Container(
              height: 320,
              decoration: BoxDecoration(
                color: _bgPresets[_selectedBgIndex]["color"] as Color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CraftTheme.borderLight, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _sliderPos = (_sliderPos + details.delta.dx / containerWidth).clamp(0.05, 0.95);
                    });
                  },
                  child: Stack(
                    children: [
                      // After Image (Studio Clean Background - matching BoxFit.contain)
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: _enhancedB64 != null
                              ? Image.memory(
                                  base64Decode(_enhancedB64!.split(',').last),
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(_originalBytes!, fit: BoxFit.contain),
                        ),
                      ),

                      // Before Image (Original Upload clipped by slider fraction - matching BoxFit.contain)
                      Positioned.fill(
                        child: ClipRect(
                          clipper: _BeforeClipper(_sliderPos),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Image.memory(_originalBytes!, fit: BoxFit.contain),
                          ),
                        ),
                      ),

                      // Vertical Split Divider Line
                      Positioned(
                        left: containerWidth * _sliderPos - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          color: CraftTheme.tealTint,
                        ),
                      ),

                      // Drag Handle Circle Icon
                      Positioned(
                        left: handleLeft,
                        top: 140,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: CraftTheme.tealTint,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: const Icon(Icons.unfold_more_rounded, color: Colors.white, size: 22),
                        ),
                      ),

                      // Badges
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                          child: Text("Original Photo", style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: CraftTheme.tealTint, borderRadius: BorderRadius.circular(999)),
                          child: Text("Studio AI Enhanced", style: GoogleFonts.notoSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
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
          style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_bgPresets.length, (index) {
            final isSelected = _selectedBgIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedBgIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    fontSize: 13,
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
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
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
              "USE THIS PHOTO →",
              style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
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

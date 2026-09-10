import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme.dart';
import '../api_service.dart';
import '../services/audio_player/audio_player_service.dart';
import '../providers/product_draft_provider.dart';
import '../models/product_facts.dart';
import '../models/catalogue.dart';
import '../widgets/responsive_container.dart';
import 'pricing_screen.dart';

class VoiceScreen extends StatefulWidget {
  final String? initialTranscript;
  const VoiceScreen({super.key, this.initialTranscript});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  bool _isListening = false;
  bool _isLoading = false;
  bool _isPlayingAudio = false;

  String _transcript = "";
  String _title = "Handcrafted Silk Chanderi Saree";
  String _description = "Authentic handwoven Chanderi saree crafted with pure zari thread and organic dye. Soft, breathable, and rich in Indian textile heritage.";
  String _hindiDescription = "प्राकृतिक रंगों और ज़री धागों से निर्मित पारंपरिक चंदेरी साड़ी।";
  List<String> _tags = ["Handloom", "Textile", "Zari", "Festive"];
  String _makerStory = "Woven by 3rd generation master weavers from Chanderi village, keeping traditional handloom art alive.";

  String _category = "Textile";
  String _material = "Pure Handloom Silk";
  String _colorMotif = "Gold Zari & Floral Motifs";
  String _origin = "Chanderi Weaving Village, MP";

  int _selectedLangIndex = 0;
  final List<Map<String, String>> _languages = [
    {"name": "हिंदी (Hindi)", "code": "hi", "locale": "hi-IN", "label": "Hindi"},
    {"name": "বাংলা (Bengali)", "code": "bn", "locale": "bn-IN", "label": "Bengali"},
    {"name": "தமிழ் (Tamil)", "code": "ta", "locale": "ta-IN", "label": "Tamil"},
    {"name": "తెలుగు (Telugu)", "code": "te", "locale": "te-IN", "label": "Telugu"},
    {"name": "मराठी (Marathi)", "code": "mr", "locale": "mr-IN", "label": "Marathi"},
    {"name": "English", "code": "en", "locale": "en-IN", "label": "English"},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.initialTranscript != null && widget.initialTranscript!.isNotEmpty) {
      _transcript = widget.initialTranscript!;
      _fetchAiListing(_transcript);
    }
  }

  @override
  void dispose() {
    _stopAudio();
    super.dispose();
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping audio: $e");
      }
    }
    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  Future<void> _listen() async {
    final langObj = _languages[_selectedLangIndex];
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: langObj["locale"],
          onResult: (val) {
            setState(() {
              _transcript = val.recognizedWords;
            });
            if (val.hasConfidenceRating && val.confidence > 0) {
              _fetchAiListing(_transcript);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _fetchAiListing(String text) async {
    setState(() => _isLoading = true);
    final langObj = _languages[_selectedLangIndex];
    final data = await ApiService.generateListing(text, _category, targetLang: langObj["code"]!);
    if (!mounted) return;
    setState(() {
      _title = data["title"] ?? _title;
      _description = data["description"] ?? _description;
      _hindiDescription = data["regional_description"] ?? data["hindi_description"] ?? _hindiDescription;
      if (data["tags"] != null && (data["tags"] as List).isNotEmpty) {
        _tags = List<String>.from(data["tags"]);
      }
      _makerStory = data["maker_story"] ?? _makerStory;
      _category = data["category"] ?? _category;
      _material = data["material"] ?? _material;
      _colorMotif = data["color_motif"] ?? _colorMotif;
      _origin = data["origin"] ?? _origin;
      _isLoading = false;
    });

    try {
      final provider = ProductDraftProvider.of(context, listen: false);
      provider.updateTranscript(text);
      provider.updateFacts(ProductFacts(
        name: _title,
        category: _category,
        material: _material,
        colorMotif: _colorMotif,
        origin: _origin,
      ));
      provider.updateCatalogue(Catalogue(
        title: _title,
        description: _description,
        regionalDescription: _hindiDescription,
        targetLang: langObj["code"]!,
        tags: _tags,
        makerStory: _makerStory,
      ));
    } catch (_) {}
  }

  Future<void> _speakListing() async {
    if (_isPlayingAudio) {
      await _stopAudio();
      return;
    }

    final langObj = _languages[_selectedLangIndex];
    final textToSpeak = _hindiDescription.isNotEmpty ? _hindiDescription : _description;

    try {
      await _stopAudio();
      if (mounted) setState(() => _isPlayingAudio = true);

      final audioB64 = await ApiService.getTtsAudio(textToSpeak, lang: langObj["code"]!);
      await _audioPlayer.playAudioB64(
        audioB64 ?? '',
        fallbackText: textToSpeak,
        langCode: langObj["code"]!,
        locale: langObj["locale"]!,
        onEnded: () {
          if (mounted) setState(() => _isPlayingAudio = false);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("TTS Audio Playback error: $e");
      }
      if (mounted) setState(() => _isPlayingAudio = false);
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
        title: Text(
          "Step 2: Voice Cataloger AI",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVoiceInputBar(),
                const SizedBox(height: 16),

                _buildLanguageSelectorChips(),
                const SizedBox(height: 20),

                if (_isLoading) ...[
                  const Center(child: CircularProgressIndicator(color: CraftTheme.violetTint)),
                  const SizedBox(height: 20),
                ],

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CraftTheme.violetLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: CraftTheme.violetTint, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "AI Extracted Listing Details (Review Suggested)",
                      style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildAudioPlaybackBar(),
                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () => _editFieldDialog("Title", _title, (v) => setState(() => _title = v)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 18, color: CraftTheme.mutedText),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Text("Search Tags:", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_tags.length, (i) => CraftTheme.tagChip(_tags[i], i)),
                ),
                const SizedBox(height: 18),

                _buildCraftSpecificationsCard(),
                const SizedBox(height: 18),

                GestureDetector(
                  onTap: () => _editFieldDialog("English Description", _description, (v) => setState(() => _description = v)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CraftTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CraftTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Product Description (English)", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                            const Icon(Icons.edit_outlined, size: 16, color: CraftTheme.mutedText),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(_description, style: GoogleFonts.notoSans(fontSize: 14, height: 1.5, color: CraftTheme.darkText)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => _editFieldDialog("विवरण (Regional)", _hindiDescription, (v) => setState(() => _hindiDescription = v)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CraftTheme.violetLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CraftTheme.violetTint.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.g_translate_rounded, size: 16, color: CraftTheme.violetTint),
                                const SizedBox(width: 6),
                                Text("विवरण - क्षेत्रीय भाषा (Regional Description)", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
                              ],
                            ),
                            const Icon(Icons.edit_outlined, size: 16, color: CraftTheme.violetTint),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hindiDescription,
                          style: GoogleFonts.notoSansDevanagari(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: CraftTheme.darkText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CraftTheme.coralLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CraftTheme.coralTint.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_florist_rounded, color: CraftTheme.coralTint, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("MAKER STORY", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.coralTint, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Text(_makerStory, style: GoogleFonts.notoSans(fontSize: 13, height: 1.4, color: CraftTheme.darkText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PricingScreen(
                            title: _title,
                            description: _description,
                            tags: _tags,
                            makerStory: _makerStory,
                            category: _category,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CraftTheme.terracottaPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 2,
                    ),
                    child: Text(
                      "PROCEED TO PRICING →",
                      style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCraftSpecificationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: CraftTheme.terracottaPrimary),
              const SizedBox(width: 6),
              Text(
                "AI Extracted Attributes (Review Suggested)",
                style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSpecChip("CATEGORY", _category, Icons.category_rounded, CraftTheme.violetTint, CraftTheme.violetLight)),
              const SizedBox(width: 8),
              Expanded(child: _buildSpecChip("MATERIAL", _material, Icons.interests_rounded, CraftTheme.tealTint, CraftTheme.tealLight)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSpecChip("MOTIF / COLOR", _colorMotif, Icons.palette_rounded, CraftTheme.terracottaPrimary, CraftTheme.terracottaLight)),
              const SizedBox(width: 8),
              Expanded(child: _buildSpecChip("ORIGIN", _origin, Icons.location_on_rounded, CraftTheme.blueTint, CraftTheme.blueLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label, String val, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.notoSans(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(val, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _listen,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic_rounded, color: _isListening ? Colors.white : CraftTheme.violetTint, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isListening ? "Listening… (LISTEN State)" : "Tap mic to describe product in your language",
                  style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                ),
                if (_transcript.isNotEmpty)
                  Text(_transcript, style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlaybackBar() {
    return GestureDetector(
      onTap: _speakListing,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CraftTheme.violetLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: CraftTheme.violetTint,
                shape: BoxShape.circle,
              ),
              child: Icon(_isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Listen Audio Readback (${_languages[_selectedLangIndex]['name']})", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      14,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 3),
                        width: 3,
                        height: 6.0 + ((i % 3 == 0) ? 10 : (i % 2 == 0) ? 14 : 4),
                        decoration: BoxDecoration(
                          color: CraftTheme.violetTint.withValues(alpha: _isPlayingAudio ? 0.9 : 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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

  Widget _buildLanguageSelectorChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language_rounded, size: 16, color: CraftTheme.violetTint),
            const SizedBox(width: 6),
            Text(
              "Select Regional Language:",
              style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_languages.length, (index) {
              final isSelected = _selectedLangIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedLangIndex = index);
                  if (_transcript.isNotEmpty) {
                    _fetchAiListing(_transcript);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CraftTheme.violetTint : CraftTheme.cardSurface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? CraftTheme.violetTint : CraftTheme.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _languages[index]["name"]!,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : CraftTheme.darkText,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _editFieldDialog(String label, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

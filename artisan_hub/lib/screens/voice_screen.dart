import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:html' as html;
import '../theme.dart';
import '../api_service.dart';
import 'pricing_screen.dart';

class VoiceScreen extends StatefulWidget {
  final String? initialTranscript;
  const VoiceScreen({super.key, this.initialTranscript});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late stt.SpeechToText _speech;
  final FlutterTts _flutterTts = FlutterTts();
  html.AudioElement? _currentAudio;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isPlayingAudio = false;

  String _transcript = "";
  String _title = "Handcrafted Silk Chanderi Saree";
  String _description = "Authentic handwoven Chanderi saree crafted with pure zari thread and organic dye. Soft, breathable, and rich in Indian textile heritage.";
  String _hindiDescription = "प्राकृतिक रंगों और ज़री धागों से निर्मित पारंपरिक चंदेरी साड़ी।";
  List<String> _tags = ["Handloom", "Textile", "Zari", "Festive"];
  String _makerStory = "Woven by 3rd generation master weavers from Chanderi village, keeping traditional handloom art alive.";

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
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio = null;
      }
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping audio: $e");
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
    final data = await ApiService.generateListing(text, "Textile", targetLang: langObj["code"]!);
    setState(() {
      _title = data["title"] ?? _title;
      _description = data["description"] ?? _description;
      _hindiDescription = data["regional_description"] ?? data["hindi_description"] ?? _hindiDescription;
      if (data["tags"] != null && (data["tags"] as List).isNotEmpty) {
        _tags = List<String>.from(data["tags"]);
      }
      _makerStory = data["maker_story"] ?? _makerStory;
      _isLoading = false;
    });
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

      // 1. Fetch real gTTS MP3 audio base64 from FastAPI backend
      final audioB64 = await ApiService.getTtsAudio(textToSpeak, lang: langObj["code"]!);
      if (audioB64 != null && audioB64.isNotEmpty) {
        _currentAudio = html.AudioElement(audioB64);
        _currentAudio!.onEnded.listen((_) {
          if (mounted) setState(() => _isPlayingAudio = false);
        });
        _currentAudio!.onPause.listen((_) {
          if (mounted) setState(() => _isPlayingAudio = false);
        });
        await _currentAudio!.play();
      } else {
        // Fallback to flutter_tts
        await _flutterTts.setLanguage(langObj["locale"]!);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.85);
        await _flutterTts.speak(textToSpeak);
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) setState(() => _isPlayingAudio = false);
      }
    } catch (e) {
      print("TTS Audio Playback error: $e");
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
          "Cataloger AI",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
      ),
      body: Stack(
        children: [
          // Background Soft Dashed Decorative Circle Accent
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CraftTheme.violetTint.withOpacity(0.12),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voice Mic Trigger Bar
                  _buildVoiceInputBar(),
                  const SizedBox(height: 18),

                  // Multilingual Language Chips Selector
                  _buildLanguageSelectorChips(),
                  const SizedBox(height: 20),

                  if (_isLoading) ...[
                    const Center(child: CircularProgressIndicator(color: CraftTheme.violetTint)),
                    const SizedBox(height: 20),
                  ],

                  // 1. Violet Quill Header Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CraftTheme.violetLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: CraftTheme.violetTint, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Your Listing",
                        style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Audio Playback Readback Bar
                  _buildAudioPlaybackBar(),
                  const SizedBox(height: 20),

                  // 3. Generated Product Title (Tap to edit)
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
                  const SizedBox(height: 14),

                  // 4. Multi-Colored Tag Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_tags.length, (i) => CraftTheme.tagChip(_tags[i], i)),
                  ),
                  const SizedBox(height: 20),

                  // 5. Description Block (Tap to edit)
                  GestureDetector(
                    onTap: () => _editFieldDialog("Description", _description, (v) => setState(() => _description = v)),
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
                              Text("Description", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
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

                  // 5b. Hindi Description Card (विवरण - हिंदी में)
                  GestureDetector(
                    onTap: () => _editFieldDialog("विवरण (Hindi)", _hindiDescription, (v) => setState(() => _hindiDescription = v)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CraftTheme.violetLight.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CraftTheme.violetTint.withOpacity(0.3), width: 1.5),
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
                                  Text("विवरण (Hindi Description)", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
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
                  const SizedBox(height: 16),

                  // 6. Coral Maker Story Callout Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CraftTheme.coralLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CraftTheme.coralTint.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_florist_rounded, color: CraftTheme.coralTint, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MAKER STORY", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.coralTint, letterSpacing: 1.0)),
                              const SizedBox(height: 4),
                              Text(_makerStory, style: GoogleFonts.notoSans(fontSize: 13, height: 1.4, color: CraftTheme.darkText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Proceed to Pricing Button
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
                              category: "Textile",
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
                        "CALCULATE FAIR PRICE →",
                        style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  _isListening ? "Listening…" : "Tap mic to refine description",
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
                  Text("Listen in ${_languages[_selectedLangIndex]['label']} (${_languages[_selectedLangIndex]['name']})", style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      14,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: 3),
                        width: 3,
                        height: 6.0 + ((i % 3 == 0) ? 10 : (i % 2 == 0) ? 14 : 4),
                        decoration: BoxDecoration(
                          color: CraftTheme.violetTint.withOpacity(_isPlayingAudio ? 0.9 : 0.4),
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
              "Select Regional Language (भाषा चुनें):",
              style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                      fontSize: 13,
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

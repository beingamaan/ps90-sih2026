import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme.dart';
import '../api_service.dart';
import '../services/audio_player/audio_player_service.dart';
import '../providers/product_draft_provider.dart';
import '../models/product_facts.dart';
import '../models/trust_claim.dart';
import '../models/catalogue.dart';
import '../widgets/responsive_container.dart';
import '../widgets/product_facts_review_widget.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/craft_buttons.dart';
import 'pricing_screen.dart';
import 'home_screen.dart';

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

  ProductFacts _facts = const ProductFacts(
    name: "Handcrafted Silk Chanderi Saree",
    category: "Textile",
    material: "Pure Handloom Silk",
    colorMotif: "Gold Zari & Floral Motifs",
    origin: "Chanderi Weaving Village, MP",
    craftTechnique: "Handloom Weaving",
  );
  List<TrustClaim> _trustClaims = const [
    TrustClaim(claimName: "Handloom Mark", isSensitive: true, provenanceStatus: 'EVIDENCE_REQUIRED', notes: 'Requires evidence / seller verification'),
    TrustClaim(claimName: "Pure Silk", isSensitive: true, provenanceStatus: 'EVIDENCE_REQUIRED', notes: 'Requires evidence / seller verification'),
  ];

  int _selectedLangIndex = 0;
  final List<Map<String, String>> _languages = [
    {"name": "हिंदी (Hindi)", "code": "hi", "locale": "hi-IN", "label": "Hindi"},
    {"name": "বাংলা (Bengali)", "code": "bn", "locale": "bn-IN", "label": "Bengali"},
    {"name": "தமிழ் (Tamil)", "code": "ta", "locale": "ta-IN", "label": "Tamil"},
    {"name": "తెలుగు (Telugu)", "code": "te", "locale": "te-IN", "label": "Telugu"},
    {"name": "मराठी (Marathi)", "code": "mr", "locale": "mr-IN", "label": "Marathi"},
    {"name": "English", "code": "en", "locale": "en-IN", "label": "English"},
  ];

  String? _activePromptHint;

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

      _facts = ProductFacts(
        name: _title,
        category: _category,
        material: _material,
        colorMotif: _colorMotif,
        origin: _origin,
        craftTechnique: data["craft_technique"] ?? "Handloom Weaving",
        statusMap: {
          'category': FactStatus.aiSuggested,
          'material': FactStatus.aiSuggested,
          'color_motif': FactStatus.aiSuggested,
          'origin': FactStatus.aiSuggested,
          'craft_technique': FactStatus.aiSuggested,
        },
      );
      _isLoading = false;
    });

    try {
      final provider = ProductDraftProvider.of(context, listen: false);
      provider.updateTranscript(text);
      provider.updateFacts(_facts);
      provider.updateTrustClaims(_trustClaims);
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

                  // 2. STEP PROGRESS BAR (Step 2 Active)
                  const StepProgressBar(currentStep: 2),
                  const SizedBox(height: 24),

                  // 3. MAIN EDITORIAL CONTENT
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildHeroVoicePanel()),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: _buildRightContentColumn()),
                      ],
                    )
                  else ...[
                    _buildHeroVoicePanel(),
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
                color: CraftTheme.violetLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mic_rounded, color: CraftTheme.violetTint, size: 22),
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
                    color: CraftTheme.violetTint,
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

  // ─── 2. HERO VOICE PANEL ──────────────────────────────
  Widget _buildHeroVoicePanel() {
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
          // Voice Storytelling Box
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CraftTheme.violetLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.violetTint.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Stack(
              children: [
                // Static Waveform Motif Graphics
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      18,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: 4,
                        height: 20.0 + ((i % 4 == 0) ? 60 : (i % 3 == 0) ? 40 : (i % 2 == 0) ? 80 : 15),
                        decoration: BoxDecoration(
                          color: CraftTheme.violetTint.withValues(alpha: _isListening ? 0.9 : 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Center Mic Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetTint,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetTint).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(Icons.mic_rounded, color: Colors.white, size: 36),
                  ),
                ),

                // Prompt Bubbles Overlay
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildPromptBubble("Materials?"),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildPromptBubble("How is it made?"),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _buildPromptBubble("Where is it from?"),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _buildPromptBubble("What makes it special?"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "VOICE STORYTELLING",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.violetTint,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Speak naturally in your native language. No technical terms required.",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CraftTheme.borderLight),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: CraftTheme.violetTint),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CraftTheme.darkText,
            ),
          ),
        ],
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
            color: CraftTheme.violetLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "STEP 2 OF 5 • DESCRIBE",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.violetTint,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "Speak naturally about your craft",
          style: GoogleFonts.notoSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "Describe materials, techniques, origin, and your craft story in your natural language.",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            height: 1.5,
            color: CraftTheme.mutedText,
          ),
        ),
        const SizedBox(height: 20),

        // VOICE INPUT BAR & LANGUAGE CHIPS
        _buildVoiceInputBar(),
        const SizedBox(height: 14),

        _buildLanguageSelectorChips(),
        const SizedBox(height: 20),

        // TELL YOUR STORY CARD
        _buildTellYourStoryCard(),
        const SizedBox(height: 20),

        // GUIDED PROMPTS
        _buildGuidedPromptsSection(),
        const SizedBox(height: 20),

        // TRUST BANNER
        _buildTrustBanner(),
        const SizedBox(height: 20),

        // EXAMPLE CARD
        _buildExampleCard(),
        const SizedBox(height: 24),

        // AUDIO READBACK BAR
        _buildAudioPlaybackBar(),
        const SizedBox(height: 20),

        if (_isLoading) ...[
          const Center(child: CircularProgressIndicator(color: CraftTheme.violetTint)),
          const SizedBox(height: 20),
        ],

        // EDITABLE STORY & TITLE PREVIEW
        _buildEditableListingFields(),
        const SizedBox(height: 24),

        // ACTIONS AREA
        _buildActionButtons(),
      ],
    );
  }

  // ─── VOICE INPUT BAR ──────────────────────────────────
  Widget _buildVoiceInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CraftTheme.violetTint.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _listen,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetTint,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetTint).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.mic_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isListening ? "Listening… (Speak freely now)" : "DESCRIBE BY VOICE",
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isListening ? CraftTheme.terracottaPrimary : CraftTheme.violetTint,
                  ),
                ),
                Text(
                  _transcript.isNotEmpty ? _transcript : "Tap mic to speak about your craft in your language",
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: _transcript.isNotEmpty ? CraftTheme.darkText : CraftTheme.mutedText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── LANGUAGE SELECTOR CHIPS ──────────────────────────
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
              style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
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

  // ─── TELL YOUR STORY CARD ─────────────────────────────
  Widget _buildTellYourStoryCard() {
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
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: CraftTheme.violetTint),
              const SizedBox(width: 8),
              Text(
                "TELL YOUR STORY",
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.violetTint,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildStoryInfoBlock("SPEAK FREELY", "Use your own words.", Icons.record_voice_over_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _buildStoryInfoBlock("NATURAL LANGUAGE", "No perfect wording required.", Icons.translate_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildStoryInfoBlock("AI STRUCTURES", "Helps structure facts.", Icons.data_object_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryInfoBlock(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CraftTheme.creamBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: CraftTheme.violetTint),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.mutedText),
          ),
        ],
      ),
    );
  }

  // ─── GUIDED PROMPTS ───────────────────────────────────
  Widget _buildGuidedPromptsSection() {
    final prompts = [
      {"label": "MATERIALS", "q": "What is it made from?", "hint": "e.g., Pure silk zari threads, organic dye..."},
      {"label": "TECHNIQUE", "q": "How do you make it?", "hint": "e.g., Traditional pit loom weaving..."},
      {"label": "ORIGIN", "q": "Where is it made?", "hint": "e.g., Chanderi artisan cluster, MP..."},
      {"label": "STORY", "q": "What makes it special?", "hint": "e.g., Handcrafted by 3rd gen weavers..."},
    ];

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
            "NOT SURE WHAT TO SAY?",
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: CraftTheme.mutedText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts.map((p) {
              final isSelected = _activePromptHint == p["hint"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activePromptHint = isSelected ? null : p["hint"];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? CraftTheme.violetTint : CraftTheme.violetLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? CraftTheme.violetTint : CraftTheme.violetTint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p["label"]!,
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : CraftTheme.violetTint,
                        ),
                      ),
                      Text(
                        p["q"]!,
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          color: isSelected ? Colors.white.withValues(alpha: 0.9) : CraftTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_activePromptHint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CraftTheme.violetLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Prompt idea: \"$_activePromptHint\"",
                style: GoogleFonts.notoSans(fontSize: 11, fontStyle: FontStyle.italic, color: CraftTheme.violetTint),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── TRUST BANNER ─────────────────────────────────────
  Widget _buildTrustBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CraftTheme.tealLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.tealTint.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: CraftTheme.tealTint, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI SUGGESTS. YOU DECIDE.",
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.tealTint,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "AI-generated product facts remain under seller review. You retain full control over your catalogue listing.",
                  style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.darkText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── EXAMPLE CARD ─────────────────────────────────────
  Widget _buildExampleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CraftTheme.creamBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: CraftTheme.terracottaLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "EXAMPLE",
              style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "\"Handwoven cotton basket, made in 3 days with natural dye...\"",
              style: GoogleFonts.notoSans(fontSize: 12, fontStyle: FontStyle.italic, color: CraftTheme.mutedText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AUDIO PLAYBACK BAR ───────────────────────────────
  Widget _buildAudioPlaybackBar() {
    return GestureDetector(
      onTap: _speakListing,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: CraftTheme.violetLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CraftTheme.violetTint.withValues(alpha: 0.3)),
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
                  Text(
                    "Listen Audio Readback (${_languages[_selectedLangIndex]['name']})",
                    style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.violetTint),
                  ),
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

  // ─── EDITABLE FIELDS PREVIEW ──────────────────────────
  Widget _buildEditableListingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _editFieldDialog("Title", _title, (v) => setState(() => _title = v)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Product Title", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                      const SizedBox(height: 4),
                      Text(
                        _title,
                        style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, size: 18, color: CraftTheme.mutedText),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Product Facts Review Widget Embedded
        ProductFactsReviewWidget(
          facts: _facts,
          trustClaims: _trustClaims,
          onFactsChanged: (newFacts) {
            setState(() {
              _facts = newFacts;
              _category = newFacts.category;
              _material = newFacts.material;
              _colorMotif = newFacts.colorMotif;
              _origin = newFacts.origin;
            });
            try {
              ProductDraftProvider.of(context, listen: false).updateFacts(newFacts);
            } catch (_) {}
          },
          onTrustClaimsChanged: (newClaims) {
            setState(() {
              _trustClaims = newClaims;
            });
            try {
              ProductDraftProvider.of(context, listen: false).updateTrustClaims(newClaims);
            } catch (_) {}
          },
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => _editFieldDialog("English Description", _description, (v) => setState(() => _description = v)),
          child: Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Product Description (English)", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                    const Icon(Icons.edit_outlined, size: 16, color: CraftTheme.mutedText),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_description, style: GoogleFonts.notoSans(fontSize: 14, height: 1.5, color: CraftTheme.darkText)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => _editFieldDialog("विवरण (Regional)", _hindiDescription, (v) => setState(() => _hindiDescription = v)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.violetLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.violetTint.withValues(alpha: 0.3)),
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
                        Text("विवरण - क्षेत्रीय भाषा (Regional Description)", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.violetTint)),
                      ],
                    ),
                    const Icon(Icons.edit_outlined, size: 16, color: CraftTheme.violetTint),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _hindiDescription,
                  style: GoogleFonts.notoSansDevanagari(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600, color: CraftTheme.darkText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── ACTIONS AREA ─────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        CraftPrimaryButton(
          label: "CONTINUE TO REVIEW →",
          icon: Icons.verified_user_rounded,
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
        ),
        const SizedBox(height: 10),
        CraftSecondaryButton(
          label: "Change Photo / Retake",
          icon: Icons.photo_camera_outlined,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _editFieldDialog(String label, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $label", style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CraftTheme.terracottaPrimary),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


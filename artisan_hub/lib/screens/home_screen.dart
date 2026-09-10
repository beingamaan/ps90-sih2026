import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';
import '../widgets/responsive_container.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/craft_chip.dart';
import '../widgets/compact_product_card.dart';
import '../providers/product_draft_provider.dart';
import 'camera_screen.dart';
import 'voice_screen.dart';
import 'voice_overlay.dart';
import 'pricing_screen.dart';
import 'my_items_screen.dart';
import 'approval_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  List<dynamic> _realProducts = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    final items = await ApiService.fetchItems();
    if (!mounted) return;
    setState(() {
      _realProducts = items;
      _isLoadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = ProductDraftProvider.of(context);
    final activeDraft = draftProvider.currentDraft;
    final bool hasActiveDraft = activeDraft.rawTranscript.isNotEmpty || activeDraft.hasImage;

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
                  // 1. Header: Brand Identity & Subtitle
                  _buildHeader(context),
                  const SizedBox(height: 16),

                  // 2. Primary Hero Action Card: CREATE PRODUCT (Visually Dominant)
                  _buildCreateProductHeroCard(context),
                  const SizedBox(height: 20),

                  // 3. Seller Readiness Journey Bar
                  Text(
                    "SELLER READINESS JOURNEY",
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CraftTheme.mutedText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const StepProgressBar(currentStep: 1),
                  const SizedBox(height: 24),

                  // 4. YOUR WORK / CONTINUE DRAFT
                  _buildActiveWorkSection(context, hasActiveDraft, activeDraft),
                  const SizedBox(height: 24),

                  // 5. MY PRODUCTS (Real SQLite Data)
                  _buildMyProductsSection(context),
                  const SizedBox(height: 24),

                  // 6. COMPACT MANAGEMENT SHORTCUTS
                  _buildCompactShortcutsSection(context),
                  const SizedBox(height: 20),

                  // 7. Craft Categories Quick Filters
                  _buildCraftCategoriesRow(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600 ? _buildBottomNavBar(context) : null,
    );
  }

  // ─── 1. BRAND HEADER ─────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CraftTheme.terracottaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: CraftTheme.terracottaPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "CraftBridge",
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Your craft. Your story. Ready to sell.",
              style: GoogleFonts.notoSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CraftTheme.mutedText,
              ),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: CraftTheme.cardSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: CraftTheme.borderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: CraftTheme.terracottaPrimary),
              const SizedBox(width: 4),
              Text(
                "Artisan Hub",
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 2. HERO ACTION CARD: CREATE PRODUCT ──────────────
  Widget _buildCreateProductHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CraftTheme.terracottaPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CraftTheme.terracottaPrimary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "SELLER ASSISTANT",
                  style: GoogleFonts.notoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            "Create Digital Product",
            style: GoogleFonts.notoSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Snap a photo + speak your story to build a market-ready listing.",
            style: GoogleFonts.notoSans(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CameraScreen()),
                    ).then((_) => _loadProducts());
                  },
                  icon: const Icon(Icons.camera_alt_rounded, color: CraftTheme.terracottaPrimary, size: 18),
                  label: Text(
                    "+ CREATE PRODUCT",
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CraftTheme.terracottaPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const VoiceOverlay(),
                    );
                  },
                  icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                  label: Text(
                    "Voice Story",
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 4. YOUR WORK / CONTINUE DRAFT ───────────────────
  Widget _buildActiveWorkSection(BuildContext context, bool hasActiveDraft, dynamic activeDraft) {
    final title = hasActiveDraft
        ? (activeDraft.catalogue.title.isNotEmpty
            ? activeDraft.catalogue.title
            : (activeDraft.rawTranscript.isNotEmpty ? activeDraft.rawTranscript : "Untitled Craft Draft"))
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR WORK / CONTINUE",
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        if (hasActiveDraft)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.terracottaPrimary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: CraftTheme.terracottaLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_document, color: CraftTheme.terracottaPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "CONTINUE PRODUCT DRAFT",
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: CraftTheme.terracottaPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          CraftStatusChip.fromStatus(activeDraft.approval.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CraftTheme.darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: CraftTheme.terracottaPrimary, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceScreen(initialTranscript: activeDraft.rawTranscript),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: CraftTheme.mutedText, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Start your first product listing using photo or voice story above.",
                    style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── 5. MY PRODUCTS (Real SQLite Data) ────────────────
  Widget _buildMyProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "MY PRODUCTS",
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: CraftTheme.darkText,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyItemsScreen()),
                ).then((_) => _loadProducts());
              },
              child: Text(
                "View Catalog (${_realProducts.length}) →",
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.terracottaPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_isLoadingProducts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: CraftTheme.terracottaPrimary),
            ),
          )
        else if (_realProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Text(
              "No saved listings yet. Your created products will appear here.",
              style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.mutedText),
            ),
          )
        else
          Column(
            children: List.generate(
              _realProducts.length > 3 ? 3 : _realProducts.length,
              (index) {
                final item = _realProducts[index];
                final title = item["title"] ?? "Untitled Craft";
                final category = item["category"] ?? "Handicraft";
                final status = item["status"] ?? "Draft";
                final price = (item["buyer_price"] as num?)?.toDouble();

                return CompactProductCard(
                  title: title,
                  category: category,
                  status: status,
                  price: price,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyItemsScreen()),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // ─── 6. COMPACT MANAGEMENT SHORTCUTS ─────────────────
  Widget _buildCompactShortcutsSection(BuildContext context) {
    final shortcuts = [
      {
        "title": "My Catalog",
        "subtitle": "View saved items",
        "icon": Icons.inventory_2_rounded,
        "color": CraftTheme.blueTint,
        "bg": CraftTheme.blueLight,
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyItemsScreen())),
      },
      {
        "title": "Fair Price",
        "subtitle": "Calculate wage floor",
        "icon": Icons.payments_rounded,
        "color": CraftTheme.greenTint,
        "bg": CraftTheme.greenLight,
        "onTap": () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PricingScreen(
                  title: "Chanderi Silk Saree",
                  description: "Handcrafted silk saree",
                  tags: ["Silk", "Textile"],
                  makerStory: "Handmade by local weavers",
                  category: "Textile",
                ),
              ),
            ),
      },
      {
        "title": "Order Readiness",
        "subtitle": "Check export readiness",
        "icon": Icons.local_shipping_rounded,
        "color": CraftTheme.amberTint,
        "bg": CraftTheme.amberLight,
        "onTap": () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ApprovalScreen(
                  title: "Handcrafted Chanderi Saree",
                  description: "Authentic handwoven saree",
                  tags: ["Silk", "Handloom"],
                  makerStory: "Woven by traditional artisans",
                  costFloor: 2500,
                  buyerPrice: 3850,
                  category: "Textile",
                ),
              ),
            ),
      },
      {
        "title": "Image Studio",
        "subtitle": "Enhance product photo",
        "icon": Icons.auto_fix_high_rounded,
        "color": CraftTheme.tealTint,
        "bg": CraftTheme.tealLight,
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "QUICK TOOLS",
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        Column(
          children: List.generate(shortcuts.length, (index) {
            final s = shortcuts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: CraftTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CraftTheme.borderLight),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: s["bg"] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s["icon"] as IconData, color: s["color"] as Color, size: 18),
                ),
                title: Text(
                  s["title"] as String,
                  style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                ),
                subtitle: Text(
                  s["subtitle"] as String,
                  style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: CraftTheme.mutedText),
                onTap: s["onTap"] as VoidCallback,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── 7. CRAFT CATEGORIES ROW ───────────────────────────
  Widget _buildCraftCategoriesRow(BuildContext context) {
    final categories = [
      {"name": "Textiles", "icon": Icons.content_cut_rounded, "color": CraftTheme.violetTint, "bg": CraftTheme.violetLight},
      {"name": "Pottery", "icon": Icons.local_florist_rounded, "color": CraftTheme.tealTint, "bg": CraftTheme.tealLight},
      {"name": "Woodcraft", "icon": Icons.park_rounded, "color": CraftTheme.blueTint, "bg": CraftTheme.blueLight},
      {"name": "Jewelry", "icon": Icons.diamond_rounded, "color": CraftTheme.terracottaPrimary, "bg": CraftTheme.terracottaLight},
      {"name": "Metalware", "icon": Icons.hardware_rounded, "color": CraftTheme.amberTint, "bg": CraftTheme.amberLight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CRAFT CATEGORIES",
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceScreen(
                          initialTranscript: "Handcrafted ${cat["name"]} item",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: cat["bg"] as Color,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: (cat["color"] as Color).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(cat["icon"] as IconData, color: cat["color"] as Color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          cat["name"] as String,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CraftTheme.darkText,
                          ),
                        ),
                      ],
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

  // ─── 8. BOTTOM NAVIGATION BAR (MOBILE) ────────────────
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      selectedItemColor: CraftTheme.terracottaPrimary,
      unselectedItemColor: CraftTheme.mutedText,
      backgroundColor: CraftTheme.cardSurface,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold),
      unselectedLabelStyle: GoogleFonts.notoSans(fontSize: 11),
      onTap: (index) {
        setState(() => _currentNavIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyItemsScreen())).then((_) => _loadProducts());
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())).then((_) => _loadProducts());
        } else if (index == 3) {
          showDialog(context: context, builder: (_) => const VoiceOverlay());
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded),
          label: "Catalog",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_a_photo_rounded),
          label: "Create",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mic_rounded),
          label: "Voice",
        ),
      ],
    );
  }
}


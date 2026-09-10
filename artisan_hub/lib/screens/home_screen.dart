import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'voice_overlay.dart';
import 'camera_screen.dart';
import 'voice_screen.dart';
import 'pricing_screen.dart';
import 'my_items_screen.dart';
import 'approval_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CraftTheme.creamBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Artisan Profile & Notification Bell
              _buildHeader(context),
              const SizedBox(height: 18),

              // Quick Earnings & Performance Stat Bar
              _buildPerformanceMetricsBar(),
              const SizedBox(height: 20),

              // Dominant Terracotta Voice Action Hero Card
              _buildVoiceActionHeroCard(context),
              const SizedBox(height: 24),

              // Craft Categories Selector
              _buildCraftCategoriesRow(context),
              const SizedBox(height: 24),

              // Management Tools (4 Tiles)
              _buildQuickActionGrid(context),
              const SizedBox(height: 24),

              // Live ONDC Orders Notification Banner
              _buildLiveOrdersBanner(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 1. ARTISAN PROFILE HEADER ────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: CraftTheme.terracottaLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: CraftTheme.terracottaPrimary, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Namaste, Artisan! 🙏",
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CraftTheme.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 13, color: CraftTheme.terracottaPrimary),
                    const SizedBox(width: 3),
                    Text(
                      "Chanderi Craft Cluster, MP",
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CraftTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Notification Bell with Active Badge
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: CraftTheme.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: CraftTheme.borderLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.notifications_outlined, color: CraftTheme.darkText, size: 22),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: CraftTheme.terracottaPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── 2. PERFORMANCE METRICS BAR ─────────────────────────
  Widget _buildPerformanceMetricsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricColumn("MONTHLY SALES", "₹18,450", Icons.trending_up_rounded, const Color(0xFF2E7D32)),
          Container(width: 1, height: 32, color: CraftTheme.borderLight),
          _buildMetricColumn("ACTIVE ITEMS", "14 Listings", Icons.storefront_rounded, CraftTheme.violetTint),
          Container(width: 1, height: 32, color: CraftTheme.borderLight),
          _buildMetricColumn("NETWORK", "ONDC Live", Icons.verified_rounded, CraftTheme.blueTint),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 0.5),
        ),
      ],
    );
  }

  // ─── 3. HERO VOICE ACTION CARD ──────────────────────────
  Widget _buildVoiceActionHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD64527), Color(0xFFF26A4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: CraftTheme.terracottaPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Craft Motif Ring
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 16),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "AI Cataloging Assistant",
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.graphic_eq_rounded, color: Colors.white70, size: 28),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                "Digitize & Sell Your Craft",
                style: GoogleFonts.notoSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Speak in Hindi or your regional language to automatically build e-commerce listings.",
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 22),

              // Action Buttons Row
              Row(
                children: [
                  // 1. Voice Mic Trigger Button
                  Expanded(
                    flex: 6,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const VoiceOverlay(),
                        );
                      },
                      icon: const Icon(Icons.mic_rounded, color: CraftTheme.terracottaPrimary, size: 22),
                      label: Text(
                        "Voice Listing",
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CraftTheme.terracottaPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Image Studio Camera Button
                  Expanded(
                    flex: 5,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraScreen()),
                        );
                      },
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      label: Text(
                        "Image Studio",
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
        ],
      ),
    );
  }

  // ─── 4. CRAFT CATEGORIES ROW ───────────────────────────
  Widget _buildCraftCategoriesRow(BuildContext context) {
    final categories = [
      {"name": "Textiles", "icon": Icons.content_cut_rounded, "color": CraftTheme.violetTint, "bg": CraftTheme.violetLight},
      {"name": "Pottery", "icon": Icons.local_florist_rounded, "color": CraftTheme.tealTint, "bg": CraftTheme.tealLight},
      {"name": "Woodcraft", "icon": Icons.park_rounded, "color": CraftTheme.blueTint, "bg": CraftTheme.blueLight},
      {"name": "Jewelry", "icon": Icons.diamond_rounded, "color": CraftTheme.terracottaPrimary, "bg": CraftTheme.terracottaLight},
      {"name": "Metalware", "icon": Icons.hardware_rounded, "color": const Color(0xFFE65100), "bg": const Color(0xFFFFF3E0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Craft Categories",
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CraftTheme.darkText,
              ),
            ),
            Text(
              "Tap to catalog",
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CraftTheme.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
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
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cat["bg"] as Color,
                          shape: BoxShape.circle,
                          border: Border.all(color: (cat["color"] as Color).withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(cat["icon"] as IconData, color: cat["color"] as Color, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat["name"] as String,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CraftTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── 5. MANAGEMENT TOOLS (4 TILES) ──────────────────────
  Widget _buildQuickActionGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Management & Growth Tools",
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CraftTheme.darkText,
          ),
        ),
        const SizedBox(height: 14),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.28,
          children: [
            _buildGridTile(
              context,
              title: "My Catalog",
              subtitle: "14 Active Listings",
              icon: Icons.inventory_2_rounded,
              color: CraftTheme.blueTint,
              bg: CraftTheme.blueLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyItemsScreen())),
            ),
            _buildGridTile(
              context,
              title: "Fair Pricing",
              subtitle: "Wage Guardrails",
              icon: Icons.payments_rounded,
              color: CraftTheme.greenTint,
              bg: CraftTheme.greenLight,
              onTap: () => Navigator.push(
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
            ),
            _buildGridTile(
              context,
              title: "ONDC Network",
              subtitle: "Publishing Hub",
              icon: Icons.hub_rounded,
              color: CraftTheme.violetTint,
              bg: CraftTheme.violetLight,
              onTap: () => Navigator.push(
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
            ),
            _buildGridTile(
              context,
              title: "Image Studio",
              subtitle: "AI Bg Removal",
              icon: Icons.auto_fix_high_rounded,
              color: CraftTheme.tealTint,
              bg: CraftTheme.tealLight,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CraftTheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CraftTheme.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CraftTheme.iconBadge(
              icon: icon,
              color: color,
              lightColor: bg,
              outerSize: 44,
              innerSize: 30,
              iconSize: 18,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: CraftTheme.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 6. LIVE ONDC ORDERS NOTIFICATION BANNER ────────────
  Widget _buildLiveOrdersBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CraftTheme.tealLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CraftTheme.tealTint.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: CraftTheme.tealTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent ONDC Network Sale! 🎉",
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: CraftTheme.tealTint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "1x Terracotta Matka ordered from Bengaluru • ₹1,250",
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: CraftTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: CraftTheme.tealTint),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyItemsScreen())),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';
import 'my_items_screen.dart';

class ApprovalScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> tags;
  final String makerStory;
  final double costFloor;
  final double buyerPrice;
  final String category;

  const ApprovalScreen({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.makerStory,
    required this.costFloor,
    required this.buyerPrice,
    required this.category,
  });

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  int _selectedNetwork = 0; // 0: ONDC Network, 1: GeM Portal
  bool _isPublishing = false;
  bool _isSuccess = false;
  String _listingId = "";
  String _liveUrl = "";

  final List<Map<String, dynamic>> _networks = [
    {
      "name": "ONDC Network",
      "subtitle": "Open Network for Digital Commerce (Paytm, Mystore, Craftsvilla)",
      "badge": "Popular",
      "icon": Icons.hub_rounded,
    },
    {
      "name": "GeM Portal",
      "subtitle": "Government e-Marketplace (Public Procurement & Tribal Cooperative)",
      "badge": "Govt Verified",
      "icon": Icons.account_balance_rounded,
    },
  ];

  Future<void> _publishNow() async {
    setState(() => _isPublishing = true);

    final payload = {
      "title": widget.title,
      "description": widget.description,
      "tags": widget.tags,
      "maker_story": widget.makerStory,
      "cost_floor": widget.costFloor,
      "buyer_price": widget.buyerPrice,
      "category": widget.category,
      "image_url": "https://example.com/craft.jpg",
      "marketplace": _networks[_selectedNetwork]["name"]
    };

    // Real call to backend POST /mock-publish endpoint (1.5s simulated network delay)
    final res = await ApiService.mockPublish(payload);

    setState(() {
      _isPublishing = false;
      _isSuccess = true;
      _listingId = res["listing_id"] ?? "ONDC-IND-1084";
      _liveUrl = res["live_url"] ?? "https://ondc.in/catalog/1084";
    });
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
          "Publishing Network",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSuccess) ...[
                // Network Selectable Cards
                Text("Select Marketplace Destination", style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                const SizedBox(height: 14),

                Column(
                  children: List.generate(_networks.length, (index) {
                    final net = _networks[index];
                    final isSelected = _selectedNetwork == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedNetwork = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected ? CraftTheme.blueLight : CraftTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? CraftTheme.blueTint : CraftTheme.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CraftTheme.iconBadge(
                              icon: net["icon"] as IconData,
                              color: CraftTheme.blueTint,
                              lightColor: Colors.white,
                              outerSize: 48,
                              innerSize: 32,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(net["name"] as String, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: CraftTheme.blueTint, borderRadius: BorderRadius.circular(999)),
                                        child: Text(net["badge"] as String, style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(net["subtitle"] as String, style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                                ],
                              ),
                            ),
                            Radio<int>(
                              value: index,
                              groupValue: _selectedNetwork,
                              activeColor: CraftTheme.blueTint,
                              onChanged: (val) => setState(() => _selectedNetwork = val!),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Product Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: CraftTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CraftTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("LISTING PREVIEW", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Text(widget.title, style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                      const SizedBox(height: 6),
                      Text("Buyer Price: ₹${widget.buyerPrice.toInt()}", style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Publish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPublishing ? null : _publishNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CraftTheme.terracottaPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 2,
                    ),
                    child: _isPublishing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                              const SizedBox(width: 12),
                              Text("Publishing to ONDC Network…", style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          )
                        : Text(
                            "PUBLISH NOW →",
                            style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                          ),
                  ),
                ),
              ],

              // Success Screen View
              if (_isSuccess) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: CraftTheme.greenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: CraftTheme.greenTint, size: 64),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Live on Marketplace!",
                        style: GoogleFonts.notoSans(fontSize: 24, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Listing ID: $_listingId",
                        style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w600, color: CraftTheme.mutedText),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: CraftTheme.cardSurface, borderRadius: BorderRadius.circular(999), border: Border.all(color: CraftTheme.borderLight)),
                        child: Text(_liveUrl, style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.blueTint, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MyItemsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CraftTheme.terracottaPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Text("VIEW IN MY ITEMS →", style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

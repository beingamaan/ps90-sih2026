import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';
import '../providers/product_draft_provider.dart';
import '../models/product_facts.dart';
import '../models/fulfilment_profile.dart';
import '../widgets/responsive_container.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/craft_buttons.dart';
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
  int _selectedNetwork = 0; // 0: ONDC Export Schema, 1: GeM Export Schema
  bool _isPublishing = false;
  bool _isSuccess = false;
  String _listingId = "";
  String _liveUrl = "";

  final List<Map<String, dynamic>> _networks = [
    {
      "name": "ONDC Export Schema",
      "subtitle": "Formatted schema ready for Open Network for Digital Commerce buyer apps",
      "badge": "Standard",
      "icon": Icons.hub_rounded,
    },
    {
      "name": "GeM Export Schema",
      "subtitle": "Formatted schema ready for Government e-Marketplace procurement",
      "badge": "Govt Format",
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

    final res = await ApiService.mockPublish(payload);

    setState(() {
      _isPublishing = false;
      _isSuccess = true;
      _listingId = res["listing_id"] ?? "EXP-IND-1084";
      _liveUrl = res["live_url"] ?? "https://craftbridge.in/catalog/1084";
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
          "Seller Approval & Export",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContainer(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepProgressBar(currentStep: 6),
                  const SizedBox(height: 20),

                  if (!_isSuccess) ...[
                    // Network Selectable Cards
                    Text(
                      "Select Export Channel Destination",
                      style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                    ),
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
                                          Text(
                                            net["name"] as String,
                                            style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: CraftTheme.blueTint, borderRadius: BorderRadius.circular(999)),
                                            child: Text(
                                              net["badge"] as String,
                                              style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        net["subtitle"] as String,
                                        style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<int>(
                                  value: index,
                                  groupValue: _selectedNetwork,
                                  activeColor: CraftTheme.blueTint,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedNetwork = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Product Summary Card
                    Builder(
                      builder: (context) {
                        ProductFacts facts = const ProductFacts();
                        List<dynamic> trustClaims = const [];
                        try {
                          final draft = ProductDraftProvider.of(context, listen: false).currentDraft;
                          facts = draft.facts;
                          trustClaims = draft.trustClaims;
                        } catch (_) {}

                        final activeClaims = trustClaims.where((c) => c.provenanceStatus != 'CLAIM_EXCLUDED').toList();
                        final excludedClaims = trustClaims.where((c) => c.provenanceStatus == 'CLAIM_EXCLUDED').toList();

                        return Container(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "LISTING PREVIEW",
                                    style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 1.0),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: CraftTheme.greenLight,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      "Seller Verified Draft",
                                      style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.greenTint),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.title,
                                style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                              ),
                              const SizedBox(height: 8),
                              
                              // Provenance & Facts Summary Chips
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (facts.material.isNotEmpty)
                                    _buildStatusChip("Material: ${facts.material}", facts.getFieldStatus('material')),
                                  if (facts.origin.isNotEmpty)
                                    _buildStatusChip("Origin: ${facts.origin}", facts.getFieldStatus('origin')),
                                  ...activeClaims.map((c) => _buildStatusChip("${c.claimName}", c.provenanceStatus == 'EVIDENCE_SUBMITTED' ? 'Evidence Submitted' : 'Self Declared', isTeal: c.provenanceStatus == 'EVIDENCE_SUBMITTED')),
                                  ...excludedClaims.map((c) => _buildStatusChip("${c.claimName}", "Not claimed", isGrey: true)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // Phase 3.2 Order Readiness Summary Section
                              Builder(
                                builder: (_) {
                                  FulfilmentProfile fulfilment = const FulfilmentProfile();
                                  try {
                                    fulfilment = ProductDraftProvider.of(context, listen: false).currentDraft.fulfilment;
                                  } catch (_) {}

                                  final readinessState = fulfilment.readinessState;
                                  final readinessScore = fulfilment.readinessScore;

                                  Color badgeBg = CraftTheme.greenLight;
                                  Color badgeFg = CraftTheme.greenTint;
                                  if (readinessState == 'CONDITIONAL') {
                                    badgeBg = CraftTheme.amberLight;
                                    badgeFg = CraftTheme.amberTint;
                                  } else if (readinessState == 'NEEDS PREPARATION') {
                                    badgeBg = CraftTheme.coralLight;
                                    badgeFg = CraftTheme.coralTint;
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "ORDER READINESS",
                                            style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 0.8),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                                            child: Text(
                                              "$readinessState • $readinessScore/100",
                                              style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: badgeFg),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Stock: ${fulfilment.stockStatus} | Prep time: ${fulfilment.leadTimeDays} days | Dispatch: ${fulfilment.dispatchStatus}",
                                        style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText),
                                      ),
                                      if (fulfilment.sellerNote.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          "Note: ${fulfilment.sellerNote}",
                                          style: GoogleFonts.notoSans(fontSize: 10, fontStyle: FontStyle.italic, color: CraftTheme.mutedText),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Artisan Floor: ₹${widget.costFloor.toInt()}",
                                    style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: CraftTheme.tealTint),
                                  ),
                                  Text(
                                    "Buyer Price: ₹${widget.buyerPrice.toInt()}",
                                    style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Publish Button
                    CraftPrimaryButton(
                      label: _isPublishing ? "Generating Export Schema..." : "APPROVE & EXPORT NOW →",
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: _isPublishing,
                      onPressed: _isPublishing ? () {} : _publishNow,
                    ),
                  ],

                  // Success Screen View
                  if (_isSuccess) ...[
                    const SizedBox(height: 20),
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
                            "Export-Ready Item Created!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Export ID: $_listingId",
                            style: GoogleFonts.notoSans(fontSize: 15, fontWeight: FontWeight.w600, color: CraftTheme.mutedText),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: CraftTheme.cardSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: CraftTheme.borderLight),
                            ),
                            child: Text(
                              _liveUrl,
                              style: GoogleFonts.notoSans(fontSize: 13, color: CraftTheme.blueTint, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 40),
                          CraftPrimaryButton(
                            label: "VIEW IN MY CATALOG →",
                            icon: Icons.inventory_2_rounded,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MyItemsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, {bool isTeal = false, bool isGrey = false}) {
    Color bg = CraftTheme.blueLight;
    Color fg = CraftTheme.blueTint;

    if (isGrey) {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade700;
    } else if (isTeal) {
      bg = CraftTheme.tealLight;
      fg = CraftTheme.tealTint;
    } else if (status == FactStatus.sellerConfirmed) {
      bg = CraftTheme.greenLight;
      fg = CraftTheme.greenTint;
    } else if (status == FactStatus.aiSuggested) {
      bg = CraftTheme.amberLight;
      fg = CraftTheme.amberTint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        "$label • $status",
        style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}


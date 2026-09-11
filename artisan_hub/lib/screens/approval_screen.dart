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
  bool _isConfirmedBySeller = false;
  bool _isPrepAcknowledged = false;
  bool _isPublishing = false;
  bool _isSuccess = false;
  String _listingId = "";
  String _liveUrl = "";

  final List<Map<String, dynamic>> _networks = [
    {
      "name": "ONDC Channel-Ready Schema",
      "subtitle": "Formatted schema ready for Open Network for Digital Commerce buyer networks",
      "badge": "ONDC Schema",
      "icon": Icons.hub_rounded,
    },
    {
      "name": "GeM Channel-Ready Schema",
      "subtitle": "Formatted schema ready for Government e-Marketplace procurement fields",
      "badge": "GeM Schema",
      "icon": Icons.account_balance_rounded,
    },
  ];

  Future<void> _publishNow() async {
    setState(() => _isPublishing = true);

    String imageUrl = "https://example.com/craft.jpg";
    try {
      final draft = ProductDraftProvider.of(context, listen: false).currentDraft;
      if (draft.enhancedImageB64 != null && draft.enhancedImageB64!.isNotEmpty) {
        imageUrl = draft.enhancedImageB64!;
      }
    } catch (_) {}

    final payload = {
      "title": widget.title,
      "description": widget.description,
      "tags": widget.tags,
      "maker_story": widget.makerStory,
      "cost_floor": widget.costFloor,
      "buyer_price": widget.buyerPrice,
      "category": widget.category,
      "image_url": imageUrl,
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
    ProductFacts facts = const ProductFacts();
    List<dynamic> trustClaims = const [];
    FulfilmentProfile fulfilment = const FulfilmentProfile();

    try {
      final draft = ProductDraftProvider.of(context, listen: false).currentDraft;
      facts = draft.facts;
      trustClaims = draft.trustClaims;
      fulfilment = draft.fulfilment;
    } catch (_) {}

    final readinessState = fulfilment.readinessState;
    final readinessScore = fulfilment.readinessScore;
    final activeClaims = trustClaims.where((c) => c.provenanceStatus != 'CLAIM_EXCLUDED').toList();
    final excludedClaims = trustClaims.where((c) => c.provenanceStatus == 'CLAIM_EXCLUDED').toList();

    // Check approval gating blockers
    final List<String> gatingBlockers = [];
    if (widget.title.trim().isEmpty) gatingBlockers.add("Product title is required");
    if (widget.description.trim().isEmpty) gatingBlockers.add("Product description is required");
    if (widget.buyerPrice <= 0) gatingBlockers.add("Buyer price must be specified");
    if (facts.getFieldStatus('material') == FactStatus.reviewRequired ||
        facts.getFieldStatus('craft_technique') == FactStatus.reviewRequired ||
        facts.getFieldStatus('origin') == FactStatus.reviewRequired) {
      gatingBlockers.add("Required Product Facts marked 'Review Required' must be resolved");
    }

    final isNeedsPrep = readinessState == 'NEEDS PREPARATION';
    final canApprove = gatingBlockers.isEmpty && _isConfirmedBySeller && (!isNeedsPrep || _isPrepAcknowledged);

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
          "Seller Review & Export Approval",
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
                  const StepProgressBar(currentStep: 5),
                  const SizedBox(height: 20),

                  if (!_isSuccess) ...[
                    // Screen Title & Positioning
                    Text(
                      "REVIEW & APPROVE",
                      style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Review your product before sharing. CraftBridge assists with formatting; seller remains final approval authority.",
                      style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 01: PRODUCT FACTS
                    _buildSectionHeader("01 PRODUCT FACTS", Icons.inventory_outlined),
                    const SizedBox(height: 8),
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                                ),
                              ),
                              _buildStatusChip("Category: ${widget.category}", "Seller Confirmed"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (facts.material.isNotEmpty)
                                _buildStatusChip("Material: ${facts.material}", facts.getFieldStatus('material')),
                              if (facts.craftTechnique.isNotEmpty)
                                _buildStatusChip("Technique: ${facts.craftTechnique}", facts.getFieldStatus('craft_technique')),
                              if (facts.origin.isNotEmpty)
                                _buildStatusChip("Origin: ${facts.origin}", facts.getFieldStatus('origin')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("Description:", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                          const SizedBox(height: 2),
                          Text(widget.description, style: GoogleFonts.notoSans(fontSize: 13, height: 1.4, color: CraftTheme.darkText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 02: TRUST & CLAIMS
                    _buildSectionHeader("02 TRUST & CLAIMS", Icons.verified_user_outlined),
                    const SizedBox(height: 8),
                    Container(
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
                          if (activeClaims.isEmpty && excludedClaims.isEmpty) ...[
                            Text("No sensitive claims detected or declared.", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                          ] else ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ...activeClaims.map((c) => _buildStatusChip(
                                  "${c.claimName}",
                                  c.provenanceStatus == 'EVIDENCE_SUBMITTED' ? 'Evidence Submitted' : 'Self Declared',
                                  isTeal: c.provenanceStatus == 'EVIDENCE_SUBMITTED',
                                )),
                                ...excludedClaims.map((c) => _buildStatusChip("${c.claimName}", "Not claimed", isGrey: true)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Note: Seller-submitted evidence is pending independent verification. It does not imply external government certification.",
                              style: GoogleFonts.notoSans(fontSize: 10, fontStyle: FontStyle.italic, color: CraftTheme.mutedText),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 03: PRICING
                    _buildSectionHeader("03 PRICING", Icons.payments_outlined),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CraftTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CraftTheme.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Artisan Cost Floor", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                              const SizedBox(height: 2),
                              Text("₹${widget.costFloor.toInt()}", style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.tealTint)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Buyer Listing Price", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                              const SizedBox(height: 2),
                              Text("₹${widget.buyerPrice.toInt()}", style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.terracottaPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 04: ORDER READINESS
                    _buildSectionHeader("04 ORDER READINESS", Icons.inventory_2_outlined),
                    const SizedBox(height: 8),
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Readiness State: $readinessState", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: readinessState == 'READY' ? CraftTheme.greenLight : (readinessState == 'CONDITIONAL' ? CraftTheme.amberLight : CraftTheme.coralLight),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  "Score: $readinessScore/100",
                                  style: GoogleFonts.notoSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: readinessState == 'READY' ? CraftTheme.greenTint : (readinessState == 'CONDITIONAL' ? CraftTheme.amberTint : CraftTheme.coralTint),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Stock: ${fulfilment.stockStatus} | Artisan Prep Time: ${fulfilment.leadTimeDays} days | Dispatch: ${fulfilment.dispatchStatus}",
                            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Based on seller-provided information, the seller has declared key operational details. (Does NOT guarantee fulfilment or delivery).",
                            style: GoogleFonts.notoSans(fontSize: 10, fontStyle: FontStyle.italic, color: CraftTheme.mutedText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Warnings & Gating Feedback Section
                    if (gatingBlockers.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: CraftTheme.coralLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: CraftTheme.coralTint.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Action Required Before Approval:", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.coralTint)),
                            const SizedBox(height: 4),
                            ...gatingBlockers.map((b) => Text("• $b", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (isNeedsPrep) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: CraftTheme.amberLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: CraftTheme.amberTint.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 18, color: CraftTheme.amberTint),
                                const SizedBox(width: 6),
                                Text("Order Readiness: Needs Preparation", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.amberTint)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Your current operational information indicates preparation is required.", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText)),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text("I understand this product needs preparation before an order can be fulfilled.", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                              value: _isPrepAcknowledged,
                              onChanged: (val) => setState(() => _isPrepAcknowledged = val ?? false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (readinessState == 'CONDITIONAL') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CraftTheme.blueLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CraftTheme.blueTint.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          "Conditional — review the highlighted operational conditions before sharing.",
                          style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.blueTint, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Export Schema Selector
                    Text("Select Prepared Export Schema Destination", style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(_networks.length, (index) {
                        final net = _networks[index];
                        final isSelected = _selectedNetwork == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedNetwork = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? CraftTheme.blueLight : CraftTheme.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? CraftTheme.blueTint : CraftTheme.borderLight, width: isSelected ? 2 : 1),
                            ),
                            child: Row(
                              children: [
                                Icon(net["icon"] as IconData, color: CraftTheme.blueTint, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(net["name"] as String, style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                                      Text(net["subtitle"] as String, style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // FINAL SELLER REVIEW & CONFIRMATION BOX
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CraftTheme.creamBase,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CraftTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("FINAL SELLER REVIEW & CONFIRMATION", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 0.6)),
                          const SizedBox(height: 6),
                          Text(
                            "AI suggestions are assistance only. Review and confirm the information before sharing. Your approval confirms that you reviewed the information. It does not independently verify product claims.",
                            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText, height: 1.4),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "I have reviewed the product information, pricing, trust/claim status, and order readiness.",
                              style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                            ),
                            value: _isConfirmedBySeller,
                            onChanged: (val) => setState(() => _isConfirmedBySeller = val ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Publish / Export Button
                    CraftPrimaryButton(
                      label: _isPublishing ? "Generating Export Schema..." : "APPROVE & PREPARE FOR SHARING →",
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: _isPublishing,
                      onPressed: canApprove && !_isPublishing ? _publishNow : () {},
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
                            "Seller-Approved Catalogue Schema Created!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(fontSize: 22, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Export Schema ID: $_listingId",
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: CraftTheme.terracottaPrimary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText, letterSpacing: 0.8),
        ),
      ],
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



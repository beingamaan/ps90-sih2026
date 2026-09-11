import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/product_facts.dart';
import '../models/trust_claim.dart';

/// Clean, mobile-first seller fact review widget (Screen 3: REVIEW / SELLER CONTROL).
/// Enforces the core CraftBridge rule: AI suggests. Seller decides.
/// Sensitive claims require seller verification/evidence and are NEVER auto-verified.
class ProductFactsReviewWidget extends StatefulWidget {
  final ProductFacts facts;
  final List<TrustClaim> trustClaims;
  final ValueChanged<ProductFacts> onFactsChanged;
  final ValueChanged<List<TrustClaim>>? onTrustClaimsChanged;

  const ProductFactsReviewWidget({
    super.key,
    required this.facts,
    this.trustClaims = const [],
    required this.onFactsChanged,
    this.onTrustClaimsChanged,
  });

  @override
  State<ProductFactsReviewWidget> createState() => _ProductFactsReviewWidgetState();
}

class _ProductFactsReviewWidgetState extends State<ProductFactsReviewWidget> {
  late ProductFacts _currentFacts;
  late List<TrustClaim> _currentClaims;
  bool _isLegendExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentFacts = widget.facts;
    _currentClaims = List.from(widget.trustClaims);
    _ensureDefaultSensitiveClaims();
  }

  @override
  void didUpdateWidget(covariant ProductFactsReviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facts != widget.facts) {
      _currentFacts = widget.facts;
      _ensureDefaultSensitiveClaims();
    }
    if (oldWidget.trustClaims != widget.trustClaims) {
      _currentClaims = List.from(widget.trustClaims);
      _ensureDefaultSensitiveClaims();
    }
  }

  void _ensureDefaultSensitiveClaims() {
    final combinedText = "${_currentFacts.material} ${_currentFacts.craftTechnique} ${_currentFacts.category} ${_currentFacts.origin}".toLowerCase();
    
    final candidateTerms = [
      'GI',
      'GI Tag',
      'Handloom',
      'Handloom Mark',
      'Pure Silk',
      'Silk Mark',
      'Khadi',
      'Organic',
    ];

    for (final term in candidateTerms) {
      if (combinedText.contains(term.toLowerCase())) {
        final exists = _currentClaims.any((c) => c.claimName.toLowerCase() == term.toLowerCase());
        if (!exists) {
          _currentClaims.add(TrustClaim(
            claimName: term,
            isSensitive: true,
            provenanceStatus: 'EVIDENCE_REQUIRED',
            isApproved: false,
            notes: 'Requires seller verification or evidence reference',
          ));
        }
      }
    }
  }

  void _notifyChanges() {
    widget.onFactsChanged(_currentFacts);
    if (widget.onTrustClaimsChanged != null) {
      widget.onTrustClaimsChanged!(_currentClaims);
    }
  }

  void _confirmFact(String fieldKey) {
    final newApprovalMap = Map<String, bool>.from(_currentFacts.approvalMap);
    final newStatusMap = Map<String, String>.from(_currentFacts.statusMap);
    newApprovalMap[fieldKey] = true;
    newStatusMap[fieldKey] = FactStatus.sellerConfirmed;

    setState(() {
      _currentFacts = _currentFacts.copyWith(
        approvalMap: newApprovalMap,
        statusMap: newStatusMap,
      );
    });
    _notifyChanges();
  }

  void _editFactDialog(String fieldKey, String label, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit $label", style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter corrected value",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CraftTheme.terracottaPrimary),
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                final newApprovalMap = Map<String, bool>.from(_currentFacts.approvalMap);
                final newStatusMap = Map<String, String>.from(_currentFacts.statusMap);
                final newSourceMap = Map<String, String>.from(_currentFacts.sourceMap);

                newApprovalMap[fieldKey] = true;
                newStatusMap[fieldKey] = FactStatus.sellerConfirmed;
                newSourceMap[fieldKey] = 'Seller Entry';

                setState(() {
                  switch (fieldKey) {
                    case 'category':
                      _currentFacts = _currentFacts.copyWith(category: newValue);
                      break;
                    case 'material':
                      _currentFacts = _currentFacts.copyWith(material: newValue);
                      break;
                    case 'color_motif':
                      _currentFacts = _currentFacts.copyWith(colorMotif: newValue);
                      break;
                    case 'origin':
                      _currentFacts = _currentFacts.copyWith(origin: newValue);
                      break;
                    case 'craft_technique':
                      _currentFacts = _currentFacts.copyWith(craftTechnique: newValue);
                      break;
                  }
                  _currentFacts = _currentFacts.copyWith(
                    approvalMap: newApprovalMap,
                    statusMap: newStatusMap,
                    sourceMap: newSourceMap,
                  );
                });
                _notifyChanges();
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save & Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmTrustClaim(int index, String status) {
    setState(() {
      final old = _currentClaims[index];
      _currentClaims[index] = old.copyWith(
        provenanceStatus: status,
        isApproved: true,
      );
    });
    _notifyChanges();
  }

  void _addEvidenceDialog(int index) {
    final old = _currentClaims[index];
    final controller = TextEditingController(text: old.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add Evidence Reference: ${old.claimName}", style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter certificate reference, reg number, or evidence note:", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Reg No: GI/2023/44, Handloom Mark ID 901",
              ),
            ),
            const SizedBox(height: 8),
            Text("Note: Seller-submitted evidence is pending independent verification.", style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.amberTint)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CraftTheme.tealTint),
            onPressed: () {
              final note = controller.text.trim();
              setState(() {
                _currentClaims[index] = old.copyWith(
                  provenanceStatus: 'EVIDENCE_SUBMITTED',
                  isApproved: true,
                  notes: note.isNotEmpty 
                      ? "$note (Pending independent verification)" 
                      : 'Evidence reference added by seller (Pending independent verification)',
                );
              });
              _notifyChanges();
              Navigator.pop(ctx);
            },
            child: const Text("Attach Reference", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _excludeClaim(int index) {
    setState(() {
      final old = _currentClaims[index];
      _currentClaims[index] = old.copyWith(
        provenanceStatus: 'CLAIM_EXCLUDED',
        isApproved: false,
        notes: 'Claim excluded by seller',
      );
    });
    _notifyChanges();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'key': 'category', 'label': 'Product Category', 'val': _currentFacts.category, 'icon': Icons.category_rounded},
      {'key': 'material', 'label': 'Material', 'val': _currentFacts.material, 'icon': Icons.interests_rounded},
      {'key': 'craft_technique', 'label': 'Craft Technique', 'val': _currentFacts.craftTechnique, 'icon': Icons.brush_rounded},
      {'key': 'color_motif', 'label': 'Motif / Color', 'val': _currentFacts.colorMotif, 'icon': Icons.palette_rounded},
      {'key': 'origin', 'label': 'Origin / Region', 'val': _currentFacts.origin, 'icon': Icons.location_on_rounded},
    ];

    // Compute progress stats derived from actual state
    int confirmedCount = 0;
    int reviewNeededCount = 0;

    for (var f in fields) {
      final key = f['key'] as String;
      final isApproved = _currentFacts.approvalMap[key] == true;
      if (isApproved) {
        confirmedCount++;
      } else {
        reviewNeededCount++;
      }
    }

    int claimsAttentionCount = _currentClaims.where((c) => c.provenanceStatus == 'EVIDENCE_REQUIRED' || !c.isApproved).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO REVIEW COMPOSITION PANEL (Pale Sage / Muted Teal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CraftTheme.tealLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CraftTheme.tealTint.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: CraftTheme.tealTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fact_check_rounded, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "STEP 3 OF 5 • REVIEW",
                              style: GoogleFonts.notoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: CraftTheme.tealTint,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              "Review AI-suggested product facts",
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CraftTheme.darkText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: CraftTheme.tealTint.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        "REVIEW → EDIT → CONFIRM",
                        style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.tealTint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "AI suggestions remain under seller review. Confirm, edit, or exclude claims before continuing.",
                  style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.darkText, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. SELLER CONTROL BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.creamBase,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 20, color: CraftTheme.tealTint),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI SUGGESTS. YOU DECIDE.",
                        style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.tealTint, letterSpacing: 0.8),
                      ),
                      Text(
                        "You remain the final authority over product information.",
                        style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. REVIEW PROGRESS SUMMARY CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CraftTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat("Facts to review", "$reviewNeededCount", CraftTheme.amberTint),
                Container(height: 24, width: 1, color: CraftTheme.borderLight),
                _buildSummaryStat("Claims requiring attention", "$claimsAttentionCount", CraftTheme.amberTint),
                Container(height: 24, width: 1, color: CraftTheme.borderLight),
                _buildSummaryStat("Seller-confirmed", "$confirmedCount", CraftTheme.tealTint),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. FACT REVIEW ROWS
          Text(
            "PRODUCT FACTS",
            style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.darkText, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),

          ...fields.map((field) {
            final key = field['key'] as String;
            final label = field['label'] as String;
            final val = (field['val'] as String).isEmpty ? 'Not specified' : field['val'] as String;
            final icon = field['icon'] as IconData;
            final isApproved = _currentFacts.approvalMap[key] == true;
            final status = _currentFacts.statusMap[key] ?? (isApproved ? FactStatus.sellerConfirmed : FactStatus.aiSuggested);
            final source = _currentFacts.sourceMap[key] ?? 'AI Suggested';

            return _buildFactRow(
              key: key,
              label: label,
              val: val,
              icon: icon,
              status: status,
              source: source,
              isApproved: isApproved,
            );
          }),

          // 5. SENSITIVE / REGULATED CLAIMS REVIEW
          if (_currentClaims.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.verified_outlined, size: 18, color: CraftTheme.amberTint),
                const SizedBox(width: 8),
                Text(
                  "SENSITIVE / REGULATED CLAIMS",
                  style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.amberTint, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Regulated claims require seller confirmation or reference notes. Never automatically verified.",
              style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
            ),
            const SizedBox(height: 12),

            ...List.generate(_currentClaims.length, (idx) {
              final claim = _currentClaims[idx];
              return _buildSensitiveClaimCard(claim, idx);
            }),
          ],

          const SizedBox(height: 16),

          // 6. TRUST LEGEND (Collapsible)
          GestureDetector(
            onTap: () => setState(() => _isLegendExpanded = !_isLegendExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CraftTheme.creamBase,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CraftTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: CraftTheme.tealTint),
                      const SizedBox(width: 8),
                      Text(
                        "TRUST LEGEND (Status Definitions)",
                        style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.tealTint),
                      ),
                    ],
                  ),
                  Icon(
                    _isLegendExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: CraftTheme.tealTint,
                  ),
                ],
              ),
            ),
          ),
          if (_isLegendExpanded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CraftTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CraftTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _LegendItem(title: "AI SUGGESTED", desc: "Generated suggestion awaiting seller review."),
                  _LegendItem(title: "SELLER CONFIRMED", desc: "Seller has reviewed & confirmed the information."),
                  _LegendItem(title: "SELF DECLARED", desc: "Seller states claim; no independent verification implied."),
                  _LegendItem(title: "EVIDENCE REQUIRED", desc: "Additional evidence is needed before claim can be treated as evidence-backed."),
                  _LegendItem(title: "EVIDENCE SUBMITTED", desc: "Seller-submitted evidence is pending independent verification."),
                  _LegendItem(title: "CLAIM EXCLUDED", desc: "Seller chose not to include the claim."),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.w600, color: CraftTheme.mutedText)),
      ],
    );
  }

  Widget _buildFactRow({
    required String key,
    required String label,
    required String val,
    required IconData icon,
    required String status,
    required String source,
    required bool isApproved,
  }) {
    Color badgeBg;
    Color badgeText;

    if (status == FactStatus.sellerConfirmed || isApproved) {
      badgeBg = CraftTheme.tealLight;
      badgeText = CraftTheme.tealTint;
    } else if (status == FactStatus.selfDeclared) {
      badgeBg = CraftTheme.violetLight;
      badgeText = CraftTheme.violetTint;
    } else {
      badgeBg = CraftTheme.amberLight;
      badgeText = CraftTheme.amberTint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isApproved ? CraftTheme.tealLight.withValues(alpha: 0.25) : CraftTheme.creamBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApproved ? CraftTheme.tealTint.withValues(alpha: 0.3) : CraftTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: CraftTheme.mutedText),
                  const SizedBox(width: 6),
                  Text(label, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  status,
                  style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: badgeText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: CraftTheme.darkText)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Source: $source",
                style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.captionText, fontStyle: FontStyle.italic),
              ),
              Row(
                children: [
                  if (!isApproved)
                    InkWell(
                      onTap: () => _confirmFact(key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CraftTheme.tealTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("Confirm", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _editFactDialog(key, label, val),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CraftTheme.cardSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CraftTheme.borderLight),
                      ),
                      child: Text("Edit", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
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

  Widget _buildSensitiveClaimCard(TrustClaim claim, int index) {
    final status = claim.provenanceStatus;
    final isExcluded = status == 'CLAIM_EXCLUDED';
    final isEvidenceSubmitted = status == 'EVIDENCE_SUBMITTED';
    final isSelfDeclared = status == 'SELF_DECLARED';

    Color bg = CraftTheme.amberLight.withValues(alpha: 0.6);
    Color border = CraftTheme.amberTint.withValues(alpha: 0.35);
    String statusBadge = "Requires evidence / review";
    Color statusBadgeColor = CraftTheme.amberTint;

    if (isExcluded) {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      statusBadge = "Claim Excluded";
      statusBadgeColor = Colors.grey.shade700;
    } else if (isEvidenceSubmitted) {
      bg = CraftTheme.tealLight;
      border = CraftTheme.tealTint.withValues(alpha: 0.4);
      statusBadge = "Evidence Submitted (Pending Verification)";
      statusBadgeColor = CraftTheme.tealTint;
    } else if (isSelfDeclared || claim.isApproved) {
      bg = CraftTheme.violetLight;
      border = CraftTheme.violetTint.withValues(alpha: 0.4);
      statusBadge = "Self Declared";
      statusBadgeColor = CraftTheme.violetTint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  claim.claimName,
                  style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  statusBadge,
                  style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusBadgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isExcluded
                ? "This sensitive claim will be omitted from the trusted catalogue export."
                : (claim.notes.isNotEmpty ? claim.notes : "Requires seller verification or evidence reference note before export."),
            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isExcluded && !isEvidenceSubmitted && !isSelfDeclared) ...[
                InkWell(
                  onTap: () => _confirmTrustClaim(index, 'SELF_DECLARED'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CraftTheme.violetTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Confirm Self-Declared", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (!isExcluded && !isEvidenceSubmitted) ...[
                InkWell(
                  onTap: () => _addEvidenceDialog(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CraftTheme.tealTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Add Evidence", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (!isExcluded)
                InkWell(
                  onTap: () => _excludeClaim(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CraftTheme.borderLight),
                    ),
                    child: Text("Do not claim", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String title;
  final String desc;

  const _LegendItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title: ", style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
          Expanded(child: Text(desc, style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.mutedText))),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/product_facts.dart';
import '../models/trust_claim.dart';

/// Clean, mobile-first seller fact review widget.
/// Enforces the core product rule: AI suggests. Seller verifies.
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

  /// Automatically inspects extracted text/fields for sensitive regulated terms
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
                hintText: "e.g. Registration No: GI/2023/44, Handloom Mark ID 901",
              ),
            ),
            const SizedBox(height: 8),
            Text("Note: Evidence reference will be marked as 'Evidence Submitted'. It does not imply external independent verification.", style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.amberTint)),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CraftTheme.terracottaLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.verified_user_outlined, size: 18, color: CraftTheme.terracottaPrimary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "PRODUCT FACTS",
                    style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CraftTheme.amberLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "Seller Review Required",
                  style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.bold, color: CraftTheme.amberTint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "AI suggests facts. Tap Confirm or Edit to make facts seller-approved.",
            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Standard Fact Rows
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

          // Sensitive Claims Review Section
          if (_currentClaims.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: CraftTheme.coralTint),
                const SizedBox(width: 6),
                Text(
                  "SENSITIVE / REGULATED CLAIMS",
                  style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.coralTint, letterSpacing: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Regulated claims require seller confirmation or reference notes. Never automatically verified.",
              style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.mutedText),
            ),
            const SizedBox(height: 12),

            ...List.generate(_currentClaims.length, (idx) {
              final claim = _currentClaims[idx];
              return _buildSensitiveClaimCard(claim, idx);
            }),
          ],
        ],
      ),
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
      badgeBg = CraftTheme.greenLight;
      badgeText = CraftTheme.greenTint;
    } else if (status == FactStatus.selfDeclared) {
      badgeBg = CraftTheme.blueLight;
      badgeText = CraftTheme.blueTint;
    } else {
      badgeBg = CraftTheme.amberLight;
      badgeText = CraftTheme.amberTint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isApproved ? CraftTheme.greenLight.withValues(alpha: 0.2) : CraftTheme.creamBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved ? CraftTheme.greenTint.withValues(alpha: 0.3) : CraftTheme.borderLight,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Source: $source",
                style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.mutedText, fontStyle: FontStyle.italic),
              ),
              Row(
                children: [
                  if (!isApproved)
                    InkWell(
                      onTap: () => _confirmFact(key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CraftTheme.greenTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("Confirm", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _editFactDialog(key, label, val),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CraftTheme.cardSurface,
                        borderRadius: BorderRadius.circular(6),
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

    Color bg = CraftTheme.amberLight.withValues(alpha: 0.5);
    Color border = CraftTheme.amberTint.withValues(alpha: 0.3);
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
      statusBadge = "Evidence Submitted";
      statusBadgeColor = CraftTheme.tealTint;
    } else if (isSelfDeclared || claim.isApproved) {
      bg = CraftTheme.blueLight;
      border = CraftTheme.blueTint.withValues(alpha: 0.4);
      statusBadge = "Self Declared";
      statusBadgeColor = CraftTheme.blueTint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                : (claim.notes.isNotEmpty ? claim.notes : "Requires seller verification / evidence reference before export."),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CraftTheme.blueTint,
                      borderRadius: BorderRadius.circular(6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CraftTheme.tealTint,
                      borderRadius: BorderRadius.circular(6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Text("Do not claim", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

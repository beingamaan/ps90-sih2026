import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/fulfilment_profile.dart';

/// Polished, mobile-first Order Readiness Widget (Phase 3.2).
/// Empowers artisans to answer: "Can I realistically accept this order right now?"
/// Rule-based, transparent score derived ONLY from seller-provided operational inputs.
class OrderReadinessWidget extends StatefulWidget {
  final FulfilmentProfile profile;
  final ValueChanged<FulfilmentProfile> onProfileChanged;

  const OrderReadinessWidget({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  @override
  State<OrderReadinessWidget> createState() => _OrderReadinessWidgetState();
}

class _OrderReadinessWidgetState extends State<OrderReadinessWidget> {
  late FulfilmentProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  void didUpdateWidget(covariant OrderReadinessWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _profile = widget.profile;
    }
  }

  void _updateProfile(FulfilmentProfile updated) {
    setState(() => _profile = updated);
    widget.onProfileChanged(updated);
  }

  void _editLeadTimeDialog() {
    final controller = TextEditingController(text: _profile.leadTimeDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Artisan Preparation Time", style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter estimated artisan preparation/production time in days.",
              style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
            ),
            const SizedBox(height: 4),
            Text(
              "Note: This represents seller preparation time only, NOT courier delivery.",
              style: GoogleFonts.notoSans(fontSize: 11, fontStyle: FontStyle.italic, color: CraftTheme.amberTint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: "days",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CraftTheme.terracottaPrimary),
            onPressed: () {
              final val = int.tryParse(controller.text) ?? _profile.leadTimeDays;
              _updateProfile(_profile.copyWith(leadTimeDays: val));
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editSellerNoteDialog() {
    final controller = TextEditingController(text: _profile.sellerNote);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Seller Operational Notes", style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add custom preparation or fulfillment constraints (e.g., 'Large bulk orders require 7 days advance notice').",
              style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter operational note or constraint...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CraftTheme.terracottaPrimary),
            onPressed: () {
              _updateProfile(_profile.copyWith(sellerNote: controller.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text("Save Note", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _profile.readinessState;
    final score = _profile.readinessScore;
    final explanation = _profile.readinessExplanation;

    Color stateBg;
    Color stateFg;
    IconData stateIcon;

    if (state == 'READY') {
      stateBg = CraftTheme.greenLight;
      stateFg = CraftTheme.greenTint;
      stateIcon = Icons.check_circle_outline_rounded;
    } else if (state == 'CONDITIONAL') {
      stateBg = CraftTheme.amberLight;
      stateFg = CraftTheme.amberTint;
      stateIcon = Icons.info_outline_rounded;
    } else {
      stateBg = CraftTheme.coralLight;
      stateFg = CraftTheme.coralTint;
      stateIcon = Icons.warning_amber_rounded;
    }

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
          // Widget Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CraftTheme.blueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 18, color: CraftTheme.blueTint),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "ORDER READINESS",
                    style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.bold, color: CraftTheme.darkText, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: stateBg, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  children: [
                    Icon(stateIcon, size: 14, color: stateFg),
                    const SizedBox(width: 4),
                    Text(
                      state,
                      style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: stateFg),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Can you accept this order right now? Based on seller-provided information.",
            style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.mutedText),
          ),
          const SizedBox(height: 12),

          // Transparent Score Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CraftTheme.creamBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rule-based readiness score: $score/100",
                        style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: score / 100.0,
                          backgroundColor: CraftTheme.borderLight,
                          color: stateFg,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Operational Controls
          Text("SELLER OPERATIONAL INPUTS", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 0.6)),
          const SizedBox(height: 10),

          // 1. Stock Availability
          _buildSelectorRow(
            label: "Stock Availability",
            options: const ["Ready stock", "Made to order", "Out of stock"],
            selectedValue: _profile.stockStatus,
            onSelected: (val) {
              _updateProfile(_profile.copyWith(
                stockStatus: val,
                isMadeToOrder: val == "Made to order",
                readyStock: val == "Ready stock" ? 1 : 0,
              ));
            },
          ),
          const SizedBox(height: 12),

          // 2. Production Lead Time
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CraftTheme.creamBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Preparation / Production Time", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                    const SizedBox(height: 2),
                    Text("${_profile.leadTimeDays} days artisan prep time (NOT courier delivery)", style: GoogleFonts.notoSans(fontSize: 10, color: CraftTheme.mutedText)),
                  ],
                ),
                InkWell(
                  onTap: _editLeadTimeDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CraftTheme.cardSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: CraftTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Text("${_profile.leadTimeDays} days", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit_outlined, size: 12, color: CraftTheme.mutedText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Production Capacity
          _buildSelectorRow(
            label: "Current Capacity",
            options: const ["Available", "Limited", "Full"],
            selectedValue: _profile.capacityStatus,
            onSelected: (val) => _updateProfile(_profile.copyWith(capacityStatus: val)),
          ),
          const SizedBox(height: 12),

          // 4. Packaging Readiness
          _buildSelectorRow(
            label: "Packaging Readiness",
            options: const ["Ready", "Needs preparation"],
            selectedValue: _profile.packagingStatus,
            onSelected: (val) => _updateProfile(_profile.copyWith(
              packagingStatus: val,
              packagingAvailable: val == "Ready",
            )),
          ),
          const SizedBox(height: 12),

          // 5. Fragility & Handling
          _buildSelectorRow(
            label: "Item Handling",
            options: const ["Standard", "Fragile", "Special handling"],
            selectedValue: _profile.handlingType,
            onSelected: (val) => _updateProfile(_profile.copyWith(
              handlingType: val,
              isFragile: val != "Standard",
            )),
          ),
          if (_profile.handlingType != "Standard") ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CraftTheme.amberLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CraftTheme.amberTint.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: CraftTheme.amberTint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Notice: Sensitive item requiring extra protective packaging during dispatch.",
                      style: GoogleFonts.notoSans(fontSize: 10, fontWeight: FontWeight.w600, color: CraftTheme.amberTint),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // 6. Dispatch Readiness
          _buildSelectorRow(
            label: "Dispatch Readiness",
            options: const ["Ready to dispatch", "Needs preparation"],
            selectedValue: _profile.dispatchStatus,
            onSelected: (val) => _updateProfile(_profile.copyWith(dispatchStatus: val)),
          ),
          const SizedBox(height: 14),

          // 7. Seller Operational Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CraftTheme.creamBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CraftTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Seller Operational Notes / Constraints", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
                    InkWell(
                      onTap: _editSellerNoteDialog,
                      child: Text(_profile.sellerNote.isEmpty ? "+ Add Note" : "Edit", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.blueTint)),
                    ),
                  ],
                ),
                if (_profile.sellerNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_profile.sellerNote, style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.darkText, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Explainable Readiness Breakdown
          Text("EXPLAINABLE READINESS SUMMARY", style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText, letterSpacing: 0.6)),
          const SizedBox(height: 10),

          ...explanation.map((item) {
            final label = item['item']!;
            final itemStatus = item['status']!;
            final note = item['note']!;

            Color badgeBg = CraftTheme.greenLight;
            Color badgeFg = CraftTheme.greenTint;

            if (itemStatus == 'Conditional') {
              badgeBg = CraftTheme.amberLight;
              badgeFg = CraftTheme.amberTint;
            } else if (itemStatus == 'Attention Needed') {
              badgeBg = CraftTheme.coralLight;
              badgeFg = CraftTheme.coralTint;
            } else if (itemStatus == 'Notice') {
              badgeBg = CraftTheme.blueLight;
              badgeFg = CraftTheme.blueTint;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                    child: Text(itemStatus, style: GoogleFonts.notoSans(fontSize: 9, fontWeight: FontWeight.bold, color: badgeFg)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("$label: $note", style: GoogleFonts.notoSans(fontSize: 11, color: CraftTheme.darkText)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectorRow({
    required String label,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: FontWeight.bold, color: CraftTheme.mutedText)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((opt) {
            final isSelected = selectedValue == opt;
            return ChoiceChip(
              label: Text(opt, style: GoogleFonts.notoSans(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              selectedColor: CraftTheme.blueTint.withValues(alpha: 0.2),
              backgroundColor: CraftTheme.creamBase,
              side: BorderSide(color: isSelected ? CraftTheme.blueTint : CraftTheme.borderLight),
              onSelected: (selected) {
                if (selected) onSelected(opt);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

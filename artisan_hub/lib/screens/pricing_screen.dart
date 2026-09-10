import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../api_service.dart';
import 'approval_screen.dart';

class PricingScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> tags;
  final String makerStory;
  final String category;

  const PricingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.makerStory,
    required this.category,
  });

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  double _materialCost = 350.0;
  int _selectedHoursIndex = 1; // 0: Few hrs (3h), 1: 1 day (8h), 2: Several days (16h)
  final List<double> _hoursValues = [3.0, 8.0, 16.0];
  final List<String> _hoursLabels = ["Few hrs (3h)", "1 day (8h)", "Several days (16h)"];

  bool _isLoading = false;
  Map<String, dynamic>? _priceResult;

  @override
  void initState() {
    super.initState();
    _calculatePricing();
  }

  Future<void> _calculatePricing() async {
    setState(() => _isLoading = true);
    final hours = _hoursValues[_selectedHoursIndex];
    final result = await ApiService.suggestPrice(_materialCost, hours, widget.category);
    setState(() {
      _priceResult = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final costFloor = _priceResult?["cost_floor"] ?? 0.0;
    final recommended = _priceResult?["recommended_price"] ?? 0.0;
    final marketMin = _priceResult?["market_min"] ?? 400.0;
    final marketMax = _priceResult?["market_max"] ?? 950.0;
    final guardrailTriggered = _priceResult?["guardrail_triggered"] ?? true;
    final guardrailMsg = _priceResult?["guardrail_message"] ?? "Fair Wage Guardrail Active";
    final seasonalNote = _priceResult?["seasonal_note"] ?? "Festive demand active!";

    // Calculate dot position on range indicator (0.0 to 1.0)
    final double posRatio = ((recommended - marketMin) / (marketMax - marketMin)).clamp(0.05, 0.95);

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
          "Pricing Assistant AI",
          style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: CraftTheme.darkText),
        ),
      ),
      body: Stack(
        children: [
          // Dashed Circle Background Accent in Bottom Corner
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CraftTheme.tealTint.withOpacity(0.15),
                  width: 2,
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
                  // Section 1: Inputs
                  Text("Material Cost & Time", style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                  const SizedBox(height: 12),

                  // Material Cost Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: CraftTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CraftTheme.terracottaPrimary.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Material Cost", style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: CraftTheme.mutedText)),
                            const SizedBox(height: 4),
                            Text("₹${_materialCost.toInt()}", style: GoogleFonts.notoSans(fontSize: 26, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: CraftTheme.terracottaPrimary, size: 28),
                              onPressed: () {
                                if (_materialCost > 50) {
                                  setState(() => _materialCost -= 50);
                                  _calculatePricing();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, color: CraftTheme.terracottaPrimary, size: 28),
                              onPressed: () {
                                setState(() => _materialCost += 50);
                                _calculatePricing();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time Selection Chips
                  Row(
                    children: List.generate(_hoursLabels.length, (index) {
                      final isSelected = _selectedHoursIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedHoursIndex = index);
                            _calculatePricing();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: index == _hoursLabels.length - 1 ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? CraftTheme.terracottaPrimary : CraftTheme.cardSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: isSelected ? CraftTheme.terracottaPrimary : CraftTheme.borderLight),
                            ),
                            child: Center(
                              child: Text(
                                _hoursLabels[index].split(' ')[0], // "Few", "1", "Several"
                                style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : CraftTheme.darkText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Section 2: Result Card
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: CraftTheme.terracottaPrimary))
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: CraftTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CraftTheme.borderLight),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          CraftTheme.iconBadge(
                            icon: Icons.payments_rounded,
                            color: CraftTheme.terracottaPrimary,
                            lightColor: CraftTheme.terracottaLight,
                            outerSize: 52,
                            innerSize: 34,
                            iconSize: 20,
                          ),
                          const SizedBox(height: 12),
                          Text("Recommended Price", style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: CraftTheme.mutedText)),
                          const SizedBox(height: 4),
                          Text("₹${recommended.toInt()}", style: GoogleFonts.notoSans(fontSize: 34, fontWeight: FontWeight.bold, color: CraftTheme.darkText)),
                          const SizedBox(height: 20),

                          // Visual Range Indicator Track & Dot
                          Column(
                            children: [
                              Stack(
                                children: [
                                  // Soft Teal Pill Track
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: CraftTheme.tealLight,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),

                                  // Solid Brand Dot
                                  FractionallySizedBox(
                                    widthFactor: posRatio,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: CraftTheme.terracottaPrimary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Min ₹${marketMin.toInt()}", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                                  Text("Cost Floor ₹${costFloor.toInt()}", style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: CraftTheme.tealTint)),
                                  Text("Max ₹${marketMax.toInt()}", style: GoogleFonts.notoSans(fontSize: 12, color: CraftTheme.mutedText)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Green Guardrail Success Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CraftTheme.greenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CraftTheme.greenTint.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: CraftTheme.greenTint, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              guardrailMsg,
                              style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: CraftTheme.greenTint),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Coral Seasonal Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CraftTheme.coralLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CraftTheme.coralTint.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_note_rounded, color: CraftTheme.coralTint, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              seasonalNote,
                              style: GoogleFonts.notoSans(fontSize: 13, fontWeight: FontWeight.w600, color: CraftTheme.coralTint),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue to Publish Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApprovalScreen(
                                title: widget.title,
                                description: widget.description,
                                tags: widget.tags,
                                makerStory: widget.makerStory,
                                costFloor: costFloor,
                                buyerPrice: recommended,
                                category: widget.category,
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
                          "PROCEED TO PUBLISH →",
                          style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

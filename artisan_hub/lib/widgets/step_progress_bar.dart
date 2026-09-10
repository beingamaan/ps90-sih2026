import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Reusable visual workflow step progress bar visually guiding artisans through the seller-readiness journey.
class StepProgressBar extends StatelessWidget {
  final int currentStep; // 1 to 6

  const StepProgressBar({
    super.key,
    required this.currentStep,
  });

  static const List<Map<String, String>> _steps = [
    {"num": "1", "label": "PHOTO"},
    {"num": "2", "label": "STORY"},
    {"num": "3", "label": "CHECK"},
    {"num": "4", "label": "PRICE"},
    {"num": "5", "label": "READY"},
    {"num": "6", "label": "APPROVE"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                "SELLER READINESS JOURNEY",
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                "Step $currentStep of 6",
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.terracottaPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal step nodes
          Row(
            children: List.generate(_steps.length, (index) {
              final stepNum = index + 1;
              final isCompleted = stepNum < currentStep;
              final isCurrent = stepNum == currentStep;

              final Color nodeBg = isCompleted
                  ? CraftTheme.greenTint
                  : (isCurrent ? CraftTheme.terracottaPrimary : CraftTheme.creamBase);
              final Color nodeBorder = isCompleted
                  ? CraftTheme.greenTint
                  : (isCurrent ? CraftTheme.terracottaPrimary : CraftTheme.borderLight);
              final Color textColor = isCompleted || isCurrent ? Colors.white : CraftTheme.mutedText;

              return Expanded(
                child: Row(
                  children: [
                    // Node dot
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: nodeBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: nodeBorder, width: 1.5),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                  : Text(
                                      _steps[index]["num"]!,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _steps[index]["label"]!,
                            style: GoogleFonts.notoSans(
                              fontSize: 9,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent ? CraftTheme.darkText : CraftTheme.mutedText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Connector line (except after last step)
                    if (index < _steps.length - 1)
                      Container(
                        width: 8,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 14),
                        color: stepNum < currentStep ? CraftTheme.greenTint : CraftTheme.borderLight,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

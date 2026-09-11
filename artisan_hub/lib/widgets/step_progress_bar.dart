import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Reusable visual workflow step progress bar visually guiding artisans through the 5-step seller journey.
class StepProgressBar extends StatelessWidget {
  final int currentStep; // 1 to 5

  const StepProgressBar({
    super.key,
    required this.currentStep,
  });

  static const List<Map<String, dynamic>> _steps = [
    {"num": "01", "label": "Capture", "color": CraftTheme.terracottaPrimary, "bg": CraftTheme.terracottaLight},
    {"num": "02", "label": "Describe", "color": CraftTheme.violetTint, "bg": CraftTheme.violetLight},
    {"num": "03", "label": "Review", "color": CraftTheme.tealTint, "bg": CraftTheme.tealLight},
    {"num": "04", "label": "Prepare", "color": CraftTheme.amberTint, "bg": CraftTheme.amberLight},
    {"num": "05", "label": "Showcase", "color": CraftTheme.terracottaPrimary, "bg": CraftTheme.terracottaLight},
  ];

  @override
  Widget build(BuildContext context) {
    final clampedStep = currentStep.clamp(1, 5);
    final activeStepColor = _steps[clampedStep - 1]["color"] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CREATE PRODUCT JOURNEY",
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: CraftTheme.mutedText,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activeStepColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "0$clampedStep / 05 — ${_steps[clampedStep - 1]["label"]}",
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: activeStepColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal step nodes
          Row(
            children: List.generate(_steps.length, (index) {
              final stepNum = index + 1;
              final isCompleted = stepNum < clampedStep;
              final isCurrent = stepNum == clampedStep;
              final stepColor = _steps[index]["color"] as Color;

              final Color nodeBg = isCompleted
                  ? CraftTheme.tealTint
                  : (isCurrent ? stepColor : CraftTheme.creamBase);
              final Color nodeBorder = isCompleted
                  ? CraftTheme.tealTint
                  : (isCurrent ? stepColor : CraftTheme.borderLight);
              final Color textColor = isCompleted || isCurrent ? Colors.white : CraftTheme.mutedText;

              return Expanded(
                child: Row(
                  children: [
                    // Node dot & label
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 26,
                            decoration: BoxDecoration(
                              color: nodeBg,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: nodeBorder, width: 1.5),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                  : Text(
                                      _steps[index]["num"] as String,
                                      style: GoogleFonts.notoSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _steps[index]["label"] as String,
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
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
                        width: 10,
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: stepNum < clampedStep ? CraftTheme.tealTint : CraftTheme.borderLight,
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


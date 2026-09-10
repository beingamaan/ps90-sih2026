import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'craft_chip.dart';

class CompactProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String status;
  final double? price;
  final String? imageUrl;
  final VoidCallback onTap;

  const CompactProductCard({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    this.price,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int displayPrice = price?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CraftTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CraftTheme.borderLight),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Product Image or Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CraftTheme.terracottaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  color: CraftTheme.terracottaPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Category & Status Chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CraftTheme.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CraftStatusChip.fromStatus(status),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            color: CraftTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Price & Arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (displayPrice > 0)
                    Text(
                      "₹$displayPrice",
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CraftTheme.darkText,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Manage",
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CraftTheme.terracottaPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: CraftTheme.terracottaPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Honest status pills displaying genuine draft & export readiness states (Draft, Ready, Approved, Export-Ready).
class CraftStatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const CraftStatusChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  factory CraftStatusChip.fromStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return const CraftStatusChip(
          label: 'Draft',
          color: CraftTheme.mutedText,
          backgroundColor: CraftTheme.creamBase,
        );
      case 'READY':
      case 'READY FOR REVIEW':
        return const CraftStatusChip(
          label: 'Ready for Review',
          color: CraftTheme.blueTint,
          backgroundColor: CraftTheme.blueLight,
        );
      case 'APPROVED':
      case 'SELLER APPROVED':
        return const CraftStatusChip(
          label: 'Seller Approved',
          color: CraftTheme.greenTint,
          backgroundColor: CraftTheme.greenLight,
        );
      case 'EXPORTED':
      case 'EXPORT-READY':
      case 'ONDC-READY':
        return const CraftStatusChip(
          label: 'Export-Ready',
          color: CraftTheme.violetTint,
          backgroundColor: CraftTheme.violetLight,
        );
      default:
        return CraftStatusChip(
          label: status,
          color: CraftTheme.darkText,
          backgroundColor: CraftTheme.borderLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = color ?? CraftTheme.darkText;
    final bg = backgroundColor ?? CraftTheme.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

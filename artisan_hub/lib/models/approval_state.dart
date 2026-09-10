/// Enums representing stages of seller readiness and catalogue approval.
enum CatalogueStatus {
  draft,
  aiPending,
  needsReview,
  ready,
  approved,
  exported,
}

/// Seller approval state model ensuring seller-exclusive approval before publishing.
class ApprovalState {
  final CatalogueStatus status;
  final bool sellerApproved;
  final DateTime? approvedAt;
  final String approvedByRole; // 'SELLER', 'HELPER', 'COORDINATOR'

  const ApprovalState({
    this.status = CatalogueStatus.draft,
    this.sellerApproved = false,
    this.approvedAt,
    this.approvedByRole = 'SELLER',
  });

  /// Displays human-readable label for current status
  String get statusLabel {
    switch (status) {
      case CatalogueStatus.draft:
        return 'Draft';
      case CatalogueStatus.aiPending:
        return 'AI Processing';
      case CatalogueStatus.needsReview:
        return 'Needs Review';
      case CatalogueStatus.ready:
        return 'Ready for Approval';
      case CatalogueStatus.approved:
        return 'Seller Approved';
      case CatalogueStatus.exported:
        return 'Export-Ready';
    }
  }

  ApprovalState copyWith({
    CatalogueStatus? status,
    bool? sellerApproved,
    DateTime? approvedAt,
    String? approvedByRole,
  }) {
    return ApprovalState(
      status: status ?? this.status,
      sellerApproved: sellerApproved ?? this.sellerApproved,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedByRole: approvedByRole ?? this.approvedByRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'seller_approved': sellerApproved,
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by_role': approvedByRole,
      'status_label': statusLabel,
    };
  }

  factory ApprovalState.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status'] as String? ?? 'draft';
    final parsedStatus = CatalogueStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => CatalogueStatus.draft,
    );

    return ApprovalState(
      status: parsedStatus,
      sellerApproved: map['seller_approved'] ?? false,
      approvedAt: map['approved_at'] != null ? DateTime.tryParse(map['approved_at']) : null,
      approvedByRole: map['approved_by_role'] ?? 'SELLER',
    );
  }
}

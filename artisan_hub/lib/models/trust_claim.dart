/// Sensitive craft claim & provenance verification model (Pillar 3).
/// Detects regulated claims (GI Tag, Handloom Mark, Silk Mark, Khadi, Organic)
/// and enforces honest provenance status.
class TrustClaim {
  final String claimName;
  final bool isSensitive;
  final String provenanceStatus; // 'SELF_DECLARED', 'DOCUMENT_BACKED', 'COORDINATOR_VOUCHED'
  final String? documentPath;
  final bool isApproved;
  final String notes;

  const TrustClaim({
    required this.claimName,
    this.isSensitive = false,
    this.provenanceStatus = 'SELF_DECLARED',
    this.documentPath,
    this.isApproved = false,
    this.notes = '',
  });

  /// Regulated sensitive terms that require explicit proof/review
  static const List<String> sensitiveTerms = [
    'GI',
    'GI Tag',
    'Handloom Mark',
    'Silk Mark',
    'Pure Silk',
    'Khadi',
    'Organic',
    'Craft Mark',
  ];

  /// Checks if a given claim term is regulated/sensitive
  static bool checkIsSensitive(String term) {
    final lower = term.toLowerCase().trim();
    return sensitiveTerms.any((t) => lower.contains(t.toLowerCase()));
  }

  TrustClaim copyWith({
    String? claimName,
    bool? isSensitive,
    String? provenanceStatus,
    String? documentPath,
    bool? isApproved,
    String? notes,
  }) {
    return TrustClaim(
      claimName: claimName ?? this.claimName,
      isSensitive: isSensitive ?? this.isSensitive,
      provenanceStatus: provenanceStatus ?? this.provenanceStatus,
      documentPath: documentPath ?? this.documentPath,
      isApproved: isApproved ?? this.isApproved,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'claim_name': claimName,
      'is_sensitive': isSensitive,
      'provenance_status': provenanceStatus,
      'document_path': documentPath,
      'is_approved': isApproved,
      'notes': notes,
    };
  }

  factory TrustClaim.fromMap(Map<String, dynamic> map) {
    final name = map['claim_name'] ?? map['claimName'] ?? '';
    return TrustClaim(
      claimName: name,
      isSensitive: map['is_sensitive'] ?? checkIsSensitive(name),
      provenanceStatus: map['provenance_status'] ?? 'SELF_DECLARED',
      documentPath: map['document_path'],
      isApproved: map['is_approved'] ?? false,
      notes: map['notes'] ?? '',
    );
  }
}

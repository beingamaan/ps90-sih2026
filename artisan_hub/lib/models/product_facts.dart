/// Fact status constants for seller verification lifecycle
class FactStatus {
  static const String aiSuggested = 'AI Suggested';
  static const String reviewRequired = 'Review Required';
  static const String sellerConfirmed = 'Seller Confirmed';
  static const String selfDeclared = 'Self Declared';
  static const String evidenceRequired = 'Evidence Required';
  static const String evidenceSubmitted = 'Evidence Submitted';
  static const String claimExcluded = 'Claim Excluded';
}

/// Structured product facts extracted from guided voice slots or user confirmation.
/// AI suggestions must be verified and approved by the seller.
class ProductFacts {
  final String name;
  final String category;
  final String material;
  final String colorMotif;
  final String origin;
  final String craftTechnique;
  final int productionTimeDays;
  final Map<String, String> confidenceMap; // e.g. {'material': 'high', 'origin': 'medium'}
  final Map<String, bool> approvalMap;   // e.g. {'material': true, 'origin': false}
  final Map<String, String> statusMap;   // e.g. {'material': FactStatus.sellerConfirmed}
  final Map<String, String> sourceMap;   // e.g. {'material': 'AI Extracted'}
  final Map<String, String> evidenceNotesMap; // e.g. {'gi_claim': 'Reg Ref: GI/102/2023'}
  final List<String> excludedClaims;     // Claims seller selected 'Do not claim'

  const ProductFacts({
    this.name = '',
    this.category = 'Textile',
    this.material = '',
    this.colorMotif = '',
    this.origin = '',
    this.craftTechnique = '',
    this.productionTimeDays = 1,
    this.confidenceMap = const {},
    this.approvalMap = const {},
    this.statusMap = const {},
    this.sourceMap = const {},
    this.evidenceNotesMap = const {},
    this.excludedClaims = const [],
  });

  /// Helper to get status for a field (defaults to AI Suggested or Review Required)
  String getFieldStatus(String fieldKey, {bool isSensitive = false}) {
    if (excludedClaims.contains(fieldKey)) return FactStatus.claimExcluded;
    if (statusMap.containsKey(fieldKey)) return statusMap[fieldKey]!;
    if (approvalMap[fieldKey] == true) return FactStatus.sellerConfirmed;
    if (isSensitive) return FactStatus.evidenceRequired;
    return FactStatus.aiSuggested;
  }

  ProductFacts copyWith({
    String? name,
    String? category,
    String? material,
    String? colorMotif,
    String? origin,
    String? craftTechnique,
    int? productionTimeDays,
    Map<String, String>? confidenceMap,
    Map<String, bool>? approvalMap,
    Map<String, String>? statusMap,
    Map<String, String>? sourceMap,
    Map<String, String>? evidenceNotesMap,
    List<String>? excludedClaims,
  }) {
    return ProductFacts(
      name: name ?? this.name,
      category: category ?? this.category,
      material: material ?? this.material,
      colorMotif: colorMotif ?? this.colorMotif,
      origin: origin ?? this.origin,
      craftTechnique: craftTechnique ?? this.craftTechnique,
      productionTimeDays: productionTimeDays ?? this.productionTimeDays,
      confidenceMap: confidenceMap ?? Map.from(this.confidenceMap),
      approvalMap: approvalMap ?? Map.from(this.approvalMap),
      statusMap: statusMap ?? Map.from(this.statusMap),
      sourceMap: sourceMap ?? Map.from(this.sourceMap),
      evidenceNotesMap: evidenceNotesMap ?? Map.from(this.evidenceNotesMap),
      excludedClaims: excludedClaims ?? List.from(this.excludedClaims),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'material': material,
      'color_motif': colorMotif,
      'origin': origin,
      'craft_technique': craftTechnique,
      'production_time_days': productionTimeDays,
      'confidence_map': confidenceMap,
      'approval_map': approvalMap,
      'status_map': statusMap,
      'source_map': sourceMap,
      'evidence_notes_map': evidenceNotesMap,
      'excluded_claims': excludedClaims,
    };
  }

  factory ProductFacts.fromMap(Map<String, dynamic> map) {
    return ProductFacts(
      name: map['name'] ?? '',
      category: map['category'] ?? 'Textile',
      material: map['material'] ?? '',
      colorMotif: map['color_motif'] ?? map['colorMotif'] ?? '',
      origin: map['origin'] ?? '',
      craftTechnique: map['craft_technique'] ?? map['craftTechnique'] ?? '',
      productionTimeDays: map['production_time_days'] ?? map['productionTimeDays'] ?? 1,
      confidenceMap: Map<String, String>.from(map['confidence_map'] ?? map['confidenceMap'] ?? {}),
      approvalMap: Map<String, bool>.from(map['approval_map'] ?? map['approvalMap'] ?? {}),
      statusMap: Map<String, String>.from(map['status_map'] ?? map['statusMap'] ?? {}),
      sourceMap: Map<String, String>.from(map['source_map'] ?? map['sourceMap'] ?? {}),
      evidenceNotesMap: Map<String, String>.from(map['evidence_notes_map'] ?? map['evidenceNotesMap'] ?? {}),
      excludedClaims: List<String>.from(map['excluded_claims'] ?? map['excludedClaims'] ?? []),
    );
  }
}

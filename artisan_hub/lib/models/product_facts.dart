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
  });

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
    );
  }
}

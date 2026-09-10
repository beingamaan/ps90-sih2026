import 'dart:typed_data';
import 'product_facts.dart';
import 'catalogue.dart';
import 'pricing.dart';
import 'fulfilment_profile.dart';
import 'trust_claim.dart';
import 'approval_state.dart';

/// Central ProductDraft model encapsulating the complete CraftBridge seller-readiness workflow state.
class ProductDraft {
  final String id;
  final Uint8List? originalImageBytes;
  final String? enhancedImageB64;
  final String rawTranscript;
  final ProductFacts facts;
  final Catalogue catalogue;
  final Pricing pricing;
  final FulfilmentProfile fulfilment;
  final List<TrustClaim> trustClaims;
  final ApprovalState approval;
  final String marketplaceDestination;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductDraft({
    required this.id,
    this.originalImageBytes,
    this.enhancedImageB64,
    this.rawTranscript = '',
    this.facts = const ProductFacts(),
    this.catalogue = const Catalogue(),
    this.pricing = const Pricing(),
    this.fulfilment = const FulfilmentProfile(),
    this.trustClaims = const [],
    this.approval = const ApprovalState(),
    this.marketplaceDestination = 'ONDC-Ready Schema',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Returns true if an image photo is attached
  bool get hasImage => originalImageBytes != null || (enhancedImageB64 != null && enhancedImageB64!.isNotEmpty);

  ProductDraft copyWith({
    String? id,
    Uint8List? originalImageBytes,
    String? enhancedImageB64,
    String? rawTranscript,
    ProductFacts? facts,
    Catalogue? catalogue,
    Pricing? pricing,
    FulfilmentProfile? fulfilment,
    List<TrustClaim>? trustClaims,
    ApprovalState? approval,
    String? marketplaceDestination,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductDraft(
      id: id ?? this.id,
      originalImageBytes: originalImageBytes ?? this.originalImageBytes,
      enhancedImageB64: enhancedImageB64 ?? this.enhancedImageB64,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      facts: facts ?? this.facts,
      catalogue: catalogue ?? this.catalogue,
      pricing: pricing ?? this.pricing,
      fulfilment: fulfilment ?? this.fulfilment,
      trustClaims: trustClaims ?? this.trustClaims,
      approval: approval ?? this.approval,
      marketplaceDestination: marketplaceDestination ?? this.marketplaceDestination,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enhanced_image_b64': enhancedImageB64,
      'raw_transcript': rawTranscript,
      'facts': facts.toMap(),
      'catalogue': catalogue.toMap(),
      'pricing': pricing.toMap(),
      'fulfilment': fulfilment.toMap(),
      'trust_claims': trustClaims.map((c) => c.toMap()).toList(),
      'approval': approval.toMap(),
      'marketplace_destination': marketplaceDestination,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductDraft.fromMap(Map<String, dynamic> map) {
    return ProductDraft(
      id: map['id'] ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
      enhancedImageB64: map['enhanced_image_b64'],
      rawTranscript: map['raw_transcript'] ?? '',
      facts: map['facts'] != null ? ProductFacts.fromMap(map['facts']) : const ProductFacts(),
      catalogue: map['catalogue'] != null ? Catalogue.fromMap(map['catalogue']) : const Catalogue(),
      pricing: map['pricing'] != null ? Pricing.fromMap(map['pricing']) : const Pricing(),
      fulfilment: map['fulfilment'] != null ? FulfilmentProfile.fromMap(map['fulfilment']) : const FulfilmentProfile(),
      trustClaims: (map['trust_claims'] as List?)?.map((c) => TrustClaim.fromMap(c)).toList() ?? const [],
      approval: map['approval'] != null ? ApprovalState.fromMap(map['approval']) : const ApprovalState(),
      marketplaceDestination: map['marketplace_destination'] ?? 'ONDC-Ready Schema',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : DateTime.now(),
    );
  }
}

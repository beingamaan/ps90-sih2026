/// Deterministic pricing model including material, labor, overhead, commissions,
/// and explicit two-tier breakdown ("Artisan ko milega" vs "Buyer dega").
class Pricing {
  final double materialCost;
  final double hoursWorked;
  final double laborRatePerHour;
  final double packagingCost;
  final double shippingEstimate;
  final double sellerMargin;
  final double marketplaceCommission;
  final double paymentGatewayFee;

  final double costFloor;
  final double marketMin;
  final double marketMax;
  final double recommendedPrice;
  final bool guardrailTriggered;
  final String guardrailMessage;
  final String seasonalNote;

  const Pricing({
    this.materialCost = 350.0,
    this.hoursWorked = 8.0,
    this.laborRatePerHour = 50.0,
    this.packagingCost = 40.0,
    this.shippingEstimate = 120.0,
    this.sellerMargin = 0.15,
    this.marketplaceCommission = 0.05,
    this.paymentGatewayFee = 0.02,
    this.costFloor = 790.0,
    this.marketMin = 400.0,
    this.marketMax = 950.0,
    this.recommendedPrice = 1250.0,
    this.guardrailTriggered = true,
    this.guardrailMessage = 'Fair Wage Guardrail active',
    this.seasonalNote = 'High festive demand season active!',
  });

  /// Computed labor cost based on fair hourly rate
  double get laborCost => hoursWorked * laborRatePerHour;

  /// Total cost basis before margin/commission
  double get totalCostBasis => materialCost + laborCost + packagingCost;

  /// Seller Realisation ("Artisan ko milega")
  double get sellerRealisation {
    final gross = recommendedPrice;
    final commissionAmount = gross * marketplaceCommission;
    final gatewayAmount = gross * paymentGatewayFee;
    final netRealisation = gross - commissionAmount - gatewayAmount - shippingEstimate;
    return netRealisation > 0 ? netRealisation : 0;
  }

  /// Buyer Price ("Buyer dega")
  double get buyerPrice => recommendedPrice;

  /// Loss Warning check: checks if seller realisation falls below required cost floor
  bool get isLossWarning => sellerRealisation < costFloor;

  double get estimatedLoss => isLossWarning ? (costFloor - sellerRealisation) : 0.0;

  Pricing copyWith({
    double? materialCost,
    double? hoursWorked,
    double? laborRatePerHour,
    double? packagingCost,
    double? shippingEstimate,
    double? sellerMargin,
    double? marketplaceCommission,
    double? paymentGatewayFee,
    double? costFloor,
    double? marketMin,
    double? marketMax,
    double? recommendedPrice,
    bool? guardrailTriggered,
    String? guardrailMessage,
    String? seasonalNote,
  }) {
    return Pricing(
      materialCost: materialCost ?? this.materialCost,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      laborRatePerHour: laborRatePerHour ?? this.laborRatePerHour,
      packagingCost: packagingCost ?? this.packagingCost,
      shippingEstimate: shippingEstimate ?? this.shippingEstimate,
      sellerMargin: sellerMargin ?? this.sellerMargin,
      marketplaceCommission: marketplaceCommission ?? this.marketplaceCommission,
      paymentGatewayFee: paymentGatewayFee ?? this.paymentGatewayFee,
      costFloor: costFloor ?? this.costFloor,
      marketMin: marketMin ?? this.marketMin,
      marketMax: marketMax ?? this.marketMax,
      recommendedPrice: recommendedPrice ?? this.recommendedPrice,
      guardrailTriggered: guardrailTriggered ?? this.guardrailTriggered,
      guardrailMessage: guardrailMessage ?? this.guardrailMessage,
      seasonalNote: seasonalNote ?? this.seasonalNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'material_cost': materialCost,
      'hours_worked': hoursWorked,
      'labor_rate_per_hour': laborRatePerHour,
      'labor_cost': laborCost,
      'packaging_cost': packagingCost,
      'shipping_estimate': shippingEstimate,
      'cost_floor': costFloor,
      'market_min': marketMin,
      'market_max': marketMax,
      'recommended_price': recommendedPrice,
      'seller_realisation': sellerRealisation,
      'buyer_price': buyerPrice,
      'guardrail_triggered': guardrailTriggered,
      'guardrail_message': guardrailMessage,
      'seasonal_note': seasonalNote,
      'is_loss_warning': isLossWarning,
      'estimated_loss': estimatedLoss,
    };
  }

  factory Pricing.fromMap(Map<String, dynamic> map) {
    return Pricing(
      materialCost: (map['material_cost'] as num?)?.toDouble() ?? 350.0,
      hoursWorked: (map['hours_worked'] as num?)?.toDouble() ?? 8.0,
      laborRatePerHour: (map['labor_rate_per_hour'] as num?)?.toDouble() ?? 50.0,
      packagingCost: (map['packaging_cost'] as num?)?.toDouble() ?? 40.0,
      shippingEstimate: (map['shipping_estimate'] as num?)?.toDouble() ?? 120.0,
      costFloor: (map['cost_floor'] as num?)?.toDouble() ?? 790.0,
      marketMin: (map['market_min'] as num?)?.toDouble() ?? 400.0,
      marketMax: (map['market_max'] as num?)?.toDouble() ?? 950.0,
      recommendedPrice: (map['recommended_price'] as num?)?.toDouble() ?? (map['buyer_price'] as num?)?.toDouble() ?? 1250.0,
      guardrailTriggered: map['guardrail_triggered'] ?? true,
      guardrailMessage: map['guardrail_message'] ?? 'Fair Wage Guardrail active',
      seasonalNote: map['seasonal_note'] ?? 'High festive demand season active!',
    );
  }
}

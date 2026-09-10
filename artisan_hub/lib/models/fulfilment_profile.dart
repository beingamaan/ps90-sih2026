/// Fulfilment & Order Readiness profile metrics (Pillar 2).
/// Computes an objective, transparent readiness score based on captured logistics & stock capacity.
class FulfilmentProfile {
  final int readyStock;
  final bool isMadeToOrder;
  final int leadTimeDays;
  final int monthlyCapacity;
  final bool packagingAvailable;
  final bool isFragile;
  final bool pickupAvailable;
  final bool dropoffCapable;
  final int dispatchTimeHours;

  const FulfilmentProfile({
    this.readyStock = 1,
    this.isMadeToOrder = false,
    this.leadTimeDays = 3,
    this.monthlyCapacity = 15,
    this.packagingAvailable = true,
    this.isFragile = false,
    this.pickupAvailable = true,
    this.dropoffCapable = true,
    this.dispatchTimeHours = 24,
  });

  /// Computes deterministic readiness score out of 100 based on captured logistics parameters
  int get readinessScore {
    int score = 0;
    if (readyStock > 0 || isMadeToOrder) score += 25;
    if (leadTimeDays > 0 && leadTimeDays <= 7) score += 20;
    if (monthlyCapacity > 0) score += 15;
    if (packagingAvailable) score += 15;
    if (pickupAvailable || dropoffCapable) score += 15;
    if (dispatchTimeHours <= 48) score += 10;
    return score.clamp(0, 100);
  }

  /// Lists explicit gaps that reduce the readiness score
  List<String> get readinessGaps {
    final gaps = <String>[];
    if (readyStock <= 0 && !isMadeToOrder) {
      gaps.add('Stock availability or made-to-order status not specified');
    }
    if (!packagingAvailable) {
      gaps.add('Standard protective packaging unavailable');
    }
    if (!pickupAvailable && !dropoffCapable) {
      gaps.add('Courier pickup or drop-off capability not specified');
    }
    if (leadTimeDays > 14) {
      gaps.add('Long production lead time (>14 days)');
    }
    return gaps;
  }

  FulfilmentProfile copyWith({
    int? readyStock,
    bool? isMadeToOrder,
    int? leadTimeDays,
    int? monthlyCapacity,
    bool? packagingAvailable,
    bool? isFragile,
    bool? pickupAvailable,
    bool? dropoffCapable,
    int? dispatchTimeHours,
  }) {
    return FulfilmentProfile(
      readyStock: readyStock ?? this.readyStock,
      isMadeToOrder: isMadeToOrder ?? this.isMadeToOrder,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      monthlyCapacity: monthlyCapacity ?? this.monthlyCapacity,
      packagingAvailable: packagingAvailable ?? this.packagingAvailable,
      isFragile: isFragile ?? this.isFragile,
      pickupAvailable: pickupAvailable ?? this.pickupAvailable,
      dropoffCapable: dropoffCapable ?? this.dropoffCapable,
      dispatchTimeHours: dispatchTimeHours ?? this.dispatchTimeHours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ready_stock': readyStock,
      'is_made_to_order': isMadeToOrder,
      'lead_time_days': leadTimeDays,
      'monthly_capacity': monthlyCapacity,
      'packaging_available': packagingAvailable,
      'is_fragile': isFragile,
      'pickup_available': pickupAvailable,
      'dropoff_capable': dropoffCapable,
      'dispatch_time_hours': dispatchTimeHours,
      'readiness_score': readinessScore,
      'readiness_gaps': readinessGaps,
    };
  }

  factory FulfilmentProfile.fromMap(Map<String, dynamic> map) {
    return FulfilmentProfile(
      readyStock: (map['ready_stock'] as num?)?.toInt() ?? 1,
      isMadeToOrder: map['is_made_to_order'] ?? false,
      leadTimeDays: (map['lead_time_days'] as num?)?.toInt() ?? 3,
      monthlyCapacity: (map['monthly_capacity'] as num?)?.toInt() ?? 15,
      packagingAvailable: map['packaging_available'] ?? true,
      isFragile: map['is_fragile'] ?? false,
      pickupAvailable: map['pickup_available'] ?? true,
      dropoffCapable: map['dropoff_capable'] ?? true,
      dispatchTimeHours: (map['dispatch_time_hours'] as num?)?.toInt() ?? 24,
    );
  }
}

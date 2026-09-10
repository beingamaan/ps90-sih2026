/// Fulfilment & Order Readiness profile metrics (Pillar 2).
/// Computes an objective, transparent rule-based readiness score based on seller-provided operational information.
class FulfilmentProfile {
  final int readyStock;
  final bool isMadeToOrder;
  final int leadTimeDays; // Preparation / production time ONLY (NOT courier delivery)
  final int monthlyCapacity;
  final bool packagingAvailable;
  final bool isFragile;
  final bool pickupAvailable;
  final bool dropoffCapable;
  final int dispatchTimeHours;

  // Phase 3.2 Seller Operational Fields
  final String stockStatus;      // 'Ready stock', 'Made to order', 'Out of stock'
  final String capacityStatus;   // 'Available', 'Limited', 'Full'
  final String packagingStatus;  // 'Ready', 'Needs preparation'
  final String handlingType;     // 'Standard', 'Fragile', 'Special handling'
  final String dispatchStatus;   // 'Ready to dispatch', 'Needs preparation'
  final String sellerNote;       // Free-text operational note/constraint

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
    this.stockStatus = 'Ready stock',
    this.capacityStatus = 'Available',
    this.packagingStatus = 'Ready',
    this.handlingType = 'Standard',
    this.dispatchStatus = 'Ready to dispatch',
    this.sellerNote = '',
  });

  /// Deterministic, transparent rule-based readiness score (0 to 100) based ONLY on seller-provided fields
  int get readinessScore {
    int score = 0;
    // Stock availability factor (max 30)
    if (stockStatus == 'Ready stock' || readyStock > 0) {
      score += 30;
    } else if (stockStatus == 'Made to order' || isMadeToOrder) {
      score += 20;
    } else {
      score += 0; // Out of stock
    }

    // Preparation lead time factor (max 20)
    if (leadTimeDays > 0 && leadTimeDays <= 14) {
      score += 20;
    } else if (leadTimeDays > 14) {
      score += 10;
    }

    // Production capacity factor (max 20)
    if (capacityStatus == 'Available') {
      score += 20;
    } else if (capacityStatus == 'Limited') {
      score += 10;
    } else {
      score += 0; // Capacity full
    }

    // Packaging readiness factor (max 15)
    if (packagingStatus == 'Ready' || packagingAvailable) {
      score += 15;
    } else {
      score += 5;
    }

    // Dispatch readiness factor (max 15)
    if (dispatchStatus == 'Ready to dispatch' || (pickupAvailable || dropoffCapable)) {
      score += 15;
    } else {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Transparent Order Readiness State: READY, CONDITIONAL, or NEEDS PREPARATION
  String get readinessState {
    if (stockStatus == 'Out of stock' || capacityStatus == 'Full' || leadTimeDays <= 0) {
      return 'NEEDS PREPARATION';
    }
    if (readinessScore >= 80 && packagingStatus == 'Ready' && dispatchStatus == 'Ready to dispatch') {
      return 'READY';
    }
    return 'CONDITIONAL';
  }

  /// Explainable breakdown list showing what is complete vs what requires seller attention
  List<Map<String, String>> get readinessExplanation {
    final list = <Map<String, String>>[];

    // Stock
    if (stockStatus == 'Ready stock') {
      list.add({'item': 'Stock Availability', 'status': 'Complete', 'note': 'Ready stock available'});
    } else if (stockStatus == 'Made to order') {
      list.add({'item': 'Stock Availability', 'status': 'Conditional', 'note': 'Made to order ($leadTimeDays days prep time)'});
    } else {
      list.add({'item': 'Stock Availability', 'status': 'Attention Needed', 'note': 'Currently out of stock'});
    }

    // Lead Time
    if (leadTimeDays > 0) {
      list.add({'item': 'Preparation Time', 'status': 'Complete', 'note': 'Estimated $leadTimeDays days artisan prep time'});
    } else {
      list.add({'item': 'Preparation Time', 'status': 'Attention Needed', 'note': 'Preparation time not specified'});
    }

    // Capacity
    if (capacityStatus == 'Available') {
      list.add({'item': 'Production Capacity', 'status': 'Complete', 'note': 'Artisan production capacity available'});
    } else if (capacityStatus == 'Limited') {
      list.add({'item': 'Production Capacity', 'status': 'Conditional', 'note': 'Limited production capacity'});
    } else {
      list.add({'item': 'Production Capacity', 'status': 'Attention Needed', 'note': 'Production capacity full'});
    }

    // Packaging
    if (packagingStatus == 'Ready' || packagingAvailable) {
      list.add({'item': 'Packaging Readiness', 'status': 'Complete', 'note': 'Protective craft packaging ready'});
    } else {
      list.add({'item': 'Packaging Readiness', 'status': 'Attention Needed', 'note': 'Packaging requires preparation'});
    }

    // Handling Warning (Does NOT penalize readiness)
    if (handlingType == 'Fragile' || handlingType == 'Special handling' || isFragile) {
      list.add({'item': 'Item Handling', 'status': 'Notice', 'note': 'Fragile item: requires careful handling during dispatch'});
    } else {
      list.add({'item': 'Item Handling', 'status': 'Complete', 'note': 'Standard craft handling'});
    }

    // Dispatch
    if (dispatchStatus == 'Ready to dispatch') {
      list.add({'item': 'Dispatch Readiness', 'status': 'Complete', 'note': 'Ready for pickup or drop-off'});
    } else {
      list.add({'item': 'Dispatch Readiness', 'status': 'Attention Needed', 'note': 'Dispatch preparation required'});
    }

    return list;
  }

  /// Lists explicit gaps that reduce the readiness score
  List<String> get readinessGaps {
    final gaps = <String>[];
    if (stockStatus == 'Out of stock') {
      gaps.add('Product marked as out of stock');
    }
    if (capacityStatus == 'Full') {
      gaps.add('Artisan production capacity currently full');
    }
    if (packagingStatus == 'Needs preparation') {
      gaps.add('Standard protective packaging needs preparation');
    }
    if (dispatchStatus == 'Needs preparation') {
      gaps.add('Dispatch capability needs preparation');
    }
    if (leadTimeDays > 14) {
      gaps.add('Extended preparation time (>14 days)');
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
    String? stockStatus,
    String? capacityStatus,
    String? packagingStatus,
    String? handlingType,
    String? dispatchStatus,
    String? sellerNote,
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
      stockStatus: stockStatus ?? this.stockStatus,
      capacityStatus: capacityStatus ?? this.capacityStatus,
      packagingStatus: packagingStatus ?? this.packagingStatus,
      handlingType: handlingType ?? this.handlingType,
      dispatchStatus: dispatchStatus ?? this.dispatchStatus,
      sellerNote: sellerNote ?? this.sellerNote,
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
      'stock_status': stockStatus,
      'capacity_status': capacityStatus,
      'packaging_status': packagingStatus,
      'handling_type': handlingType,
      'dispatch_status': dispatchStatus,
      'seller_note': sellerNote,
      'readiness_score': readinessScore,
      'readiness_state': readinessState,
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
      stockStatus: map['stock_status'] ?? 'Ready stock',
      capacityStatus: map['capacity_status'] ?? 'Available',
      packagingStatus: map['packaging_status'] ?? 'Ready',
      handlingType: map['handling_type'] ?? 'Standard',
      dispatchStatus: map['dispatch_status'] ?? 'Ready to dispatch',
      sellerNote: map['seller_note'] ?? '',
    );
  }
}

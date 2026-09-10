import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import '../models/product_draft.dart';
import '../models/product_facts.dart';
import '../models/catalogue.dart';
import '../models/pricing.dart';
import '../models/fulfilment_profile.dart';
import '../models/trust_claim.dart';
import '../models/approval_state.dart';

/// Lightweight application state provider for active product draft management.
/// Uses Flutter's native ChangeNotifier & InheritedNotifier (zero external package overhead).
class ProductDraftProvider extends ChangeNotifier {
  late ProductDraft _currentDraft;

  ProductDraftProvider() {
    _initFreshDraft();
  }

  void _initFreshDraft() {
    _currentDraft = ProductDraft(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  ProductDraft get currentDraft => _currentDraft;

  /// Resets the current draft and starts a new product workflow
  void startNewDraft() {
    _initFreshDraft();
    notifyListeners();
  }

  /// Updates original or studio enhanced craft image
  void updateImage({Uint8List? originalBytes, String? enhancedB64}) {
    _currentDraft = _currentDraft.copyWith(
      originalImageBytes: originalBytes ?? _currentDraft.originalImageBytes,
      enhancedImageB64: enhancedB64 ?? _currentDraft.enhancedImageB64,
    );
    notifyListeners();
  }

  /// Updates raw regional voice transcript
  void updateTranscript(String transcript) {
    _currentDraft = _currentDraft.copyWith(
      rawTranscript: transcript,
    );
    notifyListeners();
  }

  /// Updates verified product facts
  void updateFacts(ProductFacts facts) {
    _currentDraft = _currentDraft.copyWith(
      facts: facts,
    );
    notifyListeners();
  }

  /// Updates generated or verified catalogue details
  void updateCatalogue(Catalogue catalogue) {
    _currentDraft = _currentDraft.copyWith(
      catalogue: catalogue,
    );
    notifyListeners();
  }

  /// Updates pricing calculations & cost floor
  void updatePricing(Pricing pricing) {
    _currentDraft = _currentDraft.copyWith(
      pricing: pricing,
    );
    notifyListeners();
  }

  /// Updates fulfilment & order readiness profile
  void updateFulfilment(FulfilmentProfile fulfilment) {
    _currentDraft = _currentDraft.copyWith(
      fulfilment: fulfilment,
    );
    notifyListeners();
  }

  /// Updates sensitive trust claims list
  void updateTrustClaims(List<TrustClaim> claims) {
    _currentDraft = _currentDraft.copyWith(
      trustClaims: claims,
    );
    notifyListeners();
  }

  /// Updates approval status
  void updateApproval(ApprovalState approval) {
    _currentDraft = _currentDraft.copyWith(
      approval: approval,
    );
    notifyListeners();
  }

  /// Updates selected marketplace destination schema
  void updateMarketplaceDestination(String destination) {
    _currentDraft = _currentDraft.copyWith(
      marketplaceDestination: destination,
    );
    notifyListeners();
  }

  /// Helper method to lookup Provider instance from BuildContext
  static ProductDraftProvider of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final scope = context.dependOnInheritedWidgetOfExactType<ProductDraftScope>();
      assert(scope != null, 'No ProductDraftScope found in context');
      return scope!.notifier!;
    } else {
      final scope = context.findAncestorWidgetOfExactType<ProductDraftScope>();
      assert(scope != null, 'No ProductDraftScope found in context');
      return scope!.notifier!;
    }
  }
}

/// InheritedNotifier providing ProductDraftProvider down the widget tree
class ProductDraftScope extends InheritedNotifier<ProductDraftProvider> {
  const ProductDraftScope({
    super.key,
    required ProductDraftProvider provider,
    required super.child,
  }) : super(notifier: provider);
}

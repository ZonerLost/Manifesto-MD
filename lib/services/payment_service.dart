import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentService {
  PaymentService._internal();

  static final PaymentService instance = PaymentService._internal();

  bool _isConfigured = false;

  /// Cached offerings so we don't call RevenueCat on every screen build
  Offerings? _cachedOfferings;

  Future<void> init() async {
    if (_isConfigured) return;

    await Purchases.configure(
      PurchasesConfiguration("test_TREKzoVPAzVGFPtmfexXNgThIDg"),
    );

    _isConfigured = true;
  }

  // ================== OFFERINGS ==================

  /// Fetch offerings from RevenueCat and cache them.
  /// Set [forceRefresh] = true to always hit the network.
  Future<Offerings?> fetchOfferings({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedOfferings != null) {
        return _cachedOfferings;
      }

      final offerings = await Purchases.getOfferings();
      _cachedOfferings = offerings;
      return offerings;
    } catch (e) {
      print("❌ Error fetching offerings: $e");
      return null;
    }
  }

  /// Get the last cached offerings (may be null if fetchOfferings() wasn't called).
  Offerings? get cachedOfferings => _cachedOfferings;

  /// Convenience: get the `current` offering (as configured in RevenueCat dashboard).
  Future<Offering?> getCurrentOffering({bool forceRefresh = false}) async {
    final offerings = await fetchOfferings(forceRefresh: forceRefresh);
    return offerings?.current;
  }

  /// Convenience: get all available packages from ALL offerings.
  Future<List<Package>> getAllAvailablePackages({bool forceRefresh = false}) async {
    final offerings = await fetchOfferings(forceRefresh: forceRefresh);
    if (offerings == null) return [];

    final List<Package> packages = [];
    for (final entry in offerings.all.entries) {
      packages.addAll(entry.value.availablePackages);
    }
    return packages;
  }

  /// Get available packages for a specific offeringId
  /// (offeringId is what you set in RevenueCat dashboard).
  Future<List<Package>> getPackagesForOffering(
    String offeringId, {
    bool forceRefresh = false,
  }) async {
    final offerings = await fetchOfferings(forceRefresh: forceRefresh);
    final offering = offerings?.all[offeringId];
    return offering?.availablePackages ?? [];
  }

  /// Get a specific package by offeringId + package identifier (e.g. "monthly", "annual").
  Future<Package?> getPackage(
    String offeringId,
    String packageIdentifier, {
    bool forceRefresh = false,
  }) async {
    final packages = await getPackagesForOffering(
      offeringId,
      forceRefresh: forceRefresh,
    );
    try {
      return packages.firstWhere(
        (p) => p.identifier == packageIdentifier,
      );
    } catch (_) {
      return null;
    }
  }

  // ================== PRODUCTS ==================

  /// Fetch specific products directly by their store IDs (product identifiers).
  /// Example: ["manifesto_basic_monthly", "manifesto_premium_yearly"]
  Future<List<StoreProduct>> fetchProductsByIds(List<String> productIds) async {
    try {
      // This API name can differ slightly depending on purchases_flutter version:
      // In recent versions: Purchases.getProducts(productIds);
      final products = await Purchases.getProducts(productIds);
      return products;
    } catch (e) {
      print("❌ Error fetching products: $e");
      return [];
    }
  }

  // ================== PURCHASE & ENTITLEMENTS ==================

  /// NOTE: Your PurchaseParams type is custom. In RevenueCat you normally use:
  /// Purchases.purchasePackage(package) or Purchases.purchaseStoreProduct(product).
  /// Keep as-is if you're wrapping that logic elsewhere.
  Future<bool> purchase(PurchaseParams purchaseParams) async {
    try {
      final customerInfo = await Purchases.purchase(purchaseParams);
      return customerInfo.customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print("❌ Purchase failed: $e");
      return false;
    }
  }

  /// Simple check for "premium" entitlement.
  /// Make sure your entitlement in RevenueCat is actually named "premium".
  Future<bool> isUserPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey("premium");
    } catch (e) {
      print("❌ Error checking premium: $e");
      return false;
    }
  }
}

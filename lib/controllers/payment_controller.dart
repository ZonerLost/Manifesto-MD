import 'package:get/get.dart';
import 'package:manifesto_md/services/payment_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentController extends GetxController {
  /// Full offerings object (all offerings from RevenueCat)
  final Rx<Offerings?> offerings = Rx<Offerings?>(null);

  /// Packages (products) from the CURRENT offering
  final RxList<Package> packages = <Package>[].obs;

  /// Global loading for init + fetching offerings
  final RxBool isLoading = false.obs;

  /// Loading just for a purchase action (optional separate flag)
  final RxBool isPurchasing = false.obs;

  /// Premium state
  final RxBool isPremiumUser = false.obs;
  final RxBool hasCheckedSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    isLoading.value = true;
    try {
      // 1) Configure RevenueCat SDK
      await PaymentService.instance.init();

      // 2) Load offerings + packages
      await loadOfferings();

      // 3) Check subscription status
      await checkIfPremium();
    } catch (e) {
      print("❌ Error initializing RevenueCat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch offerings from PaymentService (with caching inside service)
  Future<void> loadOfferings({bool forceRefresh = false}) async {
    try {
      final fetchedOfferings =
          await PaymentService.instance.fetchOfferings(forceRefresh: forceRefresh);

      offerings.value = fetchedOfferings;

      // Use current offering by default
      final current = fetchedOfferings?.current;
      if (current != null) {
        packages.assignAll(current.availablePackages);
        print("✅ Packages loaded from current offering: ${packages.length}");
      } else {
        packages.clear();
        print("⚠️ No current offering or no packages available.");
      }
    } catch (e) {
      print("❌ Error loading offerings: $e");
      packages.clear();
    }
  }

  /// Optional: if you ever want ALL packages from ALL offerings:
  Future<void> loadAllPackagesFromAllOfferings({bool forceRefresh = false}) async {
    try {
      final allPackages =
          await PaymentService.instance.getAllAvailablePackages(forceRefresh: forceRefresh);
      packages.assignAll(allPackages);
      print("✅ All packages from all offerings: ${packages.length}");
    } catch (e) {
      print("❌ Error loading all packages: $e");
      packages.clear();
    }
  }

  /// Purchase using your abstracted PurchaseParams
  /// (You said you’re using a custom wrapper, so I keep it.)
  Future<void> purchase(PurchaseParams purchaseParams) async {
    isPurchasing.value = true;
    try {
      final success = await PaymentService.instance.purchase(purchaseParams);
      if (success) {
        await checkIfPremium();
        Get.snackbar("Success", "✅ Subscription Activated");
      } else {
        Get.snackbar("Error", "Subscription failed");
      }
    } catch (e) {
      print("❌ Error during purchase: $e");
      Get.snackbar("Error", "Something went wrong with the purchase");
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Check if user has "premium" entitlement
  Future<void> checkIfPremium() async {
    try {
      isPremiumUser.value = await PaymentService.instance.isUserPremium();
      hasCheckedSubscription.value = true;
      print("👑 isPremiumUser: ${isPremiumUser.value}");
    } catch (e) {
      print("❌ Error checking premium: $e");
      hasCheckedSubscription.value = true;
    }
  }
}

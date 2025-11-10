import 'package:get/get.dart';
import 'package:manifesto_md/services/payment_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentController extends GetxController {
  final Rx<Offerings?> offerings = Rx<Offerings?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPremiumUser = false.obs;
  final RxBool hasCheckedSubscription = false.obs;
  final RxList<Package> packages = <Package>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRevenueCat();
  }

  Future<void> _initializeRevenueCat() async {
    isLoading(true);
    try {
      await PaymentService.instance.init();
      await loadOfferings();
      await fetchSubscriptions();
      await checkIfPremium();
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadOfferings() async {
    offerings.value = await PaymentService.instance.getOfferings();
  }

  Future<void> fetchSubscriptions() async {
    final cachedOfferings = offerings.value;
    final fetchedOfferings =
        cachedOfferings ?? await PaymentService.instance.getOfferings();
    if (offerings.value == null && fetchedOfferings != null) {
      offerings.value = fetchedOfferings;
    }
    if (fetchedOfferings != null && fetchedOfferings.current != null) {
      packages.value = fetchedOfferings.current!.availablePackages;
      print("✅ Products Loaded: ${packages.length}");
    } else {
      packages.clear();
    }
  }

  Future<void> purchase(PurchaseParams package) async {
    final success = await PaymentService.instance.purchase(package);
    if (success) {
      await checkIfPremium();
      Get.snackbar("Success", "✅ Subscription Activated");
    } else {
      Get.snackbar("Error", "Subscription failed");
    }
  }

  Future<void> checkIfPremium() async {
    isPremiumUser.value = await PaymentService.instance.isUserPremium();
    hasCheckedSubscription.value = true;
  }
}

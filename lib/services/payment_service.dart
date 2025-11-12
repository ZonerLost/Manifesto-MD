// import 'package:purchases_flutter/purchases_flutter.dart';

// class PaymentService {
//   PaymentService._internal();

//   static final PaymentService instance = PaymentService._internal();

//   bool _isConfigured = false;

//   Future<void> init() async {
//     if (_isConfigured) return;
//     await Purchases.configure(
//       PurchasesConfiguration("test_TREKzoVPAzVGFPtmfexXNgThIDg"),
//     );
//     _isConfigured = true;
//   }

//   Future<Offerings?> getOfferings() async {
//     try {
//       return await Purchases.getOfferings();
//     } catch (e) {
//       print("❌ Error fetching offerings: $e");
//       return null;
//     }
//   }

//   Future<bool> purchase(PurchaseParams package) async {
//     try {
//       final customerInfo = await Purchases.purchase(package);
//       return customerInfo.customerInfo.entitlements.active.isNotEmpty;
//     } catch (e) {
//       print("❌ Purchase failed: $e");
//       return false;
//     }
//   }

//   Future<bool> isUserPremium() async {
//     try {
//       final customerInfo = await Purchases.getCustomerInfo();
//       return customerInfo.entitlements.active.containsKey("premium");
//     } catch (e) {
//       print("❌ Error checking premium: $e");
//       return false;
//     }
//   }
// }

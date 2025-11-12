// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:manifesto_md/constants/app_colors.dart';
// import 'package:manifesto_md/constants/app_fonts.dart';
// import 'package:manifesto_md/constants/app_images.dart';
// import 'package:manifesto_md/constants/app_sizes.dart';
// import 'package:manifesto_md/controllers/payment_controller.dart';
// import 'package:manifesto_md/view/widget/custom_container_widget.dart';
// import 'package:manifesto_md/view/widget/my_button_widget.dart';
// import 'package:manifesto_md/view/widget/my_text_widget.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// class Subscription extends StatefulWidget {
//   const Subscription({super.key});

//   @override
//   State<Subscription> createState() => _SubscriptionState();
// }

// class _SubscriptionState extends State<Subscription> {
//   // late final PaymentController paymentController;
//   final CarouselSliderController _carouselController = CarouselSliderController();

//   /// 0 = Free, 1 = Premium
//   int currentPlanIndex = 0;

//   void selectPlan(int index) {
//     setState(() {
//       currentPlanIndex = index;
//     });
//   }

//   int selectedPlanIndex = 0;

//   final List<Map<String, String>> _premiumPlan = [
//     {'title': 'Monthly', 'description': 'Billed monthly', 'price': '\$ 350.00'},
//     {
//       'title': 'Annually',
//       'description': 'Billed annually',
//       'price': '\$ 850.00',
//     },
//     {
//       'title': 'Lifetime',
//       'description': 'One time payment',
//       'price': '\$ 1999.00',
//     },
//   ];
//   final List<Map<String, String>> _standardPlan = [
//     {'title': 'Monthly', 'description': 'Billed monthly', 'price': '\$ 7.7'},
//     {'title': 'Annually', 'description': 'Billed annually', 'price': '\$ 75.5'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     paymentController = Get.find<PaymentController>();
//   }

//   int _effectiveSelectedIndex(int length) {
//     if (length <= 0) return 0;
//     final num clamped = selectedPlanIndex.clamp(0, length - 1);
//     return clamped is int ? clamped : clamped.toInt();
//   }

//   void _jumpToPlan(int index) {
//     setState(() {
//       selectedPlanIndex = index;
//     });
//     if (_carouselController.ready) {
//       _carouselController.animateToPage(index);
//     }
//   }

//   String _formatSubscriptionPeriod(String? isoPeriod) {
//     if (isoPeriod == null || isoPeriod.isEmpty) return '';
//     final exp = RegExp(r'P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?', caseSensitive: false);
//     final match = exp.firstMatch(isoPeriod);
//     if (match == null) return isoPeriod;
//     final parts = <String>[];
//     final labels = ['year', 'month', 'week', 'day'];
//     for (var i = 0; i < labels.length; i++) {
//       final valueStr = match.group(i + 1);
//       if (valueStr == null) continue;
//       final value = int.tryParse(valueStr);
//       if (value == null) continue;
//       final suffix = value == 1 ? labels[i] : '${labels[i]}s';
//       parts.add('$value $suffix');
//     }
//     return parts.isEmpty ? isoPeriod : parts.join(' ');
//   }

//   String _readablePackageType(Package package) {
//     switch (package.packageType) {
//       case PackageType.weekly:
//         return 'Weekly';
//       case PackageType.monthly:
//         return 'Monthly';
//       case PackageType.twoMonth:
//         return '2 Months';
//       case PackageType.threeMonth:
//         return '3 Months';
//       case PackageType.sixMonth:
//         return '6 Months';
//       case PackageType.annual:
//         return 'Annual';
//       case PackageType.lifetime:
//         return 'Lifetime';
//       case PackageType.custom:
//       case PackageType.unknown:
//         return package.identifier;
//     }
//   }

//   String _formatPackageTitle(Package package) {
//     final title = package.storeProduct.title.trim();
//     if (title.isNotEmpty) return title;
//     return '${_readablePackageType(package)} Plan';
//   }

//   String _packageDescription(Package package) {
//     final product = package.storeProduct;
//     final period = _formatSubscriptionPeriod(product.subscriptionPeriod);
//     if (period.isNotEmpty) {
//       return 'Billed every $period';
//     }
//     if (product.description.isNotEmpty) {
//       return product.description;
//     }
//     return _readablePackageType(package);
//   }

//   Future<void> _handleSubscribe() async {
//     final packages = paymentController.packages;
//     if (packages.isEmpty) {
//       Get.snackbar(
//         'Plans unavailable',
//         'RevenueCat did not return any products. Please try again later.',
//       );
//       return;
//     }
//     final idx = _effectiveSelectedIndex(packages.length);
//     final selectedPackage = packages[idx];
//     await paymentController.purchase(PurchaseParams.package(selectedPackage));
//   }

//   Widget _buildStatusBanner() {
//     return Obx(() {
//       final hasStatus = paymentController.hasCheckedSubscription.value;
//       final isPremium = paymentController.isPremiumUser.value;
//       final bool isLoading = !hasStatus;
//       final text =
//           isLoading
//               ? 'Checking your RevenueCat subscription status...'
//               : isPremium
//                   ? 'Your Manifesto MD Pro subscription is active via RevenueCat.'
//                   : 'You are currently on the free tier. Subscribe to unlock chat group creation.';
//       final Color accent = isPremium
//           ? const Color(0xFF1B9C85)
//           : Colors.orangeAccent;
//       final icon = isPremium ? Icons.verified : Icons.info_outline;
//       return Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: accent.withValues(alpha: 0.12),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: accent.withValues(alpha: 0.4)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: accent, size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//               child: MyText(
//                 text: text,
//                 size: 12,
//                 color: kTertiaryColor,
//                 lineHeight: 1.4,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildPlansCarousel() {
//     return Obx(() {
//       final packages = paymentController.packages;
//       final fallbackPlans =
//           currentPlanIndex == 0 ? _premiumPlan : _standardPlan;
//       final bool hasRevenueCatPlans = packages.isNotEmpty;
//       final int planCount =
//           hasRevenueCatPlans ? packages.length : fallbackPlans.length;
//       final bool isBusy =
//           paymentController.isLoading.value && packages.isEmpty;

//       if (isBusy) {
//         return SizedBox(
//           height: 180,
//           child: const Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }

//       if (planCount == 0) {
//         return Container(
//           height: 120,
//           alignment: Alignment.center,
//           child: MyText(
//             text: 'No subscription plans are available right now.',
//             size: 12,
//             color: kGreyColor,
//             textAlign: TextAlign.center,
//           ),
//         );
//       }

//       final selectedIndex = _effectiveSelectedIndex(planCount);

//       return CarouselSlider(
//         carouselController: _carouselController,
//         options: CarouselOptions(
//           viewportFraction: 0.4,
//           enableInfiniteScroll: hasRevenueCatPlans ? false : true,
//           autoPlay: false,
//           height: 180,
//           enlargeCenterPage: true,
//           onPageChanged: (index, reason) {
//             setState(() {
//               selectedPlanIndex = index;
//             });
//           },
//         ),
//         items: List.generate(planCount, (index) {
//           if (hasRevenueCatPlans) {
//             final package = packages[index];
//             return _Plan(
//               title: _formatPackageTitle(package),
//               description: _packageDescription(package),
//               price: package.storeProduct.priceString,
//               isSelected: selectedIndex == index,
//               onTap: () => _jumpToPlan(index),
//             );
//           }
//           final plan = fallbackPlans[index];
//           return _Plan(
//             title: plan['title']!,
//             description: plan['description']!,
//             price: plan['price']!,
//             isSelected: selectedIndex == index,
//             onTap: () => _jumpToPlan(index),
//           );
//         }),
//       );
//     });
//   }

//   Widget _buildSelectedPlanDetails() {
//     return Obx(() {
//       final packages = paymentController.packages;
//       if (packages.isEmpty) return const SizedBox.shrink();
//       final idx = _effectiveSelectedIndex(packages.length);
//       final package = packages[idx];
//       final product = package.storeProduct;
//       final offeringId = paymentController.offerings.value?.current?.identifier;
//       final billingCycle = _formatSubscriptionPeriod(product.subscriptionPeriod);
//       final intro = product.introductoryPrice;
//       final introPeriod =
//           intro == null ? '' : _formatSubscriptionPeriod(intro.period);
//       final introText =
//           intro == null
//               ? null
//               : introPeriod.isEmpty
//                   ? intro.priceString
//                   : '${intro.priceString} · $introPeriod x${intro.cycles}';
//       return Container(
//         margin: const EdgeInsets.only(top: 20),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: kPrimaryColor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(width: 1.0, color: kBorderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             MyText(
//               text: 'Selected RevenueCat Plan',
//               size: 12,
//               weight: FontWeight.w600,
//               color: kGreyColor,
//               paddingBottom: 8,
//             ),
//             MyText(
//               text: _formatPackageTitle(package),
//               size: 18,
//               weight: FontWeight.w700,
//               paddingBottom: 8,
//             ),
//             if (product.description.isNotEmpty)
//               MyText(
//                 text: product.description,
//                 size: 12,
//                 lineHeight: 1.4,
//                 color: kGreyColor,
//                 paddingBottom: 12,
//               ),
//             _PlanDetailRow(label: 'Price', value: product.priceString),
//             if (billingCycle.isNotEmpty)
//               _PlanDetailRow(label: 'Billing cycle', value: billingCycle),
//             if (offeringId != null)
//               _PlanDetailRow(label: 'Offering', value: offeringId),
//             _PlanDetailRow(label: 'Product ID', value: product.identifier),
//             _PlanDetailRow(
//               label: 'Package type',
//               value: _readablePackageType(package),
//             ),
//             if (introText != null)
//               _PlanDetailRow(label: 'Intro offer', value: introText),
//           ],
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomContainer(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,

//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(height: 55),
//             Padding(
//               padding: AppSizes.HORIZONTAL,
//               child: Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(2),
//                     height: 30,
//                     width: 225,
//                     decoration: BoxDecoration(
//                       color: kPrimaryColor,
//                       border: Border.all(width: 1.0, color: kBorderColor),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: List.generate(2, (index) {
//                         final planNames = ['Premium', 'Standard'];
//                         return Expanded(
//                           child: GestureDetector(
//                             onTap: () => selectPlan(index),
//                             child: Container(
//                               height: Get.height,
//                               decoration: BoxDecoration(
//                                 gradient:
//                                     currentPlanIndex == index
//                                         ? LinearGradient(
//                                           colors: [
//                                             Color(0xff12C0C0),
//                                             Color(0xff009CCD),
//                                           ],
//                                           begin: Alignment.topCenter,
//                                           end: Alignment.bottomCenter,
//                                         )
//                                         : null,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Center(
//                                 child: MyText(
//                                   text: planNames[index],
//                                   size: 12,
//                                   weight: FontWeight.w500,
//                                   color:
//                                       currentPlanIndex == index
//                                           ? kPrimaryColor
//                                           : kGreyColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                   Spacer(),
//                   GestureDetector(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: Image.asset(Assets.imagesCancel, height: 24),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: ListView(
//                 shrinkWrap: true,
//                 padding: AppSizes.VERTICAL,
//                 physics: BouncingScrollPhysics(),
//                 children: [
//                   Padding(
//                     padding: AppSizes.HORIZONTAL,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Image.asset(Assets.imagesCrown, height: 52),
//                           ],
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: [
//                             MyText(
//                               text: 'Manifesto MD',
//                               size: 30,
//                               weight: FontWeight.w700,
//                             ),
//                             MyText(
//                               text: ' PRO',
//                               size: 30,
//                               weight: FontWeight.w700,
//                               color: kSecondaryColor,
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         MyText(
//                           text:
//                               '100% ADs-Free experience with unlimited filters',
//                           size: 12,
//                           weight: FontWeight.w600,
//                           color: kGreyColor,
//                           paddingBottom: 16,
//                         ),
//                         _buildStatusBanner(),
//                         Container(
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: kPrimaryColor,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(width: 1.0, color: kBorderColor),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 6,
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 70,
//                                           height: 18,
//                                           decoration: BoxDecoration(
//                                             color: kSecondaryColor,
//                                             borderRadius: BorderRadius.circular(
//                                               4,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: MyText(
//                                               text: 'Features',
//                                               weight: FontWeight.w600,
//                                               color: kPrimaryColor,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: MyText(
//                                       text: 'Standard',
//                                       size: 12,
//                                       textAlign: TextAlign.center,
//                                       weight: FontWeight.w600,
//                                       color: kSecondaryColor,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: MyText(
//                                       text: 'Premium',
//                                       size: 12,
//                                       textAlign: TextAlign.center,
//                                       weight: FontWeight.w600,
//                                       color: kSecondaryColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 16),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 6,
//                                     child: Column(
//                                       spacing: 20,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: List.generate(4, (index) {
//                                         final features = [
//                                           'All features',
//                                           'Chat Group Creation',
//                                           'Smart DDx',
//                                           'Ads Free Version',
//                                         ];
//                                         return MyText(
//                                           text: features[index],
//                                           weight: FontWeight.w600,
//                                         );
//                                       }),
//                                     ),
//                                   ),
//                                   SizedBox(width: 10),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Column(
//                                       spacing: 16,
//                                       children: List.generate(4, (index) {
//                                         return Image.asset(
//                                           index < 3
//                                               ? Assets.imagesCancelIcon
//                                               : Assets.imagesCheckIcon,
//                                           height: 24,
//                                         );
//                                       }),
//                                     ),
//                                   ),
//                                   SizedBox(width: 12),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Column(
//                                       spacing: 16,
//                                       children: List.generate(4, (index) {
//                                         return Image.asset(
//                                           Assets.imagesCheckIcon,
//                                           height: 24,
//                                         );
//                                       }),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   _buildPlansCarousel(),
//                   _buildSelectedPlanDetails(),
//                   Padding(
//                     padding: AppSizes.DEFAULT,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         MyText(
//                           paddingTop: 20,
//                           text:
//                               'Free premium for 3 days! After that, Rs 280.00/Week,\nCancel anytime before trial ends to avoid changes.',
//                           size: 12,
//                           lineHeight: 1.5,
//                           color: kGreyColor,
//                           paddingBottom: 12,
//                           textAlign: TextAlign.center,
//                         ),
//                         Obx(() {
//                           final hasPackages =
//                               paymentController.packages.isNotEmpty;
//                           final busy = paymentController.isLoading.value &&
//                               !hasPackages;
//                           return MyButton(
//                             radius: 16,
//                             height: 56,
//                             enabled: hasPackages,
//                             isLoading: busy,
//                             buttonText: 'Subscribe Now',
//                             onTap: () => _handleSubscribe(),
//                             customChild: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: MyText(
//                                       text:
//                                           hasPackages
//                                               ? 'Subscribe with RevenueCat'
//                                               : 'Fetching plans...',
//                                       size: 16,
//                                       weight: FontWeight.w600,
//                                       color: kPrimaryColor,
//                                     ),
//                                   ),
//                                   Image.asset(
//                                     Assets.imagesArrowNextRounded,
//                                     height: 24,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10.0),
//                           child: RichText(
//                             textAlign: TextAlign.center,
//                             text: TextSpan(
//                               style: TextStyle(
//                                 fontFamily: AppFonts.URBANIST,
//                                 color: kGreyColor,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: 'Restore',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     decoration: TextDecoration.underline,
//                                     color: kGreyColor,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 TextSpan(text: ' | '),
//                                 TextSpan(
//                                   text: 'Terms of Use',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: kGreyColor,
//                                     decoration: TextDecoration.underline,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 TextSpan(text: ' | '),
//                                 TextSpan(
//                                   text: 'Privacy Policy',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: kGreyColor,
//                                     decoration: TextDecoration.underline,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Plan extends StatelessWidget {
//   final String title;
//   final String price;
//   final String description;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _Plan({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.price,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isSelected ? kBorderColor : kPrimaryColor,
//         border: Border.all(
//           width: isSelected ? 2.0 : 1.0,
//           color: isSelected ? kSecondaryColor : kBorderColor,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 12),
//             decoration: BoxDecoration(
//               color: isSelected ? kSecondaryColor : Colors.transparent,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(14),
//                 topRight: Radius.circular(14),
//               ),
//             ),
//             child: Center(
//               child: MyText(
//                 text: title.toUpperCase(),
//                 size: 16,
//                 color: isSelected ? kPrimaryColor : kTertiaryColor,
//                 textAlign: TextAlign.center,
//                 weight: FontWeight.w700,
//               ),
//             ),
//           ),
//           Spacer(),
//           MyText(
//             text: price,
//             size: 20,
//             color: isSelected ? kSecondaryColor : kTertiaryColor,
//             textAlign: TextAlign.center,
//             weight: FontWeight.w700,
//           ),
//           Spacer(),
//           MyText(
//             text:
//                 description == 'One time payment' ? 'Rs. 2500.00' : description,
//             size: 10,
//             decoration:
//                 description == 'One time payment'
//                     ? TextDecoration.lineThrough
//                     : TextDecoration.none,
//             color: isSelected ? kTertiaryColor : kGreyColor,
//             weight: FontWeight.w600,
//             textAlign: TextAlign.center,
//             paddingBottom: 12,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PlanDetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _PlanDetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: MyText(
//               text: label,
//               size: 11,
//               color: kGreyColor,
//               weight: FontWeight.w600,
//             ),
//           ),
//           Expanded(
//             child: MyText(
//               text: value,
//               size: 12,
//               color: kTertiaryColor,
//               weight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

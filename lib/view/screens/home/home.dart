import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/payment_controller.dart';
import 'package:manifesto_md/view/screens/chat_room/chat_room.dart';
import 'package:manifesto_md/view/screens/clinical_manifestations/clinical_manifestations.dart';
import 'package:manifesto_md/view/screens/diagnoses/diagnoses.dart';
import 'package:manifesto_md/view/screens/investigation/investigation.dart';
import 'package:manifesto_md/view/screens/profile/profile.dart';
import 'package:manifesto_md/view/screens/profile/references.dart';
import 'package:manifesto_md/view/screens/quick_access_management/quick_access_management.dart';
import 'package:manifesto_md/view/screens/search/search.dart';
import 'package:manifesto_md/view/screens/smart_ddx_tool/smart_ddx_tool.dart';
import 'package:manifesto_md/view/screens/subscription/subscription.dart';
import 'package:manifesto_md/view/screens/tools_calculators/tools_calculators.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final List<Map<String, String>> menuItems = [
      {
        'title': 'Clinical Manifestation',
        'image': Assets.imagesClinicalManisfesto,
      },
      {'title': 'Diagnoses', 'image': Assets.imagesDiagnoses},
      {
        'title': 'Investigation',
        'image': Assets.imagesInvestigation,
      },
      {'title': 'Smart DDx Tool', 'image': Assets.imagesSmartDdx},
      {'title': 'Quick Access', 'image': Assets.imagesQuickAccess},
      {'title': 'Chat Room', 'image': Assets.imagesChatRoom},
      {
        'title': 'Tools & Calculator',
        'image': Assets.imagesToolsCalculator,
      },
      {'title': 'References', 'image': Assets.imagesReferences},
      {'title': 'Profile', 'image': Assets.imagesProfile},
      {
        'title': 'Subscriptions',
        'image': Assets.imagesSubscription,
      },
    ];

    Widget buildMenuTile(
      Map<String, String> item,
      int index,
      bool isLocked,
    ) {
      final title = item['title'];
      return Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (isLocked) {
                Get.snackbar(
                  'Subscription Required',
                  'Smart DDx Tool is part of Manifesto MD Pro. Subscribe to unlock.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
                return;
              }
              switch (title) {
                case 'Clinical Manifestation':
                  Get.to(() => const ClinicalManifestations());
                  break;
                case 'Diagnoses':
                  Get.to(() => Diagnoses());
                  break;
                case 'Investigation':
                  Get.to(() => const Investigation());
                  break;
                case 'Smart DDx Tool':
                  Get.to(() => SmartDdxTool(), binding: AppBindings());
                  break;
                case 'Quick Access':
                  Get.to(() => QuickAccessManagement());
                  break;
                case 'Chat Room':
                  Get.to(() => const ChatRoom());
                  break;
                case 'Tools & Calculator':
                  Get.to(() => ToolsCalculators());
                  break;
                case 'References':
                  Get.to(() => const References());
                  break;
                case 'Profile':
                  Get.to(() => const Profile());
                  break;
                case 'Subscriptions':
                  Get.to(() => const Subscription());
                  break;
                default:
                  break;
              }
            },
            child: Container(
              width: Get.width,
              height: Get.height,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                border: Border.all(color: kBorderColor, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(item['image'] ?? '', height: 40),
                  MyText(
                    paddingTop: 10,
                    text: title ?? '',
                    size: 12,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                  size: 30,
                ),
              ),
            ),
          if (index == 6)
            Positioned(
              top: 0,
              right: 4,
              child: Image.asset(Assets.imagesComingSoon, height: 40),
            ),
        ],
      );
    }

    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              MyText(
                text: 'Manifesto',
                size: 20,
                weight: FontWeight.w800,
                color: kSecondaryColor,
              ),
              MyText(
                text: ' MD',
                size: 20,
                weight: FontWeight.w800,
                color: kTertiaryColor,
              ),
            ],
          ),
          actions: [
            Center(child: Image.asset(Assets.imagesBookmark, height: 28)),
            SizedBox(width: 14),
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => Subscription());
                },
                child: Image.asset(Assets.imagesProUser, height: 28),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: const BouncingScrollPhysics(),
          children: [
            Row(
              // keep spacing if your extension supports it
              spacing: 8,
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    onTap: () {
                      Get.to(() => Search());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Clinical Manifestations,ICD-11 codes',
                      hintStyle:
                          const TextStyle(color: kHintColor, fontSize: 14),
                      filled: true,
                      fillColor: kBorderColor,
                      suffixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.imagesSearchIcon, height: 20),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kBorderColor, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: kBorderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: kSecondaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                // Filter button removed entirely
              ],
            ),
            MyText(
              paddingTop: 20,
              text: 'Clinical Clarity, Instantly!',
              size: 16,
              weight: FontWeight.w600,
              paddingBottom: 12,
            ),
            GridView.builder(
              padding: AppSizes.ZERO,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 90,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: menuItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = menuItems[index];
                final isSmartDdxCard = item['title'] == 'Smart DDx Tool';
                if (isSmartDdxCard) {
                  return Obx(() {
                    final hasStatus =
                        paymentController.hasCheckedSubscription.value;
                    final isLocked = hasStatus
                        ? !paymentController.isPremiumUser.value
                        : true;
                    return buildMenuTile(item, index, isLocked);
                  });
                }
                return buildMenuTile(item, index, false);
              },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: Row(
            children: [
              MyText(
                text: 'Home',
                size: 12,
                weight: FontWeight.w600,
                color: kSecondaryColor,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 10,
                color: kGreyColor,
              ),
              MyText(
                text: 'Frequently Used',
                size: 12,
                weight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

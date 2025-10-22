import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
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
import 'package:manifesto_md/view/widget/expandable_dropdown_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 20),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            Row(
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
                      hintStyle: TextStyle(color: kHintColor, fontSize: 14),
                      filled: true,
                      fillColor: kBorderColor,
                      suffixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.imagesSearchIcon, height: 20),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(
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
                        borderSide: BorderSide(
                          color: kSecondaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(_Filter(), isScrollControlled: true);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: kBorderColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Image.asset(Assets.imagesFilterIcon, height: 24),
                    ),
                  ),
                ),
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
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 90,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                final List<Map<String, String>> items = [
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
                final item = items[index];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        switch (item['title']) {
                          case 'Clinical Manifestation':
                            Get.to(() => ClinicalManifestations());
                            break;
                          case 'Diagnoses':
                            Get.to(() => Diagnoses());
                            break;
                          case 'Investigation':
                            Get.to(() => Investigation());
                            break;
                          case 'Smart DDx Tool':
                            Get.to(() => SmartDdxTool(), binding: AppBindings());
                            break;
                          case 'Quick Access':
                            Get.to(() => QuickAccessManagement());
                            break;
                          case 'Chat Room':
                            Get.to(() => ChatRoom(), );
                            break;
                          case 'Tools & Calculator':
                            Get.to(() => ToolsCalculators());
                            break;
                          case 'References':
                            Get.to(() => References());
                            break;
                          case 'Profile':
                            Get.to(() => Profile());
                            break;
                          case 'Subscriptions':
                            Get.to(() => Subscription());
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
                              text: item['title'] ?? '',
                              size: 12,
                              weight: FontWeight.w600,
                            ),
                          ],
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
                margin: EdgeInsets.symmetric(horizontal: 8),
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

class _Filter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FilterStateful();
  }
}

class _FilterStateful extends StatefulWidget {
  @override
  State<_FilterStateful> createState() => _FilterStatefulState();
}

class _FilterStatefulState extends State<_FilterStateful> {
  String _selectedBodySystem = 'Body System';
  String _selectedICD11 = 'ICD-11 Code';
  String _selectedSeverity = 'Severity';
  String _selectedHistory = 'History';
  String _selectedSortBy = 'Sort By';

  final List<String> bodySystemItems = [
    'Body System',
    'Cardiovascular',
    'Respiratory',
    'Gastrointestinal',
    'Neurological',
    'Dermatological',
  ];

  final List<String> icd11Items = [
    'ICD-11 Code',
    '1A00.0',
    '1B20.1',
    '2C30.2',
    '3D40.3',
    '4E50.4',
  ];

  final List<String> severityItems = ['Severity', 'Mild', 'Moderate', 'Severe'];

  final List<String> historyItems = [
    'History',
    'Recent',
    'Chronic',
    'Recurrent',
  ];

  final List<String> sortByItems = [
    'Sort By',
    'Alphabetical',
    'Most Common',
    'Recently Added',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomContainer(
          height: Get.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: 'Filter & Sort',
                        size: 16,
                        weight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Image.asset(Assets.imagesClose, height: 24),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: AppSizes.DEFAULT,
                  physics: BouncingScrollPhysics(),
                  children: [
                    ExpandableDropdown2(
                      title: 'Body System',
                      selectedValue: _selectedBodySystem,
                      items: bodySystemItems,
                      onSelect: (String value) {
                        setState(() {
                          _selectedBodySystem = value;
                        });
                      },
                    ),
                    ExpandableDropdown2(
                      title: 'ICD-11 Code',
                      selectedValue: _selectedICD11,
                      items: icd11Items,
                      onSelect: (String value) {
                        setState(() {
                          _selectedICD11 = value;
                        });
                      },
                    ),
                    ExpandableDropdown2(
                      title: 'Severity',
                      selectedValue: _selectedSeverity,
                      items: severityItems,
                      onSelect: (String value) {
                        setState(() {
                          _selectedSeverity = value;
                        });
                      },
                    ),
                    ExpandableDropdown2(
                      title: 'History',
                      selectedValue: _selectedHistory,
                      items: historyItems,
                      onSelect: (String value) {
                        setState(() {
                          _selectedHistory = value;
                        });
                      },
                    ),
                    ExpandableDropdown2(
                      title: 'Sort By',
                      selectedValue: _selectedSortBy,
                      items: sortByItems,
                      onSelect: (String value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSizes.DEFAULT,
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: MyBorderButton(buttonText: 'Reset', onTap: () {}),
                    ),
                    Expanded(
                      child: MyButton(
                        buttonText: 'Apply Filters',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

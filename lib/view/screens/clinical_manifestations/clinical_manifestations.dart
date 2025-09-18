import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/search/search.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/expandable_dropdown_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ClinicalManifestations extends StatefulWidget {
  const ClinicalManifestations({super.key});

  @override
  State<ClinicalManifestations> createState() => _ClinicalManifestationsState();
}

class _ClinicalManifestationsState extends State<ClinicalManifestations> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.bottomSheet(_Information(), isScrollControlled: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Clinical Manifestations'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
            ),
            Expanded(
              child: Container(
                margin: AppSizes.DEFAULT,
                decoration: BoxDecoration(
                  color: Color(0xffDDF6F6),
                  border: Border.all(color: kBorderColor, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyText(
                      paddingTop: 16,
                      paddingLeft: 16,
                      text: 'Front View',
                      size: 12,
                      weight: FontWeight.w600,
                      paddingBottom: 4,
                    ),
                    MyText(
                      paddingLeft: 16,
                      text: 'Skin Mode',
                      size: 10,
                      weight: FontWeight.w500,
                      color: kGreyColor,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Stack(
                            children: [
                              // Human body image
                              Positioned.fill(
                                child: Image.asset(
                                  Assets.imagesHumanBody,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Example: Head marker
                              Positioned(
                                top: 60,
                                left: 110,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Chest marker
                              Positioned(
                                top: 160,
                                left: 120,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Abdomen marker
                              Positioned(
                                top: 240,
                                left: 125,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Left arm marker
                              Positioned(
                                top: 170,
                                left: 60,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Right arm marker
                              Positioned(
                                top: 170,
                                right: 60,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Left leg marker
                              Positioned(
                                bottom: 60,
                                left: 110,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                              // Example: Right leg marker
                              Positioned(
                                bottom: 60,
                                right: 110,
                                child: Image.asset(
                                  Assets.imagesBodyPartTap,
                                  height: 16,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Column(
                              children: [
                                Image.asset(Assets.imagesReferesh, height: 30),
                                SizedBox(height: 16),
                                Image.asset(Assets.imagesBoard, height: 30),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 30,
                            child: Column(
                              spacing: 12,
                              children: [
                                Image.asset(Assets.imagesZoomIn, height: 30),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Row(
                                    spacing: 12,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: SliderTheme(
                                          data: SliderTheme.of(
                                            context,
                                          ).copyWith(
                                            trackHeight: 6,
                                            thumbShape:
                                                SliderComponentShape.noThumb,
                                            activeTrackColor: kSecondaryColor,
                                            inactiveTrackColor: Color(
                                              0xffC2E8E8,
                                            ),
                                            trackShape: CustomTrackShape(),
                                          ),
                                          child: Slider(
                                            value: 70,
                                            min: 0,
                                            max: 100,
                                            onChanged: (double value) {},
                                            activeColor: kSecondaryColor,
                                            inactiveColor: Color(0xffC2E8E8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(Assets.imagesZoomOut, height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filter extends StatefulWidget {
  @override
  State<_Filter> createState() => _FilterState();
}

class _FilterState extends State<_Filter> {
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

class _Information extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: AppSizes.DEFAULT,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyText(
                text: 'Info',
                size: 18,
                weight: FontWeight.w700,
                paddingBottom: 8,
              ),
              MyText(
                size: 13,
                text:
                    'Search for clinical manifestations above Or Tap on the body to find and choose clinical manifestations!?',
                paddingBottom: 20,
              ),
              MyButton(
                height: 44,
                buttonText: 'Done',
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),

        Positioned(
          top: -16,
          right: 32,
          child: Image.asset(Assets.imagesInfoBig, height: 65),
        ),
      ],
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/utils/global_instances.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class InvestigationDetails extends StatefulWidget {
  @override
  State<InvestigationDetails> createState() => _InvestigationDetailsState();
}

class _InvestigationDetailsState extends State<InvestigationDetails> {
  int selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sections = [
      {'title': 'Description', 'image': Assets.imagesInformation},
      {'title': 'Indications', 'image': Assets.imagesPin},
      {'title': 'Interpretation', 'image': Assets.imagesPin},
      {'title': 'Linked To', 'image': Assets.imagesPin},
      {'title': 'Additional Notes', 'image': Assets.imagesPin},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Complete Blood Count...',
          actions: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6.54),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kBorderColor,
                  border: Border.all(
                    width: 0.5,
                    color: kSecondaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(Assets.imagesSaveEmpty, height: 16),
                    ),
                    MyText(
                      text: 'Add to Favorite',
                      size: 10,
                      color: kTertiaryColor,
                      paddingRight: 4,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.VERTICAL,
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 30,
              child: ListView.separated(
                shrinkWrap: true,
                padding: AppSizes.HORIZONTAL,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final bool isSelected = selectedSection == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSection = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6.54,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            isSelected
                                ? kSecondaryColor.withValues(alpha: 0.12)
                                : kPrimaryColor,
                        border: Border.all(
                          width: 1.0,
                          color: isSelected ? kSecondaryColor : kBorderColor,
                        ),
                      ),
                      child: Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              sections[index]['image']!,
                              height: 20,
                            ),
                          ),
                          MyText(
                            text: sections[index]['title']!,
                            size: 10,
                            weight: FontWeight.w500,
                            color: isSelected ? kSecondaryColor : kGreyColor,
                            paddingRight: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 8);
                },
                itemCount: sections.length,
              ),
            ),

            Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CommonImageView(
                    height: 150,
                    width: Get.width,
                    radius: 16,
                    fit: BoxFit.cover,
                    url: dummyImg,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: 'Category',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                            MyText(
                              text: 'LAB',
                              size: 16,
                              weight: FontWeight.w600,
                              color: kSecondaryColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                text: 'Ref No.',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                            MyText(
                              text: 'L-112233',
                              size: 16,
                              weight: FontWeight.w600,
                              color: kSecondaryColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Image.asset(Assets.imagesInformation, height: 16),
                            Expanded(
                              child: MyText(
                                paddingLeft: 8,
                                text: 'Description',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 8,
                          text:
                              'Complete Blood Count (CBC) is a common blood test used to evaluate the overall health by measuring different components of blood including red blood cells (RBCs), white blood cells (WBCs), hemoglobin, hematocrit, and platelets.',
                          size: 12,
                          lineHeight: 1.5,
                          color: kGreyColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _ReportCard(
                    title: 'Indications',
                    icon: Assets.imagesIndications,
                    suggestedActions: [
                      'Suspected infection (e.g., fever, fatigue)',
                      'Anemia (e.g., pallor, shortness of breath)',
                      'Bleeding disorders (e.g., gum bleeding, easy bruising)',
                      'Routine pre-surgical checkup',
                    ],
                  ),
                  _ReportCard(
                    title: 'Interpretation',
                    icon: Assets.imagesIndications,
                    suggestedActions: [
                      'High WBC count: May indicate infection or inflammation',
                      'Low Hemoglobin: Suggests anemia',
                      'Low Platelets: Could indicate bleeding risk or bone marrow suppression',
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Image.asset(Assets.imagesIt, height: 16),
                            Expanded(
                              child: MyText(
                                paddingLeft: 8,
                                text: 'Linked to',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 12,
                          text: 'Linked Symptoms:',
                          size: 16,
                          weight: FontWeight.w600,
                          paddingBottom: 12,
                        ),
                        _ExpandableTile(
                          title: 'Fever',
                          subTitle:
                              'Fever is a temporary increase in body temperature, often due to an underlying infection, inflammation, or illness. It is generally considered when body temperature rises above 100.4°F (38°C)',
                        ),

                        _ExpandableTile(
                          title: 'Fatigue',
                          subTitle:
                              'Fatigue is a feeling of tiredness or exhaustion that can be caused by anemia, infection, chronic diseases, or other underlying medical conditions.',
                        ),
                        _ExpandableTile(
                          title: 'Easy bruising',
                          subTitle:
                              'Easy bruising refers to bruises that occur with minimal or no apparent trauma, which may indicate underlying bleeding disorders or platelet abnormalities.',
                        ),
                        _ExpandableTile(
                          title: 'Shortness of breath',
                          subTitle:
                              'Shortness of breath is a feeling of not being able to get enough air, which can be caused by anemia, heart, or lung conditions.',
                        ),
                        MyText(
                          paddingTop: 10,
                          text: 'Linked Symptoms:',
                          size: 16,
                          weight: FontWeight.w600,
                          paddingBottom: 12,
                        ),
                        _ExpandableTile(
                          title: 'Anemia',
                          subTitle:
                              'Shortness of breath is a feeling of not being able to get enough air, which can be caused by anemia, heart, or lung conditions.',
                        ),
                        _ExpandableTile(
                          title: 'Leukemia',
                          subTitle:
                              'Shortness of breath is a feeling of not being able to get enough air, which can be caused by anemia, heart, or lung conditions.',
                        ),
                        _ExpandableTile(
                          mBottom: 0,
                          title: 'Thrombocytopenia',
                          subTitle:
                              'Shortness of breath is a feeling of not being able to get enough air, which can be caused by anemia, heart, or lung conditions.',
                        ),
                      ],
                    ),
                  ),
                  _ReportCard(
                    title: 'Additional Notes',
                    icon: Assets.imagesIndications,
                    suggestedActions: [
                      'Sample collected via venipuncture',
                      'No fasting required',
                      'Avoid testing during menstruation for accurate Hb',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> suggestedActions;

  const _ReportCard({
    required this.title,
    required this.suggestedActions,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(icon, height: 16),
              Expanded(
                child: MyText(
                  paddingLeft: 8,
                  text: title,
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          ...suggestedActions.map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '- ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: AppFonts.URBANIST,
                        height: 1.4,
                        color: kSecondaryColor,
                      ),
                    ),
                    TextSpan(
                      text: text,
                      style: TextStyle(
                        fontFamily: AppFonts.URBANIST,
                        fontSize: 12,
                        height: 1.3,
                        color: kGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  const _ExpandableTile({
    required this.title,
    required this.subTitle,
    this.mBottom,
  });
  final String title;
  final String subTitle;
  final double? mBottom;

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  late ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: false);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.mBottom ?? 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBorderColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.0, color: kBorderColor),
      ),
      child: ExpandableNotifier(
        controller: _controller,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            controller: _controller,
            theme: ExpandableThemeData(tapHeaderToExpand: true, hasIcon: false),
            header: Container(
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      text: widget.title,
                      size: 12,
                      color: kGreyColor,
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: _controller.expanded ? 2 : 0,
                    child: Image.asset(Assets.imagesDropdown, height: 16),
                  ),
                ],
              ),
            ),
            collapsed: SizedBox(),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                MyText(
                  text: widget.subTitle,
                  lineHeight: 1.5,
                  color: kGreyColor,
                ),
                SizedBox(height: 10),
                MyButton(
                  buttonText: 'Go to Symptoms Page',
                  onTap: () {},
                  height: 32,
                  textSize: 12,
                  radius: 12,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

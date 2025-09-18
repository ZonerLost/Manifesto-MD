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
import 'package:step_progress_indicator/step_progress_indicator.dart';

class DiagnosesDetails extends StatefulWidget {
  @override
  State<DiagnosesDetails> createState() => _DiagnosesDetailsState();
}

class _DiagnosesDetailsState extends State<DiagnosesDetails> {
  int selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sections = [
      {'title': 'Definition', 'image': Assets.imagesInformation},
      {'title': 'Etiology', 'image': Assets.imagesPin},
      {'title': 'Clinical Features', 'image': Assets.imagesCf},
      {'title': 'Investigations', 'image': Assets.imagesIt},
      {'title': 'Diagnosis', 'image': Assets.imagesDi},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Chickenpox',
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
                                text: 'Name of Manifestation',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                            MyText(
                              text: 'Hematemesis',
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
                                text: 'ICD-10 Code',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                            MyText(
                              text: 'R04.2',
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
                                text: 'Brief Definition',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 8,
                          text:
                              'Chickenpox is a highly contagious viral infection caused by the varicella-zoster virus (VZV). It primarily affects children and presents with fever, fatigue, and a characteristic itchy vesicular rash that appears in crops.',
                          size: 12,
                          lineHeight: 1.5,
                          color: kGreyColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: kRedColor.withValues(alpha: 0.06),
                      ),
                      color: kLightRedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Image.asset(Assets.imagesRedFlag, height: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: MyText(
                                text: 'Red Flag Alert',
                                size: 16,
                                color: kRedColor,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        ...[
                          'Large volume of fresh blood',
                          'Signs of shock (low BP, rapid pulse)',
                          'Associated with black tarry stools',
                          'History of liver disease or alcohol abuse',
                        ].map(
                          (text) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                MyText(
                                  text: '- ',
                                  size: 12,
                                  lineHeight: 1.5,
                                  color: kRedColor,
                                ),
                                Expanded(
                                  child: MyText(
                                    text: text,
                                    size: 12,
                                    lineHeight: 1.5,
                                    color: kGreyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _ReportCard(
                    title: 'Etiology',
                    icon: Assets.imagesPin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...[
                          {'stage': 1, 'title': 'Peptic ulcer disease'},
                          {'stage': 2, 'title': 'Esophageal varices'},
                          {
                            'stage': 3,
                            'title': 'Gastritis or gastric erosions',
                          },
                          {'stage': 4, 'title': 'Esophageal or gastric cancer'},
                        ].map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
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
                                          text: item['title'] as String,
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
                                SizedBox(
                                  width: 50,
                                  child: StepProgressIndicator(
                                    totalSteps: 4,
                                    currentStep: item['stage']! as int,
                                    size: 5,
                                    padding: 1,
                                    roundedEdges: Radius.circular(0),
                                    selectedColor: kSecondaryColor,
                                    unselectedColor: Color(
                                      0xff12C0C0,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    suggestedActions: [],
                  ),
                  _ReportCard(
                    title: 'Clinical Features',
                    icon: Assets.imagesCf,
                    suggestedActions: [
                      'Appearance of blood in vomit',
                      'Abdominal pain or discomfort',
                      'Dizziness, weakness',
                      'Melena (black stools)',
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
                                text: 'Investigations',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Investigation Page',

                          title: 'CBC (Hemoglobin, Hematocrit)',
                          subTitle:
                              'A Complete Blood Count (CBC) is a common blood test that evaluates the overall health by measuring various components of blood, including red blood cells (RBCs), white blood cells (WBCs), hemoglobin, hematocrit, and platelets.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Investigation Page',

                          title: 'Coagulation profile',
                          subTitle:
                              'Assesses the blood’s ability to clot and helps identify bleeding disorders. Includes tests like PT, aPTT, and INR.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Investigation Page',

                          title: 'Liver function tests',
                          subTitle:
                              'Evaluates liver enzymes and function to detect underlying liver disease, which can be associated with bleeding manifestations.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Investigation Page',

                          title:
                              'Endoscopy (gold standard for source identification)',
                          subTitle:
                              'A procedure using a flexible tube with a camera to directly visualize the upper gastrointestinal tract and accurately identify the source of bleeding.',
                        ),
                      ],
                    ),
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
                            Image.asset(Assets.imagesDi, height: 16),
                            Expanded(
                              child: MyText(
                                paddingLeft: 8,
                                text: 'Diagnosis',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Diagnosis Page',
                          title: 'Hemoptysis (coughing up blood)',
                          subTitle:
                              'Hemoptysis refers to coughing up blood from the respiratory tract, which can sometimes be mistaken for hematemesis if swallowed and then vomited.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Diagnosis Page',

                          title: 'Nasal/oral bleed swallowed and vomited',
                          subTitle:
                              'Bleeding from the nose or mouth may be swallowed and later vomited, mimicking gastrointestinal bleeding.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Diagnosis Page',

                          title: 'Red food or drink mimicking blood',
                          subTitle:
                              'Consumption of red-colored foods or drinks (e.g., beetroot, colored juices) can sometimes be mistaken for blood in vomit.',
                        ),
                        _ExpandableTile(
                          buttonText: 'Go to Diagnosis Page',

                          title: 'Severe gastritis',
                          subTitle:
                              'Severe inflammation of the stomach lining (gastritis) can cause upper GI bleeding and present as hematemesis.',
                        ),
                      ],
                    ),
                  ),

                  _ReportCard(
                    title: 'Management',
                    icon: Assets.imagesMp,
                    suggestedActions: [
                      'Immediate stabilization (airway, breathing, circulation)',
                      'IV fluids and blood transfusion if needed',
                      'Proton pump inhibitors (PPIs)',
                      'Endoscopic intervention for bleeding source',
                      'Surgical management in refractory cases',
                      'Antibiotics (especially in variceal bleeding)',
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
  final Widget? child;
  final List<String> suggestedActions;

  const _ReportCard({
    required this.title,
    required this.suggestedActions,
    required this.icon,
    this.child,
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
          if (child != null) ...[
            child!,
          ] else
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
    this.mTop,
    this.buttonText,
    this.onTap,
  });
  final String title;
  final String subTitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final double? mTop;

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
      margin: EdgeInsets.only(top: widget.mTop ?? 10),
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
                  buttonText: widget.buttonText ?? 'Go to Symptoms Page',
                  onTap: widget.onTap ?? () {},
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

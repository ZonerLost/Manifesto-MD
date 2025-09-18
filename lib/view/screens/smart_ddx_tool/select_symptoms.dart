import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/utils/global_instances.dart';
import 'package:manifesto_md/view/screens/smart_ddx_tool/diagnosis_results.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class SelectSymptoms extends StatefulWidget {
  const SelectSymptoms({super.key, required this.icon, required this.title});
  final String icon;
  final String title;

  @override
  State<SelectSymptoms> createState() => _SelectSymptomsState();
}

class _SelectSymptomsState extends State<SelectSymptoms> {
  @override
  Widget build(BuildContext context) {
    final List items = [
      'Burping',
      'Pain around belly button',
      'Nausea',
      'Vomiting blood',
      'Stomach inflammation',
      'Reflux',
      'Belly pain',
      'Stomach pushes through diaphragm',
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: -5.0,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(widget.icon, height: 20)],
          ),
          title: MyText(
            text: widget.title,
            size: 15,
            color: kTertiaryColor,
            weight: FontWeight.w600,
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(Assets.imagesClose, height: 24),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                padding: AppSizes.DEFAULT,
                physics: BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  final String symptom = items[index];
                  final bool isRedFlag = symptom == 'Vomiting blood';
                  final bool isSelected = smartDDxController.selectedSymptoms
                      .contains(symptom);
                  return GestureDetector(
                    onTap: () async {
                      if (isRedFlag) {
                        await Get.bottomSheet(
                          _RedFlagAlert(),
                          isScrollControlled: true,
                        );
                      }
                      if (isSelected) {
                        smartDDxController.removeSymptom(symptom);
                      } else {
                        smartDDxController.addSymptom(symptom);
                      }
                    },
                    child: Obx(
                      () => _ItemTile(
                        title: symptom,
                        isRedFlag: isRedFlag,
                        isSelected: smartDDxController.selectedSymptoms
                            .contains(symptom),
                        onSaveTap: () {
                          if (smartDDxController.selectedSymptoms.contains(
                            symptom,
                          )) {
                            smartDDxController.removeSymptom(symptom);
                          } else {
                            smartDDxController.addSymptom(symptom);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Padding(
                padding: AppSizes.DEFAULT,
                child: MyButton(
                  enabled: smartDDxController.selectedSymptoms.isNotEmpty,
                  buttonText: 'Find Possible Diagnoses',
                  onTap: () {
                    if (smartDDxController.selectedSymptoms.isNotEmpty) {
                      Get.to(() => DiagnosisResults());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final bool isRedFlag;
  final bool isSelected;
  final VoidCallback onSaveTap;

  const _ItemTile({
    required this.title,
    required this.isRedFlag,
    required this.isSelected,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRedFlag ? kRedColor.withValues(alpha: .12) : kPrimaryColor,
        border: Border.all(
          color: isRedFlag ? kRedColor.withValues(alpha: .12) : kBorderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isRedFlag) ...[
            Image.asset(Assets.imagesRedFlag, height: 16),
            SizedBox(width: 8),
          ],
          Expanded(child: MyText(text: title, size: 12, color: kGreyColor)),
          CustomCheckBox(
            borderWidth: 1.0,
            radius: 100,
            isActive: isSelected,
            onTap: onSaveTap,
          ),
        ],
      ),
    );
  }
}

class _RedFlagAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: kRedColor.withValues(alpha: 0.06),
        ),
        color: kLightRedColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
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
          MyText(
            paddingTop: 12,
            text:
                'This symptom may indicate a life-threatening condition, such as an upper gastrointestinal bleed.',
            size: 12,
            lineHeight: 1.5,
            color: kGreyColor,
          ),
          SizedBox(height: 6),
          ...[
            'Signs of shock (low BP, rapid pulse)',
            'Associated with black tarry stools',
            'History of liver disease or alcohol abuse',
            'History of liver disease or alcohol abuse',
          ].map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
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
          SizedBox(height: 10),
          MyButton(
            bgColor: kRedColor,
            buttonText: 'OK',
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/gemini_controller.dart';
import 'package:manifesto_md/utils/global_instances.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class DiagnosisResults extends StatelessWidget {
  final List<String> listSelectedSymptoms;

  DiagnosisResults({required this.listSelectedSymptoms});

  final GeminiController geminiController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>  geminiController.isLoading.value ? 
            Center(child: CircularProgressIndicator()) :
                        geminiController.diagnoses.isEmpty ?
           const Center(child: Text('No diagnoses found')) :
         CustomContainer(
      child:   Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Diagnosis Result',
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
            Padding(
              padding: AppSizes.HORIZONTAL,
              child: Row(
                children: [
                  Expanded(
                    child: MyText(
                      text: 'My Symptoms',
                      size: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                  MyText(
                    onTap: () {
                      smartDDxController.clearSymptoms();
                    },
                    text: 'CLEAR ALL',
                    size: 10,
                    color: kGreyColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: ListView.separated(
                shrinkWrap: true,
                padding: AppSizes.HORIZONTAL,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == smartDDxController.selectedSymptoms.length) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6.54,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Color(0xff12C0C0), Color(0xff009CCD)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: kPrimaryColor),
                            MyText(
                              text: 'Add Symptoms',
                              size: 10,
                              color: kPrimaryColor,
                              paddingLeft: 4,
                              paddingRight: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6.54,
                    ),
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
                        MyText(
                          text: smartDDxController.selectedSymptoms[index],
                          size: 10,
                          color: kGreyColor,
                        ),
                        GestureDetector(
                          onTap: () {
                            smartDDxController.removeSymptom(
                              smartDDxController.selectedSymptoms[index],
                            );
                          },
                          child: Image.asset(Assets.imagesClose, height: 20),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 8);
                },
                itemCount: smartDDxController.selectedSymptoms.length + 1,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              height: 1,
              color: kBorderColor,
            ),
            Padding(
              padding: AppSizes.HORIZONTAL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: 'Possible diagnoses based on selected symptoms:',
                    size: 10,
                    weight: FontWeight.w600,
                    paddingBottom: 10,
                  ),

                  ...geminiController.diagnoses.map((e) =>  _ReportCard(
                  title: e['title'] ?? 'Unknown Condition',
                  totalSteps: e['totalSteps'] ?? 1,
                  currentStep: e['currentStep'] ?? 1,
                  description: e['description'] ?? '',
                  redFlagAlert: e['redFlagAlert'] ?? '',
                  suggestedActions:
                      List<String>.from(e['suggestedActions'] ?? []),
                  ),).toList()
                ],
              ),
            ),
          ],
        ),
      ),
         )
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int totalSteps;
  final int currentStep;
  final String description;
  final String redFlagAlert;
  final Color redFlagColor;
  final List<String> suggestedActions;
  final VoidCallback? onTap;

  const _ReportCard({
    super.key,
    required this.title,
    required this.totalSteps,
    required this.currentStep,
    required this.description,
    required this.redFlagAlert,
    this.redFlagColor = kRedColor,
    required this.suggestedActions,
    this.onTap,
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
              Expanded(
                child: MyText(text: title, size: 14, weight: FontWeight.w600),
              ),
              SizedBox(
                width: 50,
                child: StepProgressIndicator(
                  totalSteps: totalSteps,
                  currentStep: currentStep,
                  size: 5,
                  padding: 1,
                  roundedEdges: Radius.circular(0),
                  selectedColor: kSecondaryColor,
                  unselectedColor: Color(0xff12C0C0).withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 16),
            color: kBorderColor,
          ),
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
            text: description,
            size: 12,
            lineHeight: 1.5,
            color: kGreyColor,
          ),
          if (redFlagAlert.isNotEmpty) ...[
            SizedBox(height: 14),
            Row(
              children: [
                Image.asset(Assets.imagesRedFlag, height: 16),
                Expanded(
                  child: MyText(
                    paddingLeft: 8,
                    text: 'Red Flag Alert',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            MyText(
              paddingTop: 8,
              text: redFlagAlert,
              size: 12,
              lineHeight: 1.5,
              color: redFlagColor,
            ),
          ],
          SizedBox(height: 14),
          Row(
            children: [
              Image.asset(Assets.imagesSuggestedActions, height: 16),
              Expanded(
                child: MyText(
                  paddingLeft: 8,
                  text: 'Suggested Action',
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          ...suggestedActions.map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
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
            buttonText: 'Go to Diagnosis Page for Full Details',
            onTap: onTap ?? () {},
            height: 32,
            textSize: 12,
            radius: 12,
            weight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

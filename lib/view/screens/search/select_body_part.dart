import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/clinical_manifestations/clinical_manifestations_details.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class SelectBodyPart extends StatefulWidget {
  const SelectBodyPart({super.key, required this.icon, required this.title});
  final String icon;
  final String title;

  @override
  State<SelectBodyPart> createState() => _SelectBodyPartState();
}

class _SelectBodyPartState extends State<SelectBodyPart> {
  final Set<int> savedIndices = {};
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
      'Stomach inflammation',
      'Nausea',
      'Reflux',
      'Belly pain',
      'Pain around belly button',
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
        body: ListView.separated(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 10);
          },
          itemBuilder: (BuildContext context, int index) {
            final bool isRedFlag = items[index] == 'Vomiting blood';
            return GestureDetector(
              onTap: () {
                if (isRedFlag) {
                  Get.bottomSheet(_RedFlagAlert(), isScrollControlled: true);
                } else {
                  Get.to(() => ClinicalManifestationsDetails());
                }
              },
              child: BodyPartItem(
                title: items[index],
                isRedFlag: isRedFlag,
                isSaved: savedIndices.contains(index),
                onSaveTap: () {
                  setState(() {
                    if (savedIndices.contains(index)) {
                      savedIndices.remove(index);
                    } else {
                      savedIndices.add(index);
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class BodyPartItem extends StatelessWidget {
  final String title;
  final bool isRedFlag;
  final bool isSaved;
  final VoidCallback onSaveTap;

  const BodyPartItem({
    super.key,
    required this.title,
    required this.isRedFlag,
    required this.isSaved,
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
          GestureDetector(
            onTap: onSaveTap,
            child: Image.asset(
              isSaved ? Assets.imagesSaveFilled : Assets.imagesSaveEmpty,
              height: 20,
            ),
          ),
          SizedBox(width: 6),
          Image.asset(Assets.imagesArrowNext, height: 20),
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

import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/tools_calculators/results.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final List<String> items = [
    'Confusion',
    'Urea > 7 mmol/L',
    'Respiratory Rate ≥ 30',
    'BP (Systolic < 90 or Diastolic ≤ 60)',
    'Age ≥ 65',
  ];
  List<bool> switchValues = List.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'CURB-65'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
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
                          text: 'Name',
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                      MyText(
                        text: 'CURB-65',
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
                          text: 'Used For',
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                      MyText(
                        text: 'Pneumonia Severity',
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
                        'A clinical tool used to assess the severity of community-acquired pneumonia and guide decisions about inpatient vs. outpatient treatment.',
                    size: 12,
                    lineHeight: 1.5,
                    color: kGreyColor,
                  ),
                ],
              ),
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
                  MyText(
                    text: 'For CURB-65',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                  Container(
                    height: 1,
                    color: kBorderColor,
                    margin: EdgeInsets.symmetric(vertical: 12),
                  ),
                  Column(
                    children: [
                      for (int i = 0; i < items.length; i++)
                        _CustomSwitchTile(
                          title: items[i],
                          value: switchValues[i],
                          onChanged: (value) {
                            setState(() {
                              switchValues[i] = value;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: MyButton(
            buttonText: 'Calculation & Result',
            onTap: () {
              Get.to(() => Results());
            },
          ),
        ),
      ),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitchTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = ValueNotifier<bool>(value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBorderColor.withValues(alpha: 0.05),
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: MyText(text: title, weight: FontWeight.w600, size: 12),
          ),
          AdvancedSwitch(
            controller: controller,
            activeColor: kSecondaryColor,
            inactiveColor: kRedColor,
            thumb: Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor,
              ),
              child: Icon(
                value ? Icons.check : Icons.close,
                color: value ? kSecondaryColor : kRedColor,
                size: 10,
              ),
            ),
            activeChild: MyText(
              text: 'Yes',
              paddingLeft: 4,
              color: kPrimaryColor,
              size: 7,
              weight: FontWeight.w600,
            ),
            inactiveChild: MyText(
              text: 'No',
              color: kPrimaryColor,
              paddingRight: 4,
              size: 7,
              weight: FontWeight.w600,
            ),
            borderRadius: BorderRadius.circular(50),
            width: 35.0,
            height: 18.0,
            enabled: true,
            disabledOpacity: 0.5,
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

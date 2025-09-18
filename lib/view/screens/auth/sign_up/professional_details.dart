import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/home/home.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/expandable_dropdown_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ProfessionalDetails extends StatefulWidget {
  const ProfessionalDetails({super.key});

  @override
  State<ProfessionalDetails> createState() => _ProfessionalDetailsState();
}

class _ProfessionalDetailsState extends State<ProfessionalDetails> {
  String _selectedMedicalSpecialty = 'Medical Student';

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Professional Details',
          actions: [
            Center(
              child: MyText(
                text: 'Skip',
                size: 14,
                weight: FontWeight.w500,
                color: kGreyColor,
                paddingRight: 20,
              ),
            ),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            MyTextField(
              labelText: 'Medical Specialty',
              hintText: 'e.g, internal  Medicine, Pediatrics',
              labelPrefix: Assets.imagesMedical,
            ),
            ExpandableDropdown(
              title: 'Medical Specialty',
              prefixIcon: Assets.imagesProfessionalLevel,
              selectedValue: _selectedMedicalSpecialty,
              items: [
                'AuthMedical Student',
                'Internship Doctor',
                'Resident',
                'General Practitioner',
                'Specialist / Consultant',
              ],
              onSelect: (v) {
                setState(() {
                  _selectedMedicalSpecialty = v;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: MyButton(
            buttonText: 'Next',
            onTap: () {
              Get.to(() => Home());
            },
          ),
        ),
      ),
    );
  }
}

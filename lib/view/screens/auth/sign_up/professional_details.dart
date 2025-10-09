import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/config/routes/routes.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
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
  AuthController authController = Get.find();
  final specialityController = TextEditingController();
  String _selectedMedicalSpecialty = 'Medical Student';



  @override
  Widget build(BuildContext context) {
    print(authController.userId.value);
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Professional Details',
          leadingWidget: AbsorbPointer(),
          actions: [
            Center(
              child: GestureDetector(
                onTap: (){
          Get.offAllNamed(AppLinks.loginScreen);

                },
                child: MyText(
                  text: 'Skip',
                  size: 14,
                  weight: FontWeight.w500,
                  color: kGreyColor,
                  paddingRight: 20,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: AppSizes.DEFAULT,
            physics: BouncingScrollPhysics(),
            children: [
              MyTextField(
                labelText: 'Medical Specialty',
                hintText: 'e.g, internal  Medicine, Pediatrics',
                labelPrefix: Assets.imagesMedical,
                controller: specialityController,
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
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: Obx( () =>  MyButton(
            isLoading: authController.isLoading.value,
            buttonText: 'Next',
            onTap: () async {
              await authController.addProfessionalDetails(specialityController.text.trim(), 
              _selectedMedicalSpecialty);
            },
          )),
        ),
      ),
    );
  }
}

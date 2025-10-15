import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_country_list.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_drop_down_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

// ignore: must_be_immutable
class EditProfile extends StatefulWidget {
   EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileController profileController = Get.find();

  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final specialityTextController = TextEditingController();
   String? selectedCountryName;
  String? selectedExpLevel;


  @override
  void initState() {
    super.initState();
    nameTextController.text = profileController.profile.value?.name ?? "";
    emailTextController.text = profileController.profile.value?.email ?? "";
    specialityTextController.text = profileController.professionalDetails.value?.speciality ?? "";
    selectedExpLevel = profileController.professionalDetails.value?.professionalLevel ?? "";
    final country = profileController.profile.value?.country ?? "";
    selectedCountryName = countryList.contains(country) ? country : null;

  }


  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Edit Profile'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: 'Your Basic\nDetails',
                  size: 24,
                  weight: FontWeight.w600,
                ),
                Stack(
                  children: [
                    CommonImageView(
                      height: 80,
                      width: 80,
                      url: dummyImg,
                      fit: BoxFit.cover,
                      radius: 100,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Image.asset(
                        Assets.imagesChangeProfileImage,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            MyTextField(
              labelText: 'Name',
              controller: nameTextController,
              hintText: profileController.profile.value?.name ?? "",
              labelPrefix: Assets.imagesName,
            ),
            MyTextField(
              labelText: 'Email',
              hintText: "Enter your email",
              isReadOnly: true,
              labelPrefix: Assets.imagesEmail,
              controller: emailTextController,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesCountryIcon,
              labelText: 'Country',
              hint: 'Select Country',
              items: countryList,
             selectedValue: selectedCountryName ,
  onChanged: (value) {
    setState(() => selectedCountryName = value);
  },
            ),
            MyTextField(
              labelText: 'Medical Specialty',
              hintText: 'Internal Medicine',
              controller: specialityTextController,
              labelPrefix: Assets.imagesMedicalSpecial,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesProfessinalLevelIcon,
              labelText: 'Professional Level',
              hint: 'General Practitioner',
              items:[
                  'AuthMedical Student',
                  'Internship Doctor',
                  'Resident',
                  'General Practitioner',
                  'Specialist / Consultant',
                ],
              selectedValue: selectedExpLevel,
              onChanged: (value) {
                setState(() {
                  selectedExpLevel = value;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: AppSizes.DEFAULT,
            child:Obx( () => MyButton(
              isLoading: profileController.isLoading.value,
              buttonText: 'Done', onTap: () async{
                  await profileController.updateProfile(profileController.docId.value, 
                  nameTextController.text, selectedCountryName!, specialityTextController.text, 
                  selectedExpLevel!);
          
            })),
          ),
        ),
      ),
    );
  }
}

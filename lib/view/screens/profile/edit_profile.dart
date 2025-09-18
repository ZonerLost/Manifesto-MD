import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_drop_down_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

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
              hintText: 'Alex Mahone',
              labelPrefix: Assets.imagesName,
            ),
            MyTextField(
              labelText: 'Email',
              hintText: 'alex.mahone@email.com',
              labelPrefix: Assets.imagesEmail,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesCountryIcon,
              labelText: 'Country',
              hint: 'USA',
              items: ['USA', 'UK', 'India', 'Canada'],
              selectedValue: 'USA',
              onChanged: (value) {},
            ),
            MyTextField(
              labelText: 'Medical Specialty',
              hintText: 'Internal Medicine',
              labelPrefix: Assets.imagesMedicalSpecial,
            ),
            CustomDropDown(
              labelPrefix: Assets.imagesProfessinalLevelIcon,
              labelText: 'Professional Level',
              hint: 'General Practitioner',
              items: ['General Practitioner', 'Mid', 'Senior'],
              selectedValue: 'General Practitioner',
              onChanged: (value) {},
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: MyButton(buttonText: 'Done', onTap: () {}),
        ),
      ),
    );
  }
}

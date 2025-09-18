import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/auth/sign_up/professional_details.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/heading_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(height: 30),
            Row(children: [Image.asset(Assets.imagesLogo, height: 46)]),
            SizedBox(height: 12),
            AuthHeading(
              title: 'Create An Account 🧑‍💻',
              subTitle: 'Sign up to get better App experience',
            ),
            MyTextField(
              labelText: 'Email',
              hintText: 'Email',
              labelPrefix: Assets.imagesEmail,
            ),
            MyTextField(
              labelText: 'Password',
              hintText: 'Password',
              labelPrefix: Assets.imagesPassword,
              labelSuffix: Assets.imagesInfo,
              isObSecure: true,

              onLabelSuffixTap: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 300, 20, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  menuPadding: EdgeInsets.all(12),
                  items: [
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText(
                            text: 'Password must contain:',
                            size: 10,
                            paddingBottom: 8,
                            weight: FontWeight.w600,
                            color: kTertiaryColor,
                          ),
                          Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...List.generate(3, (index) {
                                return Row(
                                  children: [
                                    Image.asset(
                                      index == 2
                                          ? Assets.imagesWrong
                                          : Assets.imagesRight,
                                      height: 16,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        paddingLeft: 4,
                                        text:
                                            index == 0
                                                ? 'At least 8 characters'
                                                : index == 1
                                                ? 'At least one capital letter'
                                                : 'At least one number',
                                        size: 10,
                                        weight: FontWeight.w600,
                                        color: kSecondaryColor,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            MyTextField(
              marginBottom: 30,
              labelText: 'Re-Enter Password',
              hintText: 'Password',
              labelPrefix: Assets.imagesPassword,
              isObSecure: true,
            ),

            MyButton(
              buttonText: 'Signup',
              onTap: () {
                Get.to(() => ProfessionalDetails());
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 1, color: kBorderColor)),
                MyText(
                  text: 'Or',
                  size: 12,
                  weight: FontWeight.w600,
                  color: kGreyColor,
                  paddingLeft: 10,
                  paddingRight: 10,
                ),
                Expanded(child: Container(height: 1, color: kBorderColor)),
              ],
            ),
            SizedBox(height: 16),
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> _items = [
                  {
                    'icon': Assets.imagesGoogle,
                    'title': 'Continue with Google',
                  },
                  {'icon': Assets.imagesApple, 'title': 'Continue with Apple'},
                  {
                    'icon': Assets.imagesFacebook,
                    'title': 'Continue with Facebook',
                  },
                ];
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    height: 48,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 1, color: kBorderColor),
                    ),
                    child: Row(
                      children: [
                        Image.asset(_items[index]['icon'], height: 22),
                        Expanded(
                          child: MyText(
                            text: _items[index]['title'],
                            paddingRight: 20,
                            weight: FontWeight.w600,
                            size: 14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                MyText(text: 'Already have an account? ', size: 12),
                MyText(
                  onTap: () {
                    Get.back();
                  },
                  color: kSecondaryColor,
                  text: 'Login',
                  weight: FontWeight.w600,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

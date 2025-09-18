import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/auth/forgot_password/otp_verification.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/heading_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class CreateNewPassword extends StatelessWidget {
  const CreateNewPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: ''),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            AuthHeading(
              title: 'Password Reset 🧑‍💻',
              subTitle: 'Please enter new password',
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
              onLabelSuffixTap: () {},
            ),

            MyButton(buttonText: 'Change Password', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

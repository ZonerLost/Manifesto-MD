import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/auth/login/login.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class GetStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CustomContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(Assets.imagesLogo, height: 70),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: 'Manifesto',
                  size: 24,
                  weight: FontWeight.w700,
                  color: kSecondaryColor,
                ),
                MyText(
                  text: ' MD',
                  size: 24,
                  weight: FontWeight.w700,
                  color: kRedColor,
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyButton(
                    buttonText: 'Get Started',
                    onTap: () {
                      Get.to(() => Login());
                    },
                  ),
                  MyText(
                    paddingTop: 12,
                    textAlign: TextAlign.center,
                    paddingBottom: 4,
                    text: ' This action may contain ad',
                    size: 12,
                    color: kTertiaryColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

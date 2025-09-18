import 'dart:async';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/view/screens/launch/get_started.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    splashScreenHandler();
  }

  void splashScreenHandler() {
    Timer(Duration(seconds: 2), () => Get.offAll(() => GetStarted()));
  }

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
            MyText(
              textAlign: TextAlign.center,
              paddingBottom: 20,
              text: ' This action may contain ad',
              size: 12,
              color: kTertiaryColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/auth/forgot_password/create_new_password.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/heading_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DEFAULT_THEME = PinTheme(
      width: 45,
      height: 45,
      margin: EdgeInsets.zero,
      textStyle: TextStyle(
        fontSize: 14,
        height: 0.0,
        fontWeight: FontWeight.w600,
        color: kTertiaryColor,
        fontFamily: AppFonts.URBANIST,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.0, color: kBorderColor),
        color: kFillColor,
      ),
    );
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            AuthHeading(
              title: 'Enter OTP Code 🔐',
              subTitle:
                  "We've sent an OTP code to your email. Please enter the code below to continue.",
            ),
            MyText(
              text: 'OTP',
              size: 12,
              weight: FontWeight.w600,
              paddingBottom: 6,
            ),
            Pinput(
              length: 6,
              onChanged: (value) {},
              pinContentAlignment: Alignment.center,
              defaultPinTheme: DEFAULT_THEME,
              focusedPinTheme: DEFAULT_THEME.copyWith(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1.0, color: kSecondaryColor),
                  color: kFillColor,
                ),
              ),
              submittedPinTheme: DEFAULT_THEME.copyWith(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1.0, color: kSecondaryColor),
                  color: kFillColor,
                ),
              ),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              onCompleted: (pin) => print(pin),
            ),
            SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                MyText(text: 'Didn’t receive OTP? ', size: 12),
                MyText(
                  onTap: () {},
                  color: kSecondaryColor,
                  text: 'Resend',
                  weight: FontWeight.w600,
                  size: 12,
                ),
              ],
            ),
            SizedBox(height: 30),
            MyButton(
              buttonText: 'Continue',
              onTap: () {
                Get.to(() => CreateNewPassword());
              },
            ),
          ],
        ),
      ),
    );
  }
}

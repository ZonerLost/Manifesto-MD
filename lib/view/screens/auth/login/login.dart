import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/auth/forgot_password/forgot_password.dart';
import 'package:manifesto_md/view/screens/auth/sign_up/sign_up.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            shrinkWrap: true,
            padding: AppSizes.DEFAULT,
            physics: BouncingScrollPhysics(),
            children: [
              Row(children: [Image.asset(Assets.imagesLogo, height: 46)]),
              SizedBox(height: 12),
              Row(
                children: [
                  MyText(text: 'Welcome to ', size: 20, weight: FontWeight.w800),
                  MyText(
                    text: 'Manifesto',
                    size: 20,
                    weight: FontWeight.w800,
                    color: kRedColor,
                  ),
                  MyText(
                    text: ' MD 👋',
                    size: 20,
                    weight: FontWeight.w800,
                    color: kSecondaryColor,
                  ),
                ],
              ),
        
              MyText(
                paddingTop: 8,
                text: 'Please enter your email & password to sign in.',
                size: 12,
                color: kQuaternaryColor,
              ),
              Container(
                height: 1,
                color: kBorderColor,
                margin: EdgeInsets.symmetric(vertical: 16),
              ),
        
              MyTextField(
                labelText: 'Email',
                hintText: 'Email',
                labelPrefix: Assets.imagesEmail,
              ),
              MyTextField(
                marginBottom: 16,
                labelText: 'Password',
                hintText: 'Password',
                labelPrefix: Assets.imagesPassword,
                isObSecure: true,
                // prefix: Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [Image.asset(Assets.imagesLock, height: 20)],
                // ),
                suffix: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset(Assets.imagesVisibility, height: 18)],
                ),
              ),
              Row(
                children: [
                  CustomCheckBox(isActive: false, onTap: () {}),
                  MyText(
                    text: 'Remember me',
                    size: 12,
                    weight: FontWeight.w500,
                    paddingLeft: 8,
                  ),
                  Spacer(),
                  MyText(
                    text: 'Forgot Password?',
                    onTap: () {
                      Get.to(() => ForgotPassword());
                    },
                    size: 14,
                    weight: FontWeight.w600,
                    textAlign: TextAlign.end,
                    color: kSecondaryColor,
                  ),
                ],
              ),
              SizedBox(height: 30),
              MyButton(buttonText: 'Login', onTap: () {}),
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
              SizedBox(height: 9),
              Image.asset(Assets.imagesFingerPrint, height: 60),
              SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  MyText(text: 'Don’t have an account? ', size: 12),
                  MyText(
                    onTap: () {
                      Get.to(() => SignUp());
                    },
                    color: kSecondaryColor,
                    text: 'Sign Up',
                    weight: FontWeight.w600,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

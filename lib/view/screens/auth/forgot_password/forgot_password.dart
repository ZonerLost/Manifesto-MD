import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
import 'package:manifesto_md/view/screens/auth/forgot_password/otp_verification.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/heading_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatelessWidget {
   ForgotPassword({super.key});

  final AuthController authController = Get.find();
  final emailController = TextEditingController();

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
              title: 'Forget Password 🧑‍💻',
              subTitle: 'Please enter your email to reset password',
            ),
            MyTextField(
              marginBottom: 30,
              labelText: 'Email',
              controller: emailController,
              hintText: 'Email',
              labelPrefix: Assets.imagesEmail,
            ),
          Obx( () =>  MyButton(
              buttonText: 'Continue',
              onTap: () async {
               await authController.forgotPassword(emailController.text.trim());
              },
              isLoading: authController.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }
}

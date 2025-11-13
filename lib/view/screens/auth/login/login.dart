import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
import 'package:manifesto_md/models/social_logins_model.dart';
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
   Login({super.key});

  final keyForm = GlobalKey<FormState>();
  final AuthController authController = Get.find();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Form(
            key: keyForm,
            child: ListView(
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
                  controller: emailController,
                  labelPrefix: Assets.imagesEmail,
                  validator: (v){
                    if(v == null || v.isEmpty){
                      return "Enter required field";
                    }  
                    if(!GetUtils.isEmail(v)){
                        return "Enter Valid Email";
                    }

                    return null;
                  },
                ),
              Obx( () =>   MyTextField(
                  marginBottom: 16,
                  labelText: 'Password',
                  hintText: 'Password',
                  labelPrefix: Assets.imagesPassword,
                  controller: passwordController,
                  isObSecure: authController.isObsecure.value,
                   validator: (v){
                    if(v == null || v.isEmpty){
                      return "Enter required field";
                    }  
                    

                    return null;
                  },
              
                  suffix:  GestureDetector(
                    onTap: (){
                      authController.togglePassword();
                    },
                    child: Icon(authController.isObsecure.value ? Icons.visibility : Icons.visibility_off)
                  
                ))),
                Row(
                  children: [
                   Obx( () => CustomCheckBox(isActive: authController.isRemeberMe.value, onTap: () {
                      authController.toggleRemeber();
                    })),
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
              Obx( () => MyButton(buttonText: 'Login', onTap: () async {

                    if(!keyForm.currentState!.validate()) return;


                  await authController.login(emailController.text, passwordController.text);
                }, isLoading: authController.isLoading.value,)),
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
                  itemCount: listSocialLogins.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                   
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap:  ()async{
                        final socialName = listSocialLogins[index].name;
            
              if (socialName.contains('Google')) {
                await authController.signInWithGoogle(index);
              } else if (socialName.contains('Apple')) {
                // await authController.signInWithApple();
              } 
              // else if (socialName.contains('Facebook')) {
              //   // await authController.signInWithFacebook();
              // }
                        },
                        child:Obx( () {
                          final isButtonLoading = authController.loadingIndex.value == index;
                          return Container(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          height: 48,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 1, color: kBorderColor),
                          ),
                          child: isButtonLoading ? Center(child: CircularProgressIndicator.adaptive(),) : Row(
                            children: [
                              Image.asset(listSocialLogins[index].icon, height: 22),
                              Expanded(
                                child: MyText(
                                  text: listSocialLogins[index].name,
                                  paddingRight: 20,
                                  weight: FontWeight.w600,
                                  size: 14,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                        },
                      ),
                      )
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
      ),
    );
  }
}

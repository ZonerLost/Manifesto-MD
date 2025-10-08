
import 'package:manifesto_md/config/debouncer/debouncer.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/heading_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_field_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';

class SignUp extends StatelessWidget {
   SignUp({super.key});

  final AuthController authController = Get.find();
  final keyForm = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: keyForm,
          child: ListView(
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
                labelText: 'Full Name',
                hintText: 'Full Name',
                labelPrefix: Assets.imagesName,
                validator: (v){
                  if( v == null || v.isEmpty){
                    return "Enter the required field";
                  }
                  return null;
                },
              ),
              MyTextField(
                labelText: 'Email',
                hintText: 'Email',
                onChanged: (v) async {
                  Debouncer.instance.run(()async{
                      await authController.checkForEmail(v);
                  }, delay: 300);
                },
                labelPrefix: Assets.imagesEmail,
                 validator: (v){
                  if( v == null || v.isEmpty){
                    return "Enter the required field";
                  } 
                  if(!GetUtils.isEmail(v)){
                    return "Enter Valid Email";
                  }
                  return null;
                },
              ),
              Obx(() => MyText(text: authController.emailFoundMessage.value)),
            Obx( () =>  MyTextField(
                labelText: 'Password',
                hintText: 'Password',
                labelPrefix: Assets.imagesPassword,
                labelSuffix: Assets.imagesInfo,
                 validator: (v){
                  if( v == null || v.isEmpty){
                    return "Enter the required field";
                  }
                  return null;
                },
                suffix: IconButton(onPressed: (){
                    authController.togglePassword();
                }, icon:  Icon(authController.isObsecure.value ? Icons.visibility : Icons.visibility_off, 
                color: kSecondaryColor,
                )),
                isObSecure: authController.isObsecure.value,
                onChanged: (value) => authController.checkPassword(value),
          
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
                        child:  Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyText(
                              text: 'Password must contain:',
                              size: 12,
                              paddingBottom: 8,
                              weight: FontWeight.w600,
                              color: kTertiaryColor,
                            ),
                           Row(
            children: [
              Image.asset(
                authController.hasMinLength.value
                    ? Assets.imagesRight
                    : Assets.imagesWrong,
                height: 16,
              ),
              Expanded(
                child: MyText(
                  paddingLeft: 4,
                  text: 'At least 8 characters',
                  size: 10,
                  weight: FontWeight.w600,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Image.asset(
                authController.hasUppercase.value
                    ? Assets.imagesRight
                    : Assets.imagesWrong,
                height: 16,
              ),
              Expanded(
                child: MyText(
                  paddingLeft: 4,
                  text: 'At least one capital letter',
                  size: 10,
                  weight: FontWeight.w600,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Image.asset(
                authController.hasNumber.value
                    ? Assets.imagesRight
                    : Assets.imagesWrong,
                height: 16,
              ),
              Expanded(
                child: MyText(
                  paddingLeft: 4,
                  text: 'At least one number',
                  size: 10,
                  weight: FontWeight.w600,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
                          ],
                        ),
                      
                      )
                    ],
                  );
                },
              )),
            Obx( () => MyTextField(
                marginBottom: 30,
                labelText: 'Re-Enter Password',
                hintText: 'Password',
                labelPrefix: Assets.imagesPassword,
                 suffix: IconButton(onPressed: (){
                    authController.togglePasswordRenter();
                }, icon:  Icon(authController.isObsecureReEnter.value ? Icons.visibility : Icons.visibility_off, 
                color: kSecondaryColor,
                )),
                isObSecure: authController.isObsecureReEnter.value,
              )),
          
              Obx( () => MyButton(
                buttonText: 'Signup',
                isLoading: authController.isLoading.value,
                onTap: () async {
                    if(!keyForm.currentState!.validate()) return;
                      if(passwordController.text != confirmPasswordController.text){
                        showCommonSnackbarWidget("Error", "Passowrd didn't match");
                      }
                  
                    await authController.signUp( nameController.text.trim(), emailController.text.trim(), 
                    passwordController.text.trim());

                },
              )),
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
      ),
    );
  }
}

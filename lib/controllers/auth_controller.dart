import 'package:get/get.dart';
import 'package:manifesto_md/config/routes/routes.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/services/auth_service.dart';
import 'package:manifesto_md/services/sahred_preferences_service.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';

class AuthController extends GetxController {
  var hasMinLength = false.obs;
  var hasUppercase = false.obs;
  var loadingIndex = (-1).obs;
  var hasNumber = false.obs;
  RxBool isObsecure = true.obs;
  RxBool isObsecureReEnter = true.obs;
  RxBool isEmailExist = false.obs;
  RxBool isLoading = false.obs;
  RxBool isCheckingForEmail = false.obs;
  RxString emailFoundMessage = "".obs;
  RxString userId = "".obs;
  RxBool isRemeberMe = false.obs;






  togglePassword() {
    isObsecure.value = !isObsecure.value;
  }


  toggleRemeber() {
    isRemeberMe.value = !isRemeberMe.value;
  }

  togglePasswordRenter() {
    isObsecureReEnter.value = !isObsecureReEnter.value;
  }

  void checkPassword(String password) {
    hasMinLength.value = password.length >= 8;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
  }

  clearPasswordToggle(){
    isObsecure.value = false;
  }



  bool get isValid =>
      hasMinLength.value && hasUppercase.value && hasNumber.value;

  Future login(String email, String password) async {
    isLoading.value = true;
    try {
      final respLogin = await AuthService.instance.login(
        email: email,
        password: password,
      );

        if(isRemeberMe.value){
          SharePrefService.instance.addUserId(respLogin!.uid);
        } 

      if(respLogin?.uid != null){
        Get.offAllNamed(AppLinks.homeScreen);
      }

    } catch (e) {
        print(e);
      showCommonSnackbarWidget("Error", e.toString());

    } finally {
      isLoading.value = false;
    }
  }


  Future signInWithGoogle(int index) async{

   loadingIndex.value = index;

    try {
      final respGoogleLogin  = await AuthService.instance.signInWithGoogle();

      if(respGoogleLogin?.uid != null){
          Get.offAllNamed(AppLinks.homeScreen);
      }

    } catch (e) {
      print(e);
      showCommonSnackbarWidget("Error", "Something Went Wrong");
    } finally {

      loadingIndex.value = -1;
    }
  }





  Future logOut() async {
    try {
      await AuthService.instance.logOut();
      Get.offAllNamed(AppLinks.loginScreen);
    } catch (e) {
      showCommonSnackbarWidget("Error", "Something Went Wrong");
    }
  }




  Future signUp(String name, String email, String password) async {
    isLoading.value = true;
    try {

      final respSignUp = await AuthService.instance.signUp(email: email, password: password, name: name);

      if(respSignUp?.uid != null){
        userId.value = respSignUp?.uid ?? "";
        Get.toNamed(AppLinks.professionalDetailsScreen);
      }

    } catch (e) {
      print(e);
      showCommonSnackbarWidget("Error", e.toString(), messageTextColor: kFillColor, textColor: kFillColor, );
    } finally {
      isLoading.value = false;
    }
  }


  Future checkForEmail(String email) async{
    isCheckingForEmail.value = true;
    try {
      emailFoundMessage.value = await AuthService.instance.checkForEmail(email);
     
    } catch (e) {
      print(e);
          showCommonSnackbarWidget("Error", "Something went wrong",);

    } finally {
      isCheckingForEmail.value = false;
    }
  }

  Future addProfessionalDetails(String severityLevel, String expLevel) async {

    isLoading.value = true;

      try {

            final p = await AuthService.instance.saveProfessionalData(severityLevel: severityLevel, 
            expLevel: expLevel, userId: userId.value);
      if(p != null){
          Get.offAllNamed(AppLinks.loginScreen);
          showCommonSnackbarWidget("Success", "Data Saved", bgColor: kBlueColor, 
          textColor: kFillColor, messageTextColor: kFillColor,  );
      }

      } catch (e) {
        print(e);
         showCommonSnackbarWidget("Error", "Error Saving Data",  
          textColor: kFillColor, messageTextColor: kFillColor,  );
      } finally {
        isLoading.value = false;
      }


  }


}

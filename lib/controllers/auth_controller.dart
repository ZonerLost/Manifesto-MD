import 'package:get/get.dart';
import 'package:manifesto_md/config/routes/routes.dart';
import 'package:manifesto_md/services/auth_service.dart';
import 'package:manifesto_md/view/widget/show_common_snackbar_widget.dart';

class AuthController extends GetxController {
  var hasMinLength = false.obs;
  var hasUppercase = false.obs;
  var hasNumber = false.obs;
  RxBool isObsecure = true.obs;
  RxBool isObsecureReEnter = true.obs;
  RxBool isEmailExist = false.obs;
  RxBool isLoading = false.obs;
  RxBool isCheckingForEmail = false.obs;
  RxString emailFoundMessage = "".obs;



  togglePassword() {
    isObsecure.value = !isObsecure.value;
  }

  togglePasswordRenter() {
    isObsecureReEnter.value = !isObsecureReEnter.value;
  }

  void checkPassword(String password) {
    hasMinLength.value = password.length >= 8;
    hasUppercase.value = password.contains(RegExp(r'[A-Z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
  }

  bool get isValid =>
      hasMinLength.value && hasUppercase.value && hasNumber.value;

  Future login(String name, String email, String password) async {
    try {
      final respLogin = await AuthService.instance.login(
        email: email,
        password: password,
      );
    } catch (e) {}
  }

  Future signUp(String name, String email, String password) async {
    isLoading.value = true;
    try {

      final respSignUp = await AuthService.instance.signUp(email: email, password: password, name: name);

      if(respSignUp?.uid != null){
        Get.toNamed(AppLinks.professionalDetailsScreen);
      }

    } catch (e) {
      showCommonSnackbarWidget("Error", "Something went wrong",);
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


  


}

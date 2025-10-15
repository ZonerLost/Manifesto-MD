import 'package:get/get.dart';
import 'package:manifesto_md/controllers/auth_controller.dart';
import 'package:manifesto_md/controllers/profile_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ProfileController());
  }


}
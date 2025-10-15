import '../constants/app_images.dart';

class SocialLoginsModel {
  final String name;
  final String icon;

  SocialLoginsModel({required this.icon, required this.name});
}



List<SocialLoginsModel> listSocialLogins = [
  SocialLoginsModel(icon: Assets.imagesGoogle, name: "Continue with Google"),
  SocialLoginsModel(icon: Assets.imagesApple, name: "Continue with Apple"),
  SocialLoginsModel(icon: Assets.imagesFacebook, name: "Continue with Facebook"),
];
import 'package:get/get.dart';
import 'package:manifesto_md/view/screens/auth/login/login.dart';
import 'package:manifesto_md/view/screens/auth/sign_up/professional_details.dart';
import 'package:manifesto_md/view/screens/auth/sign_up/sign_up.dart';
import 'package:manifesto_md/view/screens/home/home.dart';

import '../../view/screens/launch/splash_screen.dart';

class AppRoutes {
  static final List<GetPage> pages = [
    GetPage(
      name: AppLinks.splash_screen,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: AppLinks.professionalDetailsScreen,
      page: () => ProfessionalDetails(),
    ),
    GetPage(
      name: AppLinks.loginScreen,
      page: () => Login(),
    ),
    GetPage(
      name: AppLinks.signUpScreen,
      page: () => SignUp(),
    ),
    GetPage(
      name: AppLinks.homeScreen,
      page: () => Home(),
    ),
    // GetPage(
    //   name: AppLinks.splash_screen,
    //   page: () => SplashScreen(),
    // ),
  ];
}

class AppLinks {
  static const splash_screen = '/splash_screen';
  static const professionalDetailsScreen = '/professionalDetailsScreen';
  static const loginScreen = '/loginScreen';
  static const signUpScreen = '/signUpScreen';
  static const homeScreen = '/homeScreen';
  // static const splash_screen = '/splash_screen';
  // static const splash_screen = '/splash_screen';
  // static const splash_screen = '/splash_screen';
}

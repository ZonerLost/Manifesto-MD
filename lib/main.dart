import 'package:firebase_core/firebase_core.dart';
import 'package:manifesto_md/config/bindings/app_bindings.dart';
import 'package:manifesto_md/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/firebase_options.dart';
import 'package:manifesto_md/view/screens/smart_ddx_tool/smart_ddx_controller/smart_ddx_controller.dart';
import 'config/theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(SmartDDxController());
  runApp(MyApp());
}

String dummyImg =
    'https://images.unsplash.com/photo-1558507652-2d9626c4e67a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'manifesto_md',
      theme: lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppLinks.splash_screen,
      initialBinding: AppBindings(),
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
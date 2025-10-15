
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

showCommonSnackbarWidget(
 final String title, 
 final String mesage,
  {final Color? textColor,
  final Color? messageTextColor,  
  final Color? bgColor, 
  }

){
Get.snackbar(
  
          snackPosition: SnackPosition.TOP,
           title,
         
          mesage, 
          
        
      );

}
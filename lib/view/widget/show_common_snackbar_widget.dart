
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

showCommonSnackbarWidget(
 final String title, 
 final String mesage,
  {final Color? textColor,
  final Color? messageTextColor,  
  final Color? bgColor, 
  }

){
Get.showSnackbar(
  
        GetSnackBar(
          snackPosition: SnackPosition.TOP,
         
          borderRadius: 20,
          title: title,
          titleText: MyText(text: title, color: textColor, weight: FontWeight.bold,),
          messageText: MyText(text: mesage, color: messageTextColor, weight: FontWeight.bold,),
          backgroundColor: bgColor ?? Color(0xFF303030) ,
        )
      );

}
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar simpleAppBar({
  bool haveLeading = true,
  String? title,
  Widget? leadingWidget,
  bool? centerTitle = false,
  List<Widget>? actions,
  Color? bgColor,
}) {
  return AppBar(
    backgroundColor: bgColor ?? Colors.transparent,
    centerTitle: centerTitle,
    automaticallyImplyLeading: false,
    titleSpacing: -5.0,
    leading:
        haveLeading
            ? leadingWidget ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(Assets.imagesArrowBack, height: 24),
                    ),
                  ],
                )
            : null,
    title: MyText(
      text: title ?? '',
      size: 15,
      color: kTertiaryColor,
      weight: FontWeight.w600,
    ),
    actions: actions,
  );
}

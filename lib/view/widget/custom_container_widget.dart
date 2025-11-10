import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_images.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;
  final double? height;
  final Color? color;
  const CustomContainer({Key? key,this.color, this.child, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        color: color,
        image: DecorationImage(
          image: AssetImage(Assets.imagesMainBg),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(child: child!),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? 'Type your main clinical manifestations here',
        hintStyle: TextStyle(color: kHintColor, fontSize: 14),
        filled: true,
        fillColor: kBorderColor,
        suffixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset(Assets.imagesSearchIcon, height: 20)],
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: kBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: kBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: kSecondaryColor, width: 1),
        ),
      ),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}

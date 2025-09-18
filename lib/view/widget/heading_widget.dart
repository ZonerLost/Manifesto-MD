import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:flutter/material.dart';

class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, required this.subTitle});
  final String? title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(text: title ?? '', size: 20, weight: FontWeight.w800),
        MyText(
          paddingTop: 8,
          text: subTitle ?? '',
          size: 12,
          color: kQuaternaryColor,
        ),
        Container(
          height: 1,
          color: kBorderColor,
          margin: EdgeInsets.symmetric(vertical: 16),
        ),
      ],
    );
  }
}

class HeadingBorder extends StatelessWidget {
  HeadingBorder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        MyText(
          text: text,
          size: 13,
          color: kGreyColor,
          weight: FontWeight.w500,
        ),
        Expanded(
          child: Container(height: 1, color: kGreyColor.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

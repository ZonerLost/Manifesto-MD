import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class AppLanguage extends StatefulWidget {
  const AppLanguage({super.key});

  @override
  State<AppLanguage> createState() => _AppLanguageState();
}

class _AppLanguageState extends State<AppLanguage> {
  int selectedIndex = 0;
  final List<Map<String, String>> languages = [
    {
      'title': 'English',
      'subtitle': 'Select English',
      'icon': Assets.imagesEnglish,
    },
    {
      'title': 'Arabic (العربية)',
      'subtitle': 'اختر اللغة العربية',
      'icon': Assets.imagesArabic,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagesMainBg),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            text: 'App Language',
            size: 18,
            weight: FontWeight.w700,
            paddingBottom: 8,
          ),
          MyText(
            color: kGreyColor,
            text: 'Select Language',
            paddingBottom: 20,
            size: 12,
          ),
          Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < languages.length; i++)
                _ItemTile(
                  title: languages[i]['title']!,
                  isSelected: selectedIndex == i,
                  onTap: () {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                  icon: languages[i]['icon']!,
                  subtitle: languages[i]['subtitle']!,
                ),
            ],
          ),
          SizedBox(height: 20),
          MyButton(
            buttonText: 'Done',
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          border: Border.all(color: kBorderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: kBorderColor.withValues(alpha: 0.05),
                border: Border.all(color: kBorderColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Image.asset(icon, height: 24, width: 24)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyText(
                    text: title,
                    size: 14,
                    paddingBottom: 4,
                    weight: FontWeight.w600,
                    color: isSelected ? kSecondaryColor : kTertiaryColor,
                  ),
                  MyText(
                    text: subtitle,
                    size: 10,
                    weight: FontWeight.w500,
                    color: kGreyColor,
                  ),
                ],
              ),
            ),
            CustomCheckBox(
              borderWidth: 1.0,
              radius: 100,
              isActive: isSelected,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

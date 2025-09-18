import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/widget/custom_check_box_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class AppTheme extends StatefulWidget {
  const AppTheme({super.key});

  @override
  State<AppTheme> createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  int selectedIndex = 1; // Default to 'Light'
  final List<String> themes = ['System Default', 'Light', 'Dark'];

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
            text: 'App Theme',
            size: 18,
            weight: FontWeight.w700,
            paddingBottom: 8,
          ),
          MyText(
            color: kGreyColor,
            text: 'Select a theme that keeps you motivated every day.',
            paddingBottom: 20,
            size: 12,
          ),
          Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < themes.length; i++)
                _ItemTile(
                  title: themes[i],
                  isSelected: selectedIndex == i,
                  onTap: () {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: MyBorderButton(
                  buttonText: 'Cancel',
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
              Expanded(
                child: MyButton(
                  buttonText: 'Done',
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
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
            Expanded(
              child: MyText(
                text: title,
                size: 14,
                weight: FontWeight.w600,
                color: isSelected ? kSecondaryColor : kTertiaryColor,
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

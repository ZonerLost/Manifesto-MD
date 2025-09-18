import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/tools_calculators/calculator.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class ToolsCalculators extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {'name': 'CURB-65', 'category': 'Pneumonia Severity'},
      {'name': 'GCS', 'category': 'Glasgow Coma Scale'},
      {
        'name': 'CHA₂DS₂-VASc',
        'category': 'Stroke risk in Atrial Fibrillation',
      },
      {'name': 'Wells’ Criteria', 'category': 'DVT/PE risk'},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Tools & Calculators'),
        body: ListView.separated(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 10);
          },
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => Calculator());
              },
              child: _ItemTile(
                title: items[index]['name']!,
                subtitle: items[index]['category']!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ItemTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText(text: title, size: 14, weight: FontWeight.w600),
                MyText(
                  text: subtitle,
                  size: 12,
                  color: kGreyColor,
                  paddingTop: 4,
                ),
              ],
            ),
          ),

          Image.asset(Assets.imagesArrowNext, height: 20),
        ],
      ),
    );
  }
}

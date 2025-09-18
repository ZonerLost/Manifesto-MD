import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/diagnoses/diagnoses_details.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Diagnoses extends StatefulWidget {
  @override
  State<Diagnoses> createState() => _DiagnosesState();
}

class _DiagnosesState extends State<Diagnoses> {
  final Set<int> savedIndices = {};
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {'name': 'Asthma', 'category': 'Respiratory'},
      {'name': 'Appendicitis', 'category': 'Gastrointestinal'},
      {'name': 'Anemia', 'category': 'Hematology'},
      {'name': 'Bronchitis', 'category': 'Respiratory'},
      {'name': 'Bipolar Disorder', 'category': 'Psychiatric'},
      {'name': 'Breast Cancer', 'category': 'Oncology'},
      {'name': 'Chickenpox (Varicella)', 'category': 'Infectious'},
      {'name': 'Congestive Heart Failure', 'category': 'Cardiovascular'},
      {'name': 'COVID-19', 'category': 'Respiratory'},
      {'name': 'Congestive Heart Failure', 'category': 'Cardiovascular'},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Diagnoses'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            CustomSearchBar(hintText: 'Search By Disease Name or Code'),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              padding: AppSizes.ZERO,
              physics: BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => DiagnosesDetails());
                  },
                  child: _ItemTile(
                    title: items[index]['name']!,
                    subtitle: items[index]['category']!,
                    isRedFlag:
                        items[index]['name'] == 'Breast Cancer' ||
                        items[index]['name'] == 'Congestive Heart Failure',
                    isSaved: savedIndices.contains(index),
                    onSaveTap: () {
                      setState(() {
                        if (savedIndices.contains(index)) {
                          savedIndices.remove(index);
                        } else {
                          savedIndices.add(index);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRedFlag;
  final bool isSaved;
  final VoidCallback onSaveTap;

  const _ItemTile({
    required this.title,
    required this.subtitle,
    required this.isRedFlag,
    required this.isSaved,
    required this.onSaveTap,
  });

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
                Row(
                  children: [
                    MyText(text: title, size: 14, weight: FontWeight.w600),
                    if (isRedFlag) ...[
                      SizedBox(width: 6),
                      Image.asset(Assets.imagesRedFlag, height: 12),
                    ],
                  ],
                ),
                MyText(
                  text: subtitle,
                  size: 12,
                  color: kGreyColor,
                  paddingTop: 4,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSaveTap,
            child: Image.asset(
              isSaved ? Assets.imagesSaveFilled : Assets.imagesSaveEmpty,
              height: 20,
            ),
          ),
          SizedBox(width: 6),
          Image.asset(Assets.imagesArrowNext, height: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/utils/global_instances.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class DiseaseDetail extends StatefulWidget {
  @override
  State<DiseaseDetail> createState() => _DiseaseDetailState();
}

class _DiseaseDetailState extends State<DiseaseDetail> {
  int selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sections = [
      {'title': 'Management Plan', 'image': Assets.imagesMp},
      {'title': 'Investigations', 'image': Assets.imagesIt},
      {'title': 'Clinical Notes', 'image': Assets.imagesMp},
      {'title': 'Diagnosis', 'image': Assets.imagesDi},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Chickenpox',
          actions: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6.54),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kBorderColor,
                  border: Border.all(
                    width: 0.5,
                    color: kSecondaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(Assets.imagesSaveEmpty, height: 16),
                    ),
                    MyText(
                      text: 'Add to Favorite',
                      size: 10,
                      color: kTertiaryColor,
                      paddingRight: 4,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.VERTICAL,
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: 30,
              child: ListView.separated(
                shrinkWrap: true,
                padding: AppSizes.HORIZONTAL,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final bool isSelected = selectedSection == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSection = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6.54,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            isSelected
                                ? kSecondaryColor.withValues(alpha: 0.12)
                                : kPrimaryColor,
                        border: Border.all(
                          width: 1.0,
                          color: isSelected ? kSecondaryColor : kBorderColor,
                        ),
                      ),
                      child: Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              sections[index]['image']!,
                              height: 20,
                            ),
                          ),
                          MyText(
                            text: sections[index]['title']!,
                            size: 10,
                            weight: FontWeight.w500,
                            color: isSelected ? kSecondaryColor : kGreyColor,
                            paddingRight: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 8);
                },
                itemCount: sections.length,
              ),
            ),

            Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CommonImageView(
                    height: 150,
                    width: Get.width,
                    radius: 16,
                    fit: BoxFit.cover,
                    url: dummyImg,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Image.asset(Assets.imagesMp, height: 16),
                            Expanded(
                              child: MyText(
                                paddingLeft: 8,
                                text: 'Management Plan',
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 8,
                          text:
                              'Chickenpox is a highly contagious viral infection caused by the varicella-zoster virus (VZV). It primarily affects children and presents with fever, fatigue, and a characteristic itchy vesicular rash that appears in crops.',
                          size: 12,
                          lineHeight: 1.5,
                          color: kGreyColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

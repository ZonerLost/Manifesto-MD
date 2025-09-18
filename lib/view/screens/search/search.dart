import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/search/select_body_part.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> searchItems = [
      {'image': Assets.imagesGs, 'title': 'General Symptoms'},
      {'image': Assets.imagesSs, 'title': 'Skin Symptoms'},
      {'image': Assets.imagesHn, 'title': 'Head & Neck'},
      {'image': Assets.imagesKd, 'title': 'Kidneys'},
      {'image': Assets.imagesCt, 'title': 'Chest'},
      {'image': Assets.imagesArms, 'title': 'Arms'},
      {'image': Assets.imagesAb, 'title': 'Abdomen'},
      {'image': Assets.imagesPl, 'title': 'Pelvis'},
      {'image': Assets.imagesBk, 'title': 'Back'},
      {'image': Assets.imagesLg, 'title': 'Lungs'},
      {'image': Assets.imagesLeg, 'title': 'Legs'},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Search Clinical Manifestations'),
        body: ListView(
          shrinkWrap: true,
          padding: AppSizes.DEFAULT,
          physics: BouncingScrollPhysics(),
          children: [
            CustomSearchBar(
              hintText: 'Type your main clinical manifestations here',
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              padding: AppSizes.ZERO,
              physics: BouncingScrollPhysics(),
              itemCount: searchItems.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => SelectBodyPart(
                        icon: searchItems[index]['image'],
                        title: searchItems[index]['title'],
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset(searchItems[index]['image'], height: 20),
                        Expanded(
                          child: MyText(
                            paddingLeft: 10,
                            text: searchItems[index]['title'],
                            size: 12,
                            color: kGreyColor,
                          ),
                        ),
                        Image.asset(Assets.imagesArrowNext, height: 16),
                      ],
                    ),
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

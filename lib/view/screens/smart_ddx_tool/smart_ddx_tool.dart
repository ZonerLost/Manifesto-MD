import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/constants/disease_data_list.dart';
import 'package:manifesto_md/controllers/gemini_controller.dart';
import 'package:manifesto_md/utils/global_instances.dart';
import 'package:manifesto_md/view/screens/smart_ddx_tool/select_symptoms.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class SmartDdxTool extends StatelessWidget {
  SmartDdxTool({super.key});


  @override
  Widget build(BuildContext context) {
  
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Smart DDX Tool'),
        body: Obx(
          () => ListView(
            shrinkWrap: true,
            padding: AppSizes.VERTICAL,
            physics: BouncingScrollPhysics(),
            children: [
              Padding(
                padding: AppSizes.HORIZONTAL,
                child: CustomSearchBar(hintText: 'Type your main symptom here'),
              ),
              SizedBox(height: 16),
              if (smartDDxController.selectedSymptoms.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: AppSizes.HORIZONTAL,
                      child: Row(
                        children: [
                          Expanded(
                            child: MyText(
                              text: 'My Symptoms',
                              size: 12,
                              weight: FontWeight.w600,
                            ),
                          ),
                          MyText(
                            onTap: () {
                              smartDDxController.clearSymptoms();
                            },
                            text: 'CLEAR ALL',
                            size: 10,
                            color: kGreyColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: AppSizes.HORIZONTAL,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6.54,
                            ),
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
                                MyText(
                                  text:
                                      smartDDxController
                                          .selectedSymptoms[index],
                                  size: 10,
                                  color: kGreyColor,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    smartDDxController.removeSymptom(
                                      smartDDxController
                                          .selectedSymptoms[index],
                                    );
                                  },
                                  child: Image.asset(
                                    Assets.imagesClose,
                                    height: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 8);
                        },
                        itemCount: smartDDxController.selectedSymptoms.length,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      height: 1,
                      color: kBorderColor,
                    ),
                  ],
                ),
              ],
              ListView.separated(
                shrinkWrap: true,
                padding: AppSizes.HORIZONTAL,
                physics: BouncingScrollPhysics(),
                itemCount: searchItems.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => SelectSymptoms(
                          icon: searchItems[index].image,
                          title: searchItems[index].title,
                          details: searchItems[index].symptoms,
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
                          Image.asset(searchItems[index].image, height: 20),
                          Expanded(
                            child: MyText(
                              paddingLeft: 10,
                              text: searchItems[index].title,
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
      ),
    );
  }
}

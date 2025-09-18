import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/investigation/investigation_details.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class InvestigationTests extends StatefulWidget {
  const InvestigationTests({
    super.key,
    required this.icon,
    required this.title,
  });
  final String icon;
  final String title;

  @override
  State<InvestigationTests> createState() => _InvestigationTestsState();
}

class _InvestigationTestsState extends State<InvestigationTests> {
  final Set<int> savedIndices = {};
  @override
  Widget build(BuildContext context) {
    final List items = [
      'Complete Blood Count (CBC)',
      'Basic Metabolic Panel (BMP)',
      'Comprehensive Metabolic Panel (CMP)',
      'Liver Function Tests (LFTs)',
      'Renal Function Tests (RFTs)',
      'Lipid Profile',
      'Thyroid Function Tests (TFTs)',
      'Hemoglobin A1c (HbA1c)',
      'Erythrocyte Sedimentation Rate (ESR)',
      'C-Reactive Protein (CRP)',
      'Prothrombin Time (PT/INR)',
      'Urinalysis (UA)',
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: -5.0,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset(widget.icon, height: 20)],
          ),
          title: MyText(
            text: widget.title,
            size: 15,
            color: kTertiaryColor,
            weight: FontWeight.w600,
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(Assets.imagesClose, height: 24),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
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
                Get.to(() => InvestigationDetails());
              },
              child: _ItemTile(
                title: items[index],
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
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final bool isSaved;
  final VoidCallback onSaveTap;

  const _ItemTile({
    required this.title,
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
          Expanded(child: MyText(text: title, size: 12, color: kGreyColor)),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/clinical_manifestations/clinical_manifestations_details.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import '../../../models/clinical_models/clinical_models.dart';
import '../../../services/bookmarks_service.dart';
import '../../widget/custom_app_bar.dart';

class SelectBodyPart extends StatefulWidget {
  final ClinicalSystem system;
  final String icon;
  final String title;
  const SelectBodyPart({
    super.key,
    required this.system,
    required this.icon,
    required this.title,
  });

  @override
  State<SelectBodyPart> createState() => _SelectBodyPartState();
}

class _SelectBodyPartState extends State<SelectBodyPart> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final List<ClinicalEntry> entries = widget.system.entries;
    final List<String> items = entries
        .map((entry) => entry.name)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: widget.title),


        body: StreamBuilder<Set<String>>(
          stream: BookmarksService.instance.watchSavedEntryNames(),
          builder: (context, snap) {
            final savedNames = snap.data ?? <String>{};

            final filteredItems = items
                .where((title) =>
                title.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return ListView.separated(
              shrinkWrap: true,
              padding: AppSizes.DEFAULT,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredItems.length + 1, // +1 for search bar
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CustomSearchBar(
                    hintText: 'Search body parts',
                    onChanged: (value) => setState(() => searchQuery = value),
                  );
                }
                final adjustedIndex = index - 1;
                final title = filteredItems[adjustedIndex];
                final entry =
                entries.firstWhere((e) => e.name == title, orElse: () => entries.first);

                final bool isRedFlag = entry.redFlags.isNotEmpty;
                final bool isSaved = savedNames.contains(entry.name);

                return GestureDetector(
                  onTap: () {
                    if (isRedFlag) {
                      Get.bottomSheet(
                        _RedFlagAlert(
                          redFlags: entry.redFlags,
                          onProceed: () {
                            Get.back();
                            Get.to(() => ClinicalManifestationsDetails(entry: entry));
                          },
                        ),
                        isScrollControlled: true,
                      );
                    } else {
                      Get.to(() => ClinicalManifestationsDetails(entry: entry));
                    }
                  },
                  child: BodyPartItem(
                    title: title,
                    isRedFlag: isRedFlag,
                    isSaved: isSaved,
                    onSaveTap: () async {
                      try {
                        final nowSaved =
                        await BookmarksService.instance.toggleEntryBookmark(
                          entryName: entry.name,
                          systemName: widget.title,
                          icdCode: entry.icdCode,
                          displayName: entry.name,
                        );
                        Get.snackbar(
                          'Bookmarks',
                          nowSaved ? 'Saved to bookmarks' : 'Removed from bookmarks',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } on StateError catch (_) {
                        Get.snackbar(
                          'Sign in required',
                          'Please log in to save items.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: kLightRedColor,
                        );
                      } catch (_) {
                        Get.snackbar(
                          'Error',
                          'Could not update bookmark.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: kLightRedColor,
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BodyPartItem extends StatelessWidget {
  final String title;
  final bool isRedFlag;
  final bool isSaved;
  final VoidCallback onSaveTap;
  const BodyPartItem({
    super.key,
    required this.title,
    required this.isRedFlag,
    required this.isSaved,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRedFlag ? kRedColor.withValues(alpha: .12) : kPrimaryColor,
        border: Border.all(
          color: isRedFlag ? kRedColor.withValues(alpha: .12) : kBorderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (isRedFlag) ...[
            Image.asset(Assets.imagesRedFlag, height: 16),
            const SizedBox(width: 8),
          ],
          Expanded(child: MyText(text: title, size: 12, color: kGreyColor)),
          GestureDetector(
            onTap: onSaveTap,
            child: Image.asset(
              isSaved ? Assets.imagesSaveFilled : Assets.imagesSaveEmpty,
              height: 20,
            ),
          ),
          const SizedBox(width: 6),
          Image.asset(Assets.imagesArrowNext, height: 20),
        ],
      ),
    );
  }
}

class _RedFlagAlert extends StatelessWidget {
  final List<String> redFlags;
  final VoidCallback onProceed;

  const _RedFlagAlert({required this.redFlags, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: kRedColor.withValues(alpha: 0.06),
        ),
        color: kLightRedColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(Assets.imagesRedFlag, height: 16),
              const SizedBox(width: 8),
              Expanded(
                child: MyText(
                  text: 'Red Flag Alert',
                  size: 16,
                  color: kRedColor,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          MyText(
            paddingTop: 12,
            text:
            'This symptom may indicate a life-threatening condition. Please review the following red flags:',
            size: 12,
            lineHeight: 1.5,
            color: kGreyColor,
          ),
          const SizedBox(height: 6),
          ...redFlags.map(
                (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  MyText(
                    text: '- ',
                    size: 12,
                    lineHeight: 1.5,
                    color: kRedColor,
                  ),
                  Expanded(
                    child: MyText(
                      text: text,
                      size: 12,
                      lineHeight: 1.5,
                      color: kGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MyButton(
                  bgColor: kRedColor,
                  buttonText: 'OK',
                  onTap: () => Get.back(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyButton(
                  bgColor: kSecondaryColor,
                  buttonText: 'View Details',
                  onTap: onProceed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

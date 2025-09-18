import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/quick_access_management/disease_detail.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';

class QuickAccessManagement extends StatefulWidget {
  @override
  State<QuickAccessManagement> createState() => _QuickAccessManagementState();
}

class _QuickAccessManagementState extends State<QuickAccessManagement> {
  final Set<int> savedIndices = {};
  bool sortByAlphabeticalOrder = true;
  final ScrollController _listController = ScrollController();
  String? _selectedLetter;
  String _searchQuery = '';

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
      {'name': 'Diabetes Mellitus', 'category': 'Endocrine'},
      {'name': 'Dengue Fever', 'category': 'Infectious'},
      {'name': 'Eczema', 'category': 'Dermatology'},
      {'name': 'Epilepsy', 'category': 'Neurology'},
      {'name': 'Fibromyalgia', 'category': 'Rheumatology'},
      {'name': 'Flu (Influenza)', 'category': 'Infectious'},
      {'name': 'Gastritis', 'category': 'Gastrointestinal'},
      {'name': 'Glaucoma', 'category': 'Ophthalmology'},
      {'name': 'Hypertension', 'category': 'Cardiovascular'},
      {'name': 'Hepatitis B', 'category': 'Infectious'},
      {'name': 'Irritable Bowel Syndrome', 'category': 'Gastrointestinal'},
      {'name': 'Insomnia', 'category': 'Psychiatric'},
      {'name': 'Jaundice', 'category': 'Hepatology'},
      {'name': 'Juvenile Idiopathic Arthritis', 'category': 'Rheumatology'},
      {'name': 'Kidney Stones', 'category': 'Urology'},
      {'name': 'Kawasaki Disease', 'category': 'Pediatrics'},
      {'name': 'Lupus', 'category': 'Rheumatology'},
      {'name': 'Lyme Disease', 'category': 'Infectious'},
      {'name': 'Migraine', 'category': 'Neurology'},
      {'name': 'Multiple Sclerosis', 'category': 'Neurology'},
      {'name': 'Nephrotic Syndrome', 'category': 'Nephrology'},
      {'name': 'Narcolepsy', 'category': 'Neurology'},
      {'name': 'Osteoarthritis', 'category': 'Rheumatology'},
      {'name': 'Osteoporosis', 'category': 'Endocrine'},
      {'name': 'Pneumonia', 'category': 'Respiratory'},
      {'name': 'Psoriasis', 'category': 'Dermatology'},
      {'name': 'Quinsy (Peritonsillar Abscess)', 'category': 'ENT'},
      {'name': 'Q Fever', 'category': 'Infectious'},
      {'name': 'Rheumatoid Arthritis', 'category': 'Rheumatology'},
      {'name': 'Rosacea', 'category': 'Dermatology'},
      {'name': 'Stroke', 'category': 'Neurology'},
      {'name': 'Sinusitis', 'category': 'ENT'},
      {'name': 'Tuberculosis', 'category': 'Infectious'},
      {'name': 'Thyroiditis', 'category': 'Endocrine'},
      {'name': 'Ulcerative Colitis', 'category': 'Gastrointestinal'},
      {'name': 'Urticaria', 'category': 'Dermatology'},
      {'name': 'Varicose Veins', 'category': 'Vascular'},
      {'name': 'Vertigo', 'category': 'Neurology'},
      {'name': 'Whooping Cough (Pertussis)', 'category': 'Infectious'},
      {'name': 'Wilson\'s Disease', 'category': 'Hepatology'},
      {'name': 'Xerostomia', 'category': 'Dental'},
      {'name': 'X-linked Agammaglobulinemia', 'category': 'Immunology'},
      {'name': 'Yellow Fever', 'category': 'Infectious'},
      {'name': 'Yersiniosis', 'category': 'Infectious'},
      {'name': 'Zika Virus', 'category': 'Infectious'},
      {'name': 'Zollinger-Ellison Syndrome', 'category': 'Gastrointestinal'},
    ];
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: 'Quick Access Management',
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sortByAlphabeticalOrder = !sortByAlphabeticalOrder;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: kSecondaryColor.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                  margin: EdgeInsets.only(right: 20),
                  child: Row(
                    children: [
                      Image.asset(Assets.imagesSort, height: 15),
                      SizedBox(width: 2),
                      MyText(
                        text: 'Sort By: A-Z',
                        size: 10,
                        color: kTertiaryColor,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        body: Stack(
          children: [
            if (sortByAlphabeticalOrder) ...[
              ListView(
                shrinkWrap: true,
                padding: AppSizes.DEFAULT,
                physics: BouncingScrollPhysics(),
                children: [
                  CustomSearchBar(
                    hintText: 'Search Disease By Name or Keyword',
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                  _sortByAlphabeticalOrder(
                    _searchQuery.isEmpty
                        ? items
                        : items
                            .where(
                              (item) =>
                                  item['name']!.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  item['category']!.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ] else ...[
              Padding(
                padding: AppSizes.HORIZONTAL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    CustomSearchBar(
                      hintText: 'Search Disease By Name or Keyword',
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.separated(
                              controller: _listController,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                              physics: BouncingScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final itemIndex = index;
                                final item = items[index];
                                return _ItemTile(
                                  title: item['name']!,
                                  subtitle: item['category']!,
                                  isRedFlag:
                                      item['name'] == 'Breast Cancer' ||
                                      item['name'] ==
                                          'Congestive Heart Failure',
                                  isSaved: savedIndices.contains(itemIndex),
                                  onSaveTap: () {
                                    setState(() {
                                      if (savedIndices.contains(itemIndex)) {
                                        savedIndices.remove(itemIndex);
                                      } else {
                                        savedIndices.add(itemIndex);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            alignment: Alignment.topRight,
                            width: 16,
                            height: Get.height,
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: AppSizes.ZERO,
                              physics: BouncingScrollPhysics(),
                              itemCount: 26,
                              separatorBuilder:
                                  (context, i) => SizedBox(height: 7),
                              itemBuilder: (context, i) {
                                String letter = String.fromCharCode(65 + i);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedLetter = letter;
                                    });
                                    final idx = items.indexWhere(
                                      (item) => item['name']!
                                          .toUpperCase()
                                          .startsWith(letter),
                                    );
                                    if (idx != -1) {
                                      _listController.animateTo(
                                        idx * 70.0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: MyText(
                                    text: letter,
                                    size: 12,
                                    textAlign: TextAlign.center,
                                    weight: FontWeight.w600,
                                    color:
                                        _selectedLetter == letter
                                            ? kSecondaryColor
                                            : kGreyColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: kLightGreenColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Image.asset(Assets.imagesReferenceIcon, height: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyText(
                            text: 'References',
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                          MyText(
                            text: 'View medical sources & research',
                            size: 10,
                            weight: FontWeight.w500,
                            color: kGreyColor,
                            paddingTop: 4,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(Assets.imagesArrowNext, height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _sortByAlphabeticalOrder(List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 4),
        ListView.builder(
          padding: AppSizes.ZERO,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: 26,
          itemBuilder: (context, alphaIndex) {
            String letter = String.fromCharCode(65 + alphaIndex);
            final filteredItems =
                items
                    .asMap()
                    .entries
                    .where(
                      (entry) =>
                          entry.value['name']!.toUpperCase().startsWith(letter),
                    )
                    .toList();
            if (filteredItems.isEmpty) return SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyText(
                  paddingTop: 12,
                  text: letter,
                  size: 14,
                  weight: FontWeight.w600,
                  color: kSecondaryColor,
                  paddingBottom: 4,
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: AppSizes.ZERO,
                  physics: BouncingScrollPhysics(),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final itemIndex = filteredItems[index].key;
                    final item = filteredItems[index].value;
                    return _ItemTile(
                      title: item['name']!,
                      subtitle: item['category']!,
                      isRedFlag:
                          item['name'] == 'Breast Cancer' ||
                          item['name'] == 'Congestive Heart Failure',
                      isSaved: savedIndices.contains(itemIndex),
                      onSaveTap: () {
                        setState(() {
                          if (savedIndices.contains(itemIndex)) {
                            savedIndices.remove(itemIndex);
                          } else {
                            savedIndices.add(itemIndex);
                          }
                        });
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
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
    return GestureDetector(
      onTap: () {
        Get.to(() => DiseaseDetail());
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
      ),
    );
  }
}

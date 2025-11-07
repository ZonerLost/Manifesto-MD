import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_fonts.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/main.dart';
import 'package:manifesto_md/view/widget/common_image_view_widget.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import '../../../models/clinical_models/clinical_models.dart';
import '../../../services/bookmarks_service.dart';

class ClinicalManifestationsDetails extends StatefulWidget {
  final ClinicalEntry entry;
  const ClinicalManifestationsDetails({super.key, required this.entry});

  @override
  State<ClinicalManifestationsDetails> createState() =>
      _ClinicalManifestationsDetailsState();
}

class _ClinicalManifestationsDetailsState
    extends State<ClinicalManifestationsDetails> {
  int selectedSection = 0;
  bool isFavorite = false;
  bool _loadingFav = true;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeSectionKeys();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    try {
      final saved = await BookmarksService.instance
          .isEntryBookmarked(widget.entry.name);
      if (mounted) {
        setState(() {
          isFavorite = saved;
          _loadingFav = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFav = false);
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final nowSaved = await BookmarksService.instance.toggleEntryBookmark(
        entryName: widget.entry.name,
        systemName: widget.entry.name ?? '', // if your model has system
        icdCode: widget.entry.icdCode,
        displayName: widget.entry.name,
      );
      if (mounted) {
        setState(() => isFavorite = nowSaved);
      }
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update bookmark.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kLightRedColor,
      );
    }
  }

  void _initializeSectionKeys() {
    final sections = [
      'Overview',
      'Red Flags',
      'Etiology',
      'Clinical Features',
      'Investigations',
      'Diagnosis',
      'Management',
      'Prevention'
    ];
    for (var section in sections) {
      _sectionKeys[section] = GlobalKey();
    }
  }

  void _scrollToSection(String sectionTitle) {
    final key = _sectionKeys[sectionTitle];
    if (key != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sections = [
      {'title': 'Overview', 'image': Assets.imagesInformation},
      {'title': 'Red Flags', 'image': Assets.imagesRedFlag},
      {'title': 'Etiology', 'image': Assets.imagesPin},
      {'title': 'Clinical Features', 'image': Assets.imagesCf},
      {'title': 'Investigations', 'image': Assets.imagesIt},
      {'title': 'Diagnosis', 'image': Assets.imagesDi},
      {'title': 'Management', 'image': Assets.imagesMp},
      {'title': 'Prevention', 'image': Assets.imagesRedFlag},
    ];

    final availableSections = sections.where((section) {
      switch (section['title']) {
        case 'Overview':
          return true;
        case 'Red Flags':
          return widget.entry.redFlags.isNotEmpty;
        case 'Etiology':
          return widget.entry.etiologies.isNotEmpty;
        case 'Clinical Features':
          return widget.entry.characteristics.isNotEmpty;
        case 'Investigations':
          return widget.entry.investigations.isNotEmpty;
        case 'Diagnosis':
          return widget.entry.differentialDiagnosis.isNotEmpty;
        case 'Management':
          return widget.entry.management.isNotEmpty;
        case 'Prevention':
          return widget.entry.prevention != null &&
              widget.entry.prevention!.isNotEmpty;
        default:
          return false;
      }
    }).toList();

    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(
          title: widget.entry.name,
          actions: [
            Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
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
                      onTap: _loadingFav ? null : _toggleBookmark,
                      child: _loadingFav
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Image.asset(
                        isFavorite
                            ? Assets.imagesSaveFilled
                            : Assets.imagesSaveEmpty,
                        height: 16,
                      ),
                    ),
                    MyText(
                      text: isFavorite ? 'Remove Favorite' : 'Add to Favorite',
                      size: 10,
                      color: kTertiaryColor,
                      paddingRight: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: ListView(
          controller: _scrollController,
          padding: AppSizes.VERTICAL,
          physics: const BouncingScrollPhysics(),
          children: [
            if (availableSections.length > 1)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: AppSizes.HORIZONTAL,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final bool isSelected = selectedSection == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSection = index;
                        });
                        _scrollToSection(availableSections[index]['title']!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected
                              ? kSecondaryColor.withValues(alpha: 0.12)
                              : kPrimaryColor,
                          border: Border.all(
                            color: isSelected
                                ? kSecondaryColor
                                : kBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          spacing: 6,
                          children: [
                            Image.asset(
                              availableSections[index]['image']!,
                              height: 18, // original colors kept
                            ),
                            MyText(
                              text: availableSections[index]['title']!,
                              size: 12,
                              weight: FontWeight.w600,
                              color: isSelected
                                  ? kSecondaryColor
                                  : kGreyColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: availableSections.length,
                ),
              ),

            const SizedBox(height: 16),
            Padding(
              padding: AppSizes.DEFAULT,
              child: _buildOverviewContent(),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: AppSizes.DEFAULT,
          child: MyButton(
            buttonText: 'Explore Another Symptom',
            onTap: () => Get.back(),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonImageView(
          height: 150,
          width: Get.width,
          radius: 16,
          fit: BoxFit.cover,
          url: dummyImg,
        ),
        const SizedBox(height: 16),

        _buildHeaderSection(),
        const SizedBox(height: 16),

        if (widget.entry.definition != null &&
            widget.entry.definition!.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Overview'],
            title: "Overview",
            icon: Assets.imagesInformation,
            suggestedActions: [widget.entry.definition!],
          ),

        if (widget.entry.redFlags.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Red Flags'],
            title: "Red Flag Alert",
            icon: Assets.imagesRedFlag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.entry.redFlags
                  .map(
                    (flag) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Text("• ",
                          style: TextStyle(color: Colors.red, fontSize: 14)),
                      Expanded(
                        child: MyText(
                          text: flag,
                          size: 12,
                          color: kGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
            suggestedActions: const [],
          ),

        if (widget.entry.etiologies.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Etiology'],
            title: "Etiology",
            icon: Assets.imagesPin,
            child: Column(
              children: widget.entry.etiologies
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: MyText(
                        text: entry.value,
                        size: 12,
                        color: kGreyColor,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: StepProgressIndicator(
                        totalSteps: widget.entry.etiologies.length,
                        currentStep: entry.key + 1,
                        size: 5,
                        padding: 1,
                        roundedEdges: const Radius.circular(2),
                        selectedColor: kSecondaryColor,
                        unselectedColor:
                        kSecondaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
            suggestedActions: const [],
          ),

        if (widget.entry.characteristics.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Clinical Features'],
            title: "Clinical Features",
            icon: Assets.imagesCf,
            suggestedActions: widget.entry.characteristics,
          ),

        if (widget.entry.investigations.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Investigations'],
            title: "Investigations",
            icon: Assets.imagesIt,
            child: Column(
              children: widget.entry.investigations
                  .map(
                    (investigation) => _ExpandableTile(
                  title: investigation,
                  subTitle: "Detailed information about $investigation",
                  buttonText: "Go to Investigation Page",
                ),
              )
                  .toList(),
            ),
            suggestedActions: const [],
          ),

        if (widget.entry.differentialDiagnosis.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Diagnosis'],
            title: "Diagnosis",
            icon: Assets.imagesDi,
            child: Column(
              children: widget.entry.differentialDiagnosis
                  .map(
                    (diagnosis) => _ExpandableTile(
                  title: diagnosis,
                  subTitle: "Detailed information about $diagnosis",
                  buttonText: "Go to Diagnosis Page",
                ),
              )
                  .toList(),
            ),
            suggestedActions: const [],
          ),

        if (widget.entry.management.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Management'],
            title: "Management",
            icon: Assets.imagesMp,
            suggestedActions: widget.entry.management,
          ),

        if (widget.entry.prevention != null &&
            widget.entry.prevention!.isNotEmpty)
          _ReportCard(
            key: _sectionKeys['Prevention'],
            title: "Prevention",
            icon: Assets.imagesInformation,
            suggestedActions: widget.entry.prevention!.split("\n"),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MyText(
          text: widget.entry.name,
          size: 22,
          weight: FontWeight.w700,
          color: kSecondaryColor,
        ),
        const SizedBox(height: 6),
        if (widget.entry.icdCode != null && widget.entry.icdCode!.isNotEmpty)
          MyText(
            text: "ICD-10 Code: ${widget.entry.icdCode}",
            size: 14,
            weight: FontWeight.w500,
            color: kGreyColor,
          ),
      ],
    );
  }
}

// --- Reusable Cards and Tiles ---
class _ReportCard extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? child;
  final List<String> suggestedActions;

  const _ReportCard({
    Key? key,
    required this.title,
    required this.suggestedActions,
    required this.icon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, height: 16),
              Expanded(
                child: MyText(
                  paddingLeft: 8,
                  text: title,
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (child != null)
            child!
          else
            ...suggestedActions.map(
                  (text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "- ",
                      size: 12,
                      color: kSecondaryColor,
                    ),
                    Expanded(
                      child: MyText(
                        text: text,
                        size: 12,
                        color: kGreyColor,
                        lineHeight: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  const _ExpandableTile({
    required this.title,
    required this.subTitle,
    this.mTop,
    this.buttonText,
    this.onTap,
  });

  final String title;
  final String subTitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final double? mTop;

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  late ExpandableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpandableController(initialExpanded: false);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.mTop ?? 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBorderColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: kBorderColor),
      ),
      child: ExpandableNotifier(
        controller: _controller,
        child: ScrollOnExpand(
          child: ExpandablePanel(
            controller: _controller,
            theme: const ExpandableThemeData(
              tapHeaderToExpand: true,
              hasIcon: false,
            ),
            header: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: widget.title,
                    size: 12,
                    color: kGreyColor,
                  ),
                ),
                RotatedBox(
                  quarterTurns: _controller.expanded ? 2 : 0,
                  child: Image.asset(Assets.imagesDropdown, height: 16),
                ),
              ],
            ),
            collapsed: const SizedBox(),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                MyText(
                  text: widget.subTitle,
                  lineHeight: 1.5,
                  color: kGreyColor,
                ),
                const SizedBox(height: 10),
                MyButton(
                  buttonText: widget.buttonText ?? 'Go to Symptoms Page',
                  onTap: widget.onTap ?? () {},
                  height: 32,
                  textSize: 12,
                  radius: 12,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

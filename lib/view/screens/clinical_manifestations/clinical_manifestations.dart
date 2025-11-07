import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manifesto_md/constants/app_colors.dart';
import 'package:manifesto_md/constants/app_images.dart';
import 'package:manifesto_md/constants/app_sizes.dart';
import 'package:manifesto_md/view/screens/clinical_manifestations/clinical_manifestations_details.dart';
import 'package:manifesto_md/view/screens/search/search.dart';
import 'package:manifesto_md/view/widget/custom_app_bar.dart';
import 'package:manifesto_md/view/widget/custom_container_widget.dart';
import 'package:manifesto_md/view/widget/custom_search_bar_widget.dart';
import 'package:manifesto_md/view/widget/my_button_widget.dart';
import 'package:manifesto_md/view/widget/my_text_widget.dart';
import '../../../models/clinical_models/clinical_models.dart';
import '../../../services/clinical_services/clinical_services.dart';

class _Spot {
  final String id;
  final String label;
  final double x;
  final double y;
  final List<String> systems;

  const _Spot({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.systems,
  });
}

/// Aliases so we tolerate slightly different system ids in JSON
const Map<String, List<String>> _SYSTEM_ALIASES = {
  'head_face': [
    'neurology', 'neuro', 'ent', 'otolaryngology', 'ophthalmology',
    'dermatology', 'cosmetic_plastic', 'cosmetic', 'psych', 'psychiatry'
  ],
  'neck': ['endocrinology', 'endocrine', 'ent', 'lymph', 'lymphatic'],
  'chest': ['cardiovascular', 'cv', 'cardio', 'respiratory', 'pulmonary', 'breast'],
  'abdomen': ['gastrointestinal', 'gi', 'hepatology', 'hepatobiliary', 'pancreas', 'spleen'],
  'pelvis': ['genitourinary', 'gu', 'urology', 'gynecology', 'obgyn'],
  'upper_limb': ['musculoskeletal', 'msk', 'vascular', 'neuro'],
  'lower_limb': ['musculoskeletal', 'msk', 'vascular', 'neuro'],
  'skin': ['dermatology', 'cosmetic_plastic', 'cosmetic'],
  'general': [
    'constitutional', 'preventive_medicine', 'lifestyle_medicine',
    'hematology', 'endocrinology', 'infectious_disease', 'oncology'
  ],
};

/// The actual front-view pins (positions tuned for your screenshot layout)
List<_Spot> _spots = [
  _Spot(
    id: 'head',
    label: 'Head / Face',
    x: 0.50, y: 0.15,
    systems: _SYSTEM_ALIASES['head_face']!,
  ),
  _Spot(
    id: 'neck',
    label: 'Neck',
    x: 0.50, y: 0.22,
    systems: _SYSTEM_ALIASES['neck']!,
  ),
  _Spot(
    id: 'chest',
    label: 'Chest',
    x: 0.50, y: 0.34,
    systems: _SYSTEM_ALIASES['chest']!,
  ),
  _Spot(
    id: 'l_shoulder',
    label: 'Left Shoulder / Arm',
    x: 0.28, y: 0.37,
    systems: _SYSTEM_ALIASES['upper_limb']!,
  ),
  _Spot(
    id: 'r_shoulder',
    label: 'Right Shoulder / Arm',
    x: 0.72, y: 0.37,
    systems: _SYSTEM_ALIASES['upper_limb']!,
  ),
  _Spot(
    id: 'abdomen',
    label: 'Abdomen',
    x: 0.50, y: 0.49,
    systems: _SYSTEM_ALIASES['abdomen']!,
  ),
  _Spot(
    id: 'pelvis',
    label: 'Pelvis / GU',
    x: 0.50, y: 0.61,
    systems: _SYSTEM_ALIASES['pelvis']!,
  ),
  _Spot(
    id: 'l_thigh',
    label: 'Left Thigh / Knee',
    x: 0.44, y: 0.74,
    systems: _SYSTEM_ALIASES['lower_limb']!,
  ),
  _Spot(
    id: 'r_thigh',
    label: 'Right Thigh / Knee',
    x: 0.56, y: 0.74,
    systems: _SYSTEM_ALIASES['lower_limb']!,
  ),
  _Spot(
    id: 'l_leg',
    label: 'Left Leg / Foot',
    x: 0.47, y: 0.89,
    systems: _SYSTEM_ALIASES['lower_limb']!,
  ),
  _Spot(
    id: 'r_leg',
    label: 'Right Leg / Foot',
    x: 0.53, y: 0.89,
    systems: _SYSTEM_ALIASES['lower_limb']!,
  ),
  _Spot(
    id: 'general',
    label: 'General / Systemic',
    x: 0.50, y: 0.28,
    systems: _SYSTEM_ALIASES['general']!,
  ),
];

class ClinicalManifestations extends StatefulWidget {
  const ClinicalManifestations({super.key});

  @override
  State<ClinicalManifestations> createState() => _ClinicalManifestationsState();
}

class _ClinicalManifestationsState extends State<ClinicalManifestations> {
  final _svc = ClinicalService();
  String? _activeSpotId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.bottomSheet(_Information(), isScrollControlled: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Clinical Manifestations'),
        body: FutureBuilder<List<ClinicalSystem>>(
          future: _svc.loadSystems(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: MyText(text: 'Failed to load: ${snap.error}', size: 12, color: kRedColor),
              );
            }
            final systems = snap.data ?? [];

            // Build a set of available system ids present in JSON (lowercase)
            final Set<String> presentSystemSet =
            systems.map((s) => s.system.trim().toLowerCase()).toSet();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === EXACT SAME SEARCH BAR AS SEARCH WIDGET (read-only overlay) ===
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Stack(
                    children: [
                      // renders the exact same visuals
                      const IgnorePointer(
                        ignoring: true,
                        child: CustomSearchBar(
                          hintText: 'Type your main clinical manifestations here',
                        ),
                      ),
                      // full overlay to navigate on tap
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Get.to(() => const Search()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body + dynamic pins
                Expanded(
                  child: Container(
                    margin: AppSizes.DEFAULT,
                    decoration: BoxDecoration(
                      color: const Color(0xffDDF6F6),
                      border: Border.all(color: kBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyText(
                          paddingTop: 16,
                          paddingLeft: 16,
                          text: 'Front View',
                          size: 12,
                          weight: FontWeight.w600,
                          paddingBottom: 4,
                        ),
                        MyText(
                          paddingLeft: 16,
                          text: 'Skin Mode',
                          size: 10,
                          weight: FontWeight.w500,
                          color: kGreyColor,
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final h = constraints.maxHeight;

                              // Which spots should appear?
                              final List<_Spot> visibleSpots = _spots.where((s) {
                                return s.systems.any(
                                      (key) => presentSystemSet.contains(key.toLowerCase()),
                                );
                              }).toList();

                              return Stack(
                                children: [
                                  // Body image
                                  Positioned.fill(
                                    child: Image.asset(
                                      Assets.imagesHumanBody,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Pins
                                  for (final s in visibleSpots)
                                    Positioned(
                                      left: s.x * w - 12,
                                      top: s.y * h - 12,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _activeSpotId = s.id);
                                          _openSpotSheet(context, s, systems);
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (_activeSpotId == s.id)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                margin: const EdgeInsets.only(bottom: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: kBorderColor),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.06),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: MyText(
                                                  text: s.label,
                                                  size: 10,
                                                  color: kTertiaryColor,
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            Image.asset(Assets.imagesBodyPartTap, height: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSpotSheet(BuildContext context, _Spot spot, List<ClinicalSystem> systems) {
    // Which systems from JSON map into this spot?
    final presentById = {for (var s in systems) s.system.trim().toLowerCase(): s};
    final List<ClinicalSystem> mappedSystems = [];

    for (final key in spot.systems) {
      final hit = presentById[key.toLowerCase()];
      if (hit != null) mappedSystems.add(hit);
    }

    // Collect entries from all mapped systems; dedupe by name
    final Map<String, ClinicalEntry> entriesByName = {};
    for (final sys in mappedSystems) {
      for (final e in sys.entries) {
        if (e.name.trim().isEmpty) continue;
        entriesByName.putIfAbsent(e.name, () => e);
      }
    }
    final List<ClinicalEntry> entries = entriesByName.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    Get.bottomSheet(
      _SpotBottomSheet(
        spotLabel: spot.label,
        systems: mappedSystems,
        entries: entries,
        onTapEntry: (entry) {
          Get.back();
          Get.to(() => ClinicalManifestationsDetails(entry: entry));
        },
      ),
      isScrollControlled: true,
    );
  }
}

class _SpotBottomSheet extends StatelessWidget {
  final String spotLabel;
  final List<ClinicalSystem> systems;
  final List<ClinicalEntry> entries;
  final ValueChanged<ClinicalEntry> onTapEntry;

  const _SpotBottomSheet({
    required this.spotLabel,
    required this.systems,
    required this.entries,
    required this.onTapEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.DEFAULT,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Image.asset(Assets.imagesBodyPartTap, height: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: MyText(
                    text: spotLabel,
                    size: 16,
                    weight: FontWeight.w700,
                    color: kTertiaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(Assets.imagesClose, height: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: systems.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kSecondaryColor.withValues(alpha: .25)),
                  ),
                  child: MyText(
                    text: s.system.isNotEmpty ? s.system : s.system.capitalize!,
                    size: 10,
                    color: kSecondaryColor,
                    weight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            if (entries.isEmpty)
               Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: MyText(
                  text: 'No entries found for this region.',
                  size: 12,
                  color: kGreyColor,
                ),
              )
            else
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final isRed = e.redFlags.isNotEmpty;
                      return GestureDetector(
                        onTap: () => onTapEntry(e),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRed ? kRedColor.withValues(alpha: .10) : kPrimaryColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRed ? kRedColor.withValues(alpha: .12) : kBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isRed) ...[
                                Image.asset(Assets.imagesRedFlag, height: 16),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: MyText(
                                  text: e.name,
                                  size: 12,
                                  color: kGreyColor,
                                ),
                              ),
                              Image.asset(Assets.imagesArrowNext, height: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 12),
            MyButton(
              buttonText: 'Done',
              onTap: () => Get.back(),
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

class _Information extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: AppSizes.DEFAULT,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:  [
              MyText(
                text: 'Info',
                size: 18,
                weight: FontWeight.w700,
                paddingBottom: 8,
              ),
              MyText(
                size: 13,
                text:
                'Search for clinical manifestations above or tap on a spot to explore the entries associated with that region.',
                paddingBottom: 20,
              ),
            ],
          ),
        ),
        Positioned(
          top: -16,
          right: 32,
          child: Image.asset(Assets.imagesInfoBig, height: 65),
        ),
      ],
    );
  }
}

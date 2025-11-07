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
import '../../../models/clinical_models/clinical_models.dart';
import '../../../models/clinical_models/system_model.dart';
import '../../../services/clinical_services/clinical_services.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchQuery = '';
  final service = ClinicalService();

  /// Map + heuristics: return the best icon for a given system name
  String systemIconFor(String name) {
    final s = name.trim().toLowerCase();

    // --- Exact/primary matches first (common system keys) ---
    const exact = <String, String>{
      // Gastrointestinal
      'gastrointestinal': Assets.imagesGs,
      'gi': Assets.imagesGs,
      'hepatology': Assets.imagesGs,
      'hepatobiliary': Assets.imagesGs,
      'pancreas': Assets.imagesGs,

      // Respiratory / Pulmonary
      'respiratory': Assets.imagesPl,
      'pulmonology': Assets.imagesPl,
      'pulmonary': Assets.imagesPl,
      'lung': Assets.imagesPl,

      // Genitourinary / Kidney / Urology
      'genitourinary': Assets.imagesKd,
      'gu': Assets.imagesKd,
      'urology': Assets.imagesKd,
      'nephrology': Assets.imagesKd,
      'renal': Assets.imagesKd,
      'kidney': Assets.imagesKd,

      // Neurology / Head & Neck
      'neurology': Assets.imagesHn,
      'head & neck': Assets.imagesHn,
      'head and neck': Assets.imagesHn,
      'ent': Assets.imagesHn,
      'otolaryngology': Assets.imagesHn,

      // Musculoskeletal
      'musculoskeletal': Assets.imagesLeg,
      'msk': Assets.imagesLeg,
      'orthopedics': Assets.imagesLeg,
      'rheumatology': Assets.imagesArms,

      // Ophthalmology
      'ophthalmology': Assets.imagesVisibility,
      'eye': Assets.imagesVisibility,

      // Dermatology / Skin
      'dermatology': Assets.imagesMedical,

      // Hematology
      'hematology': Assets.imagesLabTest,

      // Infectious Disease
      'infectious disease': Assets.imagesMedicalAlerts,
      'id': Assets.imagesMedicalAlerts,

      // Cardiology (no heart icon available -> use medical_special)
      'cardiology': Assets.imagesMedicalSpecial,
      'cardiovascular': Assets.imagesMedicalSpecial,

      // Endocrinology
      'endocrinology': Assets.imagesMedical,

      // Psychiatry / Mental health
      'psychiatry': Assets.imagesProfile,
      'mental health': Assets.imagesProfile,

      // Preventive / Lifestyle
      'preventive medicine': Assets.imagesMedicalSpecial,
      'lifestyle medicine': Assets.imagesMedicalSpecial,

      // Oncology
      'oncology': Assets.imagesMedicalSpecial,

      // Generic / fallback candidates
      'general': Assets.imagesMedical,
      'general medicine': Assets.imagesMedical,
      'internal medicine': Assets.imagesMedical,
      'cosmetic/plastic': Assets.imagesMedical,
      'cosmetic_plastic': Assets.imagesMedical,
    };

    if (exact.containsKey(s)) return exact[s]!;

    // --- Heuristics / substring contains ---
    if (s.contains('gastro') || s.contains('abdomen') || s.contains('gi')) {
      return Assets.imagesGs;
    }
    if (s.contains('pulmo') || s.contains('respir') || s.contains('lung')) {
      return Assets.imagesPl;
    }
    if (s.contains('uro') || s.contains('genito') || s.contains('renal') || s.contains('kidney')) {
      return Assets.imagesKd;
    }
    if (s.contains('neuro') || s.contains('brain') || s.contains('head') || s.contains('neck') || s.contains('ent')) {
      return Assets.imagesHn;
    }
    if (s.contains('ophthal') || s.contains('eye') || s.contains('vision')) {
      return Assets.imagesVisibility;
    }
    if (s.contains('derma') || s.contains('skin')) {
      return Assets.imagesMedical;
    }
    if (s.contains('musculo') || s.contains('orthop') || s.contains('msk') || s.contains('joint')) {
      return Assets.imagesLeg;
    }
    if (s.contains('rheuma')) {
      return Assets.imagesArms;
    }
    if (s.contains('hemo') || s.contains('heme') || s.contains('blood')) {
      return Assets.imagesLabTest;
    }
    if (s.contains('infect')) {
      return Assets.imagesMedicalAlerts;
    }
    if (s.contains('cardio') || s.contains('heart')) {
      return Assets.imagesMedicalSpecial;
    }
    if (s.contains('endo') || s.contains('horm')) {
      return Assets.imagesMedical;
    }
    if (s.contains('psy') || s.contains('mental')) {
      return Assets.imagesProfile;
    }
    if (s.contains('prevent') || s.contains('lifestyle')) {
      return Assets.imagesMedicalSpecial;
    }
    if (s.contains('oncolo') || s.contains('cancer') || s.contains('tumor')) {
      return Assets.imagesMedicalSpecial;
    }
    if (s.contains('cosmet') || s.contains('plastic')) {
      return Assets.imagesMedical;
    }

    // Last-resort fallbacks
    return Assets.imagesClinicalManisfesto; // nice neutral brand icon
    // Alternatively: return Assets.imagesMedical;
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: simpleAppBar(title: 'Search Clinical Manifestations'),
        body: FutureBuilder<List<ClinicalSystem>>(
          future: service.loadSystems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: MyText(
                  text: 'Error loading data: ${snapshot.error}',
                  size: 14,
                  color: kRedColor,
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return  Center(
                child: MyText(
                  text: 'No systems available',
                  size: 14,
                  color: kGreyColor,
                ),
              );
            }

            final systems = snapshot.data!;
            final filteredSystems = systems
                .where((sys) =>
                sys.system.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return ListView(
              padding: AppSizes.DEFAULT,
              children: [
                CustomSearchBar(
                  hintText: 'Type your main clinical manifestations here',
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 16),

                ...List.generate(filteredSystems.length, (index) {
                  final sys = filteredSystems[index];
                  final iconPath = systemIconFor(sys.system);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => SelectBodyPart(
                          system: sys,
                          icon: iconPath, // <-- pass the mapped icon
                          title: sys.system,
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          border: Border.all(color: kBorderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Use the system-specific icon
                            Image.asset(iconPath, height: 22),
                            Expanded(
                              child: MyText(
                                paddingLeft: 10,
                                text: sys.system.capitalize!,
                                size: 12,
                                color: kGreyColor,
                              ),
                            ),
                            Image.asset(Assets.imagesArrowNext, height: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:manifesto_md/models/clinical_models/clinical_models.dart';

class ClinicalService {
  Future<List<ClinicalSystem>> loadSystems() async {
    // Adjust the path if your asset is elsewhere
    final String jsonString =
    await rootBundle.loadString('assets/clinical_assets/i18n/clinical_data_en.json');

    final systems = ClinicalRepository.parseAll(jsonString);

    if (systems.isEmpty) {
      throw Exception('No systems found in JSON data');
    }

    // Optional: normalize/sort for stable UX
    systems.sort((a, b) => a.system.toLowerCase().compareTo(b.system.toLowerCase()));

    // Optional: sanity log
    // for (final s in systems) {
    //   // ignore: avoid_print
    //   print('[ClinicalService] ${s.system}: ${s.entries.length} entries');
    // }

    return systems;
  }
}

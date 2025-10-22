import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:manifesto_md/services/gemini_service.dart';

class GeminiController extends GetxController {
  /// Loading state
  var isLoading = false.obs;

  /// List of diagnoses (from AI)
  var diagnoses = <Map<String, dynamic>>[].obs;

  /// Fetch and process the diagnosis data
  Future<bool?> fetchDiagnosis(List<String> symptoms) async {
    if (symptoms.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one symptom',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      diagnoses.clear();

      /// Call Gemini service to get diagnoses
      final List<Map<String, dynamic>> data =
          await GeminiService.instance.getDiagnosesFromSymptoms(symptoms);

        diagnoses.assignAll(data);

        print(data);
        return true;
    } catch (e) {
      print('Error extracting diagnosis: $e');
      Get.snackbar(
        'Error',
        'Failed to extract diagnosis information.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}

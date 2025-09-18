import 'package:get/get.dart';

class SmartDDxController extends GetxController {
  static final SmartDDxController instance = Get.find<SmartDDxController>();

  final RxList<String> selectedSymptoms = <String>[].obs;

  void addSymptom(String symptom) {
    if (!selectedSymptoms.contains(symptom)) {
      selectedSymptoms.add(symptom);
    }
  }

  void removeSymptom(String symptom) {
    selectedSymptoms.remove(symptom);
  }

  void clearSymptoms() {
    selectedSymptoms.clear();
  }

  List<String> get symptomsList => selectedSymptoms.toList();
}

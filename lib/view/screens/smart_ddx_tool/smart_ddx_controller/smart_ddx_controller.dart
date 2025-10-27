import 'package:get/get.dart';
import 'package:manifesto_md/constants/disease_data_list.dart';
import 'package:manifesto_md/models/searchitem_model.dart';

class SmartDDxController extends GetxController {
  static final SmartDDxController instance = Get.find<SmartDDxController>();

  final RxList<String> selectedSymptoms = <String>[].obs;

  final RxList<SearchItem> _allItems = <SearchItem>[].obs;
  final RxList<SearchItem> filteredItems = <SearchItem>[].obs;
  final RxList<String> symptomSuggestions = <String>[].obs;

final RxString _query = ''.obs;


  @override
  void onInit() {
    // Light debounce so filtering isn't too chatty.
    loadItems(searchItems);
    debounce<String>(_query, (_) => _applyFilter(),
        time: const Duration(milliseconds: 200));
    super.onInit();
  }

  void loadItems(List<SearchItem> items) {
    _allItems.assignAll(items);
    filteredItems.assignAll(items);
    symptomSuggestions.clear();
  }

  void addSymptom(String symptom) {
    if (!selectedSymptoms.contains(symptom)) {
      selectedSymptoms.add(symptom);
    }
  }
void searchInList(String query) {
  final q = query.trim().toLowerCase();

  if (q.isEmpty) {
    filteredItems.assignAll(_allItems);
    return;
  }

  filteredItems.assignAll(
    _allItems.where((item) {
      final inTitle = item.title.toLowerCase().contains(q);
      // final inSymptoms = item.symptoms.any((s) => s.toLowerCase().contains(q));
      return inTitle ;
    }),
  );
}


  void removeSymptom(String symptom) {
    selectedSymptoms.remove(symptom);
  }

  void clearSymptoms() {
    selectedSymptoms.clear();
  }
// ----- Internal filter logic -----
  void _applyFilter() {
    final q = _query.value.trim().toLowerCase();

    if (q.isEmpty) {
      filteredItems.assignAll(_allItems);
      symptomSuggestions.clear();
      return;
    }
    final tokens =
        q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    bool matches(SearchItem item) {
      final title = item.title.toLowerCase();
      final inTitle = tokens.every((tok) => title.contains(tok));

      final inSymptoms = item.symptoms.any((s) {
        final sl = s.toLowerCase();
        return tokens.every((tok) => sl.contains(tok));
      });

      return inTitle || inSymptoms;
    }

    // Filter
    final results = _allItems.where(matches).toList();

    // Rank: title startsWith(q) first, then symptom startsWith(q), then others.
    int rank(SearchItem item) {
      final title = item.title.toLowerCase();
      final titleStarts = title.startsWith(q) ? 0 : 2;

      final symptomStarts = item.symptoms.any(
        (s) => s.toLowerCase().startsWith(q),
      )
          ? 1
          : 3;

      return titleStarts < symptomStarts ? titleStarts : symptomStarts;
    }

    results.sort((a, b) {
      final ra = rank(a);
      final rb = rank(b);
      if (ra != rb) return ra - rb;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    filteredItems.assignAll(results);

    // Build flat symptom suggestions (unique, excluding already selected).
    final seen = <String>{};
    final sugg = <String>[];
    for (final item in results) {
      for (final s in item.symptoms) {
        final sLow = s.toLowerCase();
        final matchAllTokens = tokens.every((t) => sLow.contains(t));
        if (matchAllTokens &&
            !selectedSymptoms.contains(s) &&
            seen.add(sLow)) {
          sugg.add(s);
        }
      }
    }

    // Put symptoms that start with q first
    sugg.sort((a, b) {
      final aS = a.toLowerCase().startsWith(q) ? 0 : 1;
      final bS = b.toLowerCase().startsWith(q) ? 0 : 1;
      if (aS != bS) return aS - bS;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    symptomSuggestions.assignAll(sugg.take(25));
  }

  List<String> get symptomsList => selectedSymptoms.toList();
}

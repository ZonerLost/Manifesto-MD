// class ClinicalSystem {
//   final String system;
//   final List<ClinicalEntry> entries;
//
//   ClinicalSystem({required this.system, required this.entries});
//
//   factory ClinicalSystem.fromJson(Map<String, dynamic> json) {
//     final nested = json['entries'] as List;
//     final flat = nested.expand((e) => e).toList(); // flatten inner arrays
//     return ClinicalSystem(
//       system: json['system'] ?? json['name'] ?? '',
//       entries: flat.map((e) => ClinicalEntry.fromJson(e)).toList(),
//     );
//   }
// }
//
// class ClinicalEntry {
//   final String name;
//   final List<String> characteristics;
//
//   ClinicalEntry({
//     required this.name,
//     required this.characteristics,
//   });
//
//   factory ClinicalEntry.fromJson(Map<String, dynamic> json) {
//     return ClinicalEntry(
//       name: json['name'] ?? '',
//       characteristics: List<String>.from(json['characteristics'] ?? []),
//     );
//   }
// }

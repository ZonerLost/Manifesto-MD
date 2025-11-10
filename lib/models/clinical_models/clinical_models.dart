import 'dart:convert';

/// Enum for medical systems
enum MedicalSystem {
  constitutional,
  cardiovascular,
  respiratory,
  gastrointestinal,
  neurology,
  musculoskeletal,
  dermatology,
  endocrine,
  renal,
  hematology,
  infectiousDisease,
  psychiatry,
  ent,
  ophthalmology,
  obstetricsGynecology,
  pediatrics,
  geriatrics,
  urology,
  oncology,
  immunology,
  other,
}

String medicalSystemToString(MedicalSystem s) => s.name;

/// Common aliases → enum mapping (extend as needed)
const Map<String, MedicalSystem> _SYSTEM_ALIASES = {
  // Cardiovascular
  'cv': MedicalSystem.cardiovascular,
  'cardio': MedicalSystem.cardiovascular,
  'cardiovascular': MedicalSystem.cardiovascular,
  'heart': MedicalSystem.cardiovascular,

  // Respiratory
  'resp': MedicalSystem.respiratory,
  'respiratory': MedicalSystem.respiratory,
  'pulmo': MedicalSystem.respiratory,
  'pulmonary': MedicalSystem.respiratory,
  'lung': MedicalSystem.respiratory,

  // GI / Hepatobiliary / Pancreas
  'gi': MedicalSystem.gastrointestinal,
  'gastro': MedicalSystem.gastrointestinal,
  'gastrointestinal': MedicalSystem.gastrointestinal,
  'hepatology': MedicalSystem.gastrointestinal,
  'hepatobiliary': MedicalSystem.gastrointestinal,
  'pancreas': MedicalSystem.gastrointestinal,
  'abdo': MedicalSystem.gastrointestinal,
  'abdomen': MedicalSystem.gastrointestinal,

  // ENT
  'ent': MedicalSystem.ent,
  'ear_nose_throat': MedicalSystem.ent,
  'otolaryngology': MedicalSystem.ent,

  // Ophthalmology
  'ophthal': MedicalSystem.ophthalmology,
  'ophthalmology': MedicalSystem.ophthalmology,
  'eye': MedicalSystem.ophthalmology,

  // Neuro
  'neuro': MedicalSystem.neurology,
  'neurology': MedicalSystem.neurology,
  'head': MedicalSystem.neurology,
  'head & neck': MedicalSystem.neurology,
  'head and neck': MedicalSystem.neurology,

  // MSK / Rheum
  'msk': MedicalSystem.musculoskeletal,
  'musculoskeletal': MedicalSystem.musculoskeletal,
  'orthopedics': MedicalSystem.musculoskeletal,
  'rheumatology': MedicalSystem.musculoskeletal,

  // Derm
  'derma': MedicalSystem.dermatology,
  'dermatology': MedicalSystem.dermatology,
  'skin': MedicalSystem.dermatology,

  // Renal / GU / Urology
  'renal': MedicalSystem.renal,
  'kidney': MedicalSystem.renal,
  'gu': MedicalSystem.urology,
  'genitourinary': MedicalSystem.urology,
  'urology': MedicalSystem.urology,

  // Endocrine
  'endo': MedicalSystem.endocrine,
  'endocrine': MedicalSystem.endocrine,
  'endocrinology': MedicalSystem.endocrine,

  // Heme
  'heme': MedicalSystem.hematology,
  'hematology': MedicalSystem.hematology,
  'blood': MedicalSystem.hematology,

  // ID
  'id': MedicalSystem.infectiousDisease,
  'infectious': MedicalSystem.infectiousDisease,
  'infectious disease': MedicalSystem.infectiousDisease,
  'infection': MedicalSystem.infectiousDisease,

  // Psych
  'psych': MedicalSystem.psychiatry,
  'psychiatry': MedicalSystem.psychiatry,
  'mental': MedicalSystem.psychiatry,

  // OB/GYN
  'obgyn': MedicalSystem.obstetricsGynecology,
  'ob/gyn': MedicalSystem.obstetricsGynecology,
  'obstetrics': MedicalSystem.obstetricsGynecology,
  'gynecology': MedicalSystem.obstetricsGynecology,

  // Oncology / Immunology
  'onco': MedicalSystem.oncology,
  'oncology': MedicalSystem.oncology,
  'immuno': MedicalSystem.immunology,
  'immunology': MedicalSystem.immunology,

  // Pediatrics / Geriatrics
  'peds': MedicalSystem.pediatrics,
  'pediatrics': MedicalSystem.pediatrics,
  'geriatrics': MedicalSystem.geriatrics,
};

MedicalSystem systemFromString(String s) {
  final k = s.trim().toLowerCase();
  if (_SYSTEM_ALIASES.containsKey(k)) return _SYSTEM_ALIASES[k]!;
  return MedicalSystem.values.firstWhere(
        (v) => v.name.toLowerCase() == k,
    orElse: () => MedicalSystem.other,
  );
}

/// --- Helpers ----------------------------------------------------------------

List<String> _toStringList(dynamic v) {
  if (v == null) return const [];
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }
  if (v is String && v.trim().isNotEmpty) return [v];
  return const [];
}

List<Map<String, dynamic>> _toMapListFlatten(dynamic v) {
  // Flattens:
  //  - [{...}, {...}]
  //  - [[{...}, {...}], [{...}]]
  //  - {...} (single)
  final out = <Map<String, dynamic>>[];

  void addNode(dynamic n) {
    if (n is Map<String, dynamic>) {
      out.add(n);
    } else if (n is List) {
      for (final child in n) {
        addNode(child);
      }
    }
  }

  addNode(v);
  return out;
}

/// --- Models -----------------------------------------------------------------

/// Full Clinical Entry - matches JSON semantically
class ClinicalEntry {
  final String? id;
  final int? number;
  final String name;
  final String? icdCode;
  final String? definition;
  final List<String> etiologies;
  final String? pathophysiology;
  final List<String> characteristics;
  final List<String> redFlags;
  final List<String> differentialDiagnosis;
  final List<String> investigations;
  final List<String> management;
  final Map<String, dynamic>? extra;

  const ClinicalEntry({
    this.id,
    this.number,
    required this.name,
    this.icdCode,
    this.definition,
    this.etiologies = const [],
    this.pathophysiology,
    this.characteristics = const [],
    this.redFlags = const [],
    this.differentialDiagnosis = const [],
    this.investigations = const [],
    this.management = const [],
    this.extra,
  });

  factory ClinicalEntry.fromJson(Map<String, dynamic> json) {
    return ClinicalEntry(
      id: json['id'] as String?,
      number: json['number'] is int ? json['number'] as int? : int.tryParse('${json['number']}'),
      name: (json['name'] as String? ?? '').trim(),
      icdCode: json['icdCode'] as String?,
      definition: json['definition'] as String?,
      etiologies: _toStringList(json['etiologies']),
      pathophysiology: json['pathophysiology'] as String?,
      characteristics: _toStringList(json['characteristics']),
      redFlags: _toStringList(json['redFlags']),
      differentialDiagnosis: _toStringList(json['differentialDiagnosis']),
      investigations: _toStringList(json['investigations']),
      management: _toStringList(json['management']),
      extra: (json['extra'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'etiologies': etiologies,
      'characteristics': characteristics,
      'redFlags': redFlags,
      'differentialDiagnosis': differentialDiagnosis,
      'investigations': investigations,
      'management': management,
    };
    if (id != null) map['id'] = id;
    if (number != null) map['number'] = number;
    if (icdCode != null) map['icdCode'] = icdCode;
    if (definition != null) map['definition'] = definition;
    if (pathophysiology != null) map['pathophysiology'] = pathophysiology;
    if (extra != null) map['extra'] = extra;
    return map;
  }

  // Derived prevention
  String? get prevention {
    if (extra != null && extra!.containsKey('prevention')) {
      return extra!['prevention'] as String?;
    }
    if (management.isNotEmpty) {
      final preventive = management.where((item) {
        final l = item.toLowerCase();
        return l.contains('prevent') ||
            l.contains('avoid') ||
            l.contains('reduce risk') ||
            l.contains('prophylaxis') ||
            l.contains('screening') ||
            l.contains('monitor');
      }).toList();
      if (preventive.isNotEmpty) {
        return preventive.join('\n• ');
      }
    }
    return _generateGenericPrevention();
  }

  String? _generateGenericPrevention() {
    final n = name.toLowerCase();
    if (n.contains('fever') || n.contains('infection')) {
      return 'Hand hygiene; avoid close contact with sick individuals; stay up to date with vaccinations.';
    } else if (n.contains('chest pain') || n.contains('cardio')) {
      return 'Healthy lifestyle: exercise, diet, no smoking; control BP/lipids; regular check-ups.';
    } else if (n.contains('weight')) {
      return 'Balanced diet and regular exercise; monitor weight; address underlying conditions.';
    } else if (n.contains('fatigue') || n.contains('weakness')) {
      return 'Adequate sleep and stress management; balanced nutrition; regular physical activity.';
    } else {
      return 'Regular follow-up; healthy lifestyle; early intervention; patient education.';
    }
  }
}

/// One system (e.g., "cardiovascular") with list of entries
class ClinicalSystem {
  final String system;
  final List<ClinicalEntry> entries;

  const ClinicalSystem({
    required this.system,
    required this.entries,
  });

  factory ClinicalSystem.fromJson(Map<String, dynamic> json) {
    final systemName = (json['system'] as String? ??
        json['name'] as String? ??
        '')
        .trim();

    // entries can be [{..}], [[{..}]], or even a single {..}
    final entriesData = json['entries'];
    final maps = _toMapListFlatten(entriesData);
    final parsed = maps.map(ClinicalEntry.fromJson).toList();

    return ClinicalSystem(
      system: systemName,
      entries: parsed,
    );
  }

  Map<String, dynamic> toJson() => {
    'system': system,
    // IMPORTANT: keep flat, do NOT re-nest
    'entries': entries.map((e) => e.toJson()).toList(),
  };
}

/// Repository to load all systems
class ClinicalRepository {
  static List<ClinicalSystem> parseAll(String jsonStr) {
    try {
      final dynamic root = json.decode(jsonStr);

      // Case 1: { "systems": [ {system, entries}, ... ] }
      if (root is Map<String, dynamic>) {
        final dynSystems = root['systems'] ?? root['Systems'] ?? root['SYSTEMS'];
        if (dynSystems is List) {
          return dynSystems
              .whereType<Map<String, dynamic>>()
              .map(ClinicalSystem.fromJson)
              .toList();
        }
        if (dynSystems is Map) {
          return dynSystems.values
              .whereType<Map<String, dynamic>>()
              .map(ClinicalSystem.fromJson)
              .toList();
        }

        // Case 2: The map itself may be a single system object
        if (root.containsKey('system') && root.containsKey('entries')) {
          return [ClinicalSystem.fromJson(root)];
        }

        // Case 3: A map of systems keyed by name
        return root.values
            .whereType<Map<String, dynamic>>()
            .map(ClinicalSystem.fromJson)
            .toList();
      }

      // Case 4: Root is already a List of systems
      if (root is List) {
        return root
            .whereType<Map<String, dynamic>>()
            .map(ClinicalSystem.fromJson)
            .toList();
      }

      return [];
    } catch (e) {
      // In production you might want to log to Crashlytics/Sentry, etc.
      // Here we keep it quiet and return empty to avoid crashes.
      return [];
    }
  }
}

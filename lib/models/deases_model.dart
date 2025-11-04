/// ClinicalConditionModel
/// Fields correspond to:
/// Clinical Manifestation, ICD-11 Definition, Etiology, Pathophysiology,
/// ManifestoMD / VROCH, Specific Characteristics, Characterization VROCH,
/// Red Flags, Differential Diagnosis (Common -> Rare),
/// Investigations, Management / Protocol
class ClinicalConditionModel {
  final String clinicalManifestation;
  final String icd11Definition;
  final String etiology;
  final String pathophysiology;
  final String manifestoMdVroch;
  final String specificCharacteristics;
  final String characterizationVroch; 
  final String redFlags;
  final List<String> differentialDiagnosis; // ordered: common -> rare
  final List<String> investigations;
  final List<String> managementProtocol;

  /// Only a constructor (no other methods)
  const ClinicalConditionModel({
    required this.clinicalManifestation,
    required this.icd11Definition,
    required this.etiology,
    required this.pathophysiology,
    required this.manifestoMdVroch,
    required this.specificCharacteristics,
    required this.characterizationVroch,
    required this.redFlags,
    required this.differentialDiagnosis,
    required this.investigations,
    required this.managementProtocol,
  });
}

class ProfessionalDetailsModel {

  final String? speciality;
  final String? professionalLevel;



  ProfessionalDetailsModel({ this.professionalLevel,  this.speciality});


  factory ProfessionalDetailsModel.fromMap(Map<String, dynamic>  map) {
    return ProfessionalDetailsModel(professionalLevel: map['professionalLevel'] ?? "", 
    speciality: map['speicality'] ?? "");
  }


 Map<String, dynamic> toMap() {
  return {
    "professionalLevel" : professionalLevel ?? "", 
    'speicality' : speciality ?? ""
  };
  }


}
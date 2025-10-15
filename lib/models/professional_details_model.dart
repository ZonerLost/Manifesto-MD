class ProfessionalDetailsModel {

  final String? speciality;
  final String? professionalLevel;



  ProfessionalDetailsModel({ this.professionalLevel,  this.speciality});


  factory ProfessionalDetailsModel.fromMap(Map<String, dynamic>  map) {
    return ProfessionalDetailsModel(professionalLevel: map['professionalLevel'] ?? "", 
    speciality: map['speicality'] ?? "");
  }


  ProfessionalDetailsModel copyWith({
    String? speciality,
    String? professionalLev,
    
  }) {
    return ProfessionalDetailsModel(
     speciality:  speciality ?? this.speciality, 
     professionalLevel:  professionalLev ?? this.professionalLevel
    );
  }


 Map<String, dynamic> toMap() {
  return {
    "professionalLevel" : professionalLevel ?? "", 
    'speicality' : speciality ?? ""
  };
  }


}
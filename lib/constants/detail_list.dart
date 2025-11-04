import 'package:manifesto_md/models/deases_model.dart';

List<ClinicalConditionModel> listClincal = [

  // 1 — Fever
  ClinicalConditionModel(
    clinicalManifestation: "Fever",
    icd11Definition: "MG26",
    etiology: "Infection, inflammation, malignancy, drugs, autoimmune",
    pathophysiology: "Pyrogen-mediated hypothalamic reset",
    manifestoMdVroch: "High temp >38°C, chills, sweats, malaise",
    specificCharacteristics:
        "Oral Temp, Length, Onset, Pattern, PAF, PPS, IODL, ↑Weight",
    characterizationVroch: "High Temp, Pattern, PPS, IODL",
    redFlags: "Sepsis, meningitis, neutropenia",
    differentialDiagnosis: [
      "Infection",
      "Malignancy",
      "Autoimmune",
      "Drug & heat stroke"
    ],
    investigations: [
      "CBC (77–93)",
      "CRP (71)",
      "Blood culture (157)",
      "Urinalysis (106)"
    ],
    managementProtocol: [
      "Treat cause",
      "Antipyretics",
      "Fluids",
      "Hospitalize if unstable or red flags"
    ],
  ),

  // 2 — Fatigue
  ClinicalConditionModel(
    clinicalManifestation: "Fatigue",
    icd11Definition: "MG22",
    etiology: "Infection, anemia, chronic disease, sleep, endocrine, psychiatric",
    pathophysiology: "Multifactorial: metabolic, inflammatory, psychological",
    manifestoMdVroch: "Tiredness, low energy, poor motivation",
    specificCharacteristics:
        "Onset, Pattern, PAF, PPS, IODL, %Weight, ADLs, IADLs, SDZ-7ths, Pillow, SOAP, SFOA, SPANG, GADT, PHQ-9, Cognition, Hallucinations",
    characterizationVroch: "Onset, Pattern, PAF, PPS, IODL",
    redFlags: "Severe weakness, weight loss, night sweats",
    differentialDiagnosis: [
      "Infection",
      "Anemia",
      "Depression",
      "Endocrine"
    ],
    investigations: ["CBC (77–93)", "CRP (71)", "TSH (14)", "Glucose (2)"],
    managementProtocol: [
      "Treat cause",
      "Sleep hygiene",
      "Exercise",
      "Psychological support"
    ],
  ),

  // 3 — Unintentional Weight Loss
  ClinicalConditionModel(
    clinicalManifestation: "Unintentional weight loss",
    icd11Definition: "MG20.Y",
    etiology:
        "Endocrine (hyperthyroidism, diabetes), adrenal insufficiency, malignancy, infection, psychiatric, malabsorption",
    pathophysiology:
        "Catabolism, malabsorption, increased metabolic demand, hormonal imbalance",
    manifestoMdVroch:
        ">5% body weight loss in 6–12 months. Weight loss, muscle wasting, weakness",
    specificCharacteristics:
        "%Weight, Length, Onset, Pattern, PAF, PPS, IODL, Strength, BMI, MNA-SF, confusion, SARC-F",
    characterizationVroch:
        "%Weight, Length, Onset, Pattern, PAF, PPS, IODL, Strength",
    redFlags: "Rapid loss, night sweats, bleeding, confusion, severe dehydration",
    differentialDiagnosis: [
      "Hyperthyroidism",
      "Diabetes",
      "Malignancy",
      "Infection",
      "Psychiatric / Malabsorption"
    ],
    investigations: [
      "CBC (77–93)",
      "CRP (71)",
      "TSH (14)",
      "Glucose (2)",
      "Stool studies (168–173)"
    ],
    managementProtocol: [
      "Treat cause",
      "Nutrition support",
      "Hormone therapy",
      "Monitor",
      "Refer if red flags"
    ],
  ),

  // 4 — Weight Gain (Unintentional)
  ClinicalConditionModel(
    clinicalManifestation: "Weight Gain (Unintentional)",
    icd11Definition: "MG43.2",
    etiology:
        "Endocrine (hypothyroidism, PCOS), renal failure, drugs, psychiatric",
    pathophysiology: "Fluid retention, fat accumulation, metabolic",
    manifestoMdVroch:
        ">5% body weight gain in 6–12 months. Edema, rapid weight gain, fatigue",
    specificCharacteristics:
        "%Weight, Weight, Length, Onset, Pattern, PAF, PPS",
    characterizationVroch: "%Weight, Length, PAF, PPS, IODL",
    redFlags: "Rapid gain, dyspnea, edema",
    differentialDiagnosis: [
      "Heart failure",
      "Renal disease",
      "Endocrine",
      "Drugs",
      "Cushing"
    ],
    investigations: [
      "CBC (77–93)",
      "TSH (14)",
      "BNP (113)",
      "LFTs (107–111)"
    ],
    managementProtocol: [
      "Treat cause",
      "Diuretics if indicated",
      "Monitor",
      "Hospitalize if severe"
    ],
  ),

  // 5 — Night Sweats
  ClinicalConditionModel(
    clinicalManifestation: "Night Sweats",
    icd11Definition: "MG25.4",
    etiology: "Endocrine, infection, malignancy, menopause, drugs",
    pathophysiology: "Autonomic dysregulation, cytokines",
    manifestoMdVroch:
        "Night sweats, sleep disturbance, fever, weight loss",
    specificCharacteristics: "Length, Onset, Pattern, PAF, PPS, IODL, Rate, %Weight",
    characterizationVroch: "Length, Onset, Pattern, PAF, PPS",
    redFlags: "Fever, weight loss, lymphadenopathy",
    differentialDiagnosis: [
      "Infection",
      "TB",
      "Endocarditis",
      "Hyperthyroid",
      "HIV",
      "Drug"
    ],
    investigations: [
      "CBC (77–93)",
      "CRP (71)",
      "ESR (121)",
      "TSH (14)",
      "LFTs (107–111)"
    ],
    managementProtocol: [
      "Treat cause",
      "Antipyretics",
      "Fluids",
      "Hospitalize if unstable"
    ],
  ),

  // 6 — Chills / Rigors
  ClinicalConditionModel(
    clinicalManifestation: "Chills/Rigors",
    icd11Definition: "MG25.1",
    etiology: "Infection, bacteremia, transfusion, drugs",
    pathophysiology: "Cytokine release, pyrogenic response",
    manifestoMdVroch: "Shivering, fever, malaise",
    specificCharacteristics: "Length, Onset, Pattern, PAF, PPS, %Weight",
    characterizationVroch: "Length, Onset, PAF, PPS",
    redFlags: "Sepsis, shock, endocarditis",
    differentialDiagnosis: [
      "Bacteremia",
      "Malignancy",
      "Drug reaction",
      "Autoimmune"
    ],
    investigations: [
      "CBC (77–93)",
      "Blood culture (157)",
      "Urinalysis (166)",
      "LFTs (107–111)"
    ],
    managementProtocol: [
      "Oxygen",
      "Airway support",
      "Monitor/ICU"
    ],
  ),

  // 7 — Malaise
  ClinicalConditionModel(
    clinicalManifestation: "Malaise",
    icd11Definition: "MG21",
    etiology: "Infection, inflammation, psychiatric",
    pathophysiology: "Systemic inflammation, cytokines",
    manifestoMdVroch: "General feeling of unwellness, fatigue",
    specificCharacteristics: "Length, Onset, Pattern, PAF, PPS, IODL, PHQ-9",
    characterizationVroch: "Length, Onset, Pattern, PAF, PPS",
    redFlags: "Severe fatigue, rapid decline",
    differentialDiagnosis: [
      "Infection",
      "Malignancy",
      "Endocrine",
      "Autoimmune"
    ],
    investigations: [
      "CBC (77–93)",
      "CRP (71)",
      "LFTs (107–111)",
      "TSH (14)"
    ],
    managementProtocol: [
      "Treat cause",
      "Supportive care",
      "Monitor",
      "Refer if severe"
    ],
  ),

  // 8 — Anorexia / Loss of Appetite
  ClinicalConditionModel(
    clinicalManifestation: "Anorexia (Loss of Appetite)",
    icd11Definition: "MG43.7",
    etiology: "Infection, malignancy, GI disease, depression",
    pathophysiology: "Cytokine-mediated, GI dysfunction",
    manifestoMdVroch: "Poor appetite, weight loss, fatigue",
    specificCharacteristics: "Length, Onset, Pattern, PAF, PPS, IODL, %Weight, BMI, PHQ-9",
    characterizationVroch: "Length, Pattern, PAF, PPS",
    redFlags: "Rapid weight loss, dehydration, cachexia",
    differentialDiagnosis: [
      "Infection",
      "Malignancy",
      "Depression",
      "GI disease"
    ],
    investigations: [
      "CBC (77–93)",
      "CRP (71)",
      "TSH (14)",
      "Stool studies (168–173)"
    ],
    managementProtocol: [
      "Treat cause",
      "Nutrition support",
      "Appetite stimulants if indicated"
    ],
  ),

  // 9 — Generalized Weakness
  ClinicalConditionModel(
    clinicalManifestation: "Generalized Weakness",
    icd11Definition: "MG23",
    etiology: "Infection, anemia, neuromuscular, endocrine, cardiac",
    pathophysiology: "Metabolic, neuromuscular, inflammatory",
    manifestoMdVroch:
        "Weakness, fatigue, difficulty with ADLs",
    specificCharacteristics:
        "Location, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Location, Length, Pattern, PAF, PPS",
    redFlags: "Rapid progression, respiratory distress",
    differentialDiagnosis: [
      "Electrolyte abnormalities",
      "Anemia",
      "Stroke",
      "Neuromuscular disease"
    ],
    investigations: [
      "CBC (77–93)",
      "Electrolytes (96–100)",
      "TSH (14)",
      "LFTs (107–111)"
    ],
    managementProtocol: [
      "Treat cause",
      "PT/OT",
      "Monitor",
      "Hospitalize if severe"
    ],
  ),

  // 10 — Lymphadenopathy (Generalized)
  ClinicalConditionModel(
    clinicalManifestation: "Lymphadenopathy (Generalized)",
    icd11Definition: "EC20.1",
    etiology: "Infection, malignancy, autoimmune, drugs",
    pathophysiology: "Immune activation, metastatic infiltration",
    manifestoMdVroch:
        "Swollen nodes, fever, night sweats, weight loss",
    specificCharacteristics:
        "Location, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Location, Length, PAF, PPS, IODL",
    redFlags: "Rapid growth, hard/fixed nodes, B symptoms",
    differentialDiagnosis: [
      "Infection",
      "Lymphoma",
      "Leukemia",
      "HIV"
    ],
    investigations: [
      "CBC (77–93)",
      "LFTs (107–111)",
      "HIV (162)",
      "Biopsy/ECMW if suspicious"
    ],
    managementProtocol: [
      "Treat cause",
      "Biopsy if suspicious",
      "Monitor",
      "Refer if red flags"
    ],
  ),

  // 11 — Generalized Edema (Anasarca)
  ClinicalConditionModel(
    clinicalManifestation: "Generalized Edema (Anasarca)",
    icd11Definition: "MG29.1",
    etiology:
        "Heart failure, renal failure, hepatic failure, protein loss, drugs",
    pathophysiology:
        "Increased hydrostatic pressure, low oncotic pressure, capillary leak",
    manifestoMdVroch:
        "Swelling, weight gain, pitting edema",
    specificCharacteristics:
        "Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Length, Onset, Pattern, PAF, PPS",
    redFlags:
        "Dyspnea, rapid progression, organ failure",
    differentialDiagnosis: [
      "Heart failure",
      "Renal failure",
      "Hepatic failure",
      "Hypothyroid",
      "Allergy"
    ],
    investigations: [
      "CBC (77–93)",
      "Renal function (101–103)",
      "Albumin (104)",
      "TSH (14)"
    ],
    managementProtocol: [
      "Treat cause",
      "Diuretics",
      "Monitor",
      "Hospitalize if severe"
    ],
  ),

  // 12 — Pallor
  ClinicalConditionModel(
    clinicalManifestation: "Pallor",
    icd11Definition: "EEB00",
    etiology: "Anemia, shock, vasoconstriction, chronic disease",
    pathophysiology: "Reduced hemoglobin or blood flow",
    manifestoMdVroch: "Pale skin, mucosa, nail beds",
    specificCharacteristics:
        "Surface color, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Surface Color, Length, Onset, Pattern, PAF",
    redFlags: "Syncope, hypotension, tachycardia",
    differentialDiagnosis: [
      "Anemia",
      "Shock",
      "Vasoconstriction",
      "Chronic disease"
    ],
    investigations: [
      "CBC (77–93)",
      "Iron studies (146–150)",
      "LFTs (107–111)",
      "TSH (14)"
    ],
    managementProtocol: [
      "Treat cause",
      "Transfusion if severe",
      "Monitor/ICU"
    ],
  ),

  // 13 — Cyanosis
  ClinicalConditionModel(
    clinicalManifestation: "Cyanosis",
    icd11Definition: "EG02.Z",
    etiology:
        "Cardiac, pulmonary, vascular, hemoglobinopathy",
    pathophysiology: "Reduced oxygen saturation",
    manifestoMdVroch: "Blue lips, nail beds, extremities",
    specificCharacteristics: "Surface Color, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Surface Color, Length, PAF",
    redFlags: "Respiratory distress, altered mental status",
    differentialDiagnosis: [
      "Hypoxemia",
      "Heart failure",
      "Pulmonary disease",
      "Shock"
    ],
    investigations: [
      "Pulse oxymetry",
      "ABG (99)",
      "CBC (77–93)",
      "EKG"
    ],
    managementProtocol: [
      "Oxygen",
      "Airway support",
      "Hospitalize"
    ],
  ),

  // 14 — Flushing
  ClinicalConditionModel(
    clinicalManifestation: "Flushing",
    icd11Definition: "MG27.0",
    etiology: "Menopause, carcinoid, drugs, fever, emotion",
    pathophysiology: "Vasodilation, neuroendocrine",
    manifestoMdVroch:
        "Red, warm skin, sweating, palpitations",
    specificCharacteristics:
        "Length, Onset, Pattern, PAF, PPS, IODL, GADT",
    characterizationVroch:
        "Length, Onset, Pattern, PAF, PPS",
    redFlags: "Associated hypotension, diarrhea, wheeze",
    differentialDiagnosis: [
      "Menopause",
      "Carcinoid",
      "Drugs",
      "Anxiety"
    ],
    investigations: [
      "H/H (33)",
      "TSH (14)",
      "LFTs (107–111)"
    ],
    managementProtocol: [
      "Avoid triggers",
      "Treat cause",
      "Symptomatic therapy",
      "Refer if endocrine suspected"
    ],
  ),

  // 15 — Dehydration
  ClinicalConditionModel(
    clinicalManifestation: "Dehydration",
    icd11Definition: "SC70.0",
    etiology: "GI loss, renal, fever, poor intake",
    pathophysiology: "Volume depletion, hypovolemia",
    manifestoMdVroch: "Dry mucosa, low skin turgor, tachycardia, hypotension",
    specificCharacteristics:
        "Dehydration, Length, Onset, Pattern, PAF, PPS, IODL, %Weight, BMI, BP, I/O, urine, confusion",
    characterizationVroch:
        "Length, Onset, Pattern, PPS, IODL",
    redFlags: "Shock, altered mental status",
    differentialDiagnosis: [
      "Dehydration",
      "Electrolyte imbalance",
      "Renal failure",
      "Shock"
    ],
    investigations: [
      "CBC (77–93)",
      "Electrolytes (96–100)",
      "Renal function (101–103)",
      "Urinalysis (106)"
    ],
    managementProtocol: [
      "Oral/IV fluids",
      "Monitor electrolytes",
      "Treat cause"
    ],
  ),

  // 16 — Polyuria
  ClinicalConditionModel(
    clinicalManifestation: "Polyuria",
    icd11Definition: "MG44.2",
    etiology: "Diabetes, diuretics, hypercalcemia, DI, psychogenic",
    pathophysiology: "Osmotic diuresis, ADH dysfunction",
    manifestoMdVroch:
        "Excessive urine output (>3L/day adults)",
    specificCharacteristics:
        "%Weight, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Volume, Rate, Location, Pattern, PAF",
    redFlags: "Dehydration, electrolyte imbalance",
    differentialDiagnosis: [
      "Diabetes mellitus",
      "Diabetes insipidus",
      "Psychogenic polydipsia"
    ],
    investigations: [
      "CBC (77–93)",
      "Glucose (2)",
      "Electrolytes (96–100)",
      "Calcium (95)",
      "Urinalysis (166)"
    ],
    managementProtocol: [
      "Treat cause",
      "Fluid/electrolyte management",
      "Endocrine referral if needed"
    ],
  ),

  // 17 — Polydipsia
  ClinicalConditionModel(
    clinicalManifestation: "Polydipsia",
    icd11Definition: "MG44.3",
    etiology: "Diabetes, dry mouth, drugs, psychogenic",
    pathophysiology: "Osmotic diuresis, ADH dysfunction",
    manifestoMdVroch: "Excessive thirst/fluid intake",
    specificCharacteristics:
        "Volume, %Weight, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch: "Volume, %Weight, Length",
    redFlags: "Hyponatremia, water intoxication",
    differentialDiagnosis: [
      "Diabetes mellitus",
      "Psychogenic polydipsia",
      "Hyperthyroidism"
    ],
    investigations: [
      "CBC (77–93)",
      "Glucose (2)",
      "Electrolytes (96–100)",
      "Calcium (95)"
    ],
    managementProtocol: [
      "Treat cause",
      "Monitor electrolytes"
    ],
  ),

  // 18 — Polyphagia
  ClinicalConditionModel(
    clinicalManifestation: "Polyphagia",
    icd11Definition: "MG43.5",
    etiology: "Diabetes, hyperthyroid, psychiatric",
    pathophysiology:
        "Increased metabolic demand, hypothalamic dysfunction",
    manifestoMdVroch: "Increased hunger/increased food intake",
    specificCharacteristics:
        "Rate, %Weight, Length, Onset, Pattern, PAF, PPS, IODL",
    characterizationVroch:
        "Rate, %Weight, Length, Pattern, PAF",
    redFlags: "Rapid weight gain",
    differentialDiagnosis: [
      "Diabetes",
      "Hyperthyroid",
      "Psychogenic eating disorder"
    ],
    investigations: ["CBC (77–93)", "Glucose (2)", "TSH (14)"],
    managementProtocol: [
      "Treat cause",
      "Dietary counseling",
      "Endocrine referral if needed"
    ],
  ),

  // 19 — Sweating (Generalized / Excessive)
  ClinicalConditionModel(
    clinicalManifestation: "Sweating (Generalized/Excessive)",
    icd11Definition: "MG25.3",
    etiology: "Fever, hyperthyroid, menopause, anxiety, infection",
    pathophysiology: "Sympathetic overactivity, metabolic",
    manifestoMdVroch: "Excessive sweating, clammy skin, odor",
    specificCharacteristics:
        "Rate, Length, Pattern, PAF, PPS, IODL, GADT",
    characterizationVroch:
        "Rate, Length, Pattern, PAF",
    redFlags: "Dehydration, electrolyte imbalance",
    differentialDiagnosis: [
      "Endocrine",
      "Infection",
      "Drugs",
      "Hypoglycemia"
    ],
    investigations: [
      "CBC (77–93)",
      "TSH (14)",
      "Glucose (2)"
    ],
    managementProtocol: [
      "Treat cause",
      "Antiperspirants",
      "Medications if severe"
    ],
  ),

  // 20 — Heat Intolerance
  ClinicalConditionModel(
    clinicalManifestation: "Heat Intolerance",
    icd11Definition: "MG24.0",
    etiology: "Hyperthyroid, menopause, autonomic dysfunction",
    pathophysiology: "Altered thermoregulation",
    manifestoMdVroch: "Discomfort in heat, excessive sweating",
    specificCharacteristics:
        "Oral Temp, PAF, PFS, Length, Onset",
    characterizationVroch: "Oral Temp, PAF, PFS",
    redFlags: "Syncope, confusion, collapse",
    differentialDiagnosis: [
      "Thyroid disease",
      "Menopause",
      "Cardiac arrhythmia"
    ],
    investigations: [
      "TSH (14)",
      "CBC (77–93)"
    ],
    managementProtocol: [
      "Treat cause",
      "Environmental control"
    ],
  ),

  // 21 — Cold Intolerance
  ClinicalConditionModel(
    clinicalManifestation: "Cold Intolerance",
    icd11Definition: "MG24.1",
    etiology: "Hypothyroid, anemia, autonomic dysfunction",
    pathophysiology: "Altered thermoregulation",
    manifestoMdVroch: "Discomfort in cold, shivering, cold extremities",
    specificCharacteristics:
        "Surface Color, PAF, PPS, IODL, confusion",
    characterizationVroch: "Surface Color, PPS",
    redFlags: "Syncope, confusion, collapse",
    differentialDiagnosis: [
      "Hypothyroid",
      "Anemia",
      "Autonomic disorder"
    ],
    investigations: [
      "TSH (14)",
      "CBC (77–93)"
    ],
    managementProtocol: [
      "Treat cause",
      "Monitor temperature"
    ],
  ),
];

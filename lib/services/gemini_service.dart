import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  Future<List<Map<String, dynamic>>> getDiagnosesFromSymptoms(List<String> symptoms) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyANmrhbl15VDxQu1g1hS-8hjYOuc1gTesg',
      );

      final prompt = TextPart('''
You are a professional clinical decision support AI.

Analyze the following patient symptoms and return **detailed diagnostic reports** in **pure JSON format** (no markdown, no explanations, no ```json).

---

### JSON Format Example:
[
  {
    "title": "Gastric Ulcer / Peptic Ulcer",
    "description": "Erosion of the stomach lining often due to Helicobacter pylori infection or NSAID use.",
    "redFlagAlert": "Vomiting blood, black stools, sudden severe abdominal pain (possible perforation).",
    "suggestedActions": [
      "Urgent endoscopy for confirmation and treatment",
      "Hospital admission for IV fluids, proton pump inhibitors (PPI)",
      "Blood transfusion if anemia or shock",
      "Avoid NSAIDs and alcohol"
    ],
    "totalSteps": 4,
    "currentStep": 1,
    "detailedSteps": [
      {
        "stepNumber": 1,
        "title": "Initial Assessment",
        "details": "Assess for history of NSAID use, H. pylori symptoms, and GI bleeding."
      },
      {
        "stepNumber": 2,
        "title": "Diagnostic Testing",
        "details": "Perform upper endoscopy, test for H. pylori (urea breath test, biopsy)."
      },
      {
        "stepNumber": 3,
        "title": "Management",
        "details": "Start PPIs, eradicate H. pylori if positive, stop causative drugs."
      },
      {
        "stepNumber": 4,
        "title": "Follow-up",
        "details": "Reassess symptoms after 4–8 weeks and repeat endoscopy if needed."
      }
    ],
    "severityLevel": "Moderate",
    "confidenceLevel": "High"
  }
]

---

### Instructions:
- Return ONLY a JSON array.
- Each diagnosis must include **title, description, redFlagAlert, suggestedActions, totalSteps, currentStep, detailedSteps, severityLevel, and confidenceLevel**.
- Make each report clear, structured, and medically reasoned.
- Use currentStep = 1 always at start.

Now analyze these symptoms:
${symptoms.join(', ')}
''');

      final response = await model.generateContent([Content.text(prompt.text)]);
      var text = response.text ?? '';

      // 🧹 Clean unwanted markdown fences or code formatting
      text = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final decoded = jsonDecode(text);

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        print('Unexpected format: $decoded');
        return [];
      }
    } catch (e, st) {
      print('Error: $e');
      print(st);
      return [];
    }
  }
}

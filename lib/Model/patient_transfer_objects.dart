/// Data transfer object for patient registration form data.
/// hostUserId is NOT included here — it is injected by PatientService from LoginService.
class PatientRegistrationData {
  final String name; // max 100 chars
  final int age; // 0–150
  final String gender;
  final String phone; // max 20 chars, optional
  final String email; // max 100 chars, optional
  final String
      condition; // clinical condition, e.g. "None", "Cervical Radiculopathy"
  final String notes; // max 500 chars, optional

  // Clinical fields (mirroring sign-up)
  final String? dob; // ISO date string e.g. "1996-04-15"
  final String? dominantHand; // "Left" | "Right"
  final int? height; // cm
  final int? weight; // kg
  final double? palmLength; // cm
  final double? palmWidth; // cm
  final double? knuckleLength; // cm

  const PatientRegistrationData({
    required this.name,
    required this.age,
    required this.gender,
    this.phone = '',
    this.email = '',
    this.condition = 'None',
    this.notes = '',
    this.dob,
    this.dominantHand,
    this.height,
    this.weight,
    this.palmLength,
    this.palmWidth,
    this.knuckleLength,
  });
}

/// Data transfer object for saving a patient reading to the new Supabase project.
class PatientReadingData {
  final String patientId; // UUID from research_patients
  final String hostUserId; // from LoginService.getUserId()
  final String trial1;
  final String trial2;
  final String trial3;
  final String hand;
  final String posture;
  final String assessmentType;
  final DateTime createdAt;

  const PatientReadingData({
    required this.patientId,
    required this.hostUserId,
    required this.trial1,
    required this.trial2,
    required this.trial3,
    required this.hand,
    required this.posture,
    required this.assessmentType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'host_user_id': hostUserId,
        'trial1': double.tryParse(trial1) ?? 0.0,
        'trial2': double.tryParse(trial2) ?? 0.0,
        'trial3': double.tryParse(trial3) ?? 0.0,
        'hand': hand,
        'posture': posture,
        'assessment_type': assessmentType,
        'created_at': createdAt.toIso8601String(),
      };
}

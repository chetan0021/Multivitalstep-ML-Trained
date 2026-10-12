# VitalStep — Full Integration Reference Report

---

## 1. ML Model Integration

### Endpoint
```
POST https://vitalstep.onrender.com/api/v1/ml/predict
GET  https://vitalstep.onrender.com/api/v1/ml/health
```

### When It's Called
- After every test result is fetched (Test Result screen opens)
- When home screen loads and has 2+ test records
- When Compare screen opens

### Request Payload (JSON)
```json
{
  "trial1": 5.5,
  "trial2": 6.0,
  "trial3": 5.5,
  "hand": "right",
  "posture": "sitting",
  "age": 75,
  "gender": "Male",
  "height": 170,
  "weight": 70,
  "bmi": 24.2,
  "dominant_hand": "right",
  "palm_length": 18.0,
  "palm_width": 8.5,
  "knuckle_length": 15.0
}
```

**Required fields:** `trial1`, `trial2`, `trial3`, `hand`, `posture`  
**Optional but improve accuracy:** `age`, `gender`, `height`, `weight`, `bmi`, `dominant_hand`, `palm_length`, `palm_width`, `knuckle_length`

### Response Payload (JSON)
```json
{
  "average": 5.67,
  "predicted_category": "high",
  "confidence": 0.51,
  "percentile": 97.0,
  "expected_lower_kg": 3.51,
  "expected_median_kg": 4.06,
  "expected_upper_kg": 5.49,
  "recommendations": [
    "Palm Press flag: high (Mild High). Your average result is 5.7 kg.",
    "Nutrition: Anti-inflammatory foods: fish twice weekly, turmeric, green tea, vegetables.",
    "Movement: Check grip on mouse/phone/wheel — aim for about half the force.",
    "Daily habits: Drink water regularly through the day and rest well — 6–8 glasses, 7–8 hours sleep."
  ],
  "model_version": "latest",
  "model_source": "latest_model",
  "fallback_reason": ""
}
```

### How ML Data is Used in the App
| Field | Used For |
|---|---|
| `predicted_category` | Shown as badge on Test Result screen |
| `percentile` | Shown as badge on Test Result screen |
| `recommendations` | Shown as "AI Recommended Guidance" cards (Nutrition, Movement, Daily Habits) |
| `average` | Used in Groq prompt for narrative generation |
| `expected_lower/median/upper_kg` | Age-based benchmark context |

### Caching
- The ML result is cached using a fingerprint of: `trial1 + trial2 + trial3 + hand + posture + age + gender + dominantHand + condition`
- Groq is only called if the fingerprint changes (new data or different patient)
- Cache stored in `GetStorage` — persists across app restarts

---

## 2. Groq AI Integration

### Endpoint
```
POST https://api.groq.com/openai/v1/chat/completions
```

### API Key
```
Bearer YOUR_GROQ_API_KEY
```

### Model Used
```
llama-3.3-70b-versatile
```

### When It's Called
Groq is called AFTER the ML model responds. The ML output feeds INTO Groq.  
Groq is NOT called if the data fingerprint matches the cache.

### System Prompt
```
You are a friendly health assistant for a grip strength app.
Speak directly to the patient in simple, warm, everyday language.
Never use technical terms like "ML model", "percentile", "confidence score",
"bilateral", "clinical", or any medical jargon.
Be encouraging, brief, and clear. Write like a supportive coach.
```

### Request Structure (JSON)
```json
{
  "model": "llama-3.3-70b-versatile",
  "messages": [
    { "role": "system", "content": "...system prompt above..." },
    { "role": "user", "content": "...context prompt below..." }
  ],
  "max_tokens": 200,
  "temperature": 0.4
}
```

### Context Prompts Sent to Groq

#### Test Result Insight
```
A patient just tested their Right hand grip strength while sitting.
Their average grip was 5.7 kg, which is considered high.
The patient is 75 years old.
Write 2 friendly sentences telling them what this result means and one simple tip.
No jargon, no technical terms, speak directly to them as "you".
```

#### Home Screen Insight
```
A patient's grip strength has gotten stronger recently.
Their latest reading is 5.7 kg, previous was 4.5 kg.
Their current level is high.
Write one short, warm sentence (under 20 words) for their home screen.
No jargon. Be encouraging. Speak as "your".
```

#### Compare Screen Insight
```
A patient compared their two hands.
Left hand: 4.2 kg, Right hand: 5.7 kg.
Their dominant hand is the Right hand.
The difference is about 30%.
Write 2-3 friendly sentences explaining what this means.
If there is a clear difference, gently suggest they work on their left hand.
Keep it simple and encouraging, speak as "you".
```

### Where Groq Output Appears in the App

| Screen | Section | What Groq Generates |
|---|---|---|
| **Home Screen** | "Health Insight" card | Short warm sentence about trend |
| **Test Result Screen** | "AI Performance Insight" section | 2-sentence insight about the test |
| **Compare Screen** | "What this means for you" section | 2-3 sentence bilateral comparison insight |

---

## 3. HubSpot Integration

### Endpoint
```
POST https://vitalstep.onrender.com/api/v1/hubspot/sync/contact
GET  https://vitalstep.onrender.com/api/v1/hubspot/health
```

### When HubSpot Is Called

| Event | Trigger | What Gets Sent |
|---|---|---|
| **Patient Registered** | After `registerPatient()` succeeds in Supabase | Full registration data |
| **Test Completed** | After dual-write to Supabase in patient mode | Trial readings only |

### Trigger 1: Patient Registration Payload (JSON)
```json
{
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "patient_code": "PT-0152",
  "device_id": "host_user_uuid_from_login_service",
  "age": 45,
  "gender": "Male",
  "dominant_hand": "Right",
  "condition": "None",
  "dob": "1979-04-15"
}
```

**Source of each field:**
| Field | Source |
|---|---|
| `name` | Patient registration form |
| `phone` | Patient registration form |
| `email` | Patient registration form |
| `patient_code` | Auto-generated (PT-XXXX) by PatientService |
| `device_id` | `LoginService.getUserId()` — the host's login ID |
| `age` | Patient registration form |
| `gender` | Patient registration form (required) |
| `dominant_hand` | Patient registration form (Hand Specifications section) |
| `condition` | Patient registration form dropdown |
| `dob` | Patient registration form (optional) |

### Trigger 2: Test Reading Payload (JSON)
```json
{
  "name": "John Doe",
  "phone": "+919876543210",
  "email": "john@example.com",
  "patient_code": "PT-0152",
  "trial1": 5.09,
  "trial2": 4.85,
  "trial3": 4.69,
  "average_trial": 4.88,
  "posture": "sitting",
  "hand": "Right",
  "test_date": "2025-01-15T10:30:00.000Z",
  "right_trial_1": 5.09,
  "right_trial_2": 4.85,
  "right_trial_3": 4.69,
  "right_avg": 4.88
}
```

For Left hand:
```json
{
  "left_trial_1": 4.2,
  "left_trial_2": 4.5,
  "left_trial_3": 4.1,
  "left_avg": 4.27
}
```

### HubSpot Response
```json
{
  "status": "created",
  "hubspot_id": "530778158840",
  "message": "Contact created successfully",
  "phone_normalized": "+919876543210"
}
```

Status can be `"created"` (new contact) or `"merged"` (existing contact updated).

### HubSpot Custom Properties Set
```
patient_code, device_id, age, gender, condition, dominant_hand, dob,
test_date, posture, hand,
left_trial_1, left_trial_2, left_trial_3, left_avg,
right_trial_1, right_trial_2, right_trial_3, right_avg,
trial1, trial2, trial3, average_trial
```

---

## 4. Data From Google Form (Coming Externally)

The Google Form collects post-session feedback and clinical details that the app does NOT collect. These fields come into HubSpot from the Google Form integration directly:

| Field | Column in HubSpot |
|---|---|
| Any medical conditions affecting arm/hand | `Any medical conditions affect...` |
| Did you feel fatigue or discomfort | `Did you feel any fatigue or discomf...` |
| How easy was the device to use | `Overall, How easy was the device t...` |
| How clear was the app display | `How clear was the app's display of...` |
| Did you experience bugs or lag | `Did you experience any bugs, lag o...` |
| Overall satisfaction | `Overall, how satisfied are you with...` |
| Overall experience rating | `Rate your overall experience` |
| Additional comments | `Any other comments` |

**These fields remain as `--` in HubSpot until the patient fills the Google Form.** The app does not send these — they come from the form pipeline.

---

## 5. App Screen Map — Where AI/Data Appears

### Screen 1: Home Screen (`home_tab`)
- **Health Insight card** → Groq-generated sentence about grip strength trend
- Shows loading spinner while Groq fetches
- Falls back to rule-based text if Groq unavailable

### Screen 2: Test Result Screen (`test_result`)
- **"AI Performance Insight"** → Groq narrative (2 sentences)
- **ML Category badge** → e.g. "high", "average"
- **Percentile badge** → e.g. "97th percentile"
- **"AI Recommended Guidance"** → ML recommendations shown as cards:
  - 🍴 Nutrition (green)
  - 💪 Movement (blue)
  - 🧘 Daily Habits (purple)
  - ✅ General tips (green checkmark)
- Shows loading spinner while ML + Groq fetch

### Screen 3: Compare Screen (`compare`)
- **"What this means for you"** card → Groq-generated bilateral comparison narrative
- **"AI Recommended Actions"** list → ML recommendations for dominant hand

### Screen 4: Patient Registration (`patient_registration`)
- On submit → triggers `POST /api/v1/hubspot/sync/contact` (non-blocking)
- Fields sent: name, phone, email, patient_code, device_id, age, gender, dominant_hand, condition, dob

---

## 6. Full Data Flow Diagram

```
USER REGISTERS PATIENT
        │
        ▼
PatientRegistrationForm
(name, phone, email, age, gender,
 dominant_hand, condition, dob)
        │
        ▼
PatientService.registerPatient()
        │
        ├──► Supabase research_patients (insert)
        │         Returns: ResearchPatient with patientCode
        │
        └──► HubSpot sync (non-blocking)
                  POST /api/v1/hubspot/sync/contact
                  with all registration fields + device_id


USER TAKES TEST
        │
        ▼
Test saved to Digital Ocean backend
        │
        ▼ (if Patient Mode active)
TestResultViewModel._handleDualWrite()
        │
        ├──► Supabase patient_readings (insert)
        │
        └──► HubSpot sync (non-blocking)
                  POST /api/v1/hubspot/sync/contact
                  with trial readings + hand-specific fields


TEST RESULT SCREEN OPENS
        │
        ▼
AiService.getTestInsight()
        │
        ├──► ML Model (POST /api/v1/ml/predict)
        │         sends: trials + patient profile fields
        │         returns: category, percentile, recommendations
        │
        └──► Groq (POST api.groq.com/openai/v1/chat/completions)
                  sends: ML output + patient context
                  returns: friendly narrative paragraph
                  │
                  ▼
        TestResultView displays:
        - Groq narrative (AI Performance Insight)
        - ML category + percentile badges
        - ML recommendations (Nutrition/Movement/Daily Habits cards)
```

---

## 7. Important Notes

### Render Cold Start
The VitalStep backend on Render is on a free tier. It spins down after 15 minutes of inactivity. First request after idle takes **30-60 seconds**. The app uses a 30-second timeout to handle this.

### Caching Strategy
- Groq tokens are preserved by caching insights in `GetStorage`
- Cache key = fingerprint of data values
- Same patient, same readings = cache hit, zero Groq calls
- Different patient or new test = fresh Groq call

### Non-Blocking Design
All HubSpot syncs are fire-and-forget. If they fail, the app never shows an error — failures are logged silently. The patient registration and test flow is never interrupted by HubSpot.

### Patient Mode Requirement
- HubSpot test reading sync **only fires in Patient Mode** with an active patient selected
- In Host Mode, test readings do NOT sync to HubSpot (only registration does)

---

*Report generated: VitalStep Flutter App — Integration Reference*
*Last updated: Based on current codebase state*


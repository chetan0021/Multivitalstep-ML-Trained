# VitalStep — Formulas & Technical Reference Document

---

## 1. TRIAL AVERAGE (Core Formula — Used Everywhere)

Every test produces 3 trials. The average is the foundation of all calculations.

```
Average = (Trial1 + Trial2 + Trial3) / 3
```

**Example:** Trial1 = 25.5 kg, Trial2 = 26.0 kg, Trial3 = 24.8 kg
```
Average = (25.5 + 26.0 + 24.8) / 3 = 25.43 kg
```

---

## 2. HOME SCREEN (home_tab)

### 2.1 Left Hand Strength Display
Takes the most recent Left hand test and computes its average:
```
leftHandStrength = (Trial1 + Trial2 + Trial3) / 3
                   of the most recent Left hand test
```

### 2.2 Right Hand Strength Display
Same formula applied to the most recent Right hand test:
```
rightHandStrength = (Trial1 + Trial2 + Trial3) / 3
                    of the most recent Right hand test
```

### 2.3 Hand Symmetry Percentage (shown on home cards)
Compares both hands relative to the dominant hand (set during sign-up):

**If dominant hand is RIGHT:**
```
Right hand card = "100 %"
Left hand card  = (leftAverage / rightAverage) × 100 %
```

**If dominant hand is LEFT:**
```
Left hand card  = "100 %"
Right hand card = (rightAverage / leftAverage) × 100 %
```

**Example:** Right dominant, rightAvg = 28 kg, leftAvg = 22 kg
```
Left hand shows = (22 / 28) × 100 = 78.57 %
```

### 2.4 Symmetry Score for Health Insight Color
```
symmetry = min(left, right) / max(left, right)

symmetry > 0.9  → Green  (Excellent balance)
symmetry > 0.8  → Orange (Slight variance, monitor)
symmetry ≤ 0.8  → Red    (Significant asymmetry)
```

### 2.5 Health Streak
Counts consecutive days with at least one test:
```
- Sort tests by date descending
- Count days where consecutive tests are exactly 1 day apart
- Streak resets if gap > 1 day
```

### 2.6 Home Graph (Trend Sparkline)
Shows up to the last 10 tests per hand:
```
X-axis = test index (0 to 9)
Y-axis = average of that test = (T1 + T2 + T3) / 3
```

---

## 3. DASHBOARD SCREEN

### 3.1 Current Week Average
```
weekStart = Monday of current week (midnight)
currentWeekTests = all tests where createdAt > weekStart

leftCurrentWeek  = sum of averages of current week LEFT tests
                   ÷ count of current week LEFT tests

rightCurrentWeek = sum of averages of current week RIGHT tests
                   ÷ count of current week RIGHT tests

NOTE: If no tests this week → falls back to all-time average
      (so the value never shows 0.0)
```

### 3.2 Last Week Average
```
lastWeekStart = weekStart − 7 days

leftLastWeek  = sum of LEFT test averages in [lastWeekStart, weekStart)
                ÷ count

rightLastWeek = sum of RIGHT test averages in [lastWeekStart, weekStart)
                ÷ count

NOTE: Shows 0 if no tests last week
```

### 3.3 All-Time Average
```
leftAllTime  = sum of ALL Left test averages / total Left tests
rightAllTime = sum of ALL Right test averages / total Right tests
```

### 3.4 Peak Value
```
leftPeak  = maximum single trial value across ALL Left tests
rightPeak = maximum single trial value across ALL Right tests

peak(test) = max(Trial1, Trial2, Trial3)
```

### 3.5 Posture Breakdown
Groups tests by posture (e.g. "sitting", "standing") and computes average:
```
postureAverage[posture] = sum of averages of all tests with that posture
                          ÷ count of tests with that posture
```

### 3.6 Dashboard Trend Graph
Last 10 tests per hand:
```
X-axis = test index (0 to 9, oldest to newest)
Y-axis = (Trial1 + Trial2 + Trial3) / 3
Two lines: Left hand (blue) and Right hand (teal/green)
```

---

## 4. COMPARE SCREEN

### 4.1 Left and Right Overall Averages
Averages ALL historical tests (not just the latest):
```
leftAvg  = sum of averages of ALL Left tests / count of Left tests
rightAvg = sum of averages of ALL Right tests / count of Right tests
```

### 4.2 Peak Values
```
leftPeak  = max trial value across ALL Left test sessions
rightPeak = max trial value across ALL Right test sessions
```

### 4.3 Percentage Difference
```
diff        = |leftAvg − rightAvg|
mid         = (leftAvg + rightAvg) / 2
percentDiff = (diff / mid) × 100
```

**Example:** leftAvg = 20 kg, rightAvg = 26 kg
```
diff        = |20 − 26| = 6
mid         = (20 + 26) / 2 = 23
percentDiff = (6 / 23) × 100 = 26.1%
```

### 4.4 Balance Score
```
balanceScore = (100 − percentDiff), clamped to [0, 100]
```
- 100 = perfect symmetry
- Lower = more imbalance

### 4.5 Severity Classification
```
percentDiff ≤ 10% → "Balanced ✓"         (green)
percentDiff ≤ 20% → "Mild Imbalance"      (orange)
percentDiff ≤ 30% → "Moderate Imbalance"  (deep orange)
percentDiff  > 30% → "Significant Imbalance" (red)
```

### 4.6 Compare Trend Graph
Last 8 tests per hand:
```
X-axis = test index (0 to 7)
Y-axis = average of that test
Two lines: Left hand and Right hand side by side
```

---

## 5. TEST RESULT SCREEN

### 5.1 Peak Metric (Radar Chart)
```
peak = Trial1 of the latest test
       (first trial is typically the peak effort)
```

### 5.2 Consistency Metric (Radar Chart)
Measures how similar the 3 trials are. Higher = more consistent:
```
avg       = (T1 + T2 + T3) / 3
variation = (max(T1,T2,T3) − min(T1,T2,T3)) / avg
consistency = (1 − variation) × 50, clamped to [0, 50]
```
- Score of 50 = all 3 trials identical
- Score near 0 = very inconsistent

### 5.3 Symmetry Metric (Radar Chart)
Fetches both hands' latest tests and computes:
```
lAvg = (Left.T1 + Left.T2 + Left.T3) / 3
rAvg = (Right.T1 + Right.T2 + Right.T3) / 3
diff = |lAvg − rAvg|
symmetry = (1 − (diff / ((lAvg + rAvg) / 2))) × 50, clamped to [0, 50]
```
- Score of 50 = both hands exactly equal
- Score near 0 = very asymmetric

### 5.4 Age Calculation (for ML)
Age is derived from the date of birth stored in the profile:
```
age = current year − birth year
      (subtract 1 if birthday hasn't occurred yet this year)
```

---

## 6. ASSESSMENT HISTORY SCREEN

### 6.1 Test Average
```
average = (Trial1 + Trial2 + Trial3) / 3
```

### 6.2 Latest Average Difference (Left vs Right)
```
difference = leftLatestAverage − rightLatestAverage
(can be negative if right is stronger)
```

### 6.3 Chart Grouping by Period
Tests are grouped before plotting:

| Period | Grouping | Format |
|--------|----------|--------|
| Week   | By day   | "dd MMM" (e.g. "14 Jun") |
| Month  | By month | "MMM yy" (e.g. "Jun 25") |
| Year   | By year  | "yyyy" (e.g. "2025") |

Within each group, the average of all test averages is plotted:
```
groupAverage = sum of averages in the period group / count in group
```

---

## 7. ML MODEL (vitalstep.onrender.com)

### 7.1 What the App Sends
```json
{
  "trial1": 25.5,       ← required
  "trial2": 26.0,       ← required
  "trial3": 24.8,       ← required
  "hand": "right",      ← required (lowercased)
  "posture": "sitting", ← required
  "age": 45,            ← optional (improves accuracy)
  "weight": 70,         ← optional
  "height": 170,        ← optional
  "bmi": 24.2,          ← auto-calculated if weight+height present
  "gender": "Male",     ← optional
  "dominant_hand": "right", ← optional
  "palm_length": 18.0,  ← optional
  "palm_width": 8.5,    ← optional
  "knuckle_length": 15.0 ← optional
}
```

**BMI Formula (calculated in app before sending):**
```
BMI = weight(kg) / (height(m))²
    = weight / (height/100)²
```

### 7.2 What the ML Returns
```json
{
  "average": 25.43,
  "predicted_category": "high",   ← low / normal / high
  "confidence": 0.85,             ← 0.0 to 1.0
  "percentile": 78.0,             ← where patient ranks vs population
  "expected_lower_kg": 18.0,      ← age-based benchmark lower bound
  "expected_median_kg": 22.0,     ← age-based benchmark median
  "expected_upper_kg": 28.0,      ← age-based benchmark upper bound
  "recommendations": [
    "Movement: ...",
    "Daily habits: ...",
    "..."
  ],
  "model_source": "latest_model"
}
```

### 7.3 How Predictions Are Used in the App

| ML Field | Shown Where |
|---|---|
| `predicted_category` | Badge on Test Result screen (e.g. "high") |
| `percentile` | Badge on Test Result screen (e.g. "78th percentile") |
| `recommendations` | "AI Recommended Guidance" cards (Movement, Daily Habits) |
| `average` | Fed into Groq for narrative generation |
| `expected_lower/median/upper_kg` | Age-based benchmark reference |

### 7.4 ML Caching (Fingerprint)
To save API calls, results are cached by a fingerprint key:
```
fingerprint = trial1 | trial2 | trial3 | hand | posture 
              | age | gender | dominantHand | condition

If same fingerprint → use cached Groq narrative
                    → still call ML for fresh recommendations
If different fingerprint → call both ML and Groq fresh
```

---

## 8. GROQ AI (api.groq.com)

### 8.1 Model Used
```
llama-3.3-70b-versatile
max_tokens: 200
temperature: 0.4
```

### 8.2 When Groq Is Called
Groq is called AFTER the ML model responds. It converts ML output into a friendly sentence for the patient.

Groq is NOT called if:
- The data fingerprint matches the cache
- ML call failed or timed out

### 8.3 Prompts Sent to Groq

**Test Result Screen:**
```
A patient just tested their [hand] hand palm pressure while [posture].
Their average pressure was [X] kg, which is considered [level].
The patient is [age] years old. They have: [condition].
Write 2 friendly sentences telling them what this result means 
and one simple tip. No jargon, speak as "you".
```

**Home Screen:**
```
A patient's palm pressure has [gotten stronger / dropped / stayed steady].
Their latest reading is [X] kg, previous was [Y] kg.
Their current level is [level].
Write one short warm sentence (under 20 words). Speak as "your".
```

**Compare Screen:**
```
Left hand: [X] kg, Right hand: [Y] kg.
Dominant hand is [hand]. Difference is about [Z]%.
Write 2-3 friendly sentences. Suggest working on weaker hand if needed.
```

### 8.4 Groq Output Usage

| Screen | Section | Content |
|---|---|---|
| Home | "Health Insight" card | One warm sentence about trend |
| Test Result | "AI Performance Insight" | 2-sentence insight |
| Compare | "What this means for you" | 2-3 sentence bilateral comparison |

---

## 9. RULE-BASED FALLBACKS (when ML/Groq unavailable)

### 9.1 Trial Analysis Fallback
```
avg       = (T1 + T2 + T3) / 3
variation = (max − min) / avg

variation > 0.2  → "High variation detected (X%). Consider a re-test."
avg < 5          → "Low palm pressure measured. Regular exercise recommended."
else             → "Strong and consistent effort. Keep it up!"
```

### 9.2 Recovery Tips Fallback
```
avg < 20 kg → Light squeezing exercises, heat therapy
avg < 40 kg → Rubber band finger extensions, wrist curls
avg ≥ 40 kg → Maintenance sessions, advanced dexterity drills

variance > avg × 0.2 → "Focus on consistent, slow squeezes"
```

### 9.3 Health Nudge Fallback
```
recentAvg < prevAvg × 0.9  → "Noticeable drop. Consider rest or specialist."
recentAvg > prevAvg × 1.1  → "Great progress! Strength improving."
else                        → "Strength is stable. Consistency is key."
```

---

## 10. DATA FLOW SUMMARY

```
DEVICE (ESP32)
  → 3 trials measured via HX711 load cell
  → POST to Digital Ocean backend

FLUTTER APP
  → Fetches latest test from Digital Ocean
  → Computes average, peak, consistency, symmetry (local formulas)
  → Sends trial data + patient profile to ML model (Render)
  → ML returns: category, percentile, benchmarks, recommendations
  → ML output fed to Groq for friendly narrative
  → Results displayed on Test Result screen
  → If Patient Mode → also saved to Supabase patient_readings table
  → If Patient Mode → also synced to HubSpot CRM
```

---

*Document generated from source code analysis — VitalStep Flutter App*
*Last updated: Based on current codebase state*

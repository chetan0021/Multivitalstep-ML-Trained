import json
import urllib.request
import urllib.error

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

left_reading_payload = {
    "name": "VitalStep Clinic Patient",
    "phone": "+919876543211",
    "email": "clinicpatient@vitalstep.com",
    "patient_code": "PT-0155",
    "device_id": "supabase_host_user_uuid_102",
    "age": 42,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "Carpal Tunnel Syndrome",
    "dob": "1984-07-12",
    "trial1": 27.4,
    "trial2": 28.1,
    "trial3": 27.9,
    "average_trial": 27.80,
    "posture": "sitting",
    "hand": "Left",
    "test_date": "2026-08-08T11:37:00.000Z",
    "left_trial_1": 27.4,
    "left_trial_2": 28.1,
    "left_trial_3": 27.9,
    "left_avg": 27.80
}

headers = {"Content-Type": "application/json"}
body = json.dumps(left_reading_payload).encode("utf-8")
req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")

with urllib.request.urlopen(req, timeout=60) as response:
    res_body = response.read().decode("utf-8")
    print("FINAL LEFT HAND PUSH SUCCESS:", res_body)

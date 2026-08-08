import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post_payload(description, payload):
    print(f"\n==========================================================")
    print(f"Executing: {description}")
    print("==========================================================")
    print(f"Payload:\n{json.dumps(payload, indent=2)}")
    
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    
    start = time.time()
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            elapsed = time.time() - start
            res_body = response.read().decode("utf-8")
            res_json = json.loads(res_body)
            print(f"[SUCCESS 200] ({round(elapsed, 2)}s):\n{json.dumps(res_json, indent=2)}")
            return res_json
    except urllib.error.HTTPError as e:
        elapsed = time.time() - start
        err_text = e.read().decode("utf-8")
        print(f"[HTTP ERROR {e.code}] ({round(elapsed, 2)}s):\n{err_text}")
    except Exception as e:
        print(f"[EXCEPTION]: {e}")

# 1. Registration
registration_payload = {
    "name": "VitalStep Clinic Patient",
    "phone": "+919876543211",
    "email": "clinicpatient@vitalstep.com",
    "patient_code": "PT-0155",
    "device_id": "supabase_host_user_uuid_102",
    "age": 42,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "Carpal Tunnel Syndrome",
    "dob": "1984-07-12"
}

post_payload("Step 1: Patient Registration", registration_payload)

time.sleep(2)

# 2. Right Hand Reading
right_reading_payload = {
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
    "trial1": 31.2,
    "trial2": 32.5,
    "trial3": 31.8,
    "average_trial": 31.83,
    "posture": "sitting",
    "hand": "Right",
    "test_date": "2026-08-08T11:35:00.000Z",
    "right_trial_1": 31.2,
    "right_trial_2": 32.5,
    "right_trial_3": 31.8,
    "right_avg": 31.83
}

post_payload("Step 2: Right Hand Reading", right_reading_payload)

time.sleep(2)

# 3. Left Hand Reading
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

post_payload("Step 3: Left Hand Reading", left_reading_payload)

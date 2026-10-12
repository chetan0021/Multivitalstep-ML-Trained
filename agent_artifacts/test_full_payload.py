import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

full_payload = {
    "name": "VitalStep Complete Test Patient",
    "phone": "+919988776655",
    "email": "completetest@vitalstep.com",
    "patient_code": "PT-5555",
    "device_id": "supabase_host_user_uuid_999",
    "age": 50,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "Arthritis",
    "dob": "1974-08-20",
    "trial1": 33.5,
    "trial2": 34.0,
    "trial3": 33.8,
    "average_trial": 33.77,
    "posture": "sitting",
    "hand": "Right",
    "test_date": "2026-08-08T11:30:00.000Z",
    "right_trial_1": 33.5,
    "right_trial_2": 34.0,
    "right_trial_3": 33.8,
    "right_avg": 33.77
}

print("Pushing Combined Full Payload (Registration + Reading + device_id + gender + condition)...")
headers = {"Content-Type": "application/json"}
body = json.dumps(full_payload).encode("utf-8")
req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")

start = time.time()
try:
    with urllib.request.urlopen(req, timeout=60) as response:
        elapsed = time.time() - start
        res_body = response.read().decode("utf-8")
        res_json = json.loads(res_body)
        print(f"[SUCCESS {response.status}] ({round(elapsed, 2)}s):\n{json.dumps(res_json, indent=2)}")
except urllib.error.HTTPError as e:
    elapsed = time.time() - start
    print(f"[HTTP ERROR {e.code}] ({round(elapsed, 2)}s):\n{e.read().decode('utf-8')}")
except Exception as e:
    print(f"[ERROR]: {e}")

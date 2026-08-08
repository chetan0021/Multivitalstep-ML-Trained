import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post_payload(name, payload):
    print(f"\nPosting {name}...")
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            res_body = response.read().decode("utf-8")
            res_json = json.loads(res_body)
            print(f"[SUCCESS 200]: {json.dumps(res_json, indent=2)}")
            return res_json
    except urllib.error.HTTPError as e:
        res_body = e.read().decode("utf-8")
        print(f"[HTTP ERROR {e.code}]: {res_body}")
    except Exception as e:
        print(f"[EXCEPTION]: {e}")

# Registration Payload
reg_payload = {
    "name": "Live Test Patient",
    "phone": "+919999988888",
    "email": "livetestpatient@vitalstep.com",
    "patient_code": "PT-7777",
    "device_id": "device_live_test_001",
    "age": 45,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1981-03-25"
}

res1 = post_payload("Patient Registration", reg_payload)

time.sleep(2)

# Reading Payload Right Hand
reading_right = {
    "name": "Live Test Patient",
    "phone": "+919999988888",
    "email": "livetestpatient@vitalstep.com",
    "patient_code": "PT-7777",
    "trial1": 28.5,
    "trial2": 29.2,
    "trial3": 28.8,
    "average_trial": 28.83,
    "posture": "sitting",
    "hand": "Right",
    "test_date": "2026-08-08T11:08:00.000Z",
    "right_trial_1": 28.5,
    "right_trial_2": 29.2,
    "right_trial_3": 28.8,
    "right_avg": 28.83
}

res2 = post_payload("Right Hand Reading", reading_right)

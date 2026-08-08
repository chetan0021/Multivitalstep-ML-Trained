"""
Test UPDATE path: send the same email twice.
First call = CREATE, second call = UPDATE.
This isolates whether the backend's PATCH/update to HubSpot fails.
"""
import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def send(label, payload):
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            res_body = response.read().decode("utf-8")
            print(f"[OK 200] {label}: {res_body}")
            return True
    except urllib.error.HTTPError as e:
        err = e.read().decode('utf-8')
        print(f"[FAIL {e.code}] {label}: {err}")
        return False

ts = int(time.time())
fixed_email = f"update_test_{ts}@vitalstep-test.com"

payload_create = {
    "name": f"Update Test Patient {ts}",
    "email": fixed_email,
    "phone": "+919876543220",
    "patient_code": f"PT-UPD-{ts}",
}

payload_update = {
    "name": f"Update Test Patient {ts}",
    "email": fixed_email,
    "phone": "+919876543220",
    "patient_code": f"PT-UPD-{ts}",
    "device_id": "test-device-uuid-update",
    "age": 42,
    "gender": "Female",
    "dominant_hand": "Left",
    "condition": "Arthritis",
    "dob": "1983-05-20",
    "trial1": 22.1,
    "trial2": 23.4,
    "trial3": 21.9,
    "average_trial": 22.47,
    "posture": "Standing",
    "hand": "Left",
    "test_date": "2025-08-08T07:00:00Z",
    "left_trial_1": 22.1,
    "left_trial_2": 23.4,
    "left_trial_3": 21.9,
    "left_avg": 22.47,
}

print(f"Using fixed email: {fixed_email}")
print("\n=== CALL 1: CREATE ===")
send("CREATE (1st call)", payload_create)

time.sleep(3)

print("\n=== CALL 2: UPDATE (same email) ===")
send("UPDATE (2nd call)", payload_update)

print("\nDone.")

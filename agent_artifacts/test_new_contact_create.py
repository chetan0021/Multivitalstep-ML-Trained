"""
Test: create a completely NEW contact with all fields.
Uses a unique email so the backend creates (not updates) a fresh contact.
This isolates whether the failure is on CREATE vs UPDATE.
"""
import json
import urllib.request
import urllib.error
import time
import random

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

print("=== TEST A: Basic NEW contact (no extra fields) ===")
send("Basic CREATE", {
    "name": f"Test New Basic {ts}",
    "email": f"new_basic_{ts}@vitalstep-test.com",
    "phone": "+919876543210",
    "patient_code": f"PT-NEW-{ts}",
})

time.sleep(2)
ts2 = ts + 1

print("\n=== TEST B: Full NEW contact with ALL fields ===")
send("Full CREATE", {
    "name": f"Test New Full {ts2}",
    "email": f"new_full_{ts2}@vitalstep-test.com",
    "phone": "+919876543211",
    "patient_code": f"PT-FULL-{ts2}",
    "device_id": "test-device-uuid-123",
    "age": 35,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1990-01-15",
    "trial1": 28.5,
    "trial2": 30.2,
    "trial3": 27.8,
    "average_trial": 28.83,
    "posture": "Seated",
    "hand": "Right",
    "test_date": "2025-08-08T06:00:00Z",
    "right_trial_1": 28.5,
    "right_trial_2": 30.2,
    "right_trial_3": 27.8,
    "right_avg": 28.83,
})

print("\nDone.")

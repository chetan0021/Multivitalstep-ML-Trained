"""
Simulate the exact real-world app scenario:
1. A patient was registered earlier → contact exists in HubSpot
2. App sends a test reading → backend tries to UPDATE the same contact
3. Does it succeed?

Using phone +919876543210 which is confirmed to work (contact 528620003043).
"""
import json
import urllib.request
import urllib.error
import time

URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post(label, payload):
    body = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=body, headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            d = json.loads(r.read().decode())
            print(f"OK {label}: status={d.get('status')} id={d.get('hubspot_id')}")
            return d
    except urllib.error.HTTPError as e:
        print(f"FAIL {e.code} {label}:", e.read().decode())
        return None

now = time.strftime("%Y-%m-%dT%H:%M:%SZ")

# Simulate patient registration (first sync)
print("=== STEP 1: Patient registration sync ===")
post("Registration", {
    "name": "Live Test Patient",
    "phone": "+919876543210",
    "patient_code": "PT-0001",
    "device_id": "real-device-uuid-from-app",
    "age": 45,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1980-01-01",
})

time.sleep(3)

# Simulate test reading sync (second sync — same patient)
print("\n=== STEP 2: Test reading sync (UPDATE) ===")
post("Test Reading", {
    "name": "Live Test Patient",
    "phone": "+919876543210",
    "patient_code": "PT-0001",
    "device_id": "real-device-uuid-from-app",
    "age": 45,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1980-01-01",
    "trial1": 30.5,
    "trial2": 31.2,
    "trial3": 29.8,
    "average_trial": 30.5,
    "posture": "Seated",
    "hand": "Right",
    "test_date": now,
    "right_trial_1": 30.5,
    "right_trial_2": 31.2,
    "right_trial_3": 29.8,
    "right_avg": 30.5,
})

print("\nDone.")

"""
FINAL END-TO-END TEST (ASCII-safe output)
Simulates new patient registration + test reading.
"""
import json
import urllib.request
import urllib.error
import time
import random
import string

URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post(label, payload):
    body = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=body, headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            d = json.loads(r.read().decode())
            print(f"[OK] {label}: status={d.get('status')} | hubspot_id={d.get('hubspot_id')}")
            return d
    except urllib.error.HTTPError as e:
        body_err = e.read().decode("utf-8", errors="replace")
        print(f"[FAIL {e.code}] {label}: {body_err}")
        return None
    except Exception as ex:
        print(f"[ERROR] {label}: {ex}")
        return None

# Generate fully unique patient
ts = int(time.time())
r = random.randint(1000, 9999)
suffix = f"{r}{ts % 100000}"  # 9-digit unique string

patient_name = f"VitalPt{suffix}"
patient_email = f"vpt{suffix}@e2e-test.com"
# Use a safe format: +1 + 10 digits = 12 chars
patient_phone = f"+1{str(ts)[-10:]}"
patient_code = f"PT-E2E-{suffix}"
device_id = f"dev-{suffix}"
now = time.strftime("%Y-%m-%dT%H:%M:%SZ")

print(f"Patient: {patient_name}")
print(f"Email: {patient_email}")
print(f"Phone: {patient_phone} (len={len(patient_phone)})")
print(f"Code: {patient_code}")

# STEP 1: Registration sync
print("\n=== STEP 1: Patient Registration Sync ===")
reg = post("Registration", {
    "name": patient_name,
    "phone": patient_phone,
    "email": patient_email,
    "patient_code": patient_code,
    "device_id": device_id,
    "age": 62,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "Arthritis",
    "dob": "1963-07-20",
})

if not reg:
    print("\nRegistration FAILED - stopping")
    exit(1)

time.sleep(4)

# STEP 2: Test reading sync (same patient)
print("\n=== STEP 2: Test Reading Sync ===")
reading = post("Test Reading", {
    "name": patient_name,
    "phone": patient_phone,
    "email": patient_email,
    "patient_code": patient_code,
    "device_id": device_id,
    "age": 62,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "Arthritis",
    "dob": "1963-07-20",
    "trial1": 18.4,
    "trial2": 19.1,
    "trial3": 17.8,
    "average_trial": 18.43,
    "posture": "Seated",
    "hand": "Right",
    "test_date": now,
    "right_trial_1": 18.4,
    "right_trial_2": 19.1,
    "right_trial_3": 17.8,
    "right_avg": 18.43,
})

print()
print("=== SUMMARY ===")
print(f"Registration: {'OK' if reg else 'FAILED'}")
print(f"Test Reading:  {'OK' if reading else 'FAILED'}")
if reg:
    print(f"HubSpot Contact ID: {reg.get('hubspot_id')}")
    print(f"Look for: {patient_name} in HubSpot CRM")

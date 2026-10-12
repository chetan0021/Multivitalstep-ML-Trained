"""
FULL FIELD TEST - Sends all patient fields and reports HubSpot contact ID.
After running, check that contact ID in HubSpot CRM to verify gender/condition.
"""
import json
import urllib.request
import urllib.error
import time
import random

URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post(label, payload):
    body = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=body,
                                  headers={"Content-Type": "application/json"},
                                  method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            d = json.loads(r.read().decode())
            print("[OK] %s => status=%s | hubspot_id=%s" % (label, d.get("status"), d.get("hubspot_id")))
            return d
    except urllib.error.HTTPError as e:
        err = e.read().decode("utf-8", errors="replace")
        print("[FAIL %d] %s => %s" % (e.code, label, err))
        return None
    except Exception as ex:
        print("[ERROR] %s => %s" % (label, ex))
        return None

r = random.randint(1000, 9999)
ts = int(time.time()) % 100000

# Patient details — clearly identifiable in HubSpot
patient_name   = "Test Gender Check %d" % (r * ts % 99999)
patient_email  = "gendercheck%d@vitalstep-app.com" % r
patient_phone  = "+919100%d" % r   # e.g. +91910012345  (12-13 chars)
patient_code   = "PT-GC-%d" % r
device_id      = "device-uuid-test-%d" % r
now = time.strftime("%Y-%m-%dT%H:%M:%SZ")

print("=" * 60)
print("PATIENT DETAILS:")
print("  Name:    ", patient_name)
print("  Email:   ", patient_email)
print("  Phone:   ", patient_phone, " (len=%d)" % len(patient_phone))
print("  Code:    ", patient_code)
print("  DeviceID:", device_id)
print("=" * 60)

# ── STEP 1: Registration payload (all clinical fields) ──────────
print("\n[STEP 1] Registration sync")
reg_payload = {
    "name":         patient_name,
    "phone":        patient_phone,
    "email":        patient_email,
    "patient_code": patient_code,
    "device_id":    device_id,
    "age":          58,
    "gender":       "Female",
    "dominant_hand": "Left",
    "condition":    "Arthritis",
    "dob":          "1967-03-14",
}
print("  Sending:", json.dumps(reg_payload, indent=4))
reg = post("Registration", reg_payload)

if not reg:
    print("\nRegistration FAILED — cannot continue.")
    exit(1)

time.sleep(4)

# ── STEP 2: Test Reading payload ────────────────────────────────
print("\n[STEP 2] Test reading sync (same patient)")
reading_payload = {
    "name":         patient_name,
    "phone":        patient_phone,
    "email":        patient_email,
    "patient_code": patient_code,
    "device_id":    device_id,
    "age":          58,
    "gender":       "Female",
    "dominant_hand": "Left",
    "condition":    "Arthritis",
    "dob":          "1967-03-14",
    "trial1":       22.3,
    "trial2":       23.1,
    "trial3":       21.8,
    "average_trial": 22.4,
    "posture":      "Seated",
    "hand":         "Left",
    "test_date":    now,
    "left_trial_1": 22.3,
    "left_trial_2": 23.1,
    "left_trial_3": 21.8,
    "left_avg":     22.4,
}
print("  Sending:", json.dumps(reading_payload, indent=4))
reading = post("Test Reading", reading_payload)

print("\n" + "=" * 60)
print("RESULT SUMMARY")
print("=" * 60)
if reg:
    print("  Registration: OK  | HubSpot ID:", reg.get("hubspot_id"))
else:
    print("  Registration: FAILED")

if reading:
    print("  Test Reading:  OK  | HubSpot ID:", reading.get("hubspot_id"))
else:
    print("  Test Reading:  FAILED")

if reg:
    hubspot_id = reg.get("hubspot_id")
    print()
    print("  >> Go to HubSpot CRM and search for contact ID:", hubspot_id)
    print("  >> Or search by name:", patient_name)
    print("  >> VERIFY these fields are populated:")
    print("     - gender       = Female")
    print("     - condition    = Arthritis")
    print("     - device_id    = %s" % device_id)
    print("     - age          = 58")
    print("     - dominant_hand = Left")
    print("     - dob          = 1967-03-14")
    print("     - left_trial_1 = 22.3")
    print("     - left_trial_2 = 23.1")
    print("     - left_trial_3 = 21.8")
    print("     - left_avg     = 22.4")

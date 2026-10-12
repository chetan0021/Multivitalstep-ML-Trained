"""
Root cause diagnostic: test CREATE then UPDATE with same email.
Fixed phone to be max 15 chars.
"""
import json
import urllib.request
import urllib.error
import time
import random

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def send(label, payload, timeout=60):
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    print(f"  Sending: {json.dumps(payload, indent=2)}")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as response:
            res_body = response.read().decode("utf-8")
            data = json.loads(res_body)
            print(f"[OK 200] {label}: status={data.get('status')} id={data.get('hubspot_id')}")
            return data
    except urllib.error.HTTPError as e:
        err = e.read().decode('utf-8')
        print(f"[FAIL {e.code}] {label}: {err}")
        return None

r = random.randint(1000, 9999)
unique_email = f"diag{r}@vitalstep-diag.com"
unique_phone = f"+9190{r}000001"  # 14 chars total — valid

print(f"Email: {unique_email} | Phone: {unique_phone} (len={len(unique_phone)})")

# STEP 1: CREATE basic
print("\n--- STEP 1: CREATE basic ---")
result1 = send("CREATE", {
    "name": f"Diag {r}",
    "email": unique_email,
    "phone": unique_phone,
    "patient_code": f"PT-D{r}",
})

if not result1:
    print("CREATE failed. Stopping.")
    exit(1)

time.sleep(4)

# STEP 2: UPDATE same email+phone with clinical fields
print("\n--- STEP 2: UPDATE + clinical ---")
result2 = send("UPDATE+clinical", {
    "name": f"Diag {r}",
    "email": unique_email,
    "phone": unique_phone,
    "patient_code": f"PT-D{r}",
    "device_id": "dev-uuid-abc",
    "age": 38,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1987-03-10",
})

time.sleep(4)

# STEP 3: UPDATE same email with readings
print("\n--- STEP 3: UPDATE + readings ---")
result3 = send("UPDATE+readings", {
    "name": f"Diag {r}",
    "email": unique_email,
    "phone": unique_phone,
    "patient_code": f"PT-D{r}",
    "device_id": "dev-uuid-abc",
    "age": 38,
    "gender": "Male",
    "condition": "Arthritis",
    "trial1": 25.0,
    "trial2": 26.5,
    "trial3": 24.8,
    "average_trial": 25.43,
    "posture": "Seated",
    "hand": "Right",
    "test_date": "2025-08-08T06:00:00Z",
    "right_trial_1": 25.0,
    "right_trial_2": 26.5,
    "right_trial_3": 24.8,
    "right_avg": 25.43,
})

print("\n=== Summary ===")
print(f"CREATE: {'OK' if result1 else 'FAILED'}")
print(f"UPDATE+clinical: {'OK' if result2 else 'FAILED'}")  
print(f"UPDATE+readings: {'OK' if result3 else 'FAILED'}")

"""
Investigate: Does phone number collision cause the 400?
We'll use a completely unique phone each time.
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

r = random.randint(100000000, 999999999)
ts = int(time.time())

print("=== Test with completely unique phone AND email ===")
send("Unique phone+email", {
    "name": f"Unique Patient {ts}",
    "email": f"unique_{r}_{ts}@test-vitalstep-{r}.io",
    "phone": f"+1555{r}",   # very unique phone
    "patient_code": f"PT-UNIQUE-{r}",
    "device_id": "device-unique-uuid-abc",
    "age": 30,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
})

time.sleep(3)

print("\n=== Test with no phone (only email, all fields) ===")
r2 = random.randint(100000000, 999999999)
send("No phone, all fields", {
    "name": f"No Phone Patient {ts}",
    "email": f"nophone_{r2}@test-vitalstep-{r2}.io",
    "phone": "",
    "patient_code": f"PT-NOPHONE-{r2}",
    "device_id": "device-nophone-uuid",
    "age": 45,
    "gender": "Female",
    "dominant_hand": "Left",
    "condition": "Arthritis",
})

print("\nDone.")

import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post_test(name, payload):
    print(f"\n--- Testing: {name} ---")
    print(f"Payload:\n{json.dumps(payload, indent=2)}")
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[SUCCESS 200]: {res_body}")
    except urllib.error.HTTPError as e:
        print(f"[HTTP ERROR {e.code}]: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"[EXCEPTION]: {e}")

# Variant 1: Standard payload
v1 = {
    "name": "Property Test Patient V1",
    "phone": "+919111122222",
    "email": "proptest1@vitalstep.com",
    "patient_code": "PT-3001",
    "device_id": "device_uuid_v1",
    "host_user_id": "device_uuid_v1",
    "age": 35,
    "gender": "Female",
    "Gender": "Female",
    "dominant_hand": "Right",
    "condition": "Arthritis",
    "Condition": "Arthritis",
    "dob": "1989-01-01"
}

post_test("Variant 1 (Multiple Case Keys)", v1)

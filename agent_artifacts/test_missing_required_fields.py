import json
import urllib.request
import urllib.error

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def test_payload(name, payload):
    print(f"\nTesting: {name}")
    print(json.dumps(payload, indent=2))
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            print(f"[SUCCESS 200]: {response.read().decode('utf-8')}")
    except urllib.error.HTTPError as e:
        print(f"[FAIL {e.code}]: {e.read().decode('utf-8')}")

# Test C: Adding age, dob, dominant_hand
post_C = {
    "name": "Test User C",
    "email": "userC@vitalstep.com",
    "phone": "+919000011103",
    "patient_code": "PT-C1",
    "device_id": "device_C",
    "age": 45,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1981-03-25"
}
test_payload("Test C (All fields present)", post_C)

# Test D: Same email userC@vitalstep.com updated with new condition
post_D = {
    "name": "Test User C",
    "email": "userC@vitalstep.com",
    "phone": "+919000011103",
    "patient_code": "PT-C1",
    "device_id": "device_C",
    "age": 45,
    "gender": "Female",
    "dominant_hand": "Right",
    "condition": "Arthritis",
    "dob": "1981-03-25"
}
test_payload("Test D (Updating userC with condition = Arthritis)", post_D)

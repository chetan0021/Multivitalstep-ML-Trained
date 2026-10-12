import json
import urllib.request
import urllib.error

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def test_payload(name, phone_number):
    payload = {
        "name": f"Phone Test {name}",
        "email": f"phonetest_{name.lower()}@vitalstep.com",
        "phone": phone_number,
        "patient_code": f"PT-P{name}",
        "device_id": "device_uuid_valid",
        "age": 30,
        "gender": "Female",
        "dominant_hand": "Right",
        "condition": "Arthritis",
        "dob": "1995-01-01"
    }
    print(f"\nTesting phone: {phone_number}")
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[SUCCESS 200]: {res_body}")
    except urllib.error.HTTPError as e:
        print(f"[FAIL {e.code}]: {e.read().decode('utf-8')}")

# Test 1: Valid format +91 98765 43212
test_payload("ValidPhone", "+919876543212")

# Test 2: Dummy series +91 90000 00000
test_payload("DummyPhone", "+919000000000")

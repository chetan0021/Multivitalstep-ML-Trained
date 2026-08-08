import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def test_payload(description, payload):
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[SUCCESS 200] {description}: {res_body}")
            return True
    except urllib.error.HTTPError as e:
        res_body = e.read().decode("utf-8")
        print(f"[FAIL {e.code}] {description}: {res_body}")
        return False
    except Exception as e:
        print(f"[ERR] {description}: {e}")
        return False

# Base minimal working payload from test_hubspot.py
base_payload = {
    "name": "Live Test Contact",
    "phone": "+919876543210",
    "email": "livetest@vitalstep.com",
    "patient_code": "PT-8888",
    "device_id": "test_device_uuid_12345",
    "age": 30,
    "gender": "Male",
    "dominant_hand": "Right",
    "condition": "None",
    "dob": "1994-06-15"
}

print("=== TESTING FIELD BY FIELD ===")

# Test 1: Base working
test_payload("Base Working Payload", base_payload)

# Test 2: Different Condition "Post-Surgery Recovery"
p2 = dict(base_payload)
p2["condition"] = "Post-Surgery Recovery"
test_payload("Condition = Post-Surgery Recovery", p2)

# Test 3: Condition = "Arthritis"
p3 = dict(base_payload)
p3["condition"] = "Arthritis"
test_payload("Condition = Arthritis", p3)

# Test 4: Gender = "Female"
p4 = dict(base_payload)
p4["gender"] = "Female"
test_payload("Gender = Female", p4)

# Test 5: DOB = "1981-03-25"
p5 = dict(base_payload)
p5["dob"] = "1981-03-25"
test_payload("DOB = 1981-03-25", p5)

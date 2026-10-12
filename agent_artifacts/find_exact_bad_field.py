import json
import urllib.request
import urllib.error
import random

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def send_test(label, fields):
    rand_num = random.randint(100000, 999999)
    payload = {
        "name": f"Test {label}",
        "email": f"test_{rand_num}@vitalstep.com",
        "phone": f"+9198{rand_num}",
        "patient_code": f"PT-{rand_num}",
    }
    payload.update(fields)
    
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[OK 200] {label}: {res_body}")
            return True
    except urllib.error.HTTPError as e:
        print(f"[FAIL {e.code}] {label}: {e.read().decode('utf-8')}")
        return False

print("=== TESTING EXACT FIELD ACCEPTANCE ON FRESH CONTACTS ===")

# Test 1: Only basic info
send_test("Basic Only", {})

# Test 2: Basic + device_id
send_test("Basic + device_id", {"device_id": "test_dev_id"})

# Test 3: Basic + gender
send_test("Basic + gender", {"gender": "Female"})

# Test 4: Basic + condition
send_test("Basic + condition", {"condition": "None"})

# Test 5: Basic + age
send_test("Basic + age", {"age": 40})

# Test 6: Basic + dominant_hand
send_test("Basic + dominant_hand", {"dominant_hand": "Right"})

# Test 7: Basic + dob
send_test("Basic + dob", {"dob": "1990-01-01"})

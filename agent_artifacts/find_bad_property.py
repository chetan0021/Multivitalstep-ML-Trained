import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def test_single_field(field_name, field_val):
    payload = {
        "name": "Property Debug User",
        "email": "propdebug@vitalstep.com",
        "phone": "+919555544444",
        "patient_code": "PT-DEBUG",
        field_name: field_val
    }
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[OK 200] Field '{field_name}' = {field_val}: SUCCESS")
            return True
    except urllib.error.HTTPError as e:
        res = e.read().decode("utf-8")
        print(f"[FAIL {e.code}] Field '{field_name}' = {field_val}: {res}")
        return False
    except Exception as e:
        print(f"[ERR] Field '{field_name}' = {field_val}: {e}")
        return False

print("=== TESTING EACH FIELD INDIVIDUALLY AGAINST HUBSPOT ===")

fields_to_test = [
    ("device_id", "test_device_123"),
    ("host_user_id", "test_device_123"),
    ("age", 40),
    ("gender", "Female"),
    ("gender", "female"),
    ("gender", "Male"),
    ("dominant_hand", "Right"),
    ("dominant_hand", "right"),
    ("condition", "None"),
    ("condition", "Arthritis"),
    ("condition", "Carpal Tunnel Syndrome"),
    ("dob", "1990-01-01"),
]

for name, val in fields_to_test:
    test_single_field(name, val)
    time.sleep(1)

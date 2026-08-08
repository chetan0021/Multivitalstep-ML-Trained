import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def test_field(description, payload):
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[OK 200] {description}: {res_body}")
            return True
    except urllib.error.HTTPError as e:
        res = e.read().decode("utf-8")
        print(f"[FAIL {e.code}] {description}: {res}")
        return False
    except Exception as e:
        print(f"[ERR] {description}: {e}")
        return False

print("=== TESTING DEVICE_ID AND AGE TYPES ===")

base = {
    "name": "Schema Test Patient",
    "email": "schematest@vitalstep.com",
    "phone": "+919444433333",
    "patient_code": "PT-SCHEMA"
}

# 1. age as string
p1 = dict(base)
p1["age"] = "40"
test_field("age as string '40'", p1)

# 2. age omitted
p2 = dict(base)
p2["gender"] = "Female"
p2["condition"] = "None"
test_field("gender + condition (no age, no device_id)", p2)

# 3. device_id as integer
p3 = dict(base)
p3["device_id"] = 12345
test_field("device_id as int 12345", p3)

# 4. device_id lowercase / uppercase / alternative names
for key in ["device_id", "deviceId", "device_number", "device", "hs_device_id"]:
    p = dict(base)
    p[key] = "DEV-100"
    test_field(f"Property name '{key}' = 'DEV-100'", p)

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

# Test A: condition = "None"
post_A = {
    "name": "Test User A",
    "email": "userA@vitalstep.com",
    "phone": "+919000011101",
    "patient_code": "PT-A1",
    "device_id": "device_A",
    "gender": "Female",
    "condition": "None"
}
test_payload("Test A (condition = 'None')", post_A)

# Test B: condition = "Stroke"
post_B = {
    "name": "Test User B",
    "email": "userB@vitalstep.com",
    "phone": "+919000011102",
    "patient_code": "PT-B1",
    "device_id": "device_B",
    "gender": "Female",
    "condition": "Stroke"
}
test_payload("Test B (condition = 'Stroke')", post_B)

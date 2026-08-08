import json
import urllib.request
import urllib.error

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

left_reading = {
    "name": "Live Test Patient",
    "phone": "+919999988888",
    "email": "livetestpatient@vitalstep.com",
    "patient_code": "PT-7777",
    "trial1": 24.1,
    "trial2": 25.0,
    "trial3": 24.5,
    "average_trial": 24.53,
    "posture": "sitting",
    "hand": "Left",
    "test_date": "2026-08-08T11:10:00.000Z",
    "left_trial_1": 24.1,
    "left_trial_2": 25.0,
    "left_trial_3": 24.5,
    "left_avg": 24.53
}

headers = {"Content-Type": "application/json"}
body = json.dumps(left_reading).encode("utf-8")
req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
with urllib.request.urlopen(req, timeout=30) as response:
    res_body = response.read().decode("utf-8")
    print("LEFT HAND PUSH OK:", res_body)

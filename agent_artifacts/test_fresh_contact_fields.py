import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post_payload(description, payload):
    print(f"\n==========================================================")
    print(f"Testing: {description}")
    print(f"Payload:\n{json.dumps(payload, indent=2)}")
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            print(f"[SUCCESS 200]: {res_body}")
            return json.loads(res_body)
    except urllib.error.HTTPError as e:
        print(f"[FAIL {e.code}]: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"[ERR]: {e}")

# Fresh Email 1: Sending device_id, gender, condition
payload_1 = {
    "name": "Fresh Test Patient Alpha",
    "email": "alpha_fresh@vitalstep.com",
    "phone": "+919000011111",
    "patient_code": "PT-9001",
    "device_id": "supabase_host_uuid_alpha",
    "gender": "Female",
    "condition": "Carpal Tunnel Syndrome"
}

post_payload("Fresh Contact Alpha (device_id + gender + condition)", payload_1)

import json
import urllib.request
import urllib.error
import time

HEALTH_URL = "https://vitalstep.onrender.com/api/v1/hubspot/health"
SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def make_request(url, method="GET", data=None):
    headers = {"Content-Type": "application/json"}
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    
    start_time = time.time()
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            elapsed = time.time() - start_time
            res_body = response.read().decode("utf-8")
            try:
                res_json = json.loads(res_body)
            except Exception:
                res_json = res_body
            return {
                "status_code": response.status,
                "elapsed_seconds": round(elapsed, 2),
                "response": res_json
            }
    except urllib.error.HTTPError as e:
        elapsed = time.time() - start_time
        res_body = e.read().decode("utf-8")
        try:
            res_json = json.loads(res_body)
        except Exception:
            res_json = res_body
        return {
            "status_code": e.code,
            "elapsed_seconds": round(elapsed, 2),
            "error": str(e),
            "response": res_json
        }
    except Exception as e:
        elapsed = time.time() - start_time
        return {
            "status_code": 0,
            "elapsed_seconds": round(elapsed, 2),
            "error": str(e)
        }

def run_tests():
    print("=== STEP 1: Checking HubSpot Health Endpoint ===")
    health_res = make_request(HEALTH_URL, method="GET")
    print(f"Health Response: {json.dumps(health_res, indent=2)}\n")

    print("=== STEP 2: Testing Patient Registration Payload ===")
    reg_payload = {
        "name": "Test Dummy Patient",
        "phone": "+919876543210",
        "email": "dummy_test@vitalstep.com",
        "patient_code": "PT-9999",
        "device_id": "test_device_uuid_12345",
        "age": 32,
        "gender": "Male",
        "dominant_hand": "Right",
        "condition": "None",
        "dob": "1994-06-15"
    }
    print(f"Registration Payload:\n{json.dumps(reg_payload, indent=2)}")
    reg_res = make_request(SYNC_URL, method="POST", data=reg_payload)
    print(f"Registration Response:\n{json.dumps(reg_res, indent=2)}\n")

    print("=== STEP 3: Testing Test Reading (Right Hand) Payload ===")
    right_reading_payload = {
        "name": "Test Dummy Patient",
        "phone": "+919876543210",
        "email": "dummy_test@vitalstep.com",
        "patient_code": "PT-9999",
        "trial1": 35.5,
        "trial2": 36.2,
        "trial3": 34.8,
        "average_trial": 35.5,
        "posture": "sitting",
        "hand": "Right",
        "test_date": "2026-08-08T10:50:00.000Z",
        "right_trial_1": 35.5,
        "right_trial_2": 36.2,
        "right_trial_3": 34.8,
        "right_avg": 35.5
    }
    print(f"Right Reading Payload:\n{json.dumps(right_reading_payload, indent=2)}")
    right_res = make_request(SYNC_URL, method="POST", data=right_reading_payload)
    print(f"Right Reading Response:\n{json.dumps(right_res, indent=2)}\n")

    print("=== STEP 4: Testing Test Reading (Left Hand) Payload ===")
    left_reading_payload = {
        "name": "Test Dummy Patient",
        "phone": "+919876543210",
        "email": "dummy_test@vitalstep.com",
        "patient_code": "PT-9999",
        "trial1": 31.0,
        "trial2": 32.5,
        "trial3": 30.8,
        "average_trial": 31.43,
        "posture": "sitting",
        "hand": "Left",
        "test_date": "2026-08-08T10:52:00.000Z",
        "left_trial_1": 31.0,
        "left_trial_2": 32.5,
        "left_trial_3": 30.8,
        "left_avg": 31.43
    }
    print(f"Left Reading Payload:\n{json.dumps(left_reading_payload, indent=2)}")
    left_res = make_request(SYNC_URL, method="POST", data=left_reading_payload)
    print(f"Left Reading Response:\n{json.dumps(left_res, indent=2)}\n")

if __name__ == "__main__":
    run_tests()

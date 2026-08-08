import json
import urllib.request
import urllib.error
import time

SYNC_URL = "https://vitalstep.onrender.com/api/v1/hubspot/sync/contact"

def post_payload(payload_name, payload):
    print(f"\n--- Pushing {payload_name} ---")
    print(f"Payload:\n{json.dumps(payload, indent=2)}")
    
    headers = {"Content-Type": "application/json"}
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(SYNC_URL, data=body, headers=headers, method="POST")
    
    start_time = time.time()
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            elapsed = time.time() - start_time
            res_body = response.read().decode("utf-8")
            res_json = json.loads(res_body)
            print(f"[SUCCESS] ({round(elapsed, 2)}s): {json.dumps(res_json, indent=2)}")
            return res_json
    except urllib.error.HTTPError as e:
        elapsed = time.time() - start_time
        res_body = e.read().decode("utf-8")
        print(f"[HTTP ERROR {e.code}] ({round(elapsed, 2)}s): {res_body}")
    except Exception as e:
        print(f"[EXCEPTION]: {e}")

def main():
    print("==========================================================")
    print("PUSHING LIVE TEST DATA TO HUBSPOT")
    print("==========================================================")
    
    # 1. Patient Registration
    reg_payload = {
        "name": "VitalStep Live Test Patient",
        "phone": "+919999988888",
        "email": "live_test@vitalstep.com",
        "patient_code": "PT-8888",
        "device_id": "device_live_test_001",
        "age": 45,
        "gender": "Female",
        "dominant_hand": "Right",
        "condition": "Post-Surgery Recovery",
        "dob": "1981-03-25"
    }
    reg_res = post_payload("Patient Registration", reg_payload)
    
    # Wait 2 seconds
    time.sleep(2)
    
    # 2. Test Reading (Right Hand)
    right_reading_payload = {
        "name": "VitalStep Live Test Patient",
        "phone": "+919999988888",
        "email": "live_test@vitalstep.com",
        "patient_code": "PT-8888",
        "trial1": 28.50,
        "trial2": 29.20,
        "trial3": 28.80,
        "average_trial": 28.83,
        "posture": "sitting",
        "hand": "Right",
        "test_date": "2026-08-08T11:08:00.000Z",
        "right_trial_1": 28.50,
        "right_trial_2": 29.20,
        "right_trial_3": 28.80,
        "right_avg": 28.83
    }
    right_res = post_payload("Right Hand Reading", right_reading_payload)
    
    # Wait 2 seconds
    time.sleep(2)
    
    # 3. Test Reading (Left Hand)
    left_reading_payload = {
        "name": "VitalStep Live Test Patient",
        "phone": "+919999988888",
        "email": "live_test@vitalstep.com",
        "patient_code": "PT-8888",
        "trial1": 24.10,
        "trial2": 25.00,
        "trial3": 24.50,
        "average_trial": 24.53,
        "posture": "sitting",
        "hand": "Left",
        "test_date": "2026-08-08T11:10:00.000Z",
        "left_trial_1": 24.10,
        "left_trial_2": 25.00,
        "left_trial_3": 24.50,
        "left_avg": 24.53
    }
    left_res = post_payload("Left Hand Reading", left_reading_payload)
    
    print("\n==========================================================")
    print("ALL LIVE DATA PUSHED SUCCESSFULLY!")
    print("==========================================================")

if __name__ == "__main__":
    main()

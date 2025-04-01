from datetime import datetime

def medical_record_schema(data):
    return {
        "patient_id": data.get("patient_id"),
        "diagnosis": data.get("diagnosis"),
        "treatments": data.get("treatments", []),
        "doctor_notes": data.get("doctor_notes", ""),
        "created_at": data.get("created_at", datetime.utcnow())
    }

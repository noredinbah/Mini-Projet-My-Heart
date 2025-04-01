from flask import Blueprint, request, jsonify
from app.database import medical_records_collection
from app.models import medical_record_schema

medical_bp = Blueprint("medical", __name__)

@medical_bp.route("/medical_records", methods=["POST"])
def add_medical_record():
    data = request.json
    medical_record = medical_record_schema(data)
    medical_records_collection.insert_one(medical_record)
    return jsonify({"message": "Dossier médical ajouté avec succès"}), 201

@medical_bp.route("/medical_records", methods=["GET"])
def get_all_medical_records():
    records = list(medical_records_collection.find({}, {"_id": 0}))
    return jsonify(records), 200

@medical_bp.route("/medical_records/<patient_id>", methods=["GET"])
def get_medical_record(patient_id):
    record = medical_records_collection.find_one({"patient_id": patient_id}, {"_id": 0})
    if record:
        return jsonify(record), 200
    return jsonify({"message": "Dossier médical non trouvé"}), 404

@medical_bp.route("/medical_records/<patient_id>", methods=["PUT"])
def update_medical_record(patient_id):
    data = request.json
    updated = medical_records_collection.update_one({"patient_id": patient_id}, {"": data})
    if updated.modified_count:
        return jsonify({"message": "Dossier médical mis à jour"}), 200
    return jsonify({"message": "Aucune modification effectuée"}), 404

@medical_bp.route("/medical_records/<patient_id>", methods=["DELETE"])
def delete_medical_record(patient_id):
    deleted = medical_records_collection.delete_one({"patient_id": patient_id})
    if deleted.deleted_count:
        return jsonify({"message": "Dossier médical supprimé"}), 200
    return jsonify({"message": "Dossier médical non trouvé"}), 404

# Définir le dossier du projet
$projectDir = "dossier-medical-service"
$envDir = "$projectDir\venv"
$files = @(
    "$projectDir\app\__init__.py",
    "$projectDir\app\config.py",
    "$projectDir\app\database.py",
    "$projectDir\app\models.py",
    "$projectDir\app\routes.py",
    "$projectDir\app.py",
    "$projectDir\requirements.txt",
    "$projectDir\Dockerfile"
)

# Vérifier si le dossier du projet existe
if (!(Test-Path $projectDir)) {
    Write-Host "Création du dossier du projet..."
    New-Item -ItemType Directory -Path $projectDir -Force
}

# Créer les sous-dossiers nécessaires
Write-Host "Création de la structure du projet..."
New-Item -ItemType Directory -Path "$projectDir\app" -Force

# Créer les fichiers nécessaires
foreach ($file in $files) {
    if (!(Test-Path $file)) {
        New-Item -ItemType File -Path $file -Force
    }
}

# Écrire le contenu des fichiers
Write-Host "Écriture du contenu des fichiers..."

# config.py
@"
import os

class Config:
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/myheart_db")
"@ | Set-Content "$projectDir\app\config.py"

# database.py
@"
from pymongo import MongoClient
from app.config import Config

client = MongoClient(Config.MONGO_URI)
db = client["myheart_db"]
medical_records_collection = db["medical_records"]
"@ | Set-Content "$projectDir\app\database.py"

# models.py
@"
from datetime import datetime

def medical_record_schema(data):
    return {
        "patient_id": data.get("patient_id"),
        "diagnosis": data.get("diagnosis"),
        "treatments": data.get("treatments", []),
        "doctor_notes": data.get("doctor_notes", ""),
        "created_at": data.get("created_at", datetime.utcnow())
    }
"@ | Set-Content "$projectDir\app\models.py"

# routes.py
@"
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
    updated = medical_records_collection.update_one({"patient_id": patient_id}, {"$set": data})
    if updated.modified_count:
        return jsonify({"message": "Dossier médical mis à jour"}), 200
    return jsonify({"message": "Aucune modification effectuée"}), 404

@medical_bp.route("/medical_records/<patient_id>", methods=["DELETE"])
def delete_medical_record(patient_id):
    deleted = medical_records_collection.delete_one({"patient_id": patient_id})
    if deleted.deleted_count:
        return jsonify({"message": "Dossier médical supprimé"}), 200
    return jsonify({"message": "Dossier médical non trouvé"}), 404
"@ | Set-Content "$projectDir\app\routes.py"

# app.py
@"
from flask import Flask
from app.routes import medical_bp

app = Flask(__name__)
app.register_blueprint(medical_bp)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, debug=True)
"@ | Set-Content "$projectDir\app.py"

# requirements.txt
@"
Flask
pymongo
"@ | Set-Content "$projectDir\requirements.txt"

# Dockerfile
@"
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
"@ | Set-Content "$projectDir\Dockerfile"

# Vérifier si MongoDB est installé
$mongoService = Get-Service -Name "MongoDB" -ErrorAction SilentlyContinue
if (-not $mongoService) {
    Write-Host "MongoDB n'est pas installé. Installez MongoDB avant d'exécuter ce script."
    exit 1
}

# Créer un environnement virtuel
if (!(Test-Path $envDir)) {
    Write-Host "Création de l'environnement virtuel..."
    python -m venv $envDir
}

# Activer l'environnement virtuel
Write-Host "Activation de l'environnement virtuel..."
Set-ExecutionPolicy Unrestricted -Scope Process -Force
& "$envDir\Scripts\Activate"

# Installer les dépendances
Write-Host "Installation des dépendances..."
pip install -r "$projectDir\requirements.txt"

# Démarrer le serveur Flask
Write-Host "Démarrage du service Dossier Médical sur le port 5003..."
Start-Process -NoNewWindow -FilePath "python" -ArgumentList "$projectDir\app.py"

from pymongo import MongoClient
from app.config import Config

client = MongoClient(Config.MONGO_URI)
db = client["myheart_db"]
medical_records_collection = db["medical_records"]

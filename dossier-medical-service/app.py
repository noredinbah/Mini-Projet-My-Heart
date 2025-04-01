from flask import Flask
from app.routes import medical_bp

app = Flask(__name__)
app.register_blueprint(medical_bp)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, debug=True)

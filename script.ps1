# PowerShell Script to Set Up the Médecin Microservice (No Sequelize)
# Run this script inside your main project directory

# Step 1: Create Directories
$serviceDir = "medecin-service"
$srcDir = "$serviceDir\src"
$folders = @("controllers", "routes", "config", "models")
New-Item -ItemType Directory -Path $serviceDir -Force
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path "$srcDir\$folder" -Force
}

# Step 2: Initialize Node.js Project
Set-Location $serviceDir
npm init -y

# Step 3: Install Dependencies
npm install express mysql dotenv body-parser cors

# Step 4: Create .env File
@"
DB_HOST=localhost
DB_USER=root
DB_PASS=rootpassword
DB_NAME=medecin_db
PORT=5004
"@ | Out-File -Encoding utf8 .env

# Step 5: Create Database Connection (config/db.js)
@"
const mysql = require('mysql');
require('dotenv').config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME
});

connection.connect(err => {
  if (err) throw err;
  console.log("Connected to MySQL Database!");
});

module.exports = connection;
"@ | Out-File -Encoding utf8 src/config/db.js

# Step 6: Create Doctor Model (models/doctor.js)
@"
const connection = require('../config/db');

const Doctor = {
  getAll: (callback) => {
    connection.query("SELECT * FROM doctors", callback);
  },
  
  getById: (id, callback) => {
    connection.query("SELECT * FROM doctors WHERE id = ?", [id], callback);
  },
  
  create: (data, callback) => {
    connection.query("INSERT INTO doctors (name, specialty, availability) VALUES (?, ?, ?)", 
      [data.name, data.specialty, JSON.stringify(data.availability)], callback);
  },

  update: (id, data, callback) => {
    connection.query("UPDATE doctors SET name = ?, specialty = ?, availability = ? WHERE id = ?", 
      [data.name, data.specialty, JSON.stringify(data.availability), id], callback);
  },

  delete: (id, callback) => {
    connection.query("DELETE FROM doctors WHERE id = ?", [id], callback);
  }
};

module.exports = Doctor;
"@ | Out-File -Encoding utf8 src/models/doctor.js

# Step 7: Create Doctor Controller (controllers/doctorController.js)
@"
const Doctor = require('../models/doctor');

exports.getAllDoctors = (req, res) => {
  Doctor.getAll((err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};

exports.getDoctorById = (req, res) => {
  Doctor.getById(req.params.id, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json(results[0]);
  });
};

exports.createDoctor = (req, res) => {
  Doctor.create(req.body, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id: results.insertId, ...req.body });
  });
};

exports.updateDoctor = (req, res) => {
  Doctor.update(req.params.id, req.body, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Doctor updated successfully' });
  });
};

exports.deleteDoctor = (req, res) => {
  Doctor.delete(req.params.id, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Doctor deleted successfully' });
  });
};
"@ | Out-File -Encoding utf8 src/controllers/doctorController.js

# Step 8: Create Routes (routes/doctorRoutes.js)
@"
const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctorController');

router.get('/doctors', doctorController.getAllDoctors);
router.get('/doctors/:id', doctorController.getDoctorById);
router.post('/doctors', doctorController.createDoctor);
router.put('/doctors/:id', doctorController.updateDoctor);
router.delete('/doctors/:id', doctorController.deleteDoctor);

module.exports = router;
"@ | Out-File -Encoding utf8 src/routes/doctorRoutes.js

# Step 9: Create Express App (app.js)
@"
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const doctorRoutes = require('./src/routes/doctorRoutes');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/api', doctorRoutes);

const PORT = process.env.PORT || 5004;

app.listen(PORT, () => {
  console.log(`Médecin Service running on port \${PORT}`);
});
"@ | Out-File -Encoding utf8 app.js

# Step 10: Create Dockerfile
@"
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 5004
CMD ["node", "app.js"]
"@ | Out-File -Encoding utf8 Dockerfile

# Step 11: Create docker-compose.yml
@"
version: '3.8'
services:
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: medecin_db
    ports:
      - "3306:3306"
    networks:
      - healthcare-network

  medecin-service:
    build: .
    ports:
      - "5004:5004"
    environment:
      - DB_HOST=mysql
      - DB_USER=root
      - DB_PASS=rootpassword
      - DB_NAME=medecin_db
    depends_on:
      - mysql
    networks:
      - healthcare-network

networks:
  healthcare-network:
    driver: bridge
"@ | Out-File -Encoding utf8 docker-compose.yml

# Step 12: Run the Service
Write-Host "Setup complete. Run 'docker-compose up --build' to start the service."

# PowerShell script to create the Patient Service structure for the project

# Define the base directory for the patient service
$baseDir = "C:\Users\NOREDINE\Desktop\Mini_projet_soa\patient-service"

# Create directory structure
$directories = @(
    "config",
    "models",
    "routes",
    "middleware"
)

foreach ($dir in $directories) {
    $path = Join-Path $baseDir $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
}

# Create .env file
$envFile = Join-Path $baseDir ".env"
if (-not (Test-Path $envFile)) {
    $envContent = @"
PORT=5001
DB_NAME=myheart_patients
DB_USER=root
DB_PASSWORD=1234567890
DB_HOST=localhost
JWT_SECRET=supersecretkey

"@
    Set-Content -Path $envFile -Value $envContent
}

# Create db.js file
$dbFile = Join-Path $baseDir "config\db.js"
if (-not (Test-Path $dbFile)) {
    $dbContent = @"
const mysql = require('mysql2');
require('dotenv').config();

// Create a connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});

const query = (sql, params) => {
    return new Promise((resolve, reject) => {
        pool.query(sql, params, (err, results) => {
            if (err) reject(err);
            else resolve(results);
        });
    });
};

module.exports = { query };
"@
    Set-Content -Path $dbFile -Value $dbContent
}

# Create patient.js model file
$patientModelFile = Join-Path $baseDir "models\patient.js"
if (-not (Test-Path $patientModelFile)) {
    $patientModelContent = @"
const { query } = require('../config/db');

// Create a new patient
const createPatient = async (name, email, dob, medicalHistory) => {
    const sql = 'INSERT INTO patients (name, email, dob, medical_history) VALUES (?, ?, ?, ?)';
    return query(sql, [name, email, dob, medicalHistory]);
};

// Get all patients
const getAllPatients = async () => {
    const sql = 'SELECT * FROM patients';
    return query(sql);
};

// Get a specific patient by ID
const getPatientById = async (id) => {
    const sql = 'SELECT * FROM patients WHERE id = ?';
    return query(sql, [id]);
};

// Update a patient's data
const updatePatient = async (id, name, email, dob, medicalHistory) => {
    const sql = 'UPDATE patients SET name = ?, email = ?, dob = ?, medical_history = ? WHERE id = ?';
    return query(sql, [name, email, dob, medicalHistory, id]);
};

// Delete a patient
const deletePatient = async (id) => {
    const sql = 'DELETE FROM patients WHERE id = ?';
    return query(sql, [id]);
};

module.exports = { createPatient, getAllPatients, getPatientById, updatePatient, deletePatient };
"@
    Set-Content -Path $patientModelFile -Value $patientModelContent
}

# Create patient.js routes file
$patientRoutesFile = Join-Path $baseDir "routes\patient.js"
if (-not (Test-Path $patientRoutesFile)) {
    $patientRoutesContent = @"
const express = require('express');
const { createPatient, getAllPatients, getPatientById, updatePatient, deletePatient } = require('../models/patient');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Create a new patient
router.post('/', authenticateToken, async (req, res) => {
    const { name, email, dob, medicalHistory } = req.body;

    if (!name || !email || !dob) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const result = await createPatient(name, email, dob, medicalHistory);
        res.status(201).json({ message: 'Patient created successfully', patientId: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Error creating patient', error });
    }
});

// Get all patients
router.get('/', authenticateToken, async (req, res) => {
    try {
        const patients = await getAllPatients();
        res.json(patients);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching patients', error });
    }
});

// Get a patient by ID
router.get('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;

    try {
        const patient = await getPatientById(id);
        if (patient.length === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json(patient[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching patient', error });
    }
});

// Update a patient
router.put('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { name, email, dob, medicalHistory } = req.body;

    if (!name || !email || !dob) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const result = await updatePatient(id, name, email, dob, medicalHistory);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json({ message: 'Patient updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating patient', error });
    }
});

// Delete a patient
router.delete('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;

    try {
        const result = await deletePatient(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json({ message: 'Patient deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting patient', error });
    }
});

module.exports = router;
"@
    Set-Content -Path $patientRoutesFile -Value $patientRoutesContent
}

# Create authMiddleware.js file
$authMiddlewareFile = Join-Path $baseDir "middleware\authMiddleware.js"
if (-not (Test-Path $authMiddlewareFile)) {
    $authMiddlewareContent = @"
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) return res.status(401).json({ message: 'Access Denied' });

    try {
        const verified = jwt.verify(token.split(' ')[1], process.env.JWT_SECRET);
        req.user = verified;
        next();
    } catch (error) {
        res.status(403).json({ message: 'Invalid Token' });
    }
};

module.exports = { authenticateToken };
"@
    Set-Content -Path $authMiddlewareFile -Value $authMiddlewareContent
}

# Create index.js file
$indexFile = Join-Path $baseDir "index.js"
if (-not (Test-Path $indexFile)) {
    $indexContent = @"
const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const patientRoutes = require('./routes/patient');

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/patients', patientRoutes);

// Start Server
const PORT = process.env.PORT || 5001;
app.listen(PORT, async () => {
    console.log(\`Patient Service running on port \${PORT}\`);
});
"@
    Set-Content -Path $indexFile -Value $indexContent
}

# Create Dockerfile
$dockerFile = Join-Path $baseDir "Dockerfile"
if (-not (Test-Path $dockerFile)) {
    $dockerFileContent = @"
FROM node:18
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 5001
CMD [\"node\", \"index.js\"]
"@
    Set-Content -Path $dockerFile -Value $dockerFileContent
}

# Create docker-compose.yml file
$dockerComposeFile = Join-Path $baseDir "docker-compose.yml"
if (-not (Test-Path $dockerComposeFile)) {
    $dockerComposeContent = @"
version: '3.8'
services:
  db:
    image: mysql:8
    container_name: patient_db
    restart: always
    environment:
      MYSQL_DATABASE: myheart_patients
      MYSQL_ROOT_PASSWORD: password
    ports:
      - \"3307:3306\"
    volumes:
      - db_data:/var/lib/mysql

  patient-service:
    build: .
    container_name: patient_service
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_USER: root
      DB_PASSWORD: password
      DB_NAME: myheart_patients
      JWT_SECRET: supersecretkey
    ports:
      - \"5001:5001\"
    volumes:
      - .:/app
    command: [\"node\", \"index.js\"]
volumes:
  db_data:
"@
    Set-Content -Path $dockerComposeFile -Value $dockerComposeContent
}

Write-Host "Patient Service setup complete!"

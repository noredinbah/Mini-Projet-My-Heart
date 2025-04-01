# Set up project directory
$projectDir = "rendezvous-service"
$basePath = Join-Path (Get-Location) $projectDir

# Create project directory structure
$directories = @(
    "$basePath/config",
    "$basePath/models",
    "$basePath/routes",
    "$basePath"
)

foreach ($dir in $directories) {
    if (-Not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory
    }
}

# Create .env file
$envContent = @"
PORT=5002
DB_NAME=myheart_rendezvous
DB_USER=root
DB_PASSWORD=password
DB_HOST=localhost
JWT_SECRET=supersecretkey
"@
Set-Content -Path "$basePath\.env" -Value $envContent

# Create config/db.js file
$dbConfig = @"
const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

const connectDB = () => {
  connection.connect((err) => {
    if (err) {
      console.error('Error connecting to the database: ', err);
      process.exit(1);
    } else {
      console.log('Database connected successfully.');
    }
  });
};

module.exports = { connection, connectDB };
"@
Set-Content -Path "$basePath\config\db.js" -Value $dbConfig

# Create models/rendezvous.js file
$rendezvousModel = @"
const { connection } = require('../config/db');

// Create a new rendezvous
const createRendezvous = (patientId, doctorId, date, time, callback) => {
  const query = 'INSERT INTO rendezvous (patient_id, doctor_id, date, time) VALUES (?, ?, ?, ?)';
  connection.query(query, [patientId, doctorId, date, time], (err, result) => {
    if (err) {
      console.error('Error creating rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

// Get all rendezvous for a specific patient
const getRendezvousByPatient = (patientId, callback) => {
  const query = 'SELECT * FROM rendezvous WHERE patient_id = ?';
  connection.query(query, [patientId], (err, rows) => {
    if (err) {
      console.error('Error fetching rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, rows);
    }
  });
};

// Get all rendezvous for a specific doctor
const getRendezvousByDoctor = (doctorId, callback) => {
  const query = 'SELECT * FROM rendezvous WHERE doctor_id = ?';
  connection.query(query, [doctorId], (err, rows) => {
    if (err) {
      console.error('Error fetching rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, rows);
    }
  });
};

// Update an existing rendezvous
const updateRendezvous = (rendezvousId, newDate, newTime, callback) => {
  const query = 'UPDATE rendezvous SET date = ?, time = ? WHERE id = ?';
  connection.query(query, [newDate, newTime, rendezvousId], (err, result) => {
    if (err) {
      console.error('Error updating rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

// Delete a rendezvous
const deleteRendezvous = (rendezvousId, callback) => {
  const query = 'DELETE FROM rendezvous WHERE id = ?';
  connection.query(query, [rendezvousId], (err, result) => {
    if (err) {
      console.error('Error deleting rendezvous:', err);
      callback(err, null);
    } else {
      callback(null, result);
    }
  });
};

module.exports = {
  createRendezvous,
  getRendezvousByPatient,
  getRendezvousByDoctor,
  updateRendezvous,
  deleteRendezvous
};
"@
Set-Content -Path "$basePath\models\rendezvous.js" -Value $rendezvousModel

# Create routes/rendezvous.js file
$rendezvousRoutes = @"
const express = require('express');
const Rendezvous = require('../models/rendezvous');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Create a new rendezvous
router.post('/', authenticateToken, (req, res) => {
  const { patientId, doctorId, date, time } = req.body;

  if (!patientId || !doctorId || !date || !time) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  Rendezvous.createRendezvous(patientId, doctorId, date, time, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to create rendezvous' });
    res.status(201).json({ message: 'Rendezvous created successfully', data: result });
  });
});

// Get all rendezvous for a specific patient
router.get('/patient/:id', authenticateToken, (req, res) => {
  const patientId = req.params.id;

  Rendezvous.getRendezvousByPatient(patientId, (err, rows) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch rendezvous' });
    res.status(200).json({ data: rows });
  });
});

// Get all rendezvous for a specific doctor
router.get('/doctor/:id', authenticateToken, (req, res) => {
  const doctorId = req.params.id;

  Rendezvous.getRendezvousByDoctor(doctorId, (err, rows) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch rendezvous' });
    res.status(200).json({ data: rows });
  });
});

// Update an existing rendezvous
router.put('/:id', authenticateToken, (req, res) => {
  const { newDate, newTime } = req.body;
  const rendezvousId = req.params.id;

  if (!newDate || !newTime) {
    return res.status(400).json({ message: 'New date and time are required' });
  }

  Rendezvous.updateRendezvous(rendezvousId, newDate, newTime, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to update rendezvous' });
    res.status(200).json({ message: 'Rendezvous updated successfully', data: result });
  });
});

// Delete a rendezvous
router.delete('/:id', authenticateToken, (req, res) => {
  const rendezvousId = req.params.id;

  Rendezvous.deleteRendezvous(rendezvousId, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to delete rendezvous' });
    res.status(200).json({ message: 'Rendezvous deleted successfully' });
  });
});

module.exports = router;
"@
Set-Content -Path "$basePath\routes\rendezvous.js" -Value $rendezvousRoutes

# Create index.js file
$indexFile = @"
const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { connectDB } = require('./config/db');
const rendezvousRoutes = require('./routes/rendezvous');

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Routes
app.use('/api/rendezvous', rendezvousRoutes);

// Start Server
const PORT = process.env.PORT || 5002;
app.listen(PORT, async () => {
  await connectDB();
  console.log(\`Rendezvous Service running on port \${PORT}\`);
});
"@
Set-Content -Path "$basePath\index.js" -Value $indexFile

# Create Dockerfile
$dockerfile = @"
FROM node:18
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 5002
CMD ["node", "index.js"]
"@
Set-Content -Path "$basePath\Dockerfile" -Value $dockerfile

# Create docker-compose.yml
$dockerCompose = @"
version: '3.8'
services:
  db:
    image: mysql:8
    container_name: rendezvous_db
    restart: always
    environment:
      MYSQL_DATABASE: myheart_rendezvous
      MYSQL_ROOT_PASSWORD: password
    ports:
      - "3307:3306"
    volumes:
      - db_data:/var/lib/mysql

  rendezvous-service:
    build: .
    container_name: rendezvous_service
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_USER: root
      DB_PASSWORD: password
      DB_NAME: myheart_rendezvous
      JWT_SECRET: supersecretkey
    ports:
      - "5002:5002"
    volumes:
      - .:/app
    command: ["node", "index.js"]

volumes:
  db_data:
"@
Set-Content -Path "$basePath\docker-compose.yml" -Value $dockerCompose

# Notify user
Write-Host "Rendezvous service project structure created successfully at $basePath."

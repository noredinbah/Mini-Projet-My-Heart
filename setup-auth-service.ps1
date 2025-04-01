# Define project directory
$projectDir = "C:\Users\NOREDINE\Desktop\Mini_projet_soa\authentification-service"

# Create directory structure
$directories = @(
    "$projectDir",
    "$projectDir\config",
    "$projectDir\models",
    "$projectDir\routes",
    "$projectDir\middleware"
)

foreach ($dir in $directories) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir
    }
}

# Define file contents
$files = @{
    "config\db.js" = @"
const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

const connectDB = () => {
    pool.getConnection((err, connection) => {
        if (err) {
            console.error('Database connection failed: ' + err.stack);
            process.exit(1);
        } else {
            console.log('Database connected as id ' + connection.threadId);
        }
    });
};

module.exports = pool;
"@
    "models\user.js" = @"
const pool = require('../config/db');
const bcrypt = require('bcryptjs');

const User = {
    createUser: async (name, email, password) => {
        const hashedPassword = await bcrypt.hash(password, 10);
        return new Promise((resolve, reject) => {
            const query = 'INSERT INTO users (name, email, password) VALUES (?, ?, ?)';
            pool.query(query, [name, email, hashedPassword], (err, result) => {
                if (err) reject(err);
                resolve(result);
            });
        });
    },

    findByEmail: (email) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM users WHERE email = ?';
            pool.query(query, [email], (err, result) => {
                if (err) reject(err);
                resolve(result[0]);
            });
        });
    },

    findById: (id) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT id, name, email FROM users WHERE id = ?';
            pool.query(query, [id], (err, result) => {
                if (err) reject(err);
                resolve(result[0]);
            });
        });
    }
};

module.exports = User;
"@
    "middleware\authMiddleware.js" = @"
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
    "routes\auth.js" = @"
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        const existingUser = await User.findByEmail(email);
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const result = await User.createUser(name, email, password);
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findByEmail(email);
        if (!user) return res.status(400).json({ message: 'Invalid credentials' });

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.json({ token });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

router.get('/profile', authenticateToken, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        res.json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

module.exports = router;
"@
    "index.js" = @"
const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { connectDB } = require('./config/db');
const authRoutes = require('./routes/auth');

dotenv.config();

const app = express();
app.use(bodyParser.json());

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
    await connectDB();
    console.log(\`Authentication Service running on port \${PORT}\`);
});
"@
    "Dockerfile" = @"
FROM node:18
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ['node', 'index.js']
"@
    "docker-compose.yml" = @"
version: '3.8'
services:
  db:
    image: mysql:8
    container_name: auth_db
    restart: always
    environment:
      MYSQL_DATABASE: myheart_auth
      MYSQL_ROOT_PASSWORD: password
    ports:
      - '3306:3306'
    volumes:
      - db_data:/var/lib/mysql

  auth-service:
    build: .
    container_name: auth_service
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_USER: root
      DB_PASSWORD: password
      DB_NAME: myheart_auth
      JWT_SECRET: supersecretkey
    ports:
      - '5000:5000'
    volumes:
      - .:/app
    command: ['node', 'index.js']

volumes:
  db_data:
"@
    ".env" = @"
PORT=5000
DB_NAME=myheart_auth
DB_USER=root
DB_PASSWORD=password
DB_HOST=localhost
JWT_SECRET=supersecretkey
"@
}

# Create files with their respective content
foreach ($file in $files.GetEnumerator()) {
    $filePath = Join-Path $projectDir $file.Key
    $fileContent = $file.Value
    Set-Content -Path $filePath -Value $fileContent -Force
}

Write-Host "Setup complete! The Authentication Service is ready."

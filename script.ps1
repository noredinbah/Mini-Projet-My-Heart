# Notification Service Creator
# Usage: Right-click -> Run with PowerShell
# OR: powershell -ExecutionPolicy Bypass -File create-notification-service.ps1

$serviceName = "notification-service"
$port = 5005

# Create directory structure
New-Item -ItemType Directory -Path .\$serviceName -Force
Set-Location .\$serviceName

"Creating folder structure..."
$folders = @(
    "src",
    "src/controllers",
    "src/models",
    "src/routes",
    "src/middleware",
    "src/services",
    "docker"
)

$folders | ForEach-Object {
    New-Item -ItemType Directory -Path $_ -Force
}

# Create files
"Creating files..."

# 1. package.json
@"
{
  "name": "$serviceName",
  "version": "1.0.0",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.3.1",
    "dotenv": "^16.0.3",
    "jsonwebtoken": "^9.0.0",
    "nodemailer": "^6.9.3",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding utf8

# 2. .env
@"
PORT=$port
MONGODB_URI=mongodb://mongo-notification:27017/notificationService
JWT_SECRET=your_jwt_secret_here
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
"@ | Out-File -FilePath ".env" -Encoding utf8

# 3. src/controllers/notificationController.js
@"
const Notification = require('../models/notificationModel');
const notificationService = require('../services/notificationService');

exports.createNotification = async (req, res) => {
  try {
    const { message, userId } = req.body;
    const notification = new Notification({ message, userId });
    await notification.save();
    
    // Send email notification
    await notificationService.sendEmail(
      'recipient@example.com',
      'New Notification',
      message
    );
    
    res.status(201).json(notification);
  } catch (error) {
    res.status(500).json({ error: 'Error creating notification' });
  }
};

exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id });
    res.status(200).json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching notifications' });
  }
};

exports.deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;
    await Notification.findByIdAndDelete(id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Error deleting notification' });
  }
};
"@ | Out-File -FilePath "src/controllers/notificationController.js" -Encoding utf8

# 4. src/models/notificationModel.js
@"
const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  message: { 
    type: String, 
    required: true 
  },
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  },
  status: {
    type: String,
    enum: ['pending', 'sent', 'failed'],
    default: 'pending'
  }
});

module.exports = mongoose.model('Notification', notificationSchema);
"@ | Out-File -FilePath "src/models/notificationModel.js" -Encoding utf8

# 5. src/routes/notificationRoutes.js
@"
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

// Protected routes
router.post('/', authMiddleware.authenticate, notificationController.createNotification);
router.get('/', authMiddleware.authenticate, notificationController.getNotifications);
router.delete('/:id', authMiddleware.authenticate, notificationController.deleteNotification);

module.exports = router;
"@ | Out-File -FilePath "src/routes/notificationRoutes.js" -Encoding utf8

# 6. src/middleware/authMiddleware.js
@"
const jwt = require('jsonwebtoken');

exports.authenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(403).json({ message: 'No token provided' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    req.user = decoded;
    next();
  });
};
"@ | Out-File -FilePath "src/middleware/authMiddleware.js" -Encoding utf8

# 7. src/services/notificationService.js
@"
const nodemailer = require('nodemailer');
const logger = console;

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

exports.sendEmail = async (to, subject, text) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to,
      subject,
      text
    };

    const info = await transporter.sendMail(mailOptions);
    logger.info('Email sent:', info.messageId);
    return true;
  } catch (error) {
    logger.error('Error sending email:', error);
    return false;
  }
};

exports.sendSMS = async (phoneNumber, message) => {
  // Implement SMS functionality here
  logger.info(\`SMS sent to \${phoneNumber}: \${message}\`);
  return true;
};
"@ | Out-File -FilePath "src/services/notificationService.js" -Encoding utf8

# 8. src/app.js
@"
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const notificationRoutes = require('./routes/notificationRoutes');

const app = express();
const PORT = process.env.PORT || $port;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Routes
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(PORT, () => {
  console.log(\`Notification Service running on port \${PORT}\`);
});
"@ | Out-File -FilePath "src/app.js" -Encoding utf8

# 9. Dockerfile
@"
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE $port

CMD ["node", "src/app.js"]
"@ | Out-File -FilePath "Dockerfile" -Encoding utf8

# 10. docker/docker-compose.yml
@"
version: '3.8'

services:
  mongo-notification:
    image: mongo:6.0
    container_name: mongo-notification
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: mongopassword
    volumes:
      - notification_data:/data/db
    ports:
      - "27017:27017"
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 5s
      timeout: 10s
      retries: 5

  notification-service:
    build: ..
    ports:
      - "$($port):$($port)"
    environment:
      - MONGODB_URI=mongodb://root:mongopassword@mongo-notification:27017/notificationService?authSource=admin
      - PORT=$port
    depends_on:
      mongo-notification:
        condition: service_healthy

volumes:
  notification_data:
"@ | Out-File -FilePath "docker/docker-compose.yml" -Encoding utf8

# Final instructions
Write-Host "`nNotification Service created successfully!" -ForegroundColor Green
Write-Host "Service will run on port $port" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. cd $serviceName"
Write-Host "2. npm install"
Write-Host "3. To run with Docker: docker-compose -f docker/docker-compose.yml up --build"
Write-Host "4. To run locally: npm install && npm start`n"
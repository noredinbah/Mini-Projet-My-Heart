const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

// Protected routes
router.post('/', authMiddleware.authenticate, notificationController.createNotification);
router.get('/', authMiddleware.authenticate, notificationController.getNotifications);
router.delete('/:id', authMiddleware.authenticate, notificationController.deleteNotification);

module.exports = router;

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

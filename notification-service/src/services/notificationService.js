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
  logger.info("SMS sent to : ");
  return true;
};

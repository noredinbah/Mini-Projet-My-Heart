const logger = require('./logger');

// Centralized error handling function
const handleError = (error) => {
    logger.error('Error occurred:', error.message);
    process.exit(1); // Exit process with error code
};

module.exports = handleError;

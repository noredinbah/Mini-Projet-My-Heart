const express = require('express');
const router = express.Router();
const facturationController = require('../controllers/facturationController');

// POST route to create a facture
router.post('/create', facturationController.createFacture);

module.exports = router;

const express = require('express');
const router = express.Router();
const prescriptionController = require('../controllers/prescriptionController');

// POST route to create prescription
router.post('/create', prescriptionController.createPrescription);

module.exports = router;

const express = require('express');
const router = express.Router();
const pharmacieController = require('../controllers/pharmacieController');

// POST route to create pharmacie
router.post('/create', pharmacieController.createPharmacie);

module.exports = router;

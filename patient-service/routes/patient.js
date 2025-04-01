const express = require('express');
const { createPatient, getAllPatients, getPatientById, updatePatient, deletePatient } = require('../models/patient');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Create a new patient
router.post('/', authenticateToken, async (req, res) => {
    const { name, email, dob, medicalHistory } = req.body;

    if (!name || !email || !dob) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const result = await createPatient(name, email, dob, medicalHistory);
        res.status(201).json({ message: 'Patient created successfully', patientId: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Error creating patient', error });
    }
});

// Get all patients
router.get('/', authenticateToken, async (req, res) => {
    try {
        const patients = await getAllPatients();
        res.json(patients);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching patients', error });
    }
});

// Get a patient by ID
router.get('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;

    try {
        const patient = await getPatientById(id);
        if (patient.length === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json(patient[0]);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching patient', error });
    }
});

// Update a patient
router.put('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { name, email, dob, medicalHistory } = req.body;

    if (!name || !email || !dob) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const result = await updatePatient(id, name, email, dob, medicalHistory);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json({ message: 'Patient updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating patient', error });
    }
});

// Delete a patient
router.delete('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;

    try {
        const result = await deletePatient(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        res.json({ message: 'Patient deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting patient', error });
    }
});

module.exports = router;

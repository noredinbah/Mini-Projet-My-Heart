const express = require('express');
const Rendezvous = require('../models/rendezvous');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Create a new rendezvous
router.post('/', authenticateToken, (req, res) => {
  const { patientId, doctorId, date, time } = req.body;

  if (!patientId || !doctorId || !date || !time) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  Rendezvous.createRendezvous(patientId, doctorId, date, time, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to create rendezvous' });
    res.status(201).json({ message: 'Rendezvous created successfully', data: result });
  });
});

// Get all rendezvous for a specific patient
router.get('/patient/:id', authenticateToken, (req, res) => {
  const patientId = req.params.id;

  Rendezvous.getRendezvousByPatient(patientId, (err, rows) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch rendezvous' });
    res.status(200).json({ data: rows });
  });
});

// Get all rendezvous for a specific doctor
router.get('/doctor/:id', authenticateToken, (req, res) => {
  const doctorId = req.params.id;

  Rendezvous.getRendezvousByDoctor(doctorId, (err, rows) => {
    if (err) return res.status(500).json({ message: 'Failed to fetch rendezvous' });
    res.status(200).json({ data: rows });
  });
});

// Update an existing rendezvous
router.put('/:id', authenticateToken, (req, res) => {
  const { newDate, newTime } = req.body;
  const rendezvousId = req.params.id;

  if (!newDate || !newTime) {
    return res.status(400).json({ message: 'New date and time are required' });
  }

  Rendezvous.updateRendezvous(rendezvousId, newDate, newTime, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to update rendezvous' });
    res.status(200).json({ message: 'Rendezvous updated successfully', data: result });
  });
});

// Delete a rendezvous
router.delete('/:id', authenticateToken, (req, res) => {
  const rendezvousId = req.params.id;

  Rendezvous.deleteRendezvous(rendezvousId, (err, result) => {
    if (err) return res.status(500).json({ message: 'Failed to delete rendezvous' });
    res.status(200).json({ message: 'Rendezvous deleted successfully' });
  });
});

module.exports = router;

const Doctor = require('../models/doctor');

exports.getAllDoctors = (req, res) => {
  Doctor.getAll((err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
};

exports.getDoctorById = (req, res) => {
  Doctor.getById(req.params.id, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json(results[0]);
  });
};

exports.createDoctor = (req, res) => {
  Doctor.create(req.body, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id: results.insertId, ...req.body });
  });
};

exports.updateDoctor = (req, res) => {
  Doctor.update(req.params.id, req.body, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Doctor updated successfully' });
  });
};

exports.deleteDoctor = (req, res) => {
  Doctor.delete(req.params.id, (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Doctor deleted successfully' });
  });
};

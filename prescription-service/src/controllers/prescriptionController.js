const Prescription = require('../models/prescription');

const createPrescription = async (req, res) => {
  try {
    const prescription = new Prescription({
      patientId: req.body.patientId,
      doctorId: req.body.doctorId,
      medication: req.body.medication,
      dosage: req.body.dosage,
      instructions: req.body.instructions,
      prescribedAt: Date.now()
    });
    await prescription.save();
    res.status(201).json({ success: true, message: 'Prescription created successfully', prescription });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { createPrescription };

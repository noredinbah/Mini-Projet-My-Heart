const mongoose = require('mongoose');

const prescriptionSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true
  },
  medication: {
    type: String,
    required: true
  },
  dosage: {
    type: String,
    required: true
  },
  instructions: {
    type: String
  },
  prescribedAt: {
    type: Date,
    default: Date.now
  }
});

const Prescription = mongoose.model('Prescription', prescriptionSchema);

module.exports = Prescription;

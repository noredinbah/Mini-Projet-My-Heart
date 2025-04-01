const mongoose = require('mongoose');

const laboratoireSchema = new mongoose.Schema({
  patientId: { type: String, required: true },
  testName: { type: String, required: true },
  result: { type: String, required: true },
  date: { type: Date, required: true }
});

const Laboratoire = mongoose.model('Laboratoire', laboratoireSchema);
module.exports = Laboratoire;

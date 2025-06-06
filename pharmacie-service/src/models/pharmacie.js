const mongoose = require('mongoose');

const pharmacieSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  location: {
    type: String,
    required: true
  },
  contactInfo: {
    type: String,
    required: true
  },
  stock: {
    type: Number,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Pharmacie = mongoose.model('Pharmacie', pharmacieSchema);

module.exports = Pharmacie;

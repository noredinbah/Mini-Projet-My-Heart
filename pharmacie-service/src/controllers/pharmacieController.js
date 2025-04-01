const Pharmacie = require('../models/pharmacie');

const createPharmacie = async (req, res) => {
  try {
    const pharmacie = new Pharmacie({
      name: req.body.name,
      location: req.body.location,
      contactInfo: req.body.contactInfo,
      stock: req.body.stock,
      createdAt: Date.now()
    });
    await pharmacie.save();
    res.status(201).json({ success: true, message: 'Pharmacie created successfully', pharmacie });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = { createPharmacie };

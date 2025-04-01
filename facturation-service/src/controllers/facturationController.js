const db = require('../app');

// Create a new facture
const createFacture = (req, res) => {
  const { patientId, amount, date, status } = req.body;

  const query = 'INSERT INTO factures (patientId, amount, date, status) VALUES (?, ?, ?, ?)';
  db.query(query, [patientId, amount, date, status], (err, result) => {
    if (err) {
      res.status(500).json({ success: false, message: err.message });
    } else {
      res.status(201).json({ success: true, message: 'Facture created successfully', factureId: result.insertId });
    }
  });
};

module.exports = { createFacture };
